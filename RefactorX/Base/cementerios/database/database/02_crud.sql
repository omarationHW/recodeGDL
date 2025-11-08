CREATE OR REPLACE FUNCTION sp_abcf_get_folio(p_folio INTEGER)
RETURNS TABLE (
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase SMALLINT,
    clase_alfa VARCHAR,
    seccion SMALLINT,
    seccion_alfa VARCHAR,
    linea SMALLINT,
    linea_alfa VARCHAR,
    fosa SMALLINT,
    fosa_alfa VARCHAR,
    axo_pagado INTEGER,
    metros FLOAT,
    nombre VARCHAR,
    domicilio VARCHAR,
    exterior VARCHAR,
    interior VARCHAR,
    colonia VARCHAR,
    observaciones VARCHAR,
    usuario INTEGER,
    fecha_mov DATE,
    tipo VARCHAR,
    fecha_alta DATE,
    vigencia VARCHAR,
    usuario_nombre VARCHAR,
    id_rec SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_rcm, a.cementerio, a.clase, a.clase_alfa, a.seccion, a.seccion_alfa, a.linea, a.linea_alfa, a.fosa, a.fosa_alfa, a.axo_pagado, a.metros, a.nombre, a.domicilio, a.exterior, a.interior, a.colonia, a.observaciones, a.usuario, a.fecha_mov, a.tipo, a.fecha_alta, a.vigencia, c.nombre, c.id_rec
    FROM ta_13_datosrcm a
    LEFT JOIN ta_12_passwords c ON a.usuario = c.id_usuario
    WHERE a.control_rcm = p_folio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sp_abcf_update_folio(
    p_folio INTEGER,
    p_cementerio VARCHAR,
    p_clase SMALLINT,
    p_clase_alfa VARCHAR,
    p_seccion SMALLINT,
    p_seccion_alfa VARCHAR,
    p_linea SMALLINT,
    p_linea_alfa VARCHAR,
    p_fosa SMALLINT,
    p_fosa_alfa VARCHAR,
    p_axo_pagado INTEGER,
    p_metros FLOAT,
    p_nombre VARCHAR,
    p_domicilio VARCHAR,
    p_exterior VARCHAR,
    p_interior VARCHAR,
    p_colonia VARCHAR,
    p_observaciones VARCHAR,
    p_tipo VARCHAR,
    p_usuario INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ta_13_datosrcm SET
        cementerio = p_cementerio,
        clase = p_clase,
        clase_alfa = p_clase_alfa,
        seccion = p_seccion,
        seccion_alfa = p_seccion_alfa,
        linea = p_linea,
        linea_alfa = p_linea_alfa,
        fosa = p_fosa,
        fosa_alfa = p_fosa_alfa,
        axo_pagado = p_axo_pagado,
        metros = p_metros,
        nombre = p_nombre,
        domicilio = p_domicilio,
        exterior = p_exterior,
        interior = p_interior,
        colonia = p_colonia,
        observaciones = p_observaciones,
        usuario = p_usuario,
        fecha_mov = CURRENT_DATE,
        tipo = p_tipo
    WHERE control_rcm = p_folio;
    -- Lógica de histórico
    CALL sp_13_historia(p_folio);
END;
$$;

CREATE OR REPLACE PROCEDURE sp_abcf_baja_folio(
    p_folio INTEGER,
    p_usuario INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ta_13_datosrcm SET
        vigencia = 'B',
        usuario = p_usuario,
        fecha_mov = CURRENT_DATE
    WHERE control_rcm = p_folio;
    CALL sp_13_historia(p_folio);
END;
$$;

CREATE OR REPLACE FUNCTION sp_abcf_get_adicional(p_folio INTEGER)
RETURNS TABLE (
    control_rcm INTEGER,
    rfc VARCHAR,
    curp VARCHAR,
    telefono VARCHAR,
    clave_ife VARCHAR
) AS $$
BEGIN
    RETURN QUERY SELECT control_rcm, rfc, curp, telefono, clave_ife FROM ta_13_datosrcmadic WHERE control_rcm = p_folio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sp_abcf_update_adicional(
    p_folio INTEGER,
    p_rfc VARCHAR,
    p_curp VARCHAR,
    p_telefono VARCHAR,
    p_clave_ife VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_13_datosrcmadic WHERE control_rcm = p_folio) THEN
        UPDATE ta_13_datosrcmadic SET
            rfc = p_rfc,
            curp = p_curp,
            telefono = p_telefono,
            clave_ife = p_clave_ife
        WHERE control_rcm = p_folio;
    ELSE
        INSERT INTO ta_13_datosrcmadic (control_rcm, rfc, curp, telefono, clave_ife)
        VALUES (p_folio, p_rfc, p_curp, p_telefono, p_clave_ife);
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_abcf_delete_adicional(p_folio INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM ta_13_datosrcmadic WHERE control_rcm = p_folio;
END;
$$;

-- PostgreSQL version of spd_13_abcdesctos
CREATE OR REPLACE FUNCTION spd_13_abcdesctos(
    v_control integer,
    v_axo integer,
    v_porc integer,
    v_usu integer,
    v_reac varchar(1),
    v_tipo_descto varchar(1),
    v_opc integer
)
RETURNS TABLE(par_ok smallint, par_observ varchar) AS $$
DECLARE
    v_exists integer;
BEGIN
    IF v_opc = 1 THEN -- Alta
        SELECT COUNT(*) INTO v_exists FROM ta_13_descpens WHERE control_rcm = v_control AND axo_descto = v_axo AND vigencia = 'V';
        IF v_exists > 0 THEN
            par_ok := 1;
            par_observ := 'Ya tiene descuento para el adeudo del año seleccionado, verifique';
            RETURN NEXT;
        END IF;
        INSERT INTO ta_13_descpens (control_rcm, axo_descto, descuento, usuario, fecha_alta, vigencia, reactivar, tipo_descto)
        VALUES (v_control, v_axo, v_porc, v_usu, CURRENT_DATE, 'V', v_reac, v_tipo_descto);
        par_ok := 0;
        par_observ := 'Descuento dado de alta correctamente';
        RETURN NEXT;
    ELSIF v_opc = 2 THEN -- Baja
        UPDATE ta_13_descpens SET vigencia = 'B', usuario_mov = v_usu, fecha_mov = CURRENT_DATE
        WHERE control_rcm = v_control AND axo_descto = v_axo AND vigencia = 'V';
        par_ok := 0;
        par_observ := 'Descuento dado de baja correctamente';
        RETURN NEXT;
    ELSIF v_opc = 3 THEN -- Modifica
        UPDATE ta_13_descpens SET descuento = v_porc, usuario_mov = v_usu, fecha_mov = CURRENT_DATE
        WHERE control_rcm = v_control AND axo_descto = v_axo AND vigencia = 'V';
        par_ok := 0;
        par_observ := 'Descuento modificado correctamente';
        RETURN NEXT;
    ELSIF v_opc = 4 THEN -- Reactivar
        UPDATE ta_13_descpens SET reactivar = 'S', usuario_mov = v_usu, fecha_mov = CURRENT_DATE
        WHERE control_rcm = v_control AND axo_descto = v_axo;
        par_ok := 0;
        par_observ := 'Descuento reactivado correctamente';
        RETURN NEXT;
    ELSE
        par_ok := 1;
        par_observ := 'Operación no soportada';
        RETURN NEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure for liquidation calculation
CREATE OR REPLACE FUNCTION sp_liquidaciones_calcular(
    p_cementerio VARCHAR(1),
    p_anio_desde INTEGER,
    p_anio_hasta INTEGER,
    p_metros NUMERIC,
    p_tipo VARCHAR(1), -- 'F', 'U', 'G'
    p_nuevo BOOLEAN,
    p_mes INTEGER
)
RETURNS TABLE(
    axo_cuota INTEGER,
    manten NUMERIC,
    recargos NUMERIC
) AS $$
DECLARE
    v_cuota_col TEXT;
    v_axo INTEGER;
    v_mant NUMERIC;
    v_rec NUMERIC;
    v_porcentaje NUMERIC;
BEGIN
    -- Determinar columna de cuota
    IF p_tipo = 'F' THEN
        v_cuota_col := 'cuota1';
    ELSIF p_tipo = 'U' THEN
        v_cuota_col := 'cuota_urna';
    ELSIF p_tipo = 'G' THEN
        v_cuota_col := 'cuota_gaveta';
    ELSE
        v_cuota_col := 'cuota2';
    END IF;

    FOR v_axo IN p_anio_desde..p_anio_hasta LOOP
        -- Obtener cuota
        EXECUTE format('SELECT %I FROM ta_13_rcmcuotas WHERE cementerio = $1 AND axo_cuota = $2', v_cuota_col)
        INTO v_mant USING p_cementerio, v_axo;
        IF v_mant IS NULL THEN v_mant := 0; END IF;
        v_mant := round(v_mant * p_metros, 2);
        -- Calcular recargos
        IF p_nuevo THEN
            v_rec := 0;
        ELSE
            SELECT porcentaje_global FROM ta_13_recargosrcm WHERE axo = v_axo AND mes = p_mes INTO v_porcentaje;
            IF v_porcentaje IS NULL THEN v_porcentaje := 0; END IF;
            v_rec := round(v_mant * (v_porcentaje/100), 2);
        END IF;
        axo_cuota := v_axo;
        manten := v_mant;
        recargos := v_rec;
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_valida_usuario(p_usuario VARCHAR, p_clave VARCHAR)
RETURNS TABLE(
    valido BOOLEAN,
    id_usuario INTEGER,
    usuario VARCHAR,
    nombre VARCHAR,
    estado VARCHAR,
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora VARCHAR,
    domicilio VARCHAR,
    tel VARCHAR,
    recaudador VARCHAR,
    nivel SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        TRUE AS valido,
        a.id_usuario,
        a.usuario,
        a.nombre,
        a.estado,
        a.id_rec,
        b.id_zona,
        b.recaudadora,
        b.domicilio,
        b.tel,
        b.recaudador,
        a.nivel
    FROM ta_12_passwords a
    JOIN ta_12_recaudadoras b ON a.id_rec = b.id_rec
    WHERE a.usuario = p_usuario
      AND a.clave = p_clave
      AND a.estado = 'A'
    LIMIT 1;
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_hay_nueva_version(p_proyecto VARCHAR, p_version VARCHAR)
RETURNS TABLE(hay_nueva BOOLEAN) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM ta_versiones WHERE proyecto = p_proyecto AND version = p_version;
    IF v_count = 1 THEN
        RETURN QUERY SELECT FALSE;
    ELSE
        RETURN QUERY SELECT TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION rpt_titulos_fecha_aletras_corta(fecha date)
RETURNS varchar AS $$
DECLARE
    meses text[] := ARRAY['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    d integer;
    m integer;
    y integer;
BEGIN
    d := EXTRACT(DAY FROM fecha);
    m := EXTRACT(MONTH FROM fecha);
    y := EXTRACT(YEAR FROM fecha);
    RETURN d::text || '-' || meses[m] || '-' || y::text;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_chgpass_validate_current(p_user_id integer, p_current_password text)
RETURNS TABLE(is_valid boolean) AS $$
BEGIN
    RETURN QUERY
    SELECT (password = crypt(p_current_password, password)) AS is_valid
    FROM ta_12_passwords
    WHERE id_usuario = p_user_id AND estado = 'A';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION sp_chgpass_change(
    p_user_id integer,
    p_current_password text,
    p_new_password text,
    p_confirm_password text
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_user_record RECORD;
    v_valid boolean;
BEGIN
    -- Validar clave actual
    SELECT * INTO v_user_record FROM ta_12_passwords WHERE id_usuario = p_user_id AND estado = 'A';
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Usuario no encontrado o inactivo.';
        RETURN;
    END IF;
    v_valid := (v_user_record.password = crypt(p_current_password, v_user_record.password));
    IF NOT v_valid THEN
        RETURN QUERY SELECT false, 'La clave actual no es correcta.';
        RETURN;
    END IF;
    -- Validaciones de nueva clave
    IF p_new_password IS NULL OR length(p_new_password) < 6 THEN
        RETURN QUERY SELECT false, 'La clave debe ser mayor a 5 dígitos.';
        RETURN;
    END IF;
    IF p_new_password = p_current_password THEN
        RETURN QUERY SELECT false, 'La clave nueva no debe ser igual a la actual.';
        RETURN;
    END IF;
    IF substring(p_new_password, 1, 3) = substring(p_current_password, 1, 3) THEN
        RETURN QUERY SELECT false, 'Los tres primeros caracteres deben ser diferentes al actual.';
        RETURN;
    END IF;
    IF p_new_password <> p_confirm_password THEN
        RETURN QUERY SELECT false, 'La confirmación de la clave no es igual.';
        RETURN;
    END IF;
    IF p_new_password !~ '[a-z]' OR p_new_password !~ '[0-9]' THEN
        RETURN QUERY SELECT false, 'La clave debe contener números y letras.';
        RETURN;
    END IF;
    -- Actualizar clave
    UPDATE ta_12_passwords
    SET password = crypt(p_new_password, gen_salt('bf')),
        fecha_mov = now()
    WHERE id_usuario = p_user_id;
    RETURN QUERY SELECT true, 'Clave cambiada satisfactoriamente.';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION sp_titulos_search(p_fecha DATE, p_folio INTEGER, p_operacion INTEGER)
RETURNS TABLE(
    control_rcm INTEGER,
    titulo INTEGER,
    libro INTEGER,
    axo INTEGER,
    folio_libro INTEGER,
    nombre_beneficiario TEXT,
    domicilio_beneficiario TEXT,
    colonia_beneficiario TEXT,
    telefono_beneficiario TEXT,
    partida TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.control_rcm, t.titulo, t.libro, t.axo, t.folio, t.nombre_beneficiario, t.domicilio_beneficiario, t.colonia_beneficiario, t.telefono_beneficiario, t.partida
    FROM ta_13_titulos t
    WHERE t.fecha = p_fecha AND t.control_rcm = p_folio AND t.operacion = p_operacion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_titulos_update(
    p_control_rcm INTEGER,
    p_titulo INTEGER,
    p_fecha DATE,
    p_libro INTEGER,
    p_axo INTEGER,
    p_folio INTEGER,
    p_nombre TEXT,
    p_domicilio TEXT,
    p_colonia TEXT,
    p_telefono TEXT,
    p_partida TEXT
) RETURNS TABLE(status TEXT, observacion TEXT) AS $$
BEGIN
    UPDATE ta_13_titulos
    SET libro = p_libro,
        axo = p_axo,
        folio = p_folio,
        nombre_beneficiario = p_nombre,
        domicilio_beneficiario = p_domicilio,
        colonia_beneficiario = p_colonia,
        telefono_beneficiario = p_telefono,
        partida = p_partida
    WHERE control_rcm = p_control_rcm AND titulo = p_titulo AND fecha = p_fecha;
    RETURN QUERY SELECT 'OK', 'Actualización exitosa';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_titulos_validate(p_fecha DATE, p_folio INTEGER, p_operacion INTEGER)
RETURNS TABLE(exists BOOLEAN) AS $$
BEGIN
    RETURN QUERY
    SELECT EXISTS(
        SELECT 1 FROM ta_13_titulos t
        WHERE t.fecha = p_fecha AND t.control_rcm = p_folio AND t.operacion = p_operacion
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_titulosin_get_folio(
    p_folio INTEGER,
    p_fecha DATE,
    p_operacion INTEGER
) RETURNS TABLE(
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase SMALLINT,
    clase_alfa VARCHAR,
    seccion SMALLINT,
    seccion_alfa VARCHAR,
    linea SMALLINT,
    linea_alfa VARCHAR,
    fosa SMALLINT,
    fosa_alfa VARCHAR,
    axo_pagado INTEGER,
    metros FLOAT,
    nombre VARCHAR,
    domicilio VARCHAR,
    exterior VARCHAR,
    interior VARCHAR,
    colonia VARCHAR,
    observaciones VARCHAR,
    usuario INTEGER,
    fecha_mov DATE,
    tipo VARCHAR,
    nombre_1 VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.control_rcm, b.cementerio, b.clase, b.clase_alfa, b.seccion, b.seccion_alfa, b.linea, b.linea_alfa, b.fosa, b.fosa_alfa, b.axo_pagado, b.metros, b.nombre, b.domicilio, b.exterior, b.interior, b.colonia, b.observaciones, b.usuario, b.fecha_mov, b.tipo, c.nombre as nombre_1
    FROM ta_13_datosrcm b
    JOIN tc_13_cementerios c ON b.cementerio = c.cementerio
    WHERE b.control_rcm = p_folio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_titulosin_get_ingresos(
    p_fecha DATE,
    p_ofna SMALLINT,
    p_caja VARCHAR,
    p_operacion INTEGER
) RETURNS TABLE(
    fecha DATE,
    id_rec SMALLINT,
    caja VARCHAR,
    operacion INTEGER,
    importe NUMERIC,
    cvepago VARCHAR,
    id_modulo INTEGER,
    id_regmodulo INTEGER,
    id_rec_cta SMALLINT,
    regmunur VARCHAR,
    mesdesde SMALLINT,
    axodesde SMALLINT,
    meshasta SMALLINT,
    axohasta SMALLINT,
    nombre VARCHAR,
    domicilio VARCHAR,
    concepto VARCHAR,
    rfcini VARCHAR,
    rfcnumero INTEGER,
    rfccolonia SMALLINT,
    obra SMALLINT,
    axofolio INTEGER,
    id_usuario INTEGER,
    fecha_act TIMESTAMP,
    cajero VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.*, (SELECT nombre FROM ta_12_passwords WHERE id_usuario = a.id_usuario) as cajero
    FROM ta_12_recibos a
    WHERE a.fecha = p_fecha
      AND a.id_rec = p_ofna
      AND a.caja = p_caja
      AND a.operacion = p_operacion
      AND a.id_modulo = 12
      AND (
        SELECT COUNT(*) FROM ta_12_recibosdet
        WHERE fecha = a.fecha AND a.id_rec = id_rec AND a.caja = caja AND a.operacion = operacion
          AND cuenta IN (44304, 44301, 44307, 44314, 44311, 44310, 44450)
      ) > 0;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_titulosin_print(
    p_folio INTEGER,
    p_fecha DATE,
    p_operacion INTEGER,
    p_rec SMALLINT,
    p_telefono VARCHAR
) RETURNS JSON AS $$
DECLARE
    folio_data RECORD;
    rec_data RECORD;
    result JSON;
BEGIN
    SELECT * INTO folio_data FROM sp_titulosin_get_folio(p_folio, p_fecha, p_operacion);
    SELECT * INTO rec_data FROM sp_titulosin_get_rec(p_rec);
    result := json_build_object(
        'folio', folio_data,
        'rec', rec_data,
        'telefono', p_telefono
    );
    RETURN result;
END;
$$ LANGUAGE plpgsql;

--
-- sp_traslado_folios_sin_adeudo
-- Traslada pagos seleccionados de un folio a otro sin afectar adeudos
--
CREATE OR REPLACE FUNCTION sp_traslado_folios_sin_adeudo(
    p_folio_de integer,
    p_folio_a integer,
    p_pagos_ids jsonb,
    p_usuario integer
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_axo integer;
    v_mes integer;
    v_dia integer;
    v_suma integer := 0;
    v_pago_id integer;
    v_uap integer;
BEGIN
    -- Validaciones
    IF p_folio_de IS NULL OR p_folio_a IS NULL OR p_pagos_ids IS NULL OR p_usuario IS NULL THEN
        RETURN QUERY SELECT false, 'Parámetros incompletos';
        RETURN;
    END IF;
    IF p_folio_de = p_folio_a THEN
        RETURN QUERY SELECT false, 'Los folios no deben ser iguales';
        RETURN;
    END IF;
    -- Procesar cada pago seleccionado
    FOR v_pago_id IN SELECT jsonb_array_elements_text(p_pagos_ids)::integer LOOP
        -- Actualizar ta_13_adeudosrcm: poner id_pago=null, vigencia='V', fecha_mov=now()
        UPDATE ta_13_adeudosrcm
        SET id_pago = NULL, vigencia = 'V', fecha_mov = now()
        WHERE control_rcm = p_folio_de
          AND id_pago = v_pago_id;
        -- Actualizar ta_13_pagosrcm: cambiar datos al folio destino
        UPDATE ta_13_pagosrcm
        SET cementerio = (SELECT cementerio FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            clase = (SELECT clase FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            clase_alfa = (SELECT clase_alfa FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            seccion = (SELECT seccion FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            seccion_alfa = (SELECT seccion_alfa FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            linea = (SELECT linea FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            linea_alfa = (SELECT linea_alfa FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            fosa = (SELECT fosa FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            fosa_alfa = (SELECT fosa_alfa FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            control_rcm = p_folio_a,
            usuario = p_usuario,
            fecha_mov = now()
        WHERE control_id = v_pago_id;
        v_suma := v_suma + 1;
    END LOOP;
    -- Actualizar axo_pagado en ta_13_datosrcm para folio destino
    SELECT EXTRACT(YEAR FROM now()) INTO v_axo;
    -- UAP para folio destino
    SELECT COALESCE(MAX(axo_pago_hasta), 0) INTO v_uap FROM ta_13_pagosrcm WHERE control_rcm = p_folio_a;
    IF v_uap = 0 THEN
        v_uap := v_axo - 5;
    END IF;
    UPDATE ta_13_datosrcm SET axo_pagado = v_uap WHERE control_rcm = p_folio_a;
    -- UAP para folio origen
    SELECT COALESCE(MAX(axo_pago_hasta), 0) INTO v_uap FROM ta_13_pagosrcm WHERE control_rcm = p_folio_de;
    IF v_uap = 0 THEN
        v_uap := v_axo - 5;
    END IF;
    UPDATE ta_13_datosrcm SET axo_pagado = v_uap WHERE control_rcm = p_folio_de;
    IF v_suma > 0 THEN
        RETURN QUERY SELECT true, 'Los registros se han trasladado';
    ELSE
        RETURN QUERY SELECT false, 'No se seleccionó ningún registro a trasladar';
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION sp_traslados_buscar_pagos_origen(
    p_cementerio VARCHAR,
    p_clase INTEGER,
    p_clase_alfa VARCHAR,
    p_seccion INTEGER,
    p_seccion_alfa VARCHAR,
    p_linea INTEGER,
    p_linea_alfa VARCHAR,
    p_fosa INTEGER,
    p_fosa_alfa VARCHAR
)
RETURNS TABLE (
    control_id INTEGER,
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase INTEGER,
    clase_alfa VARCHAR,
    seccion INTEGER,
    seccion_alfa VARCHAR,
    linea INTEGER,
    linea_alfa VARCHAR,
    fosa INTEGER,
    fosa_alfa VARCHAR,
    fecing DATE,
    importe_anual NUMERIC,
    vigencia VARCHAR,
    usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT control_id, control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, fecing, importe_anual, vigencia, usuario
    FROM ta_13_pagosrcm
    WHERE cementerio = p_cementerio
      AND clase = p_clase
      AND (clase_alfa = p_clase_alfa OR (p_clase_alfa IS NULL OR p_clase_alfa = ''))
      AND seccion = p_seccion
      AND (seccion_alfa = p_seccion_alfa OR (p_seccion_alfa IS NULL OR p_seccion_alfa = ''))
      AND linea = p_linea
      AND (linea_alfa = p_linea_alfa OR (p_linea_alfa IS NULL OR p_linea_alfa = ''))
      AND fosa = p_fosa
      AND (fosa_alfa = p_fosa_alfa OR (p_fosa_alfa IS NULL OR p_fosa_alfa = ''));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_traslados_buscar_pagos_destino(
    p_cementerio VARCHAR,
    p_clase INTEGER,
    p_clase_alfa VARCHAR,
    p_seccion INTEGER,
    p_seccion_alfa VARCHAR,
    p_linea INTEGER,
    p_linea_alfa VARCHAR,
    p_fosa INTEGER,
    p_fosa_alfa VARCHAR
)
RETURNS TABLE (
    control_id INTEGER,
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase INTEGER,
    clase_alfa VARCHAR,
    seccion INTEGER,
    seccion_alfa VARCHAR,
    linea INTEGER,
    linea_alfa VARCHAR,
    fosa INTEGER,
    fosa_alfa VARCHAR,
    fecing DATE,
    importe_anual NUMERIC,
    vigencia VARCHAR,
    usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT control_id, control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, fecing, importe_anual, vigencia, usuario
    FROM ta_13_pagosrcm
    WHERE cementerio = p_cementerio
      AND clase = p_clase
      AND (clase_alfa = p_clase_alfa OR (p_clase_alfa IS NULL OR p_clase_alfa = ''))
      AND seccion = p_seccion
      AND (seccion_alfa = p_seccion_alfa OR (p_seccion_alfa IS NULL OR p_seccion_alfa = ''))
      AND linea = p_linea
      AND (linea_alfa = p_linea_alfa OR (p_linea_alfa IS NULL OR p_linea_alfa = ''))
      AND fosa = p_fosa
      AND (fosa_alfa = p_fosa_alfa OR (p_fosa_alfa IS NULL OR p_fosa_alfa = ''));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_traslados_trasladar_pagos(
    p_origen_control_id INTEGER,
    p_destino_cementerio VARCHAR,
    p_destino_clase INTEGER,
    p_destino_clase_alfa VARCHAR,
    p_destino_seccion INTEGER,
    p_destino_seccion_alfa VARCHAR,
    p_destino_linea INTEGER,
    p_destino_linea_alfa VARCHAR,
    p_destino_fosa INTEGER,
    p_destino_fosa_alfa VARCHAR,
    p_destino_control_rcm INTEGER,
    p_usuario INTEGER
) RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_axo INTEGER;
    v_uap INTEGER;
BEGIN
    -- Actualizar pagos
    UPDATE ta_13_pagosrcm
    SET cementerio = p_destino_cementerio,
        clase = p_destino_clase,
        clase_alfa = COALESCE(p_destino_clase_alfa, ''),
        seccion = p_destino_seccion,
        seccion_alfa = COALESCE(p_destino_seccion_alfa, ''),
        linea = p_destino_linea,
        linea_alfa = COALESCE(p_destino_linea_alfa, ''),
        fosa = p_destino_fosa,
        fosa_alfa = COALESCE(p_destino_fosa_alfa, ''),
        control_rcm = p_destino_control_rcm,
        usuario = p_usuario,
        fecha_mov = CURRENT_DATE
    WHERE control_id = p_origen_control_id;

    -- Actualizar axo_pagado en datosrcm destino
    SELECT EXTRACT(YEAR FROM CURRENT_DATE) INTO v_axo;
    SELECT MAX(axo_pago_hasta) INTO v_uap FROM ta_13_pagosrcm WHERE control_rcm = p_destino_control_rcm;
    IF v_uap IS NULL OR v_uap = 0 THEN
        v_uap := v_axo - 5;
    END IF;
    UPDATE ta_13_datosrcm SET axo_pagado = v_uap WHERE control_rcm = p_destino_control_rcm;

    -- Actualizar axo_pagado en datosrcm origen (opcional, según reglas)
    -- SELECT MAX(axo_pago_hasta) INTO v_uap FROM ta_13_pagosrcm WHERE control_rcm = (SELECT control_rcm FROM ta_13_pagosrcm WHERE control_id = p_origen_control_id);
    -- IF v_uap IS NULL OR v_uap = 0 THEN
    --     v_uap := v_axo - 5;
    -- END IF;
    -- UPDATE ta_13_datosrcm SET axo_pagado = v_uap WHERE control_rcm = (SELECT control_rcm FROM ta_13_pagosrcm WHERE control_id = p_origen_control_id);

    RETURN QUERY SELECT TRUE, 'Traslado realizado correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error al trasladar pagos: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;