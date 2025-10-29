CREATE OR REPLACE FUNCTION log_aviso_acknowledgement(
    p_user_id INTEGER,
    p_show_more BOOLEAN,
    p_memo_text TEXT
) RETURNS VOID AS $$
BEGIN
    INSERT INTO aviso_acknowledgements (user_id, show_more, memo_text, acknowledged_at)
    VALUES (p_user_id, p_show_more, p_memo_text, NOW());
END;
$$ LANGUAGE plpgsql;

-- Tabla de soporte:
-- CREATE TABLE aviso_acknowledgements (
--   id SERIAL PRIMARY KEY,
--   user_id INTEGER NOT NULL,
--   show_more BOOLEAN NOT NULL,
--   memo_text TEXT,
--   acknowledged_at TIMESTAMP NOT NULL
-- );

CREATE OR REPLACE FUNCTION sp_update_porcentajes(
    p_cvecuenta integer,
    p_cveregprop integer,
    p_propietarios_json jsonb,
    p_observacion text DEFAULT NULL
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    total numeric := 0;
    encabezan integer := 0;
    prop RECORD;
    cvereg integer;
    calidad_valida boolean;
BEGIN
    -- Validaciones
    FOR prop IN SELECT * FROM jsonb_to_recordset(p_propietarios_json) AS (
        cvecont integer, porcentaje numeric, encabeza text, descripcion text
    ) LOOP
        total := total + prop.porcentaje;
        IF prop.encabeza = 'S' THEN
            encabezan := encabezan + 1;
        END IF;
        -- Validar calidad
        SELECT cvereg INTO cvereg FROM c_calidpro WHERE descripcion = prop.descripcion;
        IF cvereg IS NULL THEN
            RETURN QUERY SELECT false, 'Calidad no válida para ' || prop.descripcion;
            RETURN;
        END IF;
    END LOOP;
    IF total <> 100 THEN
        RETURN QUERY SELECT false, 'El total de porcentaje debe ser 100.';
        RETURN;
    END IF;
    IF encabezan <> 1 THEN
        RETURN QUERY SELECT false, 'Debe haber exactamente un contribuyente que encabece.';
        RETURN;
    END IF;
    -- Actualización
    FOR prop IN SELECT * FROM jsonb_to_recordset(p_propietarios_json) AS (
        cvecont integer, porcentaje numeric, encabeza text, descripcion text
    ) LOOP
        SELECT cvereg INTO cvereg FROM c_calidpro WHERE descripcion = prop.descripcion;
        UPDATE regprop
        SET porcentaje = prop.porcentaje,
            cvereg = cvereg,
            encabeza = prop.encabeza
        WHERE cvecuenta = p_cvecuenta AND cveregprop = p_cveregprop AND cvecont = prop.cvecont;
    END LOOP;
    -- Registrar observación si aplica
    IF p_observacion IS NOT NULL AND length(trim(p_observacion)) > 0 THEN
        UPDATE catastro SET observacion = COALESCE(observacion, '') || '\n' || p_observacion
        WHERE cvecuenta = p_cvecuenta;
    END IF;
    RETURN QUERY SELECT true, 'Actualización exitosa.';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sp_exento_en_saldos(
    p_cvecuenta INTEGER,
    p_bim INTEGER,
    p_anio INTEGER,
    p_exento CHAR(1)
)
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN SELECT * FROM detsaldos WHERE cvecuenta = p_cvecuenta AND axosal = p_anio AND bimsal = p_bim
    LOOP
        IF p_exento = 'S' THEN
            UPDATE detsaldos SET
                exento = 'S',
                impvir = impade,
                cvedescuento = NULL,
                recvir = recfac,
                recpag = 0
            WHERE cvecuenta = p_cvecuenta AND axosal = p_anio AND bimsal = p_bim;
        ELSE
            IF r.exento = 'S' THEN
                UPDATE detsaldos SET
                    exento = 'N',
                    impvir = 0,
                    recvir = 0,
                    cvedescuento = NULL
                WHERE cvecuenta = p_cvecuenta AND axosal = p_anio AND bimsal = p_bim;
            END IF;
        END IF;
    END LOOP;
    -- Ejecutar recalculo de DPP, saldos y recargos
    CALL sp_calc_dpp(p_cvecuenta);
    CALL sp_calc_saldos(p_cvecuenta);
    CALL sp_calc_recargos(p_cvecuenta);
END;
$$;

CREATE OR REPLACE PROCEDURE sp_calc_dpp(p_cvecuenta INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Lógica de recálculo de DPP (descuento pronto pago)
    -- Aquí se debe implementar la lógica de negocio específica
    -- Ejemplo: UPDATE saldos SET desctoppp = ... WHERE cvecuenta = p_cvecuenta;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_calc_saldos(p_cvecuenta INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Lógica de recálculo de saldos
    -- Ejemplo: UPDATE saldos SET saldo = ... WHERE cvecuenta = p_cvecuenta;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_calc_recargos(p_cvecuenta INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Lógica de recálculo de recargos
    -- Ejemplo: UPDATE saldos SET recargos = ... WHERE cvecuenta = p_cvecuenta;
END;
$$;

CREATE OR REPLACE FUNCTION sp_get_catastro_by_cuenta(p_cvecuenta INTEGER)
RETURNS TABLE(
    cvecuenta INTEGER,
    cvemov INTEGER,
    cvevalor INTEGER,
    cveubic INTEGER,
    cvecartografia INTEGER,
    cveregprop INTEGER,
    cveavaluo INTEGER,
    asiento INTEGER,
    axoefec SMALLINT,
    bimefec SMALLINT,
    axocomp SMALLINT,
    nocomp INTEGER,
    axoultcomp SMALLINT,
    ultcomp INTEGER,
    observacion TEXT,
    vigente CHAR(1),
    feccap DATE,
    capturista VARCHAR(10),
    folio INTEGER,
    areatitulo FLOAT
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM catastro WHERE cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cancel_account(
    p_cvecuenta INTEGER,
    p_motivo TEXT,
    p_observacion TEXT,
    p_usuario TEXT
) RETURNS TABLE(result TEXT) AS $$
DECLARE
    v_cvemov INTEGER := 11; -- Código de movimiento de cancelación
    v_now TIMESTAMP := NOW();
    v_cvevalor INTEGER;
    v_cveubic INTEGER;
    v_cvecartografia INTEGER;
    v_cveregprop INTEGER;
    v_cveavaluo INTEGER;
    v_folio INTEGER;
    v_asiento INTEGER;
    v_axoefec INTEGER;
    v_bimefec INTEGER;
    v_axocomp INTEGER;
    v_nocomp INTEGER;
    v_axoultcomp INTEGER;
    v_ultcomp INTEGER;
    v_areatitulo FLOAT;
BEGIN
    -- 1. Actualizar convcta a cancelada
    UPDATE convcta SET vigente = 'C' WHERE cvecuenta = p_cvecuenta;

    -- 2. Obtener datos actuales de catastro
    SELECT cvevalor, cveubic, cvecartografia, cveregprop, cveavaluo, folio, asiento, axoefec, bimefec, axocomp, nocomp, axoultcomp, ultcomp, areatitulo
      INTO v_cvevalor, v_cveubic, v_cvecartografia, v_cveregprop, v_cveavaluo, v_folio, v_asiento, v_axoefec, v_bimefec, v_axocomp, v_nocomp, v_axoultcomp, v_ultcomp, v_areatitulo
      FROM catastro WHERE cvecuenta = p_cvecuenta AND vigente = 'V' LIMIT 1;

    -- 3. Insertar movimiento de cancelación en catastro
    INSERT INTO catastro (
        cvecuenta, cvemov, cvevalor, cveubic, cvecartografia, cveregprop, cveavaluo, folio, asiento, axoefec, bimefec, axocomp, nocomp, axoultcomp, ultcomp, observacion, vigente, feccap, capturista, areatitulo
    ) VALUES (
        p_cvecuenta, v_cvemov, v_cvevalor, v_cveubic, v_cvecartografia, v_cveregprop, v_cveavaluo, v_folio, v_asiento+1, v_axoefec, v_bimefec, v_axocomp, v_nocomp, v_axoultcomp, v_ultcomp, CONCAT('[CANCELACIÓN] ', p_motivo, ' ', p_observacion), 'C', v_now, p_usuario, v_areatitulo
    );

    -- 4. Actualizar vigente anterior
    UPDATE catastro SET vigente = 'C' WHERE cvecuenta = p_cvecuenta AND vigente = 'V';

    -- 5. Cancelar requerimientos vigentes
    UPDATE reqpredial SET vigencia = 'C', feccan = v_now
      WHERE cvecuenta = p_cvecuenta AND cvepago IS NULL AND vigencia = 'V';

    -- 6. Actualizar detsaldos (saldo>0) impvir y recvir
    UPDATE detsaldos SET impvir = impade, recvir = recfac
      WHERE cvecuenta = p_cvecuenta AND saldo > 0;

    -- 7. Recalcular saldos
    PERFORM calc_sdos(p_cvecuenta);

    RETURN QUERY SELECT 'OK'::TEXT;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calc_sdos(p_cvecuenta INTEGER) RETURNS VOID AS $$
BEGIN
    -- Aquí va la lógica de recálculo de saldos, recargos, etc.
    -- Por ejemplo, llamar otros SPs, actualizar tablas de saldos, etc.
    -- Este es un placeholder, debe implementarse según la lógica de negocio.
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION condueños_create(p_json jsonb)
RETURNS TABLE(result text) AS $$
DECLARE
  v_cvecont integer;
  v_cvecuenta integer;
  v_cveregprop integer;
  v_porcentaje numeric;
  v_encabeza char(1);
  v_exento char(1);
  v_vigencia char(1);
  v_usuario text;
BEGIN
  -- Extraer datos del JSON
  v_cvecuenta := (p_json->>'cvecuenta')::integer;
  v_cveregprop := (p_json->>'cveregprop')::integer;
  v_porcentaje := (p_json->>'porcentaje')::numeric;
  v_encabeza := (p_json->>'encabeza')::char(1);
  v_exento := (p_json->>'exento')::char(1);
  v_vigencia := 'V';
  v_usuario := (p_json->>'usuario');

  -- Insertar en contrib y obtener cvecont
  INSERT INTO contrib (nombre_completo, rfc, ...)
    VALUES (p_json->>'nombre_completo', p_json->>'rfc', ...)
    RETURNING cvecont INTO v_cvecont;

  -- Insertar en regprop
  INSERT INTO regprop (cvereg, cvecont, cvecuenta, cveregprop, encabeza, porcentaje, exento, vigencia, feccap, capturista)
    VALUES (1, v_cvecont, v_cvecuenta, v_cveregprop, v_encabeza, v_porcentaje, v_exento, v_vigencia, now(), v_usuario);

  RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION condueños_update(p_json jsonb)
RETURNS TABLE(result text) AS $$
DECLARE
  v_cvecont integer;
  v_porcentaje numeric;
  v_encabeza char(1);
  v_exento char(1);
  v_usuario text;
BEGIN
  v_cvecont := (p_json->>'cvecont')::integer;
  v_porcentaje := (p_json->>'porcentaje')::numeric;
  v_encabeza := (p_json->>'encabeza')::char(1);
  v_exento := (p_json->>'exento')::char(1);
  v_usuario := (p_json->>'usuario');

  UPDATE contrib SET nombre_completo = p_json->>'nombre_completo', rfc = p_json->>'rfc', ...
    WHERE cvecont = v_cvecont;

  UPDATE regprop SET porcentaje = v_porcentaje, encabeza = v_encabeza, exento = v_exento, feccap = now(), capturista = v_usuario
    WHERE cvecont = v_cvecont AND vigencia = 'V';

  RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION condueños_delete(p_cvecont integer)
RETURNS TABLE(result text) AS $$
BEGIN
  UPDATE regprop SET vigencia = 'C', feccap = now() WHERE cvecont = p_cvecont AND vigencia = 'V';
  RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION condueños_restore(p_cvecont integer)
RETURNS TABLE(result text) AS $$
BEGIN
  UPDATE regprop SET vigencia = 'V', feccap = now() WHERE cvecont = p_cvecont AND vigencia = 'C';
  RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION condueños_validate_rfc(p_rfc text, p_cvecont integer)
RETURNS TABLE(duplicados integer) AS $$
BEGIN
  RETURN QUERY
    SELECT count(*) FROM contrib WHERE rfc = p_rfc AND cvecont != p_cvecont;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_add_cvecatdup(p_recaud INTEGER, p_urbrus VARCHAR, p_cuenta INTEGER, p_cvecatnva VARCHAR)
RETURNS VOID AS $$
BEGIN
  INSERT INTO cvecatdup (recaud, urbrus, cuenta, cvecatnva)
  VALUES (p_recaud, p_urbrus, p_cuenta, p_cvecatnva);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_delete_cvecatdup(p_recaud INTEGER, p_urbrus VARCHAR, p_cuenta INTEGER, p_cvecatnva VARCHAR)
RETURNS VOID AS $$
BEGIN
  DELETE FROM cvecatdup
  WHERE recaud = p_recaud AND urbrus = p_urbrus AND cuenta = p_cuenta AND cvecatnva = p_cvecatnva;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_validate_cvecat(p_clave VARCHAR, p_subpredio INTEGER)
RETURNS JSON AS $$
DECLARE
    errors TEXT[] := ARRAY[]::TEXT[];
    zona TEXT;
    subzona TEXT;
    dig TEXT;
    exists_count INTEGER;
    r RECORD;
BEGIN
    IF length(trim(p_clave)) <> 11 AND length(trim(p_clave)) <> 8 THEN
        errors := array_append(errors, 'Existe un error en la longitud de la clave ...');
    END IF;
    zona := substring(p_clave from 1 for 3);
    IF zona <> 'D65' AND zona <> 'D66' THEN
        errors := array_append(errors, 'La clave catastral no corresponde a una zona dentro de Guadalajara ...');
    END IF;
    IF zona = 'D65' THEN
        subzona := substring(p_clave from 4 for 1);
        dig := substring(p_clave from 5 for 1);
        IF subzona NOT IN ('H','I','J') THEN
            errors := array_append(errors, 'Subzona inválida para D65');
        ELSE
            IF subzona = 'H' AND dig NOT IN ('3','4') THEN errors := array_append(errors, 'D65H sólo 3 o 4'); END IF;
            IF subzona = 'I' AND dig NOT IN ('1','2','3','4','5','6') THEN errors := array_append(errors, 'D65I sólo 1-6'); END IF;
            IF subzona = 'J' AND dig NOT IN ('0','1','2','3','4','5') THEN errors := array_append(errors, 'D65J sólo 0-5'); END IF;
        END IF;
    END IF;
    IF zona = 'D66' THEN
        subzona := substring(p_clave from 4 for 1);
        dig := substring(p_clave from 5 for 1);
        IF subzona NOT IN ('A','B') THEN
            errors := array_append(errors, 'Subzona inválida para D66');
        ELSE
            IF subzona = 'A' AND dig NOT IN ('0','1','2','3','4','5') THEN errors := array_append(errors, 'D66A sólo 0-5'); END IF;
            IF subzona = 'B' AND dig NOT IN ('1','2','3','4') THEN errors := array_append(errors, 'D66B sólo 1-4'); END IF;
        END IF;
    END IF;
    SELECT count(*) INTO exists_count FROM convcta WHERE cvecatnva = p_clave;
    IF exists_count > 0 THEN
        IF p_subpredio IS NULL THEN
            errors := array_append(errors, 'La clave catastral ya se encuentra en uso... Favor de verificar...');
        ELSE
            FOR r IN SELECT subpredio FROM convcta WHERE cvecatnva = p_clave LOOP
                IF r.subpredio = p_subpredio THEN
                    errors := array_append(errors, 'La clave catastral ya se encuentra en uso... Favor de verificar...');
                END IF;
            END LOOP;
        END IF;
    END IF;
    RETURN json_build_object('valid', array_length(errors,1) IS NULL, 'errors', errors);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_update_cvecat(
    p_cvecuenta INTEGER,
    p_clave VARCHAR,
    p_subpredio INTEGER,
    p_usuario VARCHAR,
    p_observacion TEXT,
    p_cvemov INTEGER,
    p_asiento INTEGER
) RETURNS JSON AS $$
BEGIN
    UPDATE convcta SET cvecatnva = p_clave, subpredio = p_subpredio WHERE cvecuenta = p_cvecuenta;
    UPDATE catastro SET cvemov = p_cvemov, asiento = p_asiento, observacion = p_observacion WHERE cvecuenta = p_cvecuenta;
    RETURN json_build_object('success', true);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_check_blocked_manzana(p_cvemanz VARCHAR)
RETURNS JSON AS $$
DECLARE
    bloqueada INTEGER;
BEGIN
    SELECT count(*) INTO bloqueada FROM c_manzanas WHERE cvecatmanz = p_cvemanz AND fecha_fin IS NULL;
    RETURN json_build_object('blocked', bloqueada > 0);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sp_actualiza_catastro_ubicacion(
    p_cvecuenta INTEGER,
    p_cveubic INTEGER,
    p_bimefec INTEGER,
    p_axoefec INTEGER,
    p_observacion TEXT,
    p_usuario TEXT,
    p_asiento INTEGER,
    p_cvemov INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Actualiza el registro anterior a vigencia 'C' si existe
    UPDATE catastro SET vigente = 'C'
    WHERE cvecuenta = p_cvecuenta AND vigente = 'V';

    -- Inserta nuevo registro en catastro
    INSERT INTO catastro (
        cvecuenta, cveubic, bimefec, axoefec, observacion, vigente, feccap, capturista, asiento, cvemov
    ) VALUES (
        p_cvecuenta, p_cveubic, p_bimefec, p_axoefec, p_observacion, 'V', NOW(), p_usuario, p_asiento + 1, p_cvemov
    );
END;
$$;

-- PostgreSQL stored procedure for registering exencion
CREATE OR REPLACE FUNCTION sp_registrar_exencion(
    p_cvecuenta INTEGER,
    p_axoefec INTEGER,
    p_bimefec INTEGER,
    p_observacion TEXT
) RETURNS TABLE(status TEXT, msg TEXT) AS $$
DECLARE
    v_cveregprop INTEGER;
    v_vexento TEXT := 'S';
    v_vcvemov INTEGER := 61;
    v_vcveregprop INTEGER;
    v_reg RECORD;
BEGIN
    -- Validar si la cuenta tiene abstención
    IF EXISTS (SELECT 1 FROM catastro WHERE cvecuenta = p_cvecuenta AND cvemov = 12) THEN
        RETURN QUERY SELECT 'error', 'CUENTA CON ABSTENCION. NO SE PUEDE EXENTAR';
        RETURN;
    END IF;
    -- Actualizar catastro
    UPDATE catastro
    SET cvemov = v_vcvemov, axoefec = p_axoefec, bimefec = p_bimefec, observacion = p_observacion,
        cveregprop = cveregprop + 1
    WHERE cvecuenta = p_cvecuenta;
    SELECT cveregprop INTO v_vcveregprop FROM catastro WHERE cvecuenta = p_cvecuenta;
    -- Insertar en regprop (histórico)
    FOR v_reg IN SELECT * FROM regprop WHERE cvecuenta = p_cvecuenta AND vigente = 'V' LOOP
        INSERT INTO regprop (cvereg, cvecont, cvecuenta, cveregprop, encabeza, porcentaje, exento, vigencia, feccap, capturista)
        VALUES (v_reg.cvereg, v_reg.cvecont, v_reg.cvecuenta, v_vcveregprop, v_reg.encabeza, v_reg.porcentaje, v_vexento, 'V', now(), v_reg.capturista);
        -- Cancelar anterior
        UPDATE regprop SET vigencia = 'C' WHERE cvecuenta = v_reg.cvecuenta AND cveregprop = v_reg.cveregprop;
    END LOOP;
    -- Actualizar saldos (llamar otro SP si aplica)
    PERFORM sp_exento_en_saldos(p_cvecuenta, p_bimefec, p_axoefec, v_vexento);
    RETURN QUERY SELECT 'success', 'Exención registrada correctamente';
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure for removing exencion
CREATE OR REPLACE FUNCTION sp_eliminar_exencion(
    p_cvecuenta INTEGER,
    p_axoefec INTEGER,
    p_bimefec INTEGER,
    p_observacion TEXT
) RETURNS TABLE(status TEXT, msg TEXT) AS $$
DECLARE
    v_cveregprop INTEGER;
    v_vexento TEXT := 'N';
    v_vcvemov INTEGER := 62;
    v_vcveregprop INTEGER;
    v_reg RECORD;
BEGIN
    -- Validar si la cuenta tiene abstención
    IF EXISTS (SELECT 1 FROM catastro WHERE cvecuenta = p_cvecuenta AND cvemov = 12) THEN
        RETURN QUERY SELECT 'error', 'CUENTA CON ABSTENCION. NO SE PUEDE ELIMINAR EXENCION';
        RETURN;
    END IF;
    -- Actualizar catastro
    UPDATE catastro
    SET cvemov = v_vcvemov, axoefec = p_axoefec, bimefec = p_bimefec, observacion = p_observacion,
        cveregprop = cveregprop + 1
    WHERE cvecuenta = p_cvecuenta;
    SELECT cveregprop INTO v_vcveregprop FROM catastro WHERE cvecuenta = p_cvecuenta;
    -- Insertar en regprop (histórico)
    FOR v_reg IN SELECT * FROM regprop WHERE cvecuenta = p_cvecuenta AND vigente = 'V' LOOP
        INSERT INTO regprop (cvereg, cvecont, cvecuenta, cveregprop, encabeza, porcentaje, exento, vigencia, feccap, capturista)
        VALUES (v_reg.cvereg, v_reg.cvecont, v_reg.cvecuenta, v_vcveregprop, v_reg.encabeza, v_reg.porcentaje, v_vexento, 'V', now(), v_reg.capturista);
        -- Cancelar anterior
        UPDATE regprop SET vigencia = 'C' WHERE cvecuenta = v_reg.cvecuenta AND cveregprop = v_reg.cveregprop;
    END LOOP;
    -- Actualizar saldos (llamar otro SP si aplica)
    PERFORM sp_exento_en_saldos(p_cvecuenta, p_bimefec, p_axoefec, v_vexento);
    RETURN QUERY SELECT 'success', 'Exención eliminada correctamente';
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure for updating exento in saldos
CREATE OR REPLACE FUNCTION sp_exento_en_saldos(
    p_cvecuenta INTEGER,
    p_bim INTEGER,
    p_anio INTEGER,
    p_exento TEXT
) RETURNS VOID AS $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN SELECT * FROM detsaldos WHERE cvecuenta = p_cvecuenta AND axosal = p_anio AND bimsal = p_bim LOOP
        IF p_exento = 'S' THEN
            UPDATE detsaldos SET exento = 'S', impvir = impade, cvedescuento = NULL, recvir = recfac, recpag = 0
            WHERE cvecuenta = r.cvecuenta AND axosal = r.axosal AND bimsal = r.bimsal;
        ELSE
            IF r.exento = 'S' THEN
                UPDATE detsaldos SET exento = 'N', impvir = 0, recvir = 0, cvedescuento = NULL
                WHERE cvecuenta = r.cvecuenta AND axosal = r.axosal AND bimsal = r.bimsal;
            END IF;
        END IF;
    END LOOP;
    -- Aquí se pueden llamar otros SPs para recalcular DPP, saldos, recargos si aplica
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_construc_create(
  p_cvecatnva VARCHAR,
  p_subpredio SMALLINT,
  p_cvebloque SMALLINT,
  p_axoconst SMALLINT,
  p_areaconst FLOAT,
  p_cveclasif INTEGER,
  p_cvecuenta INTEGER,
  p_estructura SMALLINT,
  p_factorajus FLOAT,
  p_numpisos SMALLINT,
  p_importe NUMERIC,
  p_cveavaluo INTEGER,
  p_axovig SMALLINT,
  p_vigente VARCHAR
) RETURNS INTEGER AS $$
DECLARE
  new_id INTEGER;
BEGIN
  INSERT INTO construc (
    cvecatnva, subpredio, cvebloque, axoconst, areaconst, cveclasif, cvecuenta, estructura, factorajus, numpisos, importe, cveavaluo, axovig, vigente
  ) VALUES (
    p_cvecatnva, p_subpredio, p_cvebloque, p_axoconst, p_areaconst, p_cveclasif, p_cvecuenta, p_estructura, p_factorajus, p_numpisos, p_importe, p_cveavaluo, p_axovig, p_vigente
  ) RETURNING cvebloque INTO new_id;
  RETURN new_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_construc_update(
  p_cvebloque INTEGER,
  p_cvecatnva VARCHAR,
  p_subpredio SMALLINT,
  p_axoconst SMALLINT,
  p_areaconst FLOAT,
  p_cveclasif INTEGER,
  p_cvecuenta INTEGER,
  p_estructura SMALLINT,
  p_factorajus FLOAT,
  p_numpisos SMALLINT,
  p_importe NUMERIC,
  p_cveavaluo INTEGER,
  p_axovig SMALLINT,
  p_vigente VARCHAR
) RETURNS BOOLEAN AS $$
BEGIN
  UPDATE construc SET
    cvecatnva = p_cvecatnva,
    subpredio = p_subpredio,
    axoconst = p_axoconst,
    areaconst = p_areaconst,
    cveclasif = p_cveclasif,
    cvecuenta = p_cvecuenta,
    estructura = p_estructura,
    factorajus = p_factorajus,
    numpisos = p_numpisos,
    importe = p_importe,
    cveavaluo = p_cveavaluo,
    axovig = p_axovig,
    vigente = p_vigente
  WHERE cvebloque = p_cvebloque;
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_construc_delete(p_cvebloque INTEGER)
RETURNS BOOLEAN AS $$
BEGIN
  DELETE FROM construc WHERE cvebloque = p_cvebloque;
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_construc_create(
    p_cvecatnva VARCHAR,
    p_subpredio SMALLINT,
    p_cvebloque SMALLINT,
    p_axoconst SMALLINT,
    p_areaconst FLOAT,
    p_cveclasif INT,
    p_cvecuenta INT,
    p_estructura SMALLINT DEFAULT NULL,
    p_factorajus FLOAT DEFAULT NULL,
    p_numpisos SMALLINT DEFAULT NULL,
    p_importe NUMERIC DEFAULT NULL,
    p_cveavaluo INT DEFAULT NULL,
    p_axovig SMALLINT DEFAULT NULL
) RETURNS INT AS $$
DECLARE
    new_id INT;
BEGIN
    INSERT INTO construc (
        cvecatnva, subpredio, cvebloque, axoconst, areaconst, cveclasif, cvecuenta, estructura, factorajus, numpisos, importe, cveavaluo, axovig, vigente
    ) VALUES (
        p_cvecatnva, p_subpredio, p_cvebloque, p_axoconst, p_areaconst, p_cveclasif, p_cvecuenta, p_estructura, p_factorajus, p_numpisos, p_importe, p_cveavaluo, p_axovig, 'V'
    ) RETURNING id INTO new_id;
    RETURN new_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_construc_update(
    p_id INT,
    p_cvecatnva VARCHAR,
    p_subpredio SMALLINT,
    p_cvebloque SMALLINT,
    p_axoconst SMALLINT,
    p_areaconst FLOAT,
    p_cveclasif INT,
    p_cvecuenta INT,
    p_estructura SMALLINT DEFAULT NULL,
    p_factorajus FLOAT DEFAULT NULL,
    p_numpisos SMALLINT DEFAULT NULL,
    p_importe NUMERIC DEFAULT NULL,
    p_cveavaluo INT DEFAULT NULL,
    p_axovig SMALLINT DEFAULT NULL,
    p_vigente VARCHAR DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    UPDATE construc SET
        cvecatnva = p_cvecatnva,
        subpredio = p_subpredio,
        cvebloque = p_cvebloque,
        axoconst = p_axoconst,
        areaconst = p_areaconst,
        cveclasif = p_cveclasif,
        cvecuenta = p_cvecuenta,
        estructura = p_estructura,
        factorajus = p_factorajus,
        numpisos = p_numpisos,
        importe = p_importe,
        cveavaluo = p_cveavaluo,
        axovig = p_axovig,
        vigente = COALESCE(p_vigente, vigente)
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_construc_delete(p_id INT)
RETURNS VOID AS $$
BEGIN
    UPDATE construc SET vigente = 'C' WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_observa_comprobante(p_cvecuenta INTEGER)
RETURNS TABLE(
    cvecuenta INTEGER,
    feccap DATE,
    capturista VARCHAR,
    axocomp INTEGER,
    nocomp INTEGER,
    observacion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecuenta, feccap, capturista, axocomp, nocomp, observacion
    FROM catastro
    WHERE cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_update_observa_comprobante(p_cvecuenta INTEGER, p_observacion TEXT)
RETURNS VOID AS $$
DECLARE
    v_axocomp INTEGER;
    v_nocomp INTEGER;
    v_feccap DATE;
BEGIN
    SELECT axocomp, nocomp, feccap INTO v_axocomp, v_nocomp, v_feccap
    FROM catastro WHERE cvecuenta = p_cvecuenta;
    IF v_axocomp IS NULL THEN
        RAISE EXCEPTION 'Comprobante no encontrado';
    END IF;
    UPDATE catastro SET observacion = p_observacion WHERE cvecuenta = p_cvecuenta;
    UPDATE h_catastro SET observacion = p_observacion
      WHERE cvecuenta = p_cvecuenta AND axocomp = v_axocomp AND nocomp = v_nocomp AND feccap = v_feccap;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION funcion_abstencion_add(
    p_cvecuenta integer,
    p_anio integer,
    p_bimestre integer,
    p_observacion text,
    p_usuario varchar
) RETURNS TABLE(status varchar, message text) AS $$
DECLARE
    existe integer;
BEGIN
    SELECT COUNT(*) INTO existe FROM abstencion_movimientos
    WHERE cvecuenta = p_cvecuenta AND anio = p_anio AND bimestre = p_bimestre;
    IF existe > 0 THEN
        RETURN QUERY SELECT 'error', 'Ya existe una abstención para esta cuenta, año y bimestre.';
        RETURN;
    END IF;
    INSERT INTO abstencion_movimientos (cvecuenta, anio, bimestre, observacion, usuario, fecha)
    VALUES (p_cvecuenta, p_anio, p_bimestre, p_observacion, p_usuario, NOW());
    RETURN QUERY SELECT 'success', 'Abstención registrada correctamente.';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION funcion_abstencion_remove(
    p_cvecuenta integer,
    p_anio integer,
    p_bimestre integer,
    p_usuario varchar
) RETURNS TABLE(status varchar, message text) AS $$
DECLARE
    existe integer;
BEGIN
    SELECT COUNT(*) INTO existe FROM abstencion_movimientos
    WHERE cvecuenta = p_cvecuenta AND anio = p_anio AND bimestre = p_bimestre;
    IF existe = 0 THEN
        RETURN QUERY SELECT 'error', 'No existe abstención para esta cuenta, año y bimestre.';
        RETURN;
    END IF;
    DELETE FROM abstencion_movimientos WHERE cvecuenta = p_cvecuenta AND anio = p_anio AND bimestre = p_bimestre;
    RETURN QUERY SELECT 'success', 'Abstención eliminada correctamente.';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_validate_hasta_form(p_bimestre integer, p_anio integer)
RETURNS TABLE(is_valid boolean, error_message text) AS $$
DECLARE
    current_year integer := EXTRACT(YEAR FROM CURRENT_DATE);
BEGIN
    IF p_bimestre IS NULL OR p_bimestre < 1 OR p_bimestre > 6 THEN
        RETURN QUERY SELECT false, 'Bimestre inválido!';
        RETURN;
    END IF;
    IF p_anio IS NULL OR p_anio < 1970 THEN
        RETURN QUERY SELECT false, 'Año inválido!';
        RETURN;
    END IF;
    IF p_anio > current_year THEN
        RETURN QUERY SELECT false, 'El año no puede ser mayor al año actual';
        RETURN;
    END IF;
    RETURN QUERY SELECT true, NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_update_investcta(
    p_cvecuenta INTEGER,
    p_observacion TEXT,
    p_usuario TEXT DEFAULT NULL
) RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_asiento INTEGER;
BEGIN
    SELECT asiento INTO v_asiento FROM catastro WHERE cvecuenta = p_cvecuenta;
    IF v_asiento IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Cuenta no encontrada';
        RETURN;
    END IF;
    UPDATE catastro SET
        cvemov = 73,
        observacion = p_observacion,
        asiento = v_asiento + 1,
        feccap = NOW(),
        capturista = COALESCE(p_usuario, capturista)
    WHERE cvecuenta = p_cvecuenta;
    RETURN QUERY SELECT TRUE, 'Investigación de cuenta actualizada correctamente';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_loctp_search(p_notaria integer, p_municipio integer, p_escrituras integer)
RETURNS TABLE(
  folio integer,
  recaudadora smallint,
  cvecuenta integer,
  cvepago integer,
  cveavaext integer,
  idnotaria integer,
  noescrituras integer,
  lugotorg integer,
  fechaotorg date,
  fechafirma date,
  fechaadjudicacion date,
  naturaleza integer,
  tipo varchar,
  documentosotros text,
  pagado varchar,
  status varchar,
  valortransm numeric,
  porcbase float,
  base numeric,
  axoefec smallint,
  bimefec smallint,
  autorizada varchar,
  exento varchar,
  valfemi numeric,
  tasaemi float,
  axocomp smallint,
  nocomp integer,
  capturista varchar,
  fectram date,
  feccap date,
  areatitulo float
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.folio, a.recaudadora, a.cvecuenta, a.cvepago, a.cveavaext, a.idnotaria, a.noescrituras, a.lugotorg, a.fechaotorg, a.fechafirma, a.fechaadjudicacion, a.naturaleza, a.tipo, a.documentosotros, a.pagado, a.status, a.valortransm, a.porcbase, a.base, a.axoefec, a.bimefec, a.autorizada, a.exento, a.valfemi, a.tasaemi, a.axocomp, a.nocomp, a.capturista, a.fectram, a.feccap, a.areatitulo
    FROM actostransm a
    JOIN notario n ON a.idnotaria = n.idnotaria
    WHERE a.noescrituras = p_escrituras AND n.notaria = p_notaria AND n.mpionot = p_municipio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_loctp_update_observacion(p_folio integer, p_observacion text)
RETURNS void AS $$
BEGIN
  UPDATE actostransm SET documentosotros = p_observacion WHERE folio = p_folio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_muestradup_create(p_cvecond INTEGER, p_cvecuenta INTEGER, p_usuario VARCHAR)
RETURNS TABLE(
    cvecond INTEGER,
    cvecuenta INTEGER,
    estado VARCHAR,
    fecha TIMESTAMP
) AS $$
BEGIN
    INSERT INTO cuentas_duplicadas (cvecond, cvecuenta, estado, fecha, usuario)
    VALUES (p_cvecond, p_cvecuenta, 'N', NOW(), p_usuario)
    RETURNING cvecond, cvecuenta, estado, fecha;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_muestradup_update(p_cvecuenta INTEGER, p_estado VARCHAR, p_usuario VARCHAR)
RETURNS TABLE(
    cvecuenta INTEGER,
    estado VARCHAR,
    fecha TIMESTAMP
) AS $$
BEGIN
    UPDATE cuentas_duplicadas
    SET estado = p_estado, fecha = NOW(), usuario = p_usuario
    WHERE cvecuenta = p_cvecuenta
    RETURNING cvecuenta, estado, fecha;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_muestradup_delete(p_cvecuenta INTEGER)
RETURNS TABLE(
    cvecuenta INTEGER,
    estado VARCHAR,
    fecha TIMESTAMP
) AS $$
BEGIN
    UPDATE cuentas_duplicadas
    SET estado = 'D', fecha = NOW()
    WHERE cvecuenta = p_cvecuenta
    RETURNING cvecuenta, estado, fecha;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_muestradup_integrate(p_cvecond INTEGER, p_usuario VARCHAR)
RETURNS TABLE(
    cvecond INTEGER,
    resultado VARCHAR,
    mensaje TEXT
) AS $$
DECLARE
    total_indiviso NUMERIC;
    total_subpredios INT;
    numpred INT;
    errores TEXT := '';
BEGIN
    -- Validar que no existan subpredios duplicados
    SELECT COUNT(*) INTO total_subpredios
    FROM cuentas_duplicadas
    WHERE cvecond = p_cvecond AND estado <> 'D';

    SELECT numpred INTO numpred FROM condominios WHERE cvecond = p_cvecond;
    IF total_subpredios <> numpred THEN
        errores := errores || 'No coincide el número de predios con el total de subpredios. ';
    END IF;

    SELECT SUM(indiviso) INTO total_indiviso
    FROM cuentas_duplicadas
    WHERE cvecond = p_cvecond AND estado <> 'D';
    IF total_indiviso IS NULL OR total_indiviso < 99 OR total_indiviso > 101 THEN
        errores := errores || 'La suma de indivisos no es 100%. ';
    END IF;

    IF errores <> '' THEN
        RETURN QUERY SELECT p_cvecond, 'ERROR', errores;
        RETURN;
    END IF;

    -- Marcar integración como realizada
    UPDATE condominios SET fecha_verificado = NOW(), usr_verificado = p_usuario
    WHERE cvecond = p_cvecond;

    RETURN QUERY SELECT p_cvecond, 'OK', 'Integración aplicada correctamente';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_observa_transm_list(p_cvecuenta INTEGER)
RETURNS TABLE(
    id INTEGER,
    cvecuenta INTEGER,
    folio INTEGER,
    observacion TEXT,
    usuario VARCHAR,
    es_global BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, cvecuenta, folio, observacion, usuario, es_global, created_at, updated_at
    FROM observa_transm
    WHERE cvecuenta = p_cvecuenta
    ORDER BY created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_observa_transm_get(p_id INTEGER)
RETURNS TABLE(
    id INTEGER,
    cvecuenta INTEGER,
    folio INTEGER,
    observacion TEXT,
    usuario VARCHAR,
    es_global BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, cvecuenta, folio, observacion, usuario, es_global, created_at, updated_at
    FROM observa_transm
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_observa_transm_create(
    p_cvecuenta INTEGER,
    p_folio INTEGER,
    p_observacion TEXT,
    p_usuario VARCHAR,
    p_es_global BOOLEAN DEFAULT FALSE
) RETURNS INTEGER AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO observa_transm (cvecuenta, folio, observacion, usuario, es_global, created_at, updated_at)
    VALUES (p_cvecuenta, p_folio, p_observacion, p_usuario, p_es_global, NOW(), NOW())
    RETURNING id INTO new_id;
    RETURN new_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_observa_transm_update(
    p_id INTEGER,
    p_observacion TEXT,
    p_usuario VARCHAR
) RETURNS BOOLEAN AS $$
BEGIN
    UPDATE observa_transm
    SET observacion = p_observacion,
        usuario = p_usuario,
        updated_at = NOW()
    WHERE id = p_id;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_observa_transm_delete(p_id INTEGER)
RETURNS BOOLEAN AS $$
BEGIN
    DELETE FROM observa_transm WHERE id = p_id;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_observa_transm_create(
    p_noControl INTEGER,
    p_cvecuenta INTEGER,
    p_folio INTEGER,
    p_observacion TEXT,
    p_usuario TEXT
) RETURNS TABLE(id INTEGER, status TEXT, message TEXT) AS $$
DECLARE
    v_id INTEGER;
BEGIN
    INSERT INTO observa_transm (nocontrol, cvecuenta, folio, observacion, status, capturista_alta, fecha_alta)
    VALUES (p_noControl, p_cvecuenta, p_folio, p_observacion, 'B', p_usuario, NOW())
    RETURNING id INTO v_id;
    RETURN QUERY SELECT v_id, 'B', 'Observación registrada';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_observa_transm_update(
    p_noControl INTEGER,
    p_folio INTEGER,
    p_observacion TEXT,
    p_usuario TEXT
) RETURNS TABLE(id INTEGER, status TEXT, message TEXT) AS $$
DECLARE
    v_id INTEGER;
BEGIN
    UPDATE observa_transm
    SET observacion = p_observacion, capturista_alta = p_usuario, fecha_alta = NOW()
    WHERE nocontrol = p_noControl AND folio = p_folio AND status = 'B'
    RETURNING id INTO v_id;
    RETURN QUERY SELECT v_id, 'B', 'Observación actualizada';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_observa_transm_delete(
    p_noControl INTEGER,
    p_folio INTEGER,
    p_usuario TEXT
) RETURNS TABLE(id INTEGER, status TEXT, message TEXT) AS $$
DECLARE
    v_id INTEGER;
BEGIN
    UPDATE observa_transm
    SET status = 'D', capturista_baja = p_usuario, fecha_baja = NOW()
    WHERE nocontrol = p_noControl AND folio = p_folio AND status = 'B'
    RETURNING id INTO v_id;
    RETURN QUERY SELECT v_id, 'D', 'Observación eliminada';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_observa_transm_lock(
    p_noControl INTEGER,
    p_cvecuenta INTEGER,
    p_folio INTEGER,
    p_observacion TEXT,
    p_usuario TEXT
) RETURNS TABLE(id INTEGER, status TEXT, message TEXT) AS $$
DECLARE
    v_id INTEGER;
BEGIN
    INSERT INTO observa_transm (nocontrol, cvecuenta, folio, observacion, status, capturista_alta, fecha_alta)
    VALUES (p_noControl, p_cvecuenta, p_folio, p_observacion, 'B', p_usuario, NOW())
    RETURNING id INTO v_id;
    RETURN QUERY SELECT v_id, 'B', 'Transmisión bloqueada';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_observa_transm_unlock(
    p_noControl INTEGER,
    p_folio INTEGER,
    p_observacion TEXT,
    p_usuario TEXT
) RETURNS TABLE(id INTEGER, status TEXT, message TEXT) AS $$
DECLARE
    v_id INTEGER;
BEGIN
    UPDATE observa_transm
    SET status = 'D', capturista_baja = p_usuario, fecha_baja = NOW(), observacion = p_observacion
    WHERE nocontrol = p_noControl AND folio = p_folio AND status = 'B'
    RETURNING id INTO v_id;
    RETURN QUERY SELECT v_id, 'D', 'Transmisión desbloqueada';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_passpropietario_login(p_usuario TEXT, p_password TEXT)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_pass TEXT;
BEGIN
    SELECT pass INTO v_pass FROM restricciones WHERE nombre = p_usuario;
    IF v_pass IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Usuario no válido';
    ELSIF v_pass = p_password THEN
        RETURN QUERY SELECT TRUE, 'Autenticación exitosa';
    ELSE
        RETURN QUERY SELECT FALSE, 'Firma electrónica incorrecta';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_passpropietario_validate(p_usuario TEXT, p_password TEXT)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_pass TEXT;
BEGIN
    SELECT pass INTO v_pass FROM restricciones WHERE nombre = p_usuario;
    IF v_pass IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Usuario no válido';
    ELSIF v_pass = p_password THEN
        RETURN QUERY SELECT TRUE, 'Firma válida';
    ELSE
        RETURN QUERY SELECT FALSE, 'Firma incorrecta';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure for passwdfrm login
CREATE OR REPLACE FUNCTION sp_passwdfrm_login(p_usuario TEXT, p_password TEXT)
RETURNS TABLE(success BOOLEAN, mensaje TEXT, usuario TEXT, autorizado BOOLEAN) AS $$
DECLARE
    v_clave TEXT;
BEGIN
    SELECT clave INTO v_clave FROM usuarios WHERE usuario = p_usuario;
    IF v_clave IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Usuario no registrado para autorizaciones', NULL, FALSE;
        RETURN;
    END IF;
    IF v_clave = p_password THEN
        -- Checa si la clave inicia con '&T' (autorizado)
        IF LEFT(v_clave, 2) = '&T' THEN
            RETURN QUERY SELECT TRUE, 'Autorización concedida', p_usuario, TRUE;
        ELSE
            RETURN QUERY SELECT FALSE, 'Usuario NO registrado para autorizaciones', p_usuario, FALSE;
        END IF;
    ELSE
        RETURN QUERY SELECT FALSE, 'Password incorrecto', p_usuario, FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_add_preferencial(
    p_folio INTEGER,
    p_tasa_nva NUMERIC,
    p_observacion TEXT,
    p_axoefec INTEGER,
    p_user TEXT
) RETURNS TABLE(id INTEGER, message TEXT) AS $$
DECLARE
    v_id INTEGER;
BEGIN
    INSERT INTO preferencial (folio, tasa_nva, observacion, axoefec, capturista, feccap)
    VALUES (p_folio, p_tasa_nva, p_observacion, p_axoefec, p_user, NOW())
    RETURNING id INTO v_id;
    RETURN QUERY SELECT v_id, 'Registro agregado correctamente';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_update_preferencial(
    p_id INTEGER,
    p_tasa_nva NUMERIC,
    p_observacion TEXT,
    p_user TEXT
) RETURNS TABLE(id INTEGER, message TEXT) AS $$
BEGIN
    UPDATE preferencial
    SET tasa_nva = p_tasa_nva,
        observacion = p_observacion,
        capturista = p_user,
        feccap = NOW()
    WHERE id = p_id;
    RETURN QUERY SELECT p_id, 'Registro actualizado correctamente';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_baja_preferencial(
    p_id INTEGER,
    p_user_baja TEXT
) RETURNS TABLE(id INTEGER, message TEXT) AS $$
BEGIN
    UPDATE preferencial
    SET fecha_baja = NOW(),
        user_baja = p_user_baja
    WHERE id = p_id;
    RETURN QUERY SELECT p_id, 'Registro dado de baja correctamente';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_prepago_liquidacion_parcial(
  p_cvecuenta INTEGER,
  p_asal INTEGER,
  p_bsal INTEGER,
  p_asalf INTEGER,
  p_bsalf INTEGER
)
RETURNS TABLE (
  impppag NUMERIC,
  recppag NUMERIC,
  gasto NUMERIC,
  multa NUMERIC,
  total NUMERIC
) AS $$
DECLARE
  multa_val NUMERIC := 0;
  impp NUMERIC := 0;
  recp NUMERIC := 0;
  gast NUMERIC := 0;
BEGIN
  SELECT COALESCE(SUM(d.impfac-d.imppag-d.impvir),0),
         COALESCE(SUM(d.recfac-d.recpag-d.recvir),0),
         COALESCE(s.gasto,0),
         COALESCE(s.multa-s.multavir,0)
  INTO impp, recp, gast, multa_val
  FROM detsaldos d
  JOIN saldos s ON s.cvecuenta = d.cvecuenta
  WHERE d.cvecuenta = p_cvecuenta AND d.saldo > 0
    AND ((d.axosal > p_asal OR (d.bimsal >= p_bsal AND d.axosal = p_asal))
         AND (d.axosal < p_asalf OR (d.bimsal <= p_bsalf AND d.axosal = p_asalf)));
  RETURN QUERY SELECT impp, recp, gast, multa_val, (impp+recp+gast+multa_val);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_prepago_calcula_multa_virtual(
  p_cvecuenta INTEGER,
  p_fecha_notif DATE,
  p_fecha_actual DATE
)
RETURNS TABLE (
  multa_virtual NUMERIC
) AS $$
DECLARE
  dias_nolab INTEGER;
  dias_vencim INTEGER;
  multa NUMERIC := 0;
  base_multa NUMERIC := 0;
  porcentaje INTEGER;
BEGIN
  SELECT COUNT(*) INTO dias_nolab FROM no_laborales WHERE fecha BETWEEN p_fecha_notif AND p_fecha_actual;
  dias_vencim := (p_fecha_actual - p_fecha_notif) - dias_nolab;
  SELECT s.multa INTO base_multa FROM saldos s WHERE s.cvecuenta = p_cvecuenta;
  FOR porcentaje IN SELECT porcentaje FROM c_descmul WHERE diaini <= dias_vencim AND diafin >= dias_vencim LOOP
    multa := base_multa * (porcentaje/100.0);
  END LOOP;
  RETURN QUERY SELECT multa;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE calc_sdos(p_cvecuenta INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Aquí se debe implementar la lógica de recálculo de saldos
    -- Por ejemplo, sumarizar detsaldos, actualizar totales, etc.
    -- Este procedimiento debe ser adaptado a la lógica de negocio real
    -- Ejemplo:
    -- UPDATE saldos SET saldo = (SELECT SUM(saldo) FROM detsaldos WHERE cvecuenta = p_cvecuenta) WHERE cvecuenta = p_cvecuenta;
    -- ...
END;
$$;

CREATE OR REPLACE FUNCTION propuestatab1_create(data jsonb)
RETURNS TABLE(cvecuenta integer) AS $$
DECLARE
  new_id integer;
BEGIN
  INSERT INTO historico_cuentas (cuenta, cvecatnva, subpredio, recaud, urbrus, asiento, cmovto, observacion)
  VALUES (
    (data->>'cuenta')::integer,
    data->>'cvecatnva',
    (data->>'subpredio')::integer,
    (data->>'recaud')::integer,
    data->>'urbrus',
    (data->>'asiento')::integer,
    data->>'cmovto',
    data->>'observacion'
  ) RETURNING cvecuenta INTO new_id;
  RETURN QUERY SELECT new_id;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION propuestatab1_update(cvecuenta integer, data jsonb)
RETURNS TABLE(success boolean) AS $$
BEGIN
  UPDATE historico_cuentas SET
    cuenta = COALESCE((data->>'cuenta')::integer, cuenta),
    cvecatnva = COALESCE(data->>'cvecatnva', cvecatnva),
    subpredio = COALESCE((data->>'subpredio')::integer, subpredio),
    recaud = COALESCE((data->>'recaud')::integer, recaud),
    urbrus = COALESCE(data->>'urbrus', urbrus),
    asiento = COALESCE((data->>'asiento')::integer, asiento),
    cmovto = COALESCE(data->>'cmovto', cmovto),
    observacion = COALESCE(data->>'observacion', observacion)
  WHERE cvecuenta = $1;
  RETURN QUERY SELECT TRUE;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION propuestatab1_delete(cvecuenta integer)
RETURNS TABLE(success boolean) AS $$
BEGIN
  DELETE FROM historico_cuentas WHERE cvecuenta = $1;
  RETURN QUERY SELECT TRUE;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION psplash_log_splash_view(p_user_id INTEGER, p_ip TEXT)
RETURNS TABLE (
    logged BOOLEAN,
    log_time TIMESTAMP
) AS $$
BEGIN
    -- Ejemplo: Insertar en tabla de logs (debe existir la tabla psplash_log)
    INSERT INTO psplash_log(user_id, ip_address, viewed_at)
    VALUES (p_user_id, p_ip, NOW());
    RETURN QUERY SELECT TRUE, NOW();
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_reactivar_cuenta(p_cvecuenta INTEGER)
RETURNS TABLE(result TEXT) AS $$
DECLARE
    v_cveubic INTEGER;
    v_cveregprop INTEGER;
BEGIN
    -- Actualiza convcta
    UPDATE convcta SET vigente = 'V' WHERE cvecuenta = p_cvecuenta;

    -- Actualiza ubicacion
    SELECT cveubic INTO v_cveubic FROM catastro WHERE cvecuenta = p_cvecuenta;
    IF v_cveubic IS NOT NULL THEN
        UPDATE ubicacion SET vigencia = 'V' WHERE cveubic = v_cveubic;
    END IF;

    -- Actualiza regprop
    SELECT cveregprop INTO v_cveregprop FROM catastro WHERE cvecuenta = p_cvecuenta;
    IF v_cveregprop IS NOT NULL THEN
        UPDATE regprop SET vigencia = 'V' WHERE cvecuenta = p_cvecuenta AND cveregprop = v_cveregprop;
    END IF;

    -- Actualiza catastro
    UPDATE catastro SET cvemov = 66, vigente = 'V' WHERE cvecuenta = p_cvecuenta;

    RETURN QUERY SELECT 'Cuenta reactivada correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- sp_rechazar_transmision(folio integer, motivo text, usuario text)
CREATE OR REPLACE FUNCTION sp_rechazar_transmision(
    p_folio integer,
    p_motivo text,
    p_usuario text
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM actostransm WHERE folio = p_folio;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'Folio no encontrado.';
        RETURN;
    END IF;
    -- Solo se puede rechazar si no está ya rechazada
    IF EXISTS (SELECT 1 FROM actostransm WHERE folio = p_folio AND status = 'R' AND axocomp = 9999 AND nocomp = 999999) THEN
        RETURN QUERY SELECT false, 'La transmisión ya está rechazada.';
        RETURN;
    END IF;
    -- Actualiza el registro
    UPDATE actostransm
    SET status = 'R',
        axocomp = 9999,
        nocomp = 999999,
        documentosotros = p_motivo,
        usuario_rechazo = p_usuario,
        fecha_rechazo = NOW()
    WHERE folio = p_folio;
    RETURN QUERY SELECT true, 'Transmisión rechazada correctamente.';
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure for updating electronic signature
CREATE OR REPLACE FUNCTION upd_firma(
    p_usuario TEXT,
    p_login TEXT,
    p_firma TEXT,
    p_firma_nva TEXT,
    p_firma_conf TEXT,
    p_modulos_id INTEGER
)
RETURNS TABLE(acceso INTEGER, mensaje TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_usuario_id INTEGER;
    v_firma_actual TEXT;
BEGIN
    -- Buscar usuario
    SELECT id, firma_electronica INTO v_usuario_id, v_firma_actual
    FROM usuarios WHERE usuario = p_usuario;
    IF v_usuario_id IS NULL THEN
        RETURN QUERY SELECT 1, 'Usuario no encontrado.';
        RETURN;
    END IF;
    -- Validar firma actual
    IF v_firma_actual IS NULL OR v_firma_actual = '' THEN
        RETURN QUERY SELECT 1, 'El usuario no tiene firma electrónica registrada.';
        RETURN;
    END IF;
    IF v_firma_actual <> p_firma THEN
        RETURN QUERY SELECT 1, 'La firma actual es incorrecta.';
        RETURN;
    END IF;
    -- Validar nueva firma
    IF length(p_firma_nva) < 6 THEN
        RETURN QUERY SELECT 1, 'La nueva firma debe tener al menos 6 caracteres.';
        RETURN;
    END IF;
    IF p_firma_nva <> p_firma_conf THEN
        RETURN QUERY SELECT 1, 'La confirmación no coincide con la nueva firma.';
        RETURN;
    END IF;
    IF p_firma_nva = p_firma THEN
        RETURN QUERY SELECT 1, 'La nueva firma no puede ser igual a la actual.';
        RETURN;
    END IF;
    -- Actualizar firma
    UPDATE usuarios SET firma_electronica = p_firma_nva, updated_at = NOW()
    WHERE id = v_usuario_id;
    RETURN QUERY SELECT 0, 'Firma electrónica actualizada correctamente.';
END;
$$;

CREATE OR REPLACE FUNCTION sp_chgpass_validate_current(p_username TEXT, p_current_password TEXT)
RETURNS TABLE(is_valid BOOLEAN) AS $$
DECLARE
    v_hash TEXT;
BEGIN
    SELECT password_hash INTO v_hash FROM users WHERE username = p_username;
    IF v_hash IS NULL THEN
        RETURN QUERY SELECT FALSE;
        RETURN;
    END IF;
    IF crypt(p_current_password, v_hash) = v_hash THEN
        RETURN QUERY SELECT TRUE;
    ELSE
        RETURN QUERY SELECT FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION sp_chgpass_validate_new(p_current_password TEXT, p_new_password TEXT)
RETURNS TABLE(is_valid BOOLEAN, error_message TEXT) AS $$
DECLARE
    cnum INT := 0;
    clet INT := 0;
    i INT;
    ch CHAR;
BEGIN
    -- Longitud
    IF LENGTH(p_new_password) < 2 OR LENGTH(p_new_password) > 8 THEN
        RETURN QUERY SELECT FALSE, 'La clave debe tener entre 2 y 8 caracteres.';
        RETURN;
    END IF;
    -- Debe contener letras y números
    FOR i IN 1..LENGTH(p_new_password) LOOP
        ch := SUBSTRING(p_new_password FROM i FOR 1);
        IF ch ~ '[0-9]' THEN
            cnum := cnum + 1;
        ELSIF ch ~ '[a-zA-Z]' THEN
            clet := clet + 1;
        END IF;
    END LOOP;
    IF cnum = 0 OR clet = 0 THEN
        RETURN QUERY SELECT FALSE, 'La clave debe contener números y letras.';
        RETURN;
    END IF;
    -- No igual a la actual
    IF p_current_password = p_new_password THEN
        RETURN QUERY SELECT FALSE, 'La clave no debe ser igual a la actual.';
        RETURN;
    END IF;
    -- Los 3 primeros caracteres diferentes
    IF SUBSTRING(p_current_password, 1, 3) = SUBSTRING(p_new_password, 1, 3) THEN
        RETURN QUERY SELECT FALSE, 'Los tres primeros caracteres deben ser diferentes al actual.';
        RETURN;
    END IF;
    RETURN QUERY SELECT TRUE, NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_chgpass_update(p_username TEXT, p_current_password TEXT, p_new_password TEXT)
RETURNS TABLE(success BOOLEAN, error_message TEXT) AS $$
DECLARE
    v_hash TEXT;
    v_valid BOOLEAN;
    v_err TEXT;
BEGIN
    -- Validar clave actual
    SELECT password_hash INTO v_hash FROM users WHERE username = p_username;
    IF v_hash IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Usuario no encontrado.';
        RETURN;
    END IF;
    IF crypt(p_current_password, v_hash) <> v_hash THEN
        RETURN QUERY SELECT FALSE, 'La clave actual no es correcta.';
        RETURN;
    END IF;
    -- Validar nueva clave
    SELECT is_valid, error_message INTO v_valid, v_err FROM sp_chgpass_validate_new(p_current_password, p_new_password);
    IF NOT v_valid THEN
        RETURN QUERY SELECT FALSE, v_err;
        RETURN;
    END IF;
    -- Actualizar clave
    UPDATE users SET password_hash = crypt(p_new_password, gen_salt('bf')) WHERE username = p_username;
    RETURN QUERY SELECT TRUE, NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_login_usuario(p_usuario TEXT, p_clave TEXT)
RETURNS TABLE(
    usuario TEXT,
    nombres TEXT,
    clave TEXT,
    cvedepto INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT usuario, nombres, clave, cvedepto
    FROM usuarios
    WHERE usuario = p_usuario AND clave = crypt(p_clave, clave);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cambiar_clave(p_usuario TEXT, p_clave_actual TEXT, p_clave_nueva TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM usuarios WHERE usuario = p_usuario AND clave = crypt(p_clave_actual, clave);
    IF v_count = 0 THEN
        RETURN FALSE;
    END IF;
    UPDATE usuarios SET clave = crypt(p_clave_nueva, gen_salt('bf')) WHERE usuario = p_usuario;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_guardar_propietario(p_cvecuenta INTEGER, p_nombre TEXT, p_rfc TEXT, p_porcentaje NUMERIC, p_tipo TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    INSERT INTO propietarios (cvecuenta, nombre, rfc, porcentaje, tipo)
    VALUES (p_cvecuenta, p_nombre, p_rfc, p_porcentaje, p_tipo);
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_autorizar_transmision(p_folio INTEGER, p_usuario TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE actostransm SET status = 'A' WHERE folio = p_folio;
    INSERT INTO autorizaciones (folio, usuario, fecha) VALUES (p_folio, p_usuario, NOW());
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure for login
CREATE OR REPLACE FUNCTION sp_login(p_username TEXT, p_password TEXT)
RETURNS TABLE(success BOOLEAN, username TEXT, fullname TEXT) AS $$
DECLARE
    v_user RECORD;
BEGIN
    -- Replace with your actual user table and password hash check
    SELECT username, fullname, password_hash
    INTO v_user
    FROM users
    WHERE username = p_username;

    IF v_user IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL, NULL;
        RETURN;
    END IF;

    -- Example: plain text password check (replace with hash check in production)
    IF v_user.password_hash = p_password THEN
        RETURN QUERY SELECT TRUE, v_user.username, v_user.fullname;
    ELSE
        RETURN QUERY SELECT FALSE, NULL, NULL;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION calc_impto_transpat(p_folio integer)
RETURNS TABLE(
  base_tot numeric,
  impuesto numeric,
  recargos numeric,
  multas numeric,
  gastos numeric,
  porctasa numeric,
  deducible numeric,
  total numeric
) AS $$
DECLARE
  v_base numeric := 0;
  v_impuesto numeric := 0;
  v_recargos numeric := 0;
  v_multas numeric := 0;
  v_gastos numeric := 0;
  v_porctasa numeric := 0;
  v_deducible numeric := 0;
  v_total numeric := 0;
  v_fecha date;
  v_sector char(1);
  v_valortransm numeric;
  v_porcbase numeric;
  v_valfemi numeric;
  v_tasaemi numeric;
  v_supterr numeric;
  v_tpreferencial char(1);
  v_naturaleza integer;
  v_exento char(1);
  v_fechafirma date;
  v_fechaotorg date;
  v_fechaadjudicacion date;
BEGIN
  -- Obtener datos principales
  SELECT valortransm, porcbase, valfemi, tasaemi, supterr, tpreferencial, naturaleza, exento, fechafirma, fechaotorg, fechaadjudicacion
    INTO v_valortransm, v_porcbase, v_valfemi, v_tasaemi, v_supterr, v_tpreferencial, v_naturaleza, v_exento, v_fechafirma, v_fechaotorg, v_fechaadjudicacion
  FROM actostransm WHERE folio = p_folio;

  -- Determinar fecha relevante
  IF v_naturaleza BETWEEN 3 AND 6 OR v_naturaleza IN (16,26,28) THEN
    v_fecha := COALESCE(v_fechaotorg, v_fechaadjudicacion, v_fechafirma, CURRENT_DATE);
  ELSE
    v_fecha := COALESCE(v_fechafirma, CURRENT_DATE);
  END IF;

  -- Calcular base
  v_base := v_valortransm * v_porcbase / 100.0;
  IF v_valfemi * v_porcbase / 100.0 > v_base THEN
    v_base := v_valfemi * v_porcbase / 100.0;
  END IF;
  -- Aquí se pueden agregar más reglas según valores referidos y avalúos externos

  base_tot := v_base;

  -- Determinar tasa y deducible según fecha
  IF v_fecha < DATE '1999-01-01' THEN
    -- Lógica histórica (simplificada)
    v_porctasa := 0.02;
    v_deducible := 0;
    v_impuesto := GREATEST(v_base - v_deducible, 0) * v_porctasa;
  ELSE
    -- Lógica moderna
    IF v_tasaemi = 0.00075 AND v_supterr <= 100 AND v_tpreferencial = 'S' THEN
      v_porctasa := 0.00075;
      v_impuesto := v_base * v_porctasa * 0.1;
    ELSE
      v_porctasa := 0.02;
      v_impuesto := v_base * v_porctasa;
    END IF;
  END IF;

  -- Multas, recargos y gastos (simplificado)
  v_multas := 0;
  v_recargos := 0;
  v_gastos := 0;

  -- Exento
  IF v_exento = 'S' THEN
    v_impuesto := 0;
    v_porctasa := 0;
    v_total := v_multas;
  ELSE
    v_total := v_impuesto + v_multas + v_recargos + v_gastos;
  END IF;

  impuesto := v_impuesto;
  recargos := v_recargos;
  multas := v_multas;
  gastos := v_gastos;
  porctasa := v_porctasa;
  deducible := v_deducible;
  total := v_total;

  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_save_adquiriente(
  p_folio integer,
  p_cvecont integer,
  p_cvecalle integer,
  p_tipo varchar,
  p_razonsocial varchar,
  p_paterno varchar,
  p_materno varchar,
  p_nombres varchar,
  p_edocivil integer,
  p_tiposociedad varchar,
  p_lugarnacimiento varchar,
  p_fechanacimiento date,
  p_porccoprop numeric,
  p_rfc varchar,
  p_noexterior varchar,
  p_interior varchar,
  p_obsinter text,
  p_telefono varchar,
  p_codpos integer,
  p_mismodom varchar,
  p_propiedades varchar,
  p_origen varchar,
  p_encabeza varchar,
  p_feccap date,
  p_capturista varchar,
  p_cverepres integer,
  p_cvepais smallint,
  p_cveestado smallint,
  p_cvemunicipio smallint,
  p_cvepoblacion smallint,
  p_cvereg integer,
  p_colonia varchar
) RETURNS void AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM receptcontrib WHERE folio = p_folio AND cvecont = p_cvecont) THEN
    UPDATE receptcontrib SET
      cvecalle = p_cvecalle,
      tipo = p_tipo,
      razonsocial = p_razonsocial,
      paterno = p_paterno,
      materno = p_materno,
      nombres = p_nombres,
      edocivil = p_edocivil,
      tiposociedad = p_tiposociedad,
      lugarnacimiento = p_lugarnacimiento,
      fechanacimiento = p_fechanacimiento,
      porccoprop = p_porccoprop,
      rfc = p_rfc,
      noexterior = p_noexterior,
      interior = p_interior,
      obsinter = p_obsinter,
      telefono = p_telefono,
      codpos = p_codpos,
      mismodom = p_mismodom,
      propiedades = p_propiedades,
      origen = p_origen,
      encabeza = p_encabeza,
      feccap = p_feccap,
      capturista = p_capturista,
      cverepres = p_cverepres,
      cvepais = p_cvepais,
      cveestado = p_cveestado,
      cvemunicipio = p_cvemunicipio,
      cvepoblacion = p_cvepoblacion,
      cvereg = p_cvereg,
      colonia = p_colonia
    WHERE folio = p_folio AND cvecont = p_cvecont;
  ELSE
    INSERT INTO receptcontrib (
      folio, cvecont, cvecalle, tipo, razonsocial, paterno, materno, nombres, edocivil, tiposociedad, lugarnacimiento, fechanacimiento, porccoprop, rfc, noexterior, interior, obsinter, telefono, codpos, mismodom, propiedades, origen, encabeza, feccap, capturista, cverepres, cvepais, cveestado, cvemunicipio, cvepoblacion, cvereg, colonia
    ) VALUES (
      p_folio, p_cvecont, p_cvecalle, p_tipo, p_razonsocial, p_paterno, p_materno, p_nombres, p_edocivil, p_tiposociedad, p_lugarnacimiento, p_fechanacimiento, p_porccoprop, p_rfc, p_noexterior, p_interior, p_obsinter, p_telefono, p_codpos, p_mismodom, p_propiedades, p_origen, p_encabeza, p_feccap, p_capturista, p_cverepres, p_cvepais, p_cveestado, p_cvemunicipio, p_cvepoblacion, p_cvereg, p_colonia
    );
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_save_transmision_pat(params_json jsonb)
RETURNS jsonb AS $$
DECLARE
    p jsonb := params_json;
    v_folio integer;
    v_result jsonb;
BEGIN
    -- Validaciones básicas (pueden expandirse)
    IF (p->>'cvecuenta') IS NULL THEN
        RAISE EXCEPTION 'Cuenta catastral requerida';
    END IF;
    -- Insertar en trans_pat
    INSERT INTO trans_pat (
        cvecuenta, cveavaext, recaudadora, status, noescrituras, fechaotorg, fechafirma, fechaadjudicacion,
        documentosotros, valortransm, porcbase, axoefec, bimefec, valfemi, tasaemi, idnotaria, lugotorg, naturaleza, areatitulo
    ) VALUES (
        (p->>'cvecuenta')::integer,
        (p->>'cveavaext')::integer,
        (p->>'recaudadora')::integer,
        (p->>'status'),
        (p->>'noescrituras'),
        NULLIF(p->>'fechaotorg','')::date,
        NULLIF(p->>'fechafirma','')::date,
        NULLIF(p->>'fechaadjudicacion','')::date,
        (p->>'documentosotros'),
        (p->>'valortransm')::numeric,
        (p->>'porcbase')::numeric,
        (p->>'axoefec')::integer,
        (p->>'bimefec')::integer,
        (p->>'valfemi')::numeric,
        (p->>'tasaemi'),
        (p->>'idnotaria')::integer,
        (p->>'lugotorg')::integer,
        (p->>'naturaleza')::integer,
        (p->>'areatitulo')::numeric
    ) RETURNING folio INTO v_folio;
    -- Aquí se puede agregar la lógica para transmitentes/adquirientes
    -- ...
    v_result := jsonb_build_object('folio', v_folio, 'message', 'Transmisión registrada');
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION crea_tmpvalade(p_cvecuenta integer)
RETURNS void AS $$
BEGIN
  -- Borra los valores temporales previos
  DELETE FROM tmp_valadeudo WHERE cvecuenta = p_cvecuenta;
  -- Inserta los valores actuales de valoradeudo como base
  INSERT INTO tmp_valadeudo (cvecuenta, axoefec, bimefec, valfiscal, tasa, axosobre, estado, observacion)
    SELECT cvecuenta, axoefec, bimefec, valfiscal, tasa, axosobre, 'M', observacion
    FROM valoradeudo WHERE cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION upd_tmpvalade(p_cvecuenta integer)
RETURNS void AS $$
DECLARE
  r RECORD;
BEGIN
  -- Elimina los valores actuales
  DELETE FROM valoradeudo WHERE cvecuenta = p_cvecuenta;
  -- Inserta los valores temporales
  FOR r IN SELECT * FROM tmp_valadeudo WHERE cvecuenta = p_cvecuenta LOOP
    INSERT INTO valoradeudo (cvecuenta, axoefec, bimefec, valfiscal, tasa, axosobre, observacion)
    VALUES (r.cvecuenta, r.axoefec, r.bimefec, r.valfiscal, r.tasa, r.axosobre, r.observacion);
  END LOOP;
  -- Actualiza catastro (ejemplo: asiento, axoefec, bimefec, observacion)
  UPDATE catastro SET asiento = asiento + 1, axoefec = (SELECT max(axoefec) FROM valoradeudo WHERE cvecuenta = p_cvecuenta), bimefec = (SELECT max(bimefec) FROM valoradeudo WHERE cvecuenta = p_cvecuenta), observacion = (SELECT observacion FROM tmp_valadeudo WHERE cvecuenta = p_cvecuenta ORDER BY axoefec DESC, bimefec DESC LIMIT 1)
  WHERE cvecuenta = p_cvecuenta;
  -- Borra los temporales
  DELETE FROM tmp_valadeudo WHERE cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_valores_aux(
    p_axoefec INTEGER,
    p_bimefec INTEGER,
    p_valfiscal NUMERIC(18,2),
    p_tasa NUMERIC(10,4),
    p_axosobre INTEGER,
    p_observacion TEXT,
    p_ahasta INTEGER,
    p_bhasta INTEGER
) RETURNS TABLE (
    id INTEGER,
    axoefec INTEGER,
    bimefec INTEGER,
    valfiscal NUMERIC(18,2),
    tasa NUMERIC(10,4),
    axosobre INTEGER,
    ahasta INTEGER,
    bhasta INTEGER,
    observacion TEXT
) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO valores_aux (axoefec, bimefec, valfiscal, tasa, axosobre, ahasta, bhasta, observacion)
    VALUES (p_axoefec, p_bimefec, p_valfiscal, p_tasa, p_axosobre, p_ahasta, p_bhasta, p_observacion)
    RETURNING id INTO new_id;
    RETURN QUERY SELECT id, axoefec, bimefec, valfiscal, tasa, axosobre, ahasta, bhasta, observacion FROM valores_aux WHERE id = new_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_valores_aux(
    p_id INTEGER,
    p_axoefec INTEGER,
    p_bimefec INTEGER,
    p_valfiscal NUMERIC(18,2),
    p_tasa NUMERIC(10,4),
    p_axosobre INTEGER,
    p_observacion TEXT,
    p_ahasta INTEGER,
    p_bhasta INTEGER
) RETURNS TABLE (
    id INTEGER,
    axoefec INTEGER,
    bimefec INTEGER,
    valfiscal NUMERIC(18,2),
    tasa NUMERIC(10,4),
    axosobre INTEGER,
    ahasta INTEGER,
    bhasta INTEGER,
    observacion TEXT
) AS $$
BEGIN
    UPDATE valores_aux SET
        axoefec = p_axoefec,
        bimefec = p_bimefec,
        valfiscal = p_valfiscal,
        tasa = p_tasa,
        axosobre = p_axosobre,
        ahasta = p_ahasta,
        bhasta = p_bhasta,
        observacion = p_observacion
    WHERE id = p_id;
    RETURN QUERY SELECT id, axoefec, bimefec, valfiscal, tasa, axosobre, ahasta, bhasta, observacion FROM valores_aux WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_valores_aux(p_id INTEGER)
RETURNS TABLE (deleted BOOLEAN) AS $$
BEGIN
    DELETE FROM valores_aux WHERE id = p_id;
    RETURN QUERY SELECT TRUE AS deleted;
END;
$$ LANGUAGE plpgsql;