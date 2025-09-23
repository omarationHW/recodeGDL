CREATE OR REPLACE FUNCTION sp_baja_anuncio_buscar(p_anuncio INTEGER)
RETURNS TABLE (
  id_anuncio INTEGER,
  id_licencia INTEGER,
  fecha_otorgamiento DATE,
  propietario TEXT,
  propietarionvo TEXT,
  medidas1 NUMERIC,
  medidas2 NUMERIC,
  area_anuncio NUMERIC,
  ubicacion TEXT,
  numext_ubic TEXT,
  letraext_ubic TEXT,
  numint_ubic TEXT,
  letraint_ubic TEXT,
  telefono_prop TEXT,
  vigente TEXT,
  adeudos JSONB
) AS $$
DECLARE
  v_adeudos JSONB;
BEGIN
  SELECT a.id_anuncio, a.id_licencia, a.fecha_otorgamiento, l.propietario,
         TRIM(COALESCE(l.primer_ap,'') || ' ' || COALESCE(l.segundo_ap,'') || ' ' || l.propietario) AS propietarionvo,
         a.medidas1, a.medidas2, a.area_anuncio, a.ubicacion, a.numext_ubic, a.letraext_ubic, a.numint_ubic, a.letraint_ubic,
         l.telefono_prop, a.vigente,
         (
           SELECT jsonb_agg(row_to_json(s)) FROM (
             SELECT axo, saldo FROM detsal_lic WHERE id_anuncio = a.id_anuncio AND cvepago = 0
           ) s
         ) AS adeudos
  INTO id_anuncio, id_licencia, fecha_otorgamiento, propietario, propietarionvo, medidas1, medidas2, area_anuncio, ubicacion, numext_ubic, letraext_ubic, numint_ubic, letraint_ubic, telefono_prop, vigente, v_adeudos
  FROM anuncios a
  LEFT JOIN licencias l ON l.id_licencia = a.id_licencia
  WHERE a.anuncio = p_anuncio;
  adeudos := COALESCE(v_adeudos, '[]'::jsonb);
  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_baja_anuncio_verificar_permisos(p_usuario TEXT)
RETURNS TABLE (
  nivel SMALLINT,
  cvedependencia INTEGER,
  cvedepto INTEGER
) AS $$
BEGIN
  RETURN QUERY
    SELECT u.nivel, d.cvedependencia, u.cvedepto
    FROM usuarios u
    JOIN deptos d ON d.cvedepto = u.cvedepto
    WHERE u.usuario = p_usuario;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_baja_anuncio_procesar(
  p_anuncio INTEGER,
  p_motivo TEXT,
  p_axo_baja INTEGER,
  p_folio_baja INTEGER,
  p_usuario TEXT,
  p_baja_error BOOLEAN,
  p_baja_tiempo BOOLEAN,
  p_fecha TIMESTAMP
) RETURNS TABLE (result TEXT, status TEXT) AS $$
DECLARE
  v_vigente TEXT;
  v_id_licencia INTEGER;
BEGIN
  SELECT vigente, id_licencia INTO v_vigente, v_id_licencia FROM anuncios WHERE anuncio = p_anuncio;
  IF v_vigente IS NULL OR v_vigente <> 'V' THEN
    RETURN QUERY SELECT 'El anuncio ya se encuentra cancelado.', 'error';
    RETURN;
  END IF;
  -- Cancelar el anuncio
  UPDATE anuncios SET
    vigente = 'C',
    fecha_baja = p_fecha,
    axo_baja = p_axo_baja,
    folio_baja = p_folio_baja,
    espubic = p_motivo
  WHERE anuncio = p_anuncio;
  -- Cancelar adeudos
  UPDATE detsal_lic SET cvepago = 999999 WHERE id_anuncio = p_anuncio AND cvepago = 0;
  -- Recalcular saldo de la licencia
  PERFORM calc_sdosl(v_id_licencia);
  RETURN QUERY SELECT 'Baja realizada correctamente', 'ok';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_baja_licencia(
    p_id_licencia INTEGER,
    p_motivo TEXT,
    p_anio INTEGER DEFAULT NULL,
    p_folio INTEGER DEFAULT NULL,
    p_baja_error BOOLEAN DEFAULT FALSE,
    p_usuario TEXT
) RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_licencia RECORD;
    v_anuncio RECORD;
BEGIN
    SELECT * INTO v_licencia FROM licencias WHERE id_licencia = p_id_licencia;
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Licencia no encontrada.';
        RETURN;
    END IF;
    IF v_licencia.vigente <> 'V' THEN
        RETURN QUERY SELECT FALSE, 'La licencia ya está dada de baja o cancelada.';
        RETURN;
    END IF;
    IF v_licencia.bloqueado > 0 AND v_licencia.bloqueado < 5 THEN
        RETURN QUERY SELECT FALSE, 'La licencia está bloqueada.';
        RETURN;
    END IF;
    -- Verificar anuncios bloqueados
    FOR v_anuncio IN SELECT * FROM anuncios WHERE id_licencia = p_id_licencia AND vigente = 'V' LOOP
        IF v_anuncio.bloqueado > 0 THEN
            RETURN QUERY SELECT FALSE, 'No se puede dar de baja la licencia. El anuncio ' || v_anuncio.anuncio || ' está bloqueado.';
            RETURN;
        END IF;
    END LOOP;
    -- Cancelar adeudos de la licencia
    UPDATE detsal_lic SET cvepago = 999999 WHERE id_licencia = p_id_licencia AND (id_anuncio IS NULL OR id_anuncio = 0) AND cvepago = 0;
    -- Dar de baja anuncios y sus adeudos
    FOR v_anuncio IN SELECT * FROM anuncios WHERE id_licencia = p_id_licencia AND vigente = 'V' LOOP
        UPDATE detsal_lic SET cvepago = 999999 WHERE id_anuncio = v_anuncio.id_anuncio AND cvepago = 0;
        UPDATE anuncios SET vigente = 'C', fecha_baja = CURRENT_DATE, axo_baja = p_anio, folio_baja = p_folio, espubic = p_motivo WHERE id_anuncio = v_anuncio.id_anuncio;
    END LOOP;
    -- Recalcular saldo de la licencia (puede ser otro SP)
    -- Aquí se asume que existe un SP llamado calc_sdosl
    PERFORM calc_sdosl(p_id_licencia);
    -- Dar de baja la licencia
    UPDATE licencias SET vigente = 'C', fecha_baja = CURRENT_DATE, axo_baja = p_anio, folio_baja = p_folio, espubic = p_motivo WHERE id_licencia = p_id_licencia;
    -- Registrar bitácora (opcional)
    INSERT INTO lic_bajas_bitacora(id_licencia, usuario, fecha, motivo, anio, folio, baja_error)
    VALUES (p_id_licencia, p_usuario, CURRENT_TIMESTAMP, p_motivo, p_anio, p_folio, p_baja_error);
    RETURN QUERY SELECT TRUE, 'Licencia dada de baja correctamente.';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calc_sdosl(p_id_licencia INTEGER) RETURNS VOID AS $$
BEGIN
    -- Lógica de recálculo de saldos (simplificada)
    UPDATE saldos_lic SET total = (
        COALESCE(derechos,0) + COALESCE(anuncios,0) + COALESCE(recargos,0) + COALESCE(gastos,0) + COALESCE(multas,0) + COALESCE(formas,0)
    ) WHERE id_licencia = p_id_licencia;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION bloquear_anuncio(
    id_anuncio INTEGER,
    observa TEXT,
    usuario TEXT
) RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_bloqueado INTEGER;
BEGIN
    SELECT bloqueado INTO v_bloqueado FROM anuncios WHERE id_anuncio = bloquear_anuncio.id_anuncio;
    IF v_bloqueado IS NULL THEN
        RETURN QUERY SELECT FALSE, 'No existe el anuncio';
        RETURN;
    END IF;
    IF v_bloqueado > 0 THEN
        RETURN QUERY SELECT FALSE, 'El anuncio ya está bloqueado, no se puede bloquear';
        RETURN;
    END IF;
    -- Actualiza el estado del anuncio
    UPDATE anuncios SET bloqueado = 1 WHERE id_anuncio = bloquear_anuncio.id_anuncio;
    -- Cancela el último registro vigente
    UPDATE bloqueo SET vigente = 'C' WHERE id_anuncio = bloquear_anuncio.id_anuncio AND vigente = 'V';
    -- Registra el nuevo bloqueo
    INSERT INTO bloqueo (bloqueado, id_anuncio, observa, capturista, fecha_mov, vigente)
    VALUES (1, bloquear_anuncio.id_anuncio, observa, usuario, CURRENT_DATE, 'V');
    RETURN QUERY SELECT TRUE, 'Anuncio bloqueado correctamente';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION desbloquear_anuncio(
    id_anuncio INTEGER,
    observa TEXT,
    usuario TEXT
) RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_bloqueado INTEGER;
BEGIN
    SELECT bloqueado INTO v_bloqueado FROM anuncios WHERE id_anuncio = desbloquear_anuncio.id_anuncio;
    IF v_bloqueado IS NULL THEN
        RETURN QUERY SELECT FALSE, 'No existe el anuncio';
        RETURN;
    END IF;
    IF v_bloqueado = 0 THEN
        RETURN QUERY SELECT FALSE, 'El anuncio no está bloqueado, no se puede desbloquear';
        RETURN;
    END IF;
    -- Actualiza el estado del anuncio
    UPDATE anuncios SET bloqueado = 0 WHERE id_anuncio = desbloquear_anuncio.id_anuncio;
    -- Cancela el último registro vigente
    UPDATE bloqueo SET vigente = 'C' WHERE id_anuncio = desbloquear_anuncio.id_anuncio AND vigente = 'V';
    -- Registra el nuevo desbloqueo
    INSERT INTO bloqueo (bloqueado, id_anuncio, observa, capturista, fecha_mov, vigente)
    VALUES (0, desbloquear_anuncio.id_anuncio, observa, usuario, CURRENT_DATE, 'V');
    RETURN QUERY SELECT TRUE, 'Anuncio desbloqueado correctamente';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_bloquear_licencia(
    p_id_licencia INTEGER,
    p_tipo_bloqueo INTEGER,
    p_motivo TEXT,
    p_usuario TEXT
) RETURNS VOID AS $$
DECLARE
    v_calle TEXT;
    v_cvecalle INTEGER;
    v_noext TEXT;
    v_noint TEXT;
    v_letext TEXT;
    v_letint TEXT;
    v_bloqueos INT;
BEGIN
    -- Actualiza la licencia
    UPDATE licencias SET bloqueado = p_tipo_bloqueo WHERE id_licencia = p_id_licencia;
    -- Cancela bloqueos vigentes del mismo tipo
    UPDATE bloqueo SET vigente = 'C' WHERE id_licencia = p_id_licencia AND vigente = 'V' AND bloqueado = p_tipo_bloqueo;
    -- Inserta el nuevo bloqueo
    INSERT INTO bloqueo (bloqueado, id_licencia, observa, capturista, fecha_mov, vigente)
    VALUES (p_tipo_bloqueo, p_id_licencia, p_motivo, p_usuario, CURRENT_DATE, 'V');
    -- Si el tipo de bloqueo no es 'responsiva', bloquea domicilio si no hay otro bloqueo activo
    IF p_tipo_bloqueo <> 5 THEN
        SELECT ubicacion, cvecalle, numext_ubic::TEXT, numint_ubic::TEXT, letraext_ubic, letraint_ubic
        INTO v_calle, v_cvecalle, v_noext, v_noint, v_letext, v_letint
        FROM licencias WHERE id_licencia = p_id_licencia;
        SELECT COUNT(*) INTO v_bloqueos FROM bloqueo WHERE id_licencia = p_id_licencia AND vigente = 'V' AND bloqueado > 0;
        IF v_bloqueos = 1 THEN
            INSERT INTO bloqueo_dom (calle, cvecalle, num_ext, let_ext, num_int, let_int, observacion, vig, fecha, capturista)
            VALUES (v_calle, v_cvecalle, v_noext, v_letext, v_noint, v_letint, p_motivo, 'V', CURRENT_DATE, p_usuario);
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_desbloquear_licencia(
    p_id_licencia INTEGER,
    p_tipo_bloqueo INTEGER,
    p_motivo TEXT,
    p_usuario TEXT
) RETURNS VOID AS $$
DECLARE
    v_calle TEXT;
    v_noext TEXT;
    v_letext TEXT;
    v_noint TEXT;
    v_letint TEXT;
    v_cvecalle INTEGER;
    v_bloqueos INT;
    v_ultimo_bloqueo INTEGER;
BEGIN
    -- Cancela el último bloqueo vigente de ese tipo
    UPDATE bloqueo SET vigente = 'C' WHERE id_licencia = p_id_licencia AND bloqueado = p_tipo_bloqueo AND vigente = 'V';
    -- Verifica si quedan bloqueos activos
    SELECT COUNT(*) INTO v_bloqueos FROM bloqueo WHERE id_licencia = p_id_licencia AND vigente = 'V' AND bloqueado > 0;
    IF v_bloqueos = 0 THEN
        UPDATE licencias SET bloqueado = 0 WHERE id_licencia = p_id_licencia;
    ELSE
        SELECT bloqueado INTO v_ultimo_bloqueo FROM bloqueo WHERE id_licencia = p_id_licencia AND vigente = 'V' ORDER BY fecha_mov DESC LIMIT 1;
        UPDATE licencias SET bloqueado = v_ultimo_bloqueo WHERE id_licencia = p_id_licencia;
    END IF;
    -- Inserta registro de desbloqueo
    INSERT INTO bloqueo (bloqueado, id_licencia, observa, capturista, fecha_mov, vigente)
    VALUES (0, p_id_licencia, p_motivo, p_usuario, CURRENT_DATE, 'V');
    -- Si no quedan bloqueos, elimina el domicilio bloqueado y guarda histórico
    IF v_bloqueos = 0 THEN
        SELECT ubicacion, cvecalle, numext_ubic::TEXT, letraext_ubic, numint_ubic::TEXT, letraint_ubic
        INTO v_calle, v_cvecalle, v_noext, v_letext, v_noint, v_letint
        FROM licencias WHERE id_licencia = p_id_licencia;
        -- Guarda histórico
        INSERT INTO h_bloqueo_dom SELECT *, CURRENT_DATE, p_motivo, 'EL', p_usuario FROM bloqueo_dom WHERE calle = v_calle AND (num_ext = v_noext OR v_noext IS NULL) AND (let_ext = v_letext OR v_letext IS NULL) AND (num_int = v_noint OR v_noint IS NULL) AND (let_int = v_letint OR v_letint IS NULL);
        -- Elimina
        DELETE FROM bloqueo_dom WHERE calle = v_calle AND (num_ext = v_noext OR v_noext IS NULL) AND (let_ext = v_letext OR v_letext IS NULL) AND (num_int = v_noint OR v_noint IS NULL) AND (let_int = v_letint OR v_letint IS NULL);
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION bloquear_tramite(p_id_tramite integer, p_observa varchar, p_capturista varchar)
RETURNS TABLE (success boolean, message text) AS $$
DECLARE
    v_count integer;
BEGIN
    -- Actualizar campo bloqueado en tramites
    UPDATE tramites SET bloqueado = 1 WHERE id_tramite = p_id_tramite;
    -- Cancelar último bloqueo vigente
    UPDATE bloqueo SET vigente = 'C' WHERE id_tramite = p_id_tramite AND vigente = 'V';
    -- Insertar nuevo bloqueo
    INSERT INTO bloqueo (bloqueado, id_tramite, observa, capturista, fecha_mov, vigente)
    VALUES (1, p_id_tramite, p_observa, p_capturista, CURRENT_DATE, 'V');
    RETURN QUERY SELECT true, 'Trámite bloqueado correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, 'Error al bloquear trámite: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION desbloquear_tramite(p_id_tramite integer, p_observa varchar, p_capturista varchar)
RETURNS TABLE (success boolean, message text) AS $$
DECLARE
    v_count integer;
BEGIN
    -- Actualizar campo bloqueado en tramites
    UPDATE tramites SET bloqueado = 0 WHERE id_tramite = p_id_tramite;
    -- Cancelar último bloqueo vigente
    UPDATE bloqueo SET vigente = 'C' WHERE id_tramite = p_id_tramite AND vigente = 'V';
    -- Insertar nuevo desbloqueo
    INSERT INTO bloqueo (bloqueado, id_tramite, observa, capturista, fecha_mov, vigente)
    VALUES (0, p_id_tramite, p_observa, p_capturista, CURRENT_DATE, 'V');
    RETURN QUERY SELECT true, 'Trámite desbloqueado correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, 'Error al desbloquear trámite: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_add_bloqueo_rfc(
    p_rfc VARCHAR(13),
    p_id_tramite INTEGER,
    p_licencia INTEGER,
    p_observacion VARCHAR(255),
    p_capturista VARCHAR(10)
) RETURNS VOID AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT 1 INTO v_exists FROM bloqueo_rfc_lic WHERE rfc = p_rfc AND vig = 'V' LIMIT 1;
    IF v_exists IS NOT NULL THEN
        RAISE EXCEPTION 'Ya existe un bloqueo vigente para este RFC';
    END IF;
    INSERT INTO bloqueo_rfc_lic (rfc, id_tramite, licencia, hora, vig, observacion, capturista)
    VALUES (p_rfc, p_id_tramite, p_licencia, now(), 'V', p_observacion, p_capturista);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_edit_bloqueo_rfc(
    p_rfc VARCHAR(13),
    p_observacion VARCHAR(255),
    p_capturista VARCHAR(10)
) RETURNS INTEGER AS $$
DECLARE
    v_updated INTEGER;
BEGIN
    UPDATE bloqueo_rfc_lic SET observacion = p_observacion, hora = now(), capturista = p_capturista
    WHERE rfc = p_rfc AND vig = 'V';
    GET DIAGNOSTICS v_updated = ROW_COUNT;
    RETURN v_updated;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_desbloquear_rfc(
    p_rfc VARCHAR(13),
    p_observacion VARCHAR(255),
    p_capturista VARCHAR(10)
) RETURNS INTEGER AS $$
DECLARE
    v_updated INTEGER;
BEGIN
    UPDATE bloqueo_rfc_lic SET observacion = p_observacion, vig = 'C', hora = now(), capturista = p_capturista
    WHERE rfc = p_rfc AND vig = 'V';
    GET DIAGNOSTICS v_updated = ROW_COUNT;
    RETURN v_updated;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cancel_tramite(p_id_tramite INTEGER, p_motivo TEXT)
RETURNS TABLE (
    result TEXT,
    new_status VARCHAR(1)
) AS $$
DECLARE
    v_estatus VARCHAR(1);
    v_motivo TEXT;
BEGIN
    SELECT estatus INTO v_estatus FROM tramites WHERE id_tramite = p_id_tramite;
    IF v_estatus IS NULL THEN
        RETURN QUERY SELECT 'Trámite no encontrado'::TEXT, NULL::VARCHAR;
        RETURN;
    END IF;
    IF v_estatus = 'C' THEN
        RETURN QUERY SELECT 'El trámite ya se encuentra cancelado'::TEXT, v_estatus;
        RETURN;
    END IF;
    IF v_estatus = 'A' THEN
        RETURN QUERY SELECT 'El trámite ya se encuentra aprobado. No se puede cancelar.'::TEXT, v_estatus;
        RETURN;
    END IF;
    v_motivo := 'CANCELADO POR PADRON Y LICENCIAS.' || chr(13) || chr(10) || p_motivo;
    UPDATE tramites SET estatus = 'C', espubic = v_motivo WHERE id_tramite = p_id_tramite;
    RETURN QUERY SELECT 'Trámite cancelado exitosamente'::TEXT, 'C'::VARCHAR;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_predio_by_clave_catastral(p_cvecatnva VARCHAR, p_subpredio INTEGER)
RETURNS TABLE(
    cvecatnva VARCHAR,
    subpredio INTEGER,
    cuenta INTEGER,
    recaud INTEGER,
    urbrus VARCHAR,
    propietario VARCHAR,
    ubicacion VARCHAR,
    colonia VARCHAR,
    noexterior VARCHAR,
    interior VARCHAR,
    supterr NUMERIC,
    supconst NUMERIC,
    valorterr NUMERIC,
    valorconst NUMERIC,
    valfiscal NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cvecatnva, c.subpredio, c.cuenta, c.recaud, c.urbrus, p.nombre_completo AS propietario,
           u.calle AS ubicacion, u.colonia, u.noexterior, u.interior, a.supterr, a.supconst, a.valorterr, a.valorconst, a.valfiscal
    FROM convcta c
    LEFT JOIN catastro a ON a.cvecuenta = c.cvecuenta
    LEFT JOIN ubicacion u ON u.cvecuenta = c.cvecuenta
    LEFT JOIN (
        SELECT cvecuenta, MAX(CONCAT(paterno, ' ', materno, ' ', nombres)) AS nombre_completo
        FROM contrib
        GROUP BY cvecuenta
    ) p ON p.cvecuenta = c.cvecuenta
    WHERE c.cvecatnva = p_cvecatnva AND c.subpredio = p_subpredio AND c.vigente = 'V';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_predio_by_cuenta(p_recaud INTEGER, p_urbrus VARCHAR, p_cuenta INTEGER)
RETURNS TABLE(
    cvecatnva VARCHAR,
    subpredio INTEGER,
    cuenta INTEGER,
    recaud INTEGER,
    urbrus VARCHAR,
    propietario VARCHAR,
    ubicacion VARCHAR,
    colonia VARCHAR,
    noexterior VARCHAR,
    interior VARCHAR,
    supterr NUMERIC,
    supconst NUMERIC,
    valorterr NUMERIC,
    valorconst NUMERIC,
    valfiscal NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cvecatnva, c.subpredio, c.cuenta, c.recaud, c.urbrus, p.nombre_completo AS propietario,
           u.calle AS ubicacion, u.colonia, u.noexterior, u.interior, a.supterr, a.supconst, a.valorterr, a.valorconst, a.valfiscal
    FROM convcta c
    LEFT JOIN catastro a ON a.cvecuenta = c.cvecuenta
    LEFT JOIN ubicacion u ON u.cvecuenta = c.cvecuenta
    LEFT JOIN (
        SELECT cvecuenta, MAX(CONCAT(paterno, ' ', materno, ' ', nombres)) AS nombre_completo
        FROM contrib
        GROUP BY cvecuenta
    ) p ON p.cvecuenta = c.cvecuenta
    WHERE c.recaud = p_recaud AND c.urbrus = p_urbrus AND c.cuenta = p_cuenta AND c.vigente = 'V';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION save_cargadatos(p_cvecatnva TEXT, p_data JSON)
RETURNS JSON AS $$
DECLARE
  -- Aquí se haría el upsert de los datos principales
  result JSON;
BEGIN
  -- Ejemplo: actualizar propietario
  UPDATE contribuyente SET nombre_completo = p_data->>'nombre_completo', rfc = p_data->>'rfc'
  WHERE cvecatnva = p_cvecatnva;
  -- Otros updates según la estructura de p_data
  result := json_build_object('updated', true);
  RETURN result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_upload_image(
  p_tramite_id integer,
  p_document_type_id integer,
  p_id_licencia integer,
  p_file bytea,
  p_capturista varchar
) RETURNS integer AS $$
DECLARE
  new_id integer;
BEGIN
  INSERT INTO digital_docs (cvedocto, id_tramite, id_licencia, imagen, feccap, capturista)
  VALUES (p_document_type_id, p_tramite_id, p_id_licencia, p_file, NOW(), p_capturista)
  RETURNING id_imagen INTO new_id;

  INSERT INTO tramitedocs (id_tramite, id_imagen, id_licencia, cvedocto)
  VALUES (p_tramite_id, new_id, p_id_licencia, p_document_type_id);

  RETURN new_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_delete_image(p_id_imagen integer)
RETURNS void AS $$
BEGIN
  DELETE FROM tramitedocs WHERE id_imagen = p_id_imagen;
  DELETE FROM digital_docs WHERE id_imagen = p_id_imagen;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_cartografia_predial(p_cvecuenta INTEGER)
RETURNS TABLE (
    cvecuenta INTEGER,
    cvemunicipio SMALLINT,
    recaud SMALLINT,
    urbrus VARCHAR(1),
    cuenta INTEGER,
    digver SMALLINT,
    zonaanter SMALLINT,
    manzanter SMALLINT,
    loteanter SMALLINT,
    cvecatnva VARCHAR(11),
    subpredio SMALLINT,
    crec SMALLINT,
    cur VARCHAR(1),
    ccta INTEGER,
    cip VARCHAR(9),
    vigente VARCHAR(1),
    cvelocalidad SMALLINT,
    coordenada_x DOUBLE PRECISION,
    coordenada_y DOUBLE PRECISION,
    visor_url TEXT
) AS $$
DECLARE
    v_cvecatnva VARCHAR(11);
    v_url TEXT;
BEGIN
    SELECT * INTO STRICT cvecuenta, cvemunicipio, recaud, urbrus, cuenta, digver, zonaanter, manzanter, loteanter, cvecatnva, subpredio, crec, cur, ccta, cip, vigente, cvelocalidad, coordenada_x, coordenada_y
    FROM convcta WHERE cvecuenta = p_cvecuenta;
    v_cvecatnva := cvecatnva;
    v_url := 'http://192.168.4.20:8080/Visor/index.html#user=123&session=se123&clavePredi0=' || v_cvecatnva;
    visor_url := v_url;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION catalogo_actividades_create(
  id_giro INTEGER,
  descripcion TEXT,
  observaciones TEXT,
  vigente CHAR(1),
  usuario_alta VARCHAR(50)
) RETURNS TABLE (id_actividad INTEGER) AS $$
DECLARE
  new_id INTEGER;
BEGIN
  INSERT INTO c_actividades_lic (id_giro, descripcion, observaciones, vigente, fecha_alta, usuario_alta)
  VALUES (id_giro, descripcion, observaciones, vigente, NOW(), usuario_alta)
  RETURNING id_actividad INTO new_id;
  RETURN QUERY SELECT new_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION catalogo_actividades_update(
  id INTEGER,
  id_giro INTEGER,
  descripcion TEXT,
  observaciones TEXT,
  vigente CHAR(1),
  usuario_mod VARCHAR(50)
) RETURNS TABLE (id_actividad INTEGER) AS $$
BEGIN
  UPDATE c_actividades_lic
  SET id_giro = id_giro,
      descripcion = descripcion,
      observaciones = observaciones,
      vigente = vigente,
      fecha_alta = CASE WHEN vigente = 'V' THEN NOW() ELSE fecha_alta END,
      usuario_alta = CASE WHEN vigente = 'V' THEN usuario_mod ELSE usuario_alta END,
      fecha_baja = CASE WHEN vigente = 'C' THEN NOW() ELSE NULL END,
      usuario_baja = CASE WHEN vigente = 'C' THEN usuario_mod ELSE NULL END
  WHERE id_actividad = id;
  RETURN QUERY SELECT id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION catalogo_actividades_delete(
  id INTEGER,
  usuario_baja VARCHAR(50),
  motivo_baja TEXT
) RETURNS TABLE (id_actividad INTEGER) AS $$
BEGIN
  UPDATE c_actividades_lic
  SET vigente = 'C', fecha_baja = NOW(), usuario_baja = usuario_baja, motivo_baja = motivo_baja
  WHERE id_actividad = id;
  RETURN QUERY SELECT id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cat_requisitos_create(p_descripcion varchar)
RETURNS TABLE(req integer, descripcion varchar) AS $$
DECLARE
  new_req integer;
BEGIN
  SELECT COALESCE(MAX(req),0)+1 INTO new_req FROM c_girosreq;
  INSERT INTO c_girosreq(req, descripcion) VALUES (new_req, p_descripcion);
  RETURN QUERY SELECT req, descripcion FROM c_girosreq WHERE req = new_req;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cat_requisitos_update(p_req integer, p_descripcion varchar)
RETURNS TABLE(req integer, descripcion varchar) AS $$
BEGIN
  UPDATE c_girosreq SET descripcion = p_descripcion WHERE req = p_req;
  RETURN QUERY SELECT req, descripcion FROM c_girosreq WHERE req = p_req;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cat_requisitos_delete(p_req integer)
RETURNS TABLE(req integer, descripcion varchar) AS $$
DECLARE
  old_desc varchar;
BEGIN
  SELECT descripcion INTO old_desc FROM c_girosreq WHERE req = p_req;
  DELETE FROM c_girosreq WHERE req = p_req;
  RETURN QUERY SELECT p_req, old_desc;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_certificaciones_create(p_tipo TEXT, p_id_licencia INT, p_observacion TEXT, p_partidapago TEXT, p_capturista TEXT)
RETURNS INT AS $$
DECLARE
  new_folio INT;
  new_id INT;
BEGIN
  SELECT certificacion INTO new_folio FROM parametros_lic;
  new_folio := new_folio + 1;
  UPDATE parametros_lic SET certificacion = new_folio;
  INSERT INTO certificaciones(tipo, id_licencia, axo, folio, vigente, observacion, partidapago, feccap, capturista)
  VALUES (p_tipo, p_id_licencia, EXTRACT(YEAR FROM CURRENT_DATE), new_folio, 'V', p_observacion, p_partidapago, CURRENT_DATE, p_capturista)
  RETURNING id INTO new_id;
  RETURN new_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_certificaciones_update(p_id INT, p_observacion TEXT, p_partidapago TEXT, p_capturista TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE certificaciones SET observacion = p_observacion, partidapago = p_partidapago, capturista = p_capturista WHERE id = p_id;
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_certificaciones_cancel(p_id INT, p_motivo TEXT, p_capturista TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE certificaciones SET vigente = 'C', observacion = p_motivo, capturista = p_capturista WHERE id = p_id;
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_solicnooficial_create(
    p_propietario VARCHAR,
    p_actividad VARCHAR,
    p_ubicacion VARCHAR,
    p_zona SMALLINT,
    p_subzona SMALLINT,
    p_capturista VARCHAR,
    p_feccap DATE
) RETURNS TABLE(axo INT, folio INT, propietario VARCHAR, actividad VARCHAR, ubicacion VARCHAR, zona SMALLINT, subzona SMALLINT, vigente VARCHAR, feccap DATE, capturista VARCHAR) AS $$
DECLARE
    nvofolio INT;
    nvoaxo INT := EXTRACT(YEAR FROM CURRENT_DATE);
BEGIN
    -- Obtener el último folio del año
    SELECT COALESCE(MAX(folio), 0) + 1 INTO nvofolio FROM solicnooficial WHERE axo = nvoaxo;
    INSERT INTO solicnooficial(axo, folio, propietario, actividad, ubicacion, zona, subzona, vigente, feccap, capturista)
    VALUES (nvoaxo, nvofolio, p_propietario, p_actividad, p_ubicacion, p_zona, p_subzona, 'V', p_feccap, p_capturista)
    RETURNING *;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_solicnooficial_update(
    p_axo INT,
    p_folio INT,
    p_propietario VARCHAR,
    p_actividad VARCHAR,
    p_ubicacion VARCHAR,
    p_zona SMALLINT,
    p_subzona SMALLINT
) RETURNS TABLE(axo INT, folio INT, propietario VARCHAR, actividad VARCHAR, ubicacion VARCHAR, zona SMALLINT, subzona SMALLINT, vigente VARCHAR, feccap DATE, capturista VARCHAR) AS $$
BEGIN
    UPDATE solicnooficial
    SET propietario = COALESCE(p_propietario, propietario),
        actividad = COALESCE(p_actividad, actividad),
        ubicacion = COALESCE(p_ubicacion, ubicacion),
        zona = COALESCE(p_zona, zona),
        subzona = COALESCE(p_subzona, subzona)
    WHERE axo = p_axo AND folio = p_folio
    RETURNING *;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_solicnooficial_cancel(
    p_axo INT,
    p_folio INT
) RETURNS TABLE(axo INT, folio INT, vigente VARCHAR) AS $$
BEGIN
    UPDATE solicnooficial
    SET vigente = 'C'
    WHERE axo = p_axo AND folio = p_folio
    RETURNING axo, folio, vigente;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_bloquear_licencia(p_id_licencia integer, p_tipo_bloqueo integer, p_motivo varchar)
RETURNS void AS $$
BEGIN
  UPDATE licencias SET bloqueado = p_tipo_bloqueo WHERE id_licencia = p_id_licencia;
  INSERT INTO bloqueo (bloqueado, id_licencia, observa, vigente, fecha_mov, capturista)
    VALUES (p_tipo_bloqueo, p_id_licencia, p_motivo, 'V', now(), current_user);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_desbloquear_licencia(p_id_licencia integer, p_tipo_bloqueo integer, p_motivo varchar)
RETURNS void AS $$
BEGIN
  UPDATE bloqueo SET vigente = 'C' WHERE id_licencia = p_id_licencia AND bloqueado = p_tipo_bloqueo AND vigente = 'V';
  UPDATE licencias SET bloqueado = 0 WHERE id_licencia = p_id_licencia;
  INSERT INTO bloqueo (bloqueado, id_licencia, observa, vigente, fecha_mov, capturista)
    VALUES (0, p_id_licencia, p_motivo, 'V', now(), current_user);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cruces_localiza_calle(cvecalle1 INTEGER, cvecalle2 INTEGER)
RETURNS TABLE (
    tipo INTEGER,
    cvecalle INTEGER,
    cvepoblacion INTEGER,
    desvial INTEGER,
    calle VARCHAR(40),
    cvevig CHAR(1),
    anterior INTEGER,
    feccap DATE,
    capturista VARCHAR(10)
) AS $$
BEGIN
    IF cvecalle1 > 0 THEN
        RETURN QUERY
        SELECT 1 AS tipo, cvecalle, cvepoblacion, desvial, calle, cvevig, anterior, feccap, capturista
        FROM c_calles WHERE cvecalle = cvecalle1;
    END IF;
    IF cvecalle2 > 0 THEN
        RETURN QUERY
        SELECT 2 AS tipo, cvecalle, cvepoblacion, desvial, calle, cvevig, anterior, feccap, capturista
        FROM c_calles WHERE cvecalle = cvecalle2;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_add_inspeccion(p_id_tramite INT, p_id_dependencia INT, p_usuario TEXT)
RETURNS TEXT AS $$
DECLARE
  v_exists INT;
  v_id_revision INT;
  v_desc TEXT;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM revisiones WHERE id_tramite = p_id_tramite AND id_dependencia = p_id_dependencia AND estatus = 'V';
  IF v_exists > 0 THEN
    RETURN 'Ya existe esta inspección para el trámite';
  END IF;
  SELECT descripcion INTO v_desc FROM c_dependencias WHERE id_dependencia = p_id_dependencia;
  INSERT INTO revisiones (id_tramite, id_dependencia, fecha_inicio, estatus, descripcion)
    VALUES (p_id_tramite, p_id_dependencia, NOW(), 'V', v_desc)
    RETURNING id_revision INTO v_id_revision;
  INSERT INTO seg_revision (id_revision, estatus, feccap, usr_revisa)
    VALUES (v_id_revision, 'V', NOW(), p_usuario);
  RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_delete_inspeccion(p_id_tramite INT, p_id_dependencia INT)
RETURNS TEXT AS $$
DECLARE
  v_id_revision INT;
BEGIN
  SELECT id_revision INTO v_id_revision FROM revisiones WHERE id_tramite = p_id_tramite AND id_dependencia = p_id_dependencia AND estatus = 'V' LIMIT 1;
  IF v_id_revision IS NULL THEN
    RETURN 'No existe la inspección para eliminar';
  END IF;
  DELETE FROM seg_revision WHERE id_revision = v_id_revision;
  DELETE FROM revisiones WHERE id_revision = v_id_revision;
  RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dictamenusodesuelo_create(
  p_solicita VARCHAR,
  p_partidapago VARCHAR,
  p_observacion VARCHAR,
  p_domicilio VARCHAR,
  p_id_licencia INTEGER,
  p_capturista VARCHAR,
  p_tipo INTEGER,
  p_recaud INTEGER DEFAULT NULL,
  p_actividad VARCHAR DEFAULT NULL,
  p_propietario VARCHAR DEFAULT NULL,
  p_ubicacion VARCHAR DEFAULT NULL,
  p_numext_ubic VARCHAR DEFAULT NULL,
  p_letraext_ubic VARCHAR DEFAULT NULL,
  p_numint_ubic VARCHAR DEFAULT NULL,
  p_letraint_ubic VARCHAR DEFAULT NULL,
  p_sup_construida NUMERIC DEFAULT NULL,
  p_sup_autorizada NUMERIC DEFAULT NULL,
  p_num_cajones INTEGER DEFAULT NULL,
  p_num_empleados INTEGER DEFAULT NULL,
  p_vigente VARCHAR DEFAULT 'V',
  p_feccap DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE(axo INTEGER, folio INTEGER) AS $$
DECLARE
  nvo_folio INTEGER;
  nvo_axo INTEGER;
BEGIN
  nvo_axo := EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;
  -- Obtener folio actual
  SELECT constancia + 1 INTO nvo_folio FROM parametros LIMIT 1;
  -- Actualizar folio en parametros
  UPDATE parametros SET constancia = nvo_folio;
  -- Insertar constancia
  INSERT INTO constancias (
    axo, folio, id_licencia, solicita, partidapago, observacion, domicilio, vigente, feccap, capturista, tipo
  ) VALUES (
    nvo_axo, nvo_folio, p_id_licencia, p_solicita, p_partidapago, p_observacion, p_domicilio, p_vigente, p_feccap, p_capturista, p_tipo
  );
  RETURN QUERY SELECT nvo_axo, nvo_folio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dictamenusodesuelo_update(
  p_axo INTEGER,
  p_folio INTEGER,
  p_solicita VARCHAR,
  p_partidapago VARCHAR,
  p_observacion VARCHAR,
  p_domicilio VARCHAR,
  p_id_licencia INTEGER,
  p_capturista VARCHAR,
  p_tipo INTEGER,
  p_recaud INTEGER DEFAULT NULL,
  p_actividad VARCHAR DEFAULT NULL,
  p_propietario VARCHAR DEFAULT NULL,
  p_ubicacion VARCHAR DEFAULT NULL,
  p_numext_ubic VARCHAR DEFAULT NULL,
  p_letraext_ubic VARCHAR DEFAULT NULL,
  p_numint_ubic VARCHAR DEFAULT NULL,
  p_letraint_ubic VARCHAR DEFAULT NULL,
  p_sup_construida NUMERIC DEFAULT NULL,
  p_sup_autorizada NUMERIC DEFAULT NULL,
  p_num_cajones INTEGER DEFAULT NULL,
  p_num_empleados INTEGER DEFAULT NULL,
  p_vigente VARCHAR DEFAULT 'V'
)
RETURNS VOID AS $$
BEGIN
  UPDATE constancias SET
    solicita = p_solicita,
    partidapago = p_partidapago,
    observacion = p_observacion,
    domicilio = p_domicilio,
    id_licencia = p_id_licencia,
    capturista = p_capturista,
    tipo = p_tipo,
    vigente = p_vigente
  WHERE axo = p_axo AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dictamenusodesuelo_cancel(
  p_axo INTEGER,
  p_folio INTEGER,
  p_motivo VARCHAR
)
RETURNS VOID AS $$
BEGIN
  UPDATE constancias SET
    vigente = 'C',
    observacion = p_motivo
  WHERE axo = p_axo AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_doctosfrm_get(p_tramite_id integer)
RETURNS TABLE(documentos text[], otro text) AS $$
BEGIN
  RETURN QUERY
    SELECT d.documentos, d.otro
    FROM doctosfrm_tramite d
    WHERE d.tramite_id = p_tramite_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_doctosfrm_save(p_tramite_id integer, p_documentos json, p_otro text)
RETURNS TABLE(success boolean, message text) AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM doctosfrm_tramite WHERE tramite_id = p_tramite_id) THEN
    UPDATE doctosfrm_tramite
      SET documentos = ARRAY(SELECT json_array_elements_text(p_documentos)), otro = p_otro
      WHERE tramite_id = p_tramite_id;
  ELSE
    INSERT INTO doctosfrm_tramite(tramite_id, documentos, otro)
      VALUES (p_tramite_id, ARRAY(SELECT json_array_elements_text(p_documentos)), p_otro);
  END IF;
  RETURN QUERY SELECT true, 'Documentos guardados';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_doctosfrm_clear(p_tramite_id integer)
RETURNS TABLE(success boolean, message text) AS $$
BEGIN
  UPDATE doctosfrm_tramite SET documentos = ARRAY[]::text[], otro = NULL WHERE tramite_id = p_tramite_id;
  RETURN QUERY SELECT true, 'Selección limpiada';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_doctosfrm_delete(p_tramite_id integer, p_documento text)
RETURNS TABLE(success boolean, message text) AS $$
BEGIN
  UPDATE doctosfrm_tramite
    SET documentos = array_remove(documentos, p_documento)
    WHERE tramite_id = p_tramite_id;
  RETURN QUERY SELECT true, 'Documento eliminado';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fechasegfrm_save(p_fecha DATE, p_oficio VARCHAR)
RETURNS TABLE(id INTEGER, fecha DATE, oficio VARCHAR, created_at TIMESTAMP) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO fechasegfrm (fecha, oficio, created_at)
    VALUES (p_fecha, p_oficio, NOW())
    RETURNING id, fecha, oficio, created_at INTO new_id, fechasegfrm_save.fecha, fechasegfrm_save.oficio, fechasegfrm_save.created_at;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_firma_validate(p_firma_digital TEXT)
RETURNS TABLE(is_valid BOOLEAN, usuario_id INTEGER, nombre TEXT) AS $$
BEGIN
    -- Ejemplo: Validar contra tabla de usuarios
    RETURN QUERY
    SELECT TRUE AS is_valid, id AS usuario_id, nombre
    FROM usuarios
    WHERE firma_digital = p_firma_digital
    LIMIT 1;
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, NULL, NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_firma_save(p_usuario_id INTEGER, p_firma_digital TEXT)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    UPDATE usuarios SET firma_digital = p_firma_digital WHERE id = p_usuario_id;
    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Firma actualizada correctamente.';
    ELSE
        RETURN QUERY SELECT FALSE, 'Usuario no encontrado.';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_validate_firma_usuario(p_usuario VARCHAR, p_firma VARCHAR)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Suponiendo que existe una tabla usuarios con campos usuario y firma_digital
    SELECT COUNT(*) INTO v_count
    FROM usuarios
    WHERE usuario = p_usuario AND firma_digital = p_firma;

    IF v_count > 0 THEN
        RETURN QUERY SELECT TRUE, 'Firma validada correctamente.';
    ELSE
        RETURN QUERY SELECT FALSE, 'Usuario o firma incorrectos.';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_create_licencia_reglamentada(
    p_nombre VARCHAR,
    p_descripcion TEXT,
    p_usuario_id INTEGER
) RETURNS TABLE(
    id INTEGER,
    nombre VARCHAR,
    descripcion TEXT,
    usuario_id INTEGER,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO licencias_reglamentadas (nombre, descripcion, usuario_id, created_at, updated_at)
    VALUES (p_nombre, p_descripcion, p_usuario_id, NOW(), NOW())
    RETURNING id INTO new_id;
    RETURN QUERY SELECT id, nombre, descripcion, usuario_id, created_at, updated_at FROM licencias_reglamentadas WHERE id = new_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_update_licencia_reglamentada(
    p_id INTEGER,
    p_nombre VARCHAR,
    p_descripcion TEXT,
    p_usuario_id INTEGER
) RETURNS TABLE(
    id INTEGER,
    nombre VARCHAR,
    descripcion TEXT,
    usuario_id INTEGER,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    UPDATE licencias_reglamentadas
    SET nombre = p_nombre,
        descripcion = p_descripcion,
        usuario_id = p_usuario_id,
        updated_at = NOW()
    WHERE id = p_id;
    RETURN QUERY SELECT id, nombre, descripcion, usuario_id, created_at, updated_at FROM licencias_reglamentadas WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_delete_licencia_reglamentada(
    p_id INTEGER
) RETURNS TABLE(
    deleted BOOLEAN
) AS $$
BEGIN
    DELETE FROM licencias_reglamentadas WHERE id = p_id;
    RETURN QUERY SELECT TRUE AS deleted;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION anuncios_grupos_insert(p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT)
LANGUAGE plpgsql AS $$
DECLARE
  new_id INTEGER;
BEGIN
  INSERT INTO anuncios_grupos(descripcion)
  VALUES (UPPER(TRIM(p_descripcion)))
  RETURNING id, descripcion INTO new_id, p_descripcion;
  RETURN QUERY SELECT new_id, p_descripcion;
END;
$$;

CREATE OR REPLACE FUNCTION anuncios_grupos_update(p_id INTEGER, p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE anuncios_grupos
  SET descripcion = UPPER(TRIM(p_descripcion))
  WHERE id = p_id;
  RETURN QUERY SELECT id, descripcion FROM anuncios_grupos WHERE id = p_id;
END;
$$;

CREATE OR REPLACE FUNCTION anuncios_grupos_delete(p_id INTEGER)
RETURNS TABLE(id INTEGER, descripcion TEXT)
LANGUAGE plpgsql AS $$
DECLARE
  old_id INTEGER;
  old_desc TEXT;
BEGIN
  SELECT id, descripcion INTO old_id, old_desc FROM anuncios_grupos WHERE id = p_id;
  DELETE FROM anuncios_grupos WHERE id = p_id;
  RETURN QUERY SELECT old_id, old_desc;
END;
$$;

CREATE OR REPLACE FUNCTION sp_insert_grupo_licencia(p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
DECLARE
  new_id INTEGER;
BEGIN
  INSERT INTO lic_grupos(descripcion)
  VALUES (UPPER(TRIM(p_descripcion)))
  RETURNING id, descripcion INTO new_id, p_descripcion;
  RETURN QUERY SELECT new_id, p_descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_update_grupo_licencia(p_id INTEGER, p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
BEGIN
  UPDATE lic_grupos
  SET descripcion = UPPER(TRIM(p_descripcion))
  WHERE id = p_id;
  RETURN QUERY SELECT id, descripcion FROM lic_grupos WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_delete_grupo_licencia(p_id INTEGER)
RETURNS TABLE(id INTEGER) AS $$
BEGIN
  DELETE FROM lic_grupos WHERE id = p_id RETURNING id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_grupo_licencia(p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
DECLARE
  new_id INTEGER;
BEGIN
  INSERT INTO lic_grupos (descripcion) VALUES (p_descripcion) RETURNING id INTO new_id;
  RETURN QUERY SELECT id, descripcion FROM lic_grupos WHERE id = new_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_grupo_licencia(p_id INTEGER, p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
BEGIN
  UPDATE lic_grupos SET descripcion = p_descripcion WHERE id = p_id;
  RETURN QUERY SELECT id, descripcion FROM lic_grupos WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_grupo_licencia(p_id INTEGER)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
DECLARE
  old_row lic_grupos%ROWTYPE;
BEGIN
  SELECT * INTO old_row FROM lic_grupos WHERE id = p_id;
  DELETE FROM lic_grupos WHERE id = p_id;
  RETURN QUERY SELECT old_row.id, old_row.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_licencias_to_grupo(p_grupo_id INTEGER, p_licencias INTEGER[])
RETURNS TABLE(added_count INTEGER) AS $$
DECLARE
  i INTEGER;
  cnt INTEGER := 0;
BEGIN
  FOREACH i IN ARRAY p_licencias LOOP
    INSERT INTO lic_detgrupo (lic_grupos_id, licencia)
    VALUES (p_grupo_id, i)
    ON CONFLICT DO NOTHING;
    cnt := cnt + 1;
  END LOOP;
  RETURN QUERY SELECT cnt;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION remove_licencias_from_grupo(p_grupo_id INTEGER, p_licencias INTEGER[])
RETURNS TABLE(removed_count INTEGER) AS $$
DECLARE
  cnt INTEGER;
BEGIN
  DELETE FROM lic_detgrupo
  WHERE lic_grupos_id = p_grupo_id AND licencia = ANY(p_licencias);
  GET DIAGNOSTICS cnt = ROW_COUNT;
  RETURN QUERY SELECT cnt;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_validate_hasta_form(p_bimestre integer, p_anio integer)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    current_year integer := EXTRACT(YEAR FROM CURRENT_DATE);
BEGIN
    IF p_bimestre IS NULL OR p_bimestre < 1 OR p_bimestre > 6 THEN
        RETURN QUERY SELECT false, 'Bimestre inválido: debe ser entre 1 y 6.';
        RETURN;
    END IF;
    IF p_anio IS NULL OR p_anio < 1970 OR p_anio > current_year THEN
        RETURN QUERY SELECT false, 'Año inválido: debe ser entre 1970 y ' || current_year || '.';
        RETURN;
    END IF;
    RETURN QUERY SELECT true, 'Validación exitosa.';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calc_adeudolic(p_id_licencia INTEGER)
RETURNS VOID AS $$
BEGIN
  -- Limpiar temporal para la licencia
  DELETE FROM tmp_adeudolic WHERE id_licencia = p_id_licencia;

  -- Insertar adeudos de licencias
  INSERT INTO tmp_adeudolic (id_licencia, numero, texto, ctaapl, importe)
  SELECT l.id_licencia, g.descripcion, g.ctaaplic, 'LIC', COALESCE(s.saldo,0)
  FROM licencias l
  JOIN c_giros g ON g.id_giro = l.id_giro
  JOIN detsal_lic s ON s.id_licencia = l.id_licencia AND s.id_anuncio = 0 AND s.cvepago = 0
  WHERE l.id_licencia = p_id_licencia AND l.vigente = 'V';

  -- Insertar adeudos de anuncios
  INSERT INTO tmp_adeudolic (id_licencia, numero, texto, ctaapl, importe)
  SELECT a.id_licencia, g.descripcion, g.ctaaplic, 'ANU', COALESCE(s.saldo,0)
  FROM anuncios a
  JOIN c_giros g ON g.id_giro = a.id_giro
  JOIN detsal_lic s ON s.id_anuncio = a.id_anuncio AND s.cvepago = 0
  WHERE a.id_licencia = p_id_licencia AND a.vigente = 'V' AND a.misma_forma = 'S';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_imp_oficio_register(
    p_tramite_id INTEGER,
    p_oficio_type INTEGER,
    p_usuario_id INTEGER,
    p_observaciones TEXT DEFAULT NULL
) RETURNS TABLE(result TEXT) AS $$
DECLARE
    v_tipo_oficio TEXT;
BEGIN
    -- Validación básica
    IF p_oficio_type NOT IN (1,2,3,4) THEN
        RAISE EXCEPTION 'Tipo de oficio inválido';
    END IF;
    -- Determinar tipo de oficio
    CASE p_oficio_type
        WHEN 1 THEN v_tipo_oficio := 'Uno';
        WHEN 2 THEN v_tipo_oficio := 'Dos';
        WHEN 3 THEN v_tipo_oficio := 'M24BIS';
        WHEN 4 THEN v_tipo_oficio := 'Informativo';
    END CASE;
    -- Registrar la decisión en una tabla de bitácora
    INSERT INTO imp_oficio_bitacora(tramite_id, oficio_type, oficio_label, usuario_id, observaciones, fecha)
    VALUES (p_tramite_id, p_oficio_type, v_tipo_oficio, p_usuario_id, p_observaciones, NOW());
    -- Aquí se podría invocar la lógica de impresión o generación de PDF
    RETURN QUERY SELECT 'Oficio registrado: ' || v_tipo_oficio;
END;
$$ LANGUAGE plpgsql;

-- NOTA: Para producción, usar una extensión o función más robusta
CREATE OR REPLACE FUNCTION sp_numero_a_letras(p_numero NUMERIC)
RETURNS TEXT AS $$
DECLARE
    unidades TEXT[] := ARRAY['CERO','UNO','DOS','TRES','CUATRO','CINCO','SEIS','SIETE','OCHO','NUEVE'];
    decenas TEXT[] := ARRAY['', 'DIEZ','VEINTE','TREINTA','CUARENTA','CINCUENTA','SESENTA','SETENTA','OCHENTA','NOVENTA'];
    centenas TEXT[] := ARRAY['','CIEN','DOSCIENTOS','TRESCIENTOS','CUATROCIENTOS','QUINIENTOS','SEISCIENTOS','SETECIENTOS','OCHOCIENTOS','NOVECIENTOS'];
    n INT := p_numero;
    resultado TEXT := '';
BEGIN
    IF n < 10 THEN
        resultado := unidades[n+1];
    ELSIF n < 100 THEN
        resultado := decenas[n/10] || CASE WHEN n%10 > 0 THEN ' Y ' || unidades[(n%10)+1] ELSE '' END;
    ELSIF n < 1000 THEN
        resultado := centenas[n/100] || CASE WHEN n%100 > 0 THEN ' ' || decenas[(n%100)/10] END;
    ELSE
        resultado := 'CANTIDAD ALTA';
    END IF;
    RETURN resultado;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sp_ligar_anuncio(
    p_anuncio_id INTEGER,
    p_licencia_id INTEGER,
    p_empresa_id INTEGER,
    p_is_empresa BOOLEAN,
    p_user TEXT,
    OUT p_success BOOLEAN,
    OUT p_message TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    v_anuncio RECORD;
    v_licencia RECORD;
    v_empresa RECORD;
BEGIN
    p_success := FALSE;
    p_message := '';
    SELECT * INTO v_anuncio FROM anuncios WHERE id_anuncio = p_anuncio_id;
    IF NOT FOUND THEN
        p_message := 'Anuncio no encontrado';
        RETURN;
    END IF;
    IF v_anuncio.vigente <> 'V' THEN
        p_message := 'No se puede ligar un anuncio cancelado.';
        RETURN;
    END IF;
    IF p_is_empresa THEN
        SELECT * INTO v_empresa FROM licencias WHERE id_licencia = p_empresa_id;
        IF NOT FOUND THEN
            p_message := 'Empresa no encontrada';
            RETURN;
        END IF;
        IF v_empresa.vigente <> 'V' THEN
            p_message := 'No se puede ligar a una empresa cancelada.';
            RETURN;
        END IF;
        UPDATE anuncios SET id_licencia = p_empresa_id WHERE id_anuncio = p_anuncio_id;
        UPDATE detsal_lic SET id_licencia = p_empresa_id WHERE id_anuncio = p_anuncio_id;
        PERFORM calc_sdosl(p_empresa_id);
    ELSE
        SELECT * INTO v_licencia FROM licencias WHERE id_licencia = p_licencia_id;
        IF NOT FOUND THEN
            p_message := 'Licencia no encontrada';
            RETURN;
        END IF;
        IF v_licencia.vigente <> 'V' THEN
            p_message := 'No se puede ligar a una licencia cancelada.';
            RETURN;
        END IF;
        UPDATE anuncios SET id_licencia = p_licencia_id,
            zona = v_licencia.zona,
            subzona = v_licencia.subzona,
            cvecalle = v_licencia.cvecalle,
            ubicacion = v_licencia.ubicacion,
            numext_ubic = v_licencia.numext_ubic,
            letraext_ubic = v_licencia.letraext_ubic,
            numint_ubic = v_licencia.numint_ubic,
            letraint_ubic = v_licencia.letraint_ubic
        WHERE id_anuncio = p_anuncio_id;
        UPDATE detsal_lic SET id_licencia = p_licencia_id WHERE id_anuncio = p_anuncio_id;
        PERFORM calc_sdosl(p_licencia_id);
    END IF;
    p_success := TRUE;
    p_message := 'Anuncio ligado correctamente';
END;
$$;

CREATE OR REPLACE PROCEDURE calc_sdosl(p_id_licencia INTEGER)
LANGUAGE plpgsql AS $$
BEGIN
    -- Aquí va la lógica de recálculo de saldos de la licencia
    -- Por ejemplo, sumar derechos, anuncios, recargos, etc.
    -- UPDATE saldos_lic SET total = derechos + anuncios + recargos + gastos + multas + formas WHERE id_licencia = p_id_licencia;
    -- ...
END;
$$;

CREATE OR REPLACE PROCEDURE sp_ligarequisito_add(p_id_giro INTEGER, p_req INTEGER, p_usuario TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM giro_req WHERE id_giro = p_id_giro AND req = p_req) THEN
        RAISE EXCEPTION 'El requisito ya está ligado a este giro';
    END IF;
    INSERT INTO giro_req (id_giro, req) VALUES (p_id_giro, p_req);
    -- Opcional: registrar en bitácora
END;
$$;

CREATE OR REPLACE PROCEDURE sp_ligarequisito_remove(p_id_giro INTEGER, p_req INTEGER, p_usuario TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM giro_req WHERE id_giro = p_id_giro AND req = p_req) THEN
        RAISE EXCEPTION 'El requisito no está ligado a este giro';
    END IF;
    DELETE FROM giro_req WHERE id_giro = p_id_giro AND req = p_req;
    -- Opcional: registrar en bitácora
END;
$$;

CREATE OR REPLACE PROCEDURE calc_sdoslsr(IN p_id_licencia INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_forma NUMERIC := 0;
    v_derechos NUMERIC := 0;
    v_derechos2 NUMERIC := 0;
    v_recargos NUMERIC := 0;
    v_anuncios NUMERIC := 0;
    v_gastos NUMERIC := 0;
    v_multas NUMERIC := 0;
    v_formas NUMERIC := 0;
    v_total NUMERIC := 0;
    v_base NUMERIC := 0;
    v_desc_derechos NUMERIC := 0;
    v_desc_recargos NUMERIC := 0;
BEGIN
    -- Suma de licencias (sin anuncios)
    SELECT COALESCE(SUM(forma),0), COALESCE(SUM(derechos),0), COALESCE(SUM(derechos2),0), COALESCE(SUM(recargos),0),
           COALESCE(SUM(desc_derechos),0), COALESCE(SUM(desc_recargos),0)
      INTO v_forma, v_derechos, v_derechos2, v_recargos, v_desc_derechos, v_desc_recargos
      FROM detsal_lic
     WHERE id_licencia = p_id_licencia
       AND (id_anuncio IS NULL OR id_anuncio = 0)
       AND (cvepago IS NULL OR cvepago = 0);

    -- Suma de anuncios
    SELECT COALESCE(SUM(forma),0), COALESCE(SUM(derechos),0), COALESCE(SUM(recargos),0)
      INTO v_formas, v_anuncios, v_recargos
      FROM detsal_lic
     WHERE id_licencia = p_id_licencia
       AND (id_anuncio > 0)
       AND (cvepago IS NULL OR cvepago = 0);

    -- Gastos y multas pueden ser calculados de otras tablas si aplica, aquí se dejan en 0
    v_gastos := 0;
    v_multas := 0;

    -- Base = derechos
    v_base := v_derechos;

    -- Total
    v_total := v_formas + v_forma + v_derechos + v_anuncios + v_recargos + v_gastos + v_multas;

    -- Upsert en saldos_lic
    IF EXISTS (SELECT 1 FROM saldos_lic WHERE id_licencia = p_id_licencia) THEN
        UPDATE saldos_lic SET
            derechos = v_derechos,
            anuncios = v_anuncios,
            recargos = v_recargos,
            gastos = v_gastos,
            multas = v_multas,
            formas = v_formas + v_forma,
            total = v_total,
            base = v_base,
            desc_derechos = v_desc_derechos,
            desc_recargos = v_desc_recargos
        WHERE id_licencia = p_id_licencia;
    ELSE
        INSERT INTO saldos_lic (
            id_licencia, derechos, anuncios, recargos, gastos, multas, formas, total, base, desc_derechos, desc_recargos
        ) VALUES (
            p_id_licencia, v_derechos, v_anuncios, v_recargos, v_gastos, v_multas, v_formas + v_forma, v_total, v_base, v_desc_derechos, v_desc_recargos
        );
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION sp_save_observacion(p_observacion TEXT)
RETURNS TABLE(id BIGINT, observacion TEXT, created_at TIMESTAMP) AS $$
BEGIN
    INSERT INTO observaciones (observacion, created_at)
    VALUES (UPPER(p_observacion), NOW());
    RETURN QUERY
        SELECT id, observacion, created_at
        FROM observaciones
        WHERE id = currval('observaciones_id_seq');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_prepago_liquidacion_parcial(
    p_cvecuenta INTEGER,
    p_asalf INTEGER,
    p_bsalf INTEGER
) RETURNS JSON AS $$
DECLARE
    v_detalle JSON;
    v_totales JSON;
BEGIN
    -- Detalle de bimestres
    SELECT json_agg(row_to_json(t)) INTO v_detalle FROM (
        SELECT v.axoefec, v.valfiscal, v.tasa, v.axosobre,
               SUM(d.recvir) AS recvir, SUM(d.impade+d.impvir) AS impfac,
               SUM(d.impvir) AS impvir, SUM(d.impade) AS impade,
               SUM(d.recfac-d.recpag-d.recvir) AS total,
               MIN(v.bimefec) AS bimini, MAX(v.bimefec) AS bimfin,
               MIN(v.bimefec)::TEXT || '/' || v.axoefec AS inicio,
               MAX(v.bimefec)::TEXT || '/' || v.axoefec AS fin
        FROM detsaldos d
        JOIN valoradeudo v ON v.cvecuenta = d.cvecuenta AND v.axoefec = d.axosal AND v.bimefec = d.bimsal
        WHERE d.cvecuenta = p_cvecuenta AND d.saldo > 0
          AND ((d.axosal > 1900 OR (d.bimsal >= 1 AND d.axosal = 1900))
               AND (d.axosal < p_asalf OR (d.bimsal <= p_bsalf AND d.axosal = p_asalf)))
        GROUP BY v.axoefec, v.valfiscal, v.tasa, v.axosobre
        ORDER BY v.axoefec, bimini
    ) t;
    -- Totales
    SELECT row_to_json(t) INTO v_totales FROM (
        SELECT SUM(d.recfac-d.recpag-d.recvir) AS recppag,
               SUM(d.impfac-d.imppag-d.impvir) AS impppag,
               (s.multa-s.multavir) AS multa,
               s.multavir, s.gasto, s.axotope, s.desctope, s.desctoppp
        FROM detsaldos d
        JOIN saldos s ON s.cvecuenta = d.cvecuenta
        WHERE d.cvecuenta = p_cvecuenta AND d.saldo > 0
          AND ((d.axosal > 1900 OR (d.bimsal >= 1 AND d.axosal = 1900))
               AND (d.axosal < p_asalf OR (d.bimsal <= p_bsalf AND d.axosal = p_asalf)))
        GROUP BY s.multa, s.multavir, s.gasto, s.axotope, s.desctope, s.desctoppp
        LIMIT 1
    ) t;
    RETURN json_build_object('detalle', v_detalle, 'totales', v_totales);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_prepago_recalcular_dpp(p_cvecuenta INTEGER)
RETURNS TEXT AS $$
BEGIN
    -- Aquí se ejecutaría la lógica de recálculo (actualiza tablas, etc)
    -- Por ejemplo, llamar otro SP o actualizar campos
    -- UPDATE detsaldos SET ... WHERE cvecuenta = p_cvecuenta;
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_prepago_eliminar_dpp(p_cvecuenta INTEGER)
RETURNS TEXT AS $$
BEGIN
    -- Aquí se ejecutaría la lógica de eliminación (actualiza tablas, etc)
    -- UPDATE detsaldos SET ... WHERE cvecuenta = p_cvecuenta;
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_prepago_calcular_descpred(p_cvecuenta INTEGER)
RETURNS TEXT AS $$
BEGIN
    -- Aquí se ejecutaría la lógica de cálculo de descuento predial
    -- UPDATE detsaldos SET ... WHERE cvecuenta = p_cvecuenta;
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_contribholog(
    p_nombre varchar,
    p_domicilio varchar,
    p_colonia varchar,
    p_telefono varchar,
    p_rfc varchar,
    p_curp varchar,
    p_email varchar,
    p_capturista varchar
) RETURNS TABLE (
    idcontrib integer,
    nombre varchar,
    domicilio varchar,
    colonia varchar,
    telefono varchar,
    rfc varchar,
    curp varchar,
    email varchar,
    feccap timestamp,
    capturista varchar
) AS $$
DECLARE
    v_idcontrib integer;
BEGIN
    INSERT INTO c_contribholog (nombre, domicilio, colonia, telefono, rfc, curp, email, feccap, capturista)
    VALUES (p_nombre, p_domicilio, p_colonia, p_telefono, p_rfc, p_curp, p_email, NOW(), p_capturista)
    RETURNING idcontrib INTO v_idcontrib;

    RETURN QUERY
    SELECT idcontrib, nombre, domicilio, colonia, telefono, rfc, curp, email, feccap, capturista
    FROM c_contribholog WHERE idcontrib = v_idcontrib;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_contribholog(
    p_idcontrib integer,
    p_nombre varchar,
    p_domicilio varchar,
    p_colonia varchar,
    p_telefono varchar,
    p_rfc varchar,
    p_curp varchar,
    p_email varchar,
    p_capturista varchar
) RETURNS TABLE (
    idcontrib integer,
    nombre varchar,
    domicilio varchar,
    colonia varchar,
    telefono varchar,
    rfc varchar,
    curp varchar,
    email varchar,
    feccap timestamp,
    capturista varchar
) AS $$
BEGIN
    UPDATE c_contribholog
    SET nombre = p_nombre,
        domicilio = p_domicilio,
        colonia = p_colonia,
        telefono = p_telefono,
        rfc = p_rfc,
        curp = p_curp,
        email = p_email,
        capturista = p_capturista
    WHERE idcontrib = p_idcontrib;

    RETURN QUERY
    SELECT idcontrib, nombre, domicilio, colonia, telefono, rfc, curp, email, feccap, capturista
    FROM c_contribholog WHERE idcontrib = p_idcontrib;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_contribholog(p_idcontrib integer)
RETURNS TABLE (
    idcontrib integer,
    nombre varchar,
    domicilio varchar,
    colonia varchar,
    telefono varchar,
    rfc varchar,
    curp varchar,
    email varchar,
    feccap timestamp,
    capturista varchar
) AS $$
DECLARE
    v_row RECORD;
BEGIN
    SELECT * INTO v_row FROM c_contribholog WHERE idcontrib = p_idcontrib;
    IF FOUND THEN
        DELETE FROM c_contribholog WHERE idcontrib = p_idcontrib;
        RETURN QUERY SELECT v_row.*;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION propuestatab_list(p_cvecuenta INTEGER)
RETURNS TABLE(
  cvecuenta INTEGER,
  cvecatnva VARCHAR,
  subpredio INTEGER,
  cmovto VARCHAR,
  observacion TEXT,
  tasa NUMERIC,
  indiviso NUMERIC,
  calle VARCHAR,
  noexterior VARCHAR,
  interior VARCHAR,
  colonia VARCHAR,
  vigencia VARCHAR,
  obsinter TEXT,
  fechaotorg DATE,
  importe NUMERIC,
  valortransm NUMERIC,
  areatitulo NUMERIC,
  notario VARCHAR,
  noescrituras INTEGER,
  recaud INTEGER,
  urbrus VARCHAR,
  cuenta INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT c.cvecuenta, c.cvecatnva, c.subpredio, c.cmovto, c.observacion, v.tasa, c.indiviso,
         u.calle, u.noexterior, u.interior, u.colonia, u.vigencia, u.obsinter,
         a.fechaotorg, p.importe, p.valortransm, h.areatitulo, n.notario, p.noescrituras,
         c.recaud, c.urbrus, c.cuenta
  FROM cuentas c
  LEFT JOIN valores v ON v.cvecuenta = c.cvecuenta
  LEFT JOIN ubicacion u ON u.cvecuenta = c.cvecuenta
  LEFT JOIN pagos p ON p.cvecuenta = c.cvecuenta
  LEFT JOIN historico h ON h.cvecuenta = c.cvecuenta
  LEFT JOIN notarios n ON n.idnotaria = p.idnotaria
  WHERE c.cvecuenta = p_cvecuenta
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reactivar_tramite(p_id_tramite integer, p_motivo text)
RETURNS TABLE (success boolean, message text) AS $$
DECLARE
    v_estatus varchar;
    v_motivo text;
    v_count integer;
BEGIN
    SELECT estatus INTO v_estatus FROM tramites WHERE id_tramite = p_id_tramite;
    IF v_estatus IS NULL THEN
        RETURN QUERY SELECT false, 'Trámite no encontrado.';
        RETURN;
    END IF;
    IF v_estatus NOT IN ('C', 'R') THEN
        RETURN QUERY SELECT false, 'El trámite no se encuentra cancelado o rechazado.';
        RETURN;
    END IF;
    IF v_estatus = 'A' THEN
        RETURN QUERY SELECT false, 'El trámite ya se encuentra aprobado. No se puede reactivar.';
        RETURN;
    END IF;
    v_motivo := 'REACTIVADO POR PADRON Y LICENCIAS.\n' || p_motivo;
    -- Actualizar tramite
    UPDATE tramites SET estatus = 'T', espubic = v_motivo WHERE id_tramite = p_id_tramite;
    -- Reactivar revisiones
    UPDATE revisiones SET estatus = 'V'
    WHERE id_tramite = p_id_tramite AND estatus IN ('C', 'N');
    -- Reactivar seg_revision
    UPDATE seg_revision SET estatus = 'V', observacion = v_motivo
    WHERE id_revision IN (
        SELECT id_revision FROM revisiones WHERE id_tramite = p_id_tramite AND estatus = 'V'
    );
    RETURN QUERY SELECT true, 'Trámite reactivado correctamente.';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_create_historic_record(p_cvecuenta INTEGER, p_axocomp INTEGER, p_nocomp INTEGER)
RETURNS VOID AS $$
BEGIN
    INSERT INTO h_catastro (cvecuenta, axocomp, nocomp)
    VALUES (p_cvecuenta, p_axocomp, p_nocomp);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_update_historic_record(p_cvecuenta INTEGER, p_axocomp INTEGER, p_nocomp INTEGER, p_new_axocomp INTEGER, p_new_nocomp INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE h_catastro
    SET axocomp = p_new_axocomp, nocomp = p_new_nocomp
    WHERE cvecuenta = p_cvecuenta AND axocomp = p_axocomp AND nocomp = p_nocomp;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_delete_historic_record(p_cvecuenta INTEGER, p_axocomp INTEGER, p_nocomp INTEGER)
RETURNS VOID AS $$
BEGIN
    DELETE FROM h_catastro WHERE cvecuenta = p_cvecuenta AND axocomp = p_axocomp AND nocomp = p_nocomp;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION crear_responsiva(
    p_id_licencia INTEGER,
    p_tipo TEXT, -- 'R' o 'S'
    p_usuario TEXT,
    p_observacion TEXT DEFAULT NULL
) RETURNS TABLE (axo INTEGER, folio INTEGER, id_licencia INTEGER, tipo TEXT, vigente TEXT, feccap DATE, capturista TEXT) AS $$
DECLARE
    v_folio INTEGER;
    v_axo INTEGER := EXTRACT(YEAR FROM CURRENT_DATE);
    v_param_col TEXT;
BEGIN
    IF p_tipo = 'R' THEN
        v_param_col := 'responsiva';
    ELSE
        v_param_col := 'supervision';
    END IF;
    -- Obtener folio actual
    EXECUTE format('SELECT %I FROM parametros_lic', v_param_col) INTO v_folio;
    v_folio := v_folio + 1;
    -- Actualizar folio en parametros_lic
    EXECUTE format('UPDATE parametros_lic SET %I = $1', v_param_col) USING v_folio;
    -- Insertar responsiva
    INSERT INTO responsivas(axo, folio, id_licencia, tipo, observacion, vigente, feccap, capturista)
    VALUES (v_axo, v_folio, p_id_licencia, p_tipo, p_observacion, 'V', CURRENT_DATE, p_usuario);
    RETURN QUERY SELECT v_axo, v_folio, p_id_licencia, p_tipo, 'V', CURRENT_DATE, p_usuario;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cancelar_responsiva(
    p_axo INTEGER,
    p_folio INTEGER,
    p_motivo TEXT,
    p_usuario TEXT
) RETURNS TABLE (axo INTEGER, folio INTEGER, vigente TEXT, observacion TEXT) AS $$
BEGIN
    UPDATE responsivas
    SET vigente = 'C', observacion = p_motivo, capturista = p_usuario
    WHERE axo = p_axo AND folio = p_folio;
    RETURN QUERY SELECT p_axo, p_folio, 'C', p_motivo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_semaforo_get_random_color()
RETURNS TABLE(color VARCHAR, numcolor INT) AS $$
DECLARE
  n INT;
BEGIN
  n := floor(random()*100 + 1);
  IF n <= 10 THEN
    color := 'ROJO';
  ELSE
    color := 'VERDE';
  END IF;
  numcolor := n;
  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_semaforo_register_color_result(
  p_tramite_id INT,
  p_color VARCHAR,
  p_user_id INT
) RETURNS VOID AS $$
BEGIN
  INSERT INTO semaforo_tramites(tramite_id, color, user_id, created_at)
  VALUES (p_tramite_id, p_color, p_user_id, NOW());
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure for updating electronic signature
CREATE OR REPLACE FUNCTION upd_firma(
    p_usuario VARCHAR,
    p_login VARCHAR,
    p_firma VARCHAR,
    p_firma_nva VARCHAR,
    p_firma_conf VARCHAR,
    p_modulos_id INTEGER
)
RETURNS TABLE(acceso INTEGER, mensaje VARCHAR) AS $$
DECLARE
    v_usuario_id INTEGER;
    v_firma_actual VARCHAR;
BEGIN
    -- Validar existencia de usuario
    SELECT id INTO v_usuario_id FROM usuarios WHERE usuario = p_usuario;
    IF v_usuario_id IS NULL THEN
        RETURN QUERY SELECT 1, 'Usuario no encontrado';
        RETURN;
    END IF;

    -- Validar firma actual
    SELECT firma INTO v_firma_actual FROM usuarios_firma WHERE usuario_id = v_usuario_id AND modulos_id = p_modulos_id;
    IF v_firma_actual IS NULL THEN
        RETURN QUERY SELECT 1, 'No tiene firma registrada para este módulo';
        RETURN;
    END IF;
    IF v_firma_actual <> p_firma THEN
        RETURN QUERY SELECT 1, 'La firma actual es incorrecta';
        RETURN;
    END IF;

    -- Validar nueva firma
    IF length(p_firma_nva) < 6 THEN
        RETURN QUERY SELECT 1, 'La nueva firma debe tener al menos 6 caracteres';
        RETURN;
    END IF;
    IF p_firma_nva <> p_firma_conf THEN
        RETURN QUERY SELECT 1, 'La confirmación no coincide';
        RETURN;
    END IF;
    IF p_firma_nva = p_firma THEN
        RETURN QUERY SELECT 1, 'La nueva firma no puede ser igual a la actual';
        RETURN;
    END IF;

    -- Actualizar firma
    UPDATE usuarios_firma SET firma = p_firma_nva, fecha_mod = now()
    WHERE usuario_id = v_usuario_id AND modulos_id = p_modulos_id;

    RETURN QUERY SELECT 0, 'Firma electrónica actualizada correctamente';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_validate_user_password(p_username TEXT, p_password TEXT)
RETURNS TABLE(is_valid BOOLEAN) AS $$
BEGIN
  RETURN QUERY
    SELECT (u.password_hash = crypt(p_password, u.password_hash)) AS is_valid
    FROM users u WHERE u.username = p_username;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION sp_change_user_password(p_username TEXT, p_current_password TEXT, p_new_password TEXT)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
  v_user RECORD;
BEGIN
  SELECT * INTO v_user FROM users WHERE username = p_username;
  IF NOT FOUND THEN
    RETURN QUERY SELECT FALSE, 'Usuario no encontrado';
    RETURN;
  END IF;
  IF v_user.password_hash <> crypt(p_current_password, v_user.password_hash) THEN
    RETURN QUERY SELECT FALSE, 'La clave actual no es correcta';
    RETURN;
  END IF;
  IF p_current_password = p_new_password THEN
    RETURN QUERY SELECT FALSE, 'La nueva clave no debe ser igual a la actual';
    RETURN;
  END IF;
  IF substring(p_current_password from 1 for 3) = substring(p_new_password from 1 for 3) THEN
    RETURN QUERY SELECT FALSE, 'Los tres primeros caracteres deben ser diferentes a la clave actual';
    RETURN;
  END IF;
  IF NOT (p_new_password ~ '^(?=.*[a-z])(?=.*[0-9])[a-z0-9]{6,8}$') THEN
    RETURN QUERY SELECT FALSE, 'La nueva clave debe contener letras y números, y tener entre 6 y 8 caracteres';
    RETURN;
  END IF;
  UPDATE users SET password_hash = crypt(p_new_password, gen_salt('bf')) WHERE username = p_username;
  RETURN QUERY SELECT TRUE, 'Clave cambiada exitosamente';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION sp_alta_tramite_licencia(p_json JSON)
RETURNS JSON AS $$
DECLARE
    v_id_tramite INTEGER;
    v_result JSON;
BEGIN
    -- Extraer campos del JSON y realizar inserciones en tramites, licencias, etc.
    -- Ejemplo (simplificado):
    INSERT INTO tramites (tipo_tramite, id_giro, propietario, rfc, curp, domicilio, telefono_prop, email, feccap)
    VALUES (
        (p_json->>'tipo_tramite')::INTEGER,
        (p_json->>'id_giro')::INTEGER,
        p_json->>'propietario',
        p_json->>'rfc',
        p_json->>'curp',
        p_json->>'domicilio',
        p_json->>'telefono_prop',
        p_json->>'email',
        NOW()
    ) RETURNING id_tramite INTO v_id_tramite;
    -- ... lógica adicional ...
    v_result := json_build_object('id_tramite', v_id_tramite, 'status', 'ok');
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_bloquear_licencia(p_licencia INTEGER, p_motivo TEXT, p_usuario TEXT)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    UPDATE licencias SET bloqueado = 1 WHERE licencia = p_licencia;
    INSERT INTO bloqueo (id_licencia, bloqueado, observacion, capturista, fecha_mov, vigente)
    VALUES (p_licencia, 1, p_motivo, p_usuario, NOW(), 'V');
    v_result := json_build_object('licencia', p_licencia, 'status', 'bloqueada');
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_desbloquear_licencia(p_licencia INTEGER, p_motivo TEXT, p_usuario TEXT)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    UPDATE licencias SET bloqueado = 0 WHERE licencia = p_licencia;
    INSERT INTO bloqueo (id_licencia, bloqueado, observacion, capturista, fecha_mov, vigente)
    VALUES (p_licencia, 0, p_motivo, p_usuario, NOW(), 'V');
    v_result := json_build_object('licencia', p_licencia, 'status', 'desbloqueada');
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_baja_licencia(p_licencia INTEGER, p_motivo TEXT, p_usuario TEXT)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    UPDATE licencias SET vigente = 'C', fecha_baja = NOW(), espubic = p_motivo WHERE licencia = p_licencia;
    UPDATE anuncios SET vigente = 'C', fecha_baja = NOW() WHERE id_licencia = (SELECT id_licencia FROM licencias WHERE licencia = p_licencia);
    v_result := json_build_object('licencia', p_licencia, 'status', 'baja');
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_baja_anuncio(p_anuncio INTEGER, p_motivo TEXT, p_usuario TEXT)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    UPDATE anuncios SET vigente = 'C', fecha_baja = NOW(), espubic = p_motivo WHERE anuncio = p_anuncio;
    v_result := json_build_object('anuncio', p_anuncio, 'status', 'baja');
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION bloquear_licencia(
    p_tipo_bloqueo_id integer,
    p_motivo varchar,
    p_usuario_id integer,
    p_licencia_id integer
) RETURNS TABLE(success boolean, message text)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists integer;
BEGIN
    -- Validar existencia de licencia
    SELECT COUNT(*) INTO v_exists FROM licencias WHERE id = p_licencia_id;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'Licencia no encontrada.';
        RETURN;
    END IF;
    -- Validar tipo de bloqueo
    SELECT COUNT(*) INTO v_exists FROM c_tipobloqueo WHERE id = p_tipo_bloqueo_id AND sel_cons = 'S';
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'Tipo de bloqueo inválido.';
        RETURN;
    END IF;
    -- Registrar bloqueo (tabla ejemplo: bloqueos_licencia)
    INSERT INTO bloqueos_licencia (licencia_id, tipo_bloqueo_id, motivo, usuario_id, fecha)
    VALUES (p_licencia_id, p_tipo_bloqueo_id, upper(p_motivo), p_usuario_id, now());
    RETURN QUERY SELECT true, 'Bloqueo registrado correctamente.';
END;
$$;

CREATE OR REPLACE FUNCTION sp_tramite_baja_anun_buscar(p_anuncio INTEGER)
RETURNS TABLE(
    anuncio JSONB,
    saldos JSONB,
    licencia JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        row_to_json(a),
        (SELECT json_agg(row_to_json(s)) FROM detsal_lic s WHERE s.id_anuncio = a.id_anuncio AND s.cvepago = 0),
        row_to_json(l)
    FROM anuncios a
    LEFT JOIN licencias l ON l.id_licencia = a.id_licencia
    WHERE a.anuncio = p_anuncio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_tramite_baja_anun_tramitar(
    p_anuncio INTEGER,
    p_motivo TEXT,
    p_usuario TEXT,
    p_axo_baja INTEGER DEFAULT NULL,
    p_folio_baja INTEGER DEFAULT NULL,
    p_rec INTEGER DEFAULT 0,
    p_imp_solicitud NUMERIC DEFAULT 0,
    p_imp_licencia NUMERIC DEFAULT 0,
    p_importe NUMERIC DEFAULT 0
) RETURNS TEXT AS $$
DECLARE
    v_anuncio RECORD;
    v_folio INTEGER;
    v_axo INTEGER := COALESCE(p_axo_baja, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER);
BEGIN
    SELECT * INTO v_anuncio FROM anuncios WHERE anuncio = p_anuncio FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró el anuncio';
    END IF;
    IF v_anuncio.vigente <> 'V' THEN
        RAISE EXCEPTION 'El anuncio ya se encuentra cancelado.';
    END IF;
    -- Actualizar anuncio
    UPDATE anuncios SET vigente = 'C', fecha_baja = NOW(), axo_baja = v_axo, folio_baja = COALESCE(p_folio_baja, 0), espubic = p_motivo WHERE anuncio = p_anuncio;
    -- Cancelar adeudos
    UPDATE detsal_lic SET cvepago = 999999 WHERE id_anuncio = v_anuncio.id_anuncio AND cvepago = 0;
    -- Recalcular saldo de la licencia
    PERFORM calc_sdosl(v_anuncio.id_licencia);
    -- Insertar registro en lic_cancel
    SELECT COALESCE(MAX(folio),0)+1 INTO v_folio FROM lic_cancel WHERE rec = p_rec AND axo = v_axo;
    INSERT INTO lic_cancel (rec, axo, folio, licencia, anuncio, motivo, usuario, fecha, imp_solicitud, imp_licencia, importe, cvepago)
    VALUES (p_rec, v_axo, v_folio, 0, v_anuncio.anuncio, p_motivo, p_usuario, NOW(), p_imp_solicitud, p_imp_licencia, p_importe, 0);
    RETURN 'Baja tramitada correctamente';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calc_sdosl(p_id_licencia INTEGER)
RETURNS VOID AS $$
BEGIN
    -- Aquí va la lógica para recalcular el saldo de la licencia
    -- Por ejemplo, sumar los saldos de detsal_lic y actualizar saldos_lic
    -- Esta función debe ser implementada según la lógica real
    NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_tramite_baja_lic_consulta(p_licencia INTEGER)
RETURNS JSON AS $$
DECLARE
  v_licencia RECORD;
  v_adeudos JSON;
  v_tramites JSON;
BEGIN
  SELECT *,
    TRIM(COALESCE(primer_ap, '') || ' ' || COALESCE(segundo_ap, '') || ' ' || COALESCE(propietario, '')) AS propietarionvo
  INTO v_licencia
  FROM licencias
  WHERE licencia = p_licencia;

  IF NOT FOUND THEN
    RETURN json_build_object('success', false, 'message', 'Licencia no encontrada');
  END IF;

  SELECT json_agg(row_to_json(a))
    INTO v_adeudos
    FROM (
      SELECT axo, formas, derechos, recargos, gastos, multas, saldo
      FROM detsal_lic
      WHERE id_licencia = v_licencia.id_licencia AND (id_anuncio IS NULL OR id_anuncio = 0) AND cvepago = 0
      ORDER BY axo
    ) a;

  SELECT json_agg(row_to_json(t))
    INTO v_tramites
    FROM (
      SELECT axo, folio, motivo, baja_admva, total, usuario, fecha
      FROM lic_tramitebaja
      WHERE licencia = p_licencia
      ORDER BY fecha DESC
    ) t;

  RETURN json_build_object(
    'success', true,
    'propietarionvo', v_licencia.propietarionvo,
    'ubicacion', v_licencia.ubicacion,
    'actividad', v_licencia.actividad,
    'sup_construida', v_licencia.sup_construida,
    'sup_autorizada', v_licencia.sup_autorizada,
    'num_cajones', v_licencia.num_cajones,
    'num_empleados', v_licencia.num_empleados,
    'vigente', v_licencia.vigente,
    'adeudos', COALESCE(v_adeudos, '[]'),
    'tramites', COALESCE(v_tramites, '[]')
  );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_tramite_baja_lic_tramitar(
  p_licencia INTEGER,
  p_motivo TEXT,
  p_baja_admva DATE,
  p_usuario TEXT
) RETURNS JSON AS $$
DECLARE
  v_licencia RECORD;
  v_parametros RECORD;
  v_adeudos RECORD;
  v_folio INTEGER;
  v_axo INTEGER := EXTRACT(YEAR FROM CURRENT_DATE);
  v_formas NUMERIC := 0;
  v_derechos NUMERIC := 0;
  v_gastos NUMERIC := 0;
  v_multa NUMERIC := 0;
  v_total NUMERIC := 0;
  v_axo_min INTEGER := 0;
  v_axo_max INTEGER := 0;
BEGIN
  SELECT * INTO v_licencia FROM licencias WHERE licencia = p_licencia;
  IF NOT FOUND THEN
    RETURN json_build_object('success', false, 'message', 'Licencia no encontrada');
  END IF;
  SELECT * INTO v_parametros FROM parametros_lic LIMIT 1;

  -- Sumar adeudos
  FOR v_adeudos IN SELECT * FROM spget_lic_adeudos(v_licencia.id_licencia, 'L') LOOP
    IF v_axo_min = 0 THEN v_axo_min := v_adeudos.axo; END IF;
    v_formas := v_formas + v_adeudos.formas;
    v_derechos := v_derechos + v_adeudos.derechos;
    v_axo_max := v_adeudos.axo;
  END LOOP;

  -- Gastos y multa
  SELECT gastos, multas FROM get_gastoslic(v_licencia.id_licencia) INTO v_gastos, v_multa;
  IF v_derechos > 0 THEN
    v_multa := 14844.00;
  ELSE
    v_multa := 7422.00;
  END IF;
  v_total := COALESCE(v_parametros.costo_solicitud,0) + v_formas + v_gastos + v_multa;

  -- Folio
  SELECT COALESCE(MAX(folio),0)+1 INTO v_folio FROM lic_tramitebaja WHERE axo = v_axo;

  INSERT INTO lic_tramitebaja(axo, folio, licencia, anuncio, motivo, axo_min, axo_max, imp_solicitud, imp_formas, imp_gastos, imp_multa, total, cvepago, vigencia, usuario, fecha, baja_admva)
  VALUES (v_axo, v_folio, v_licencia.licencia, 0, p_motivo, v_axo_min, v_axo_max, COALESCE(v_parametros.costo_solicitud,0), v_formas, v_gastos, v_multa, v_total, 0, 'V', p_usuario, NOW(), p_baja_admva)
  RETURNING *;

  RETURN json_build_object('success', true, 'folio', v_folio, 'total', v_total);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_tramite_baja_lic_recalcula(p_licencia INTEGER)
RETURNS JSON AS $$
DECLARE
  v_licencia RECORD;
BEGIN
  SELECT * INTO v_licencia FROM licencias WHERE licencia = p_licencia;
  IF NOT FOUND THEN
    RETURN json_build_object('success', false, 'message', 'Licencia no encontrada');
  END IF;
  -- Aquí se puede llamar a un SP que recalcula los saldos proporcionales
  PERFORM calc_sdosl(v_licencia.id_licencia);
  RETURN json_build_object('success', true, 'message', 'Recalculo realizado');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION set_unidad_img(p_unidad VARCHAR)
RETURNS TABLE(success BOOLEAN, msg TEXT) AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM configuracion WHERE clave = 'UnidadImg') THEN
    UPDATE configuracion SET valor = TRIM(p_unidad) WHERE clave = 'UnidadImg';
    RETURN QUERY SELECT TRUE, 'Actualizado correctamente';
  ELSE
    INSERT INTO configuracion(clave, valor) VALUES ('UnidadImg', TRIM(p_unidad));
    RETURN QUERY SELECT TRUE, 'Insertado correctamente';
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION rutaimagen(id_tramite INTEGER, id_imagen INTEGER)
RETURNS TABLE(ruta TEXT) AS $$
DECLARE
  unidad VARCHAR;
  destino TEXT;
BEGIN
  SELECT valor INTO unidad FROM configuracion WHERE clave = 'UnidadImg' LIMIT 1;
  IF unidad IS NULL OR TRIM(unidad) = '' THEN
    unidad := 'N';
  END IF;
  IF id_tramite BETWEEN 1 AND 999 THEN
    destino := unidad || 'trlic00000/' || id_imagen;
  ELSIF id_tramite BETWEEN 1000 AND 9999 THEN
    destino := unidad || 'trlic0' || (id_tramite/1000)::INT || '000/' || id_imagen;
  ELSIF id_tramite BETWEEN 10000 AND 999999 THEN
    destino := unidad || 'trlic' || (id_tramite/1000)::INT || '000/' || id_imagen;
  ELSE
    destino := unidad || 'no_encontro';
  END IF;
  RETURN QUERY SELECT destino;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION rutadir(id_tramite INTEGER)
RETURNS TABLE(ruta TEXT) AS $$
DECLARE
  unidad VARCHAR;
  dir TEXT;
BEGIN
  SELECT valor INTO unidad FROM configuracion WHERE clave = 'UnidadImg' LIMIT 1;
  IF unidad IS NULL OR TRIM(unidad) = '' THEN
    unidad := 'N';
  END IF;
  IF id_tramite BETWEEN 1 AND 999 THEN
    dir := unidad || 'trlic00000';
  ELSIF id_tramite BETWEEN 1000 AND 9999 THEN
    dir := unidad || 'trlic0' || (id_tramite/1000)::INT || '000';
  ELSIF id_tramite BETWEEN 10000 AND 999999 THEN
    dir := unidad || 'trlic' || (id_tramite/1000)::INT || '000';
  ELSE
    dir := unidad;
  END IF;
  RETURN QUERY SELECT dir;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_log_navigation_event(p_user_id integer, p_url text, p_ip text)
RETURNS void AS $$
BEGIN
    INSERT INTO navigation_events(user_id, url, ip_address, event_time)
    VALUES (p_user_id, p_url, p_ip, NOW());
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_zonaanuncio_get(p_anuncio INTEGER)
RETURNS TABLE(anuncio INTEGER, zona SMALLINT, subzona SMALLINT, recaud SMALLINT, feccap TIMESTAMP, capturista VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT anuncio, zona, subzona, recaud, feccap, capturista FROM anuncios_zona WHERE anuncio = p_anuncio;
END; $$;

CREATE OR REPLACE FUNCTION sp_zonaanuncio_list(p_anuncio INTEGER)
RETURNS TABLE(anuncio INTEGER, zona SMALLINT, subzona SMALLINT, recaud SMALLINT, feccap TIMESTAMP, capturista VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT anuncio, zona, subzona, recaud, feccap, capturista FROM anuncios_zona WHERE anuncio = p_anuncio;
END; $$;

CREATE OR REPLACE FUNCTION sp_zonaanuncio_create(p_anuncio INTEGER, p_zona SMALLINT, p_subzona SMALLINT, p_recaud SMALLINT, p_capturista VARCHAR)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO anuncios_zona (anuncio, zona, subzona, recaud, feccap, capturista)
  VALUES (p_anuncio, p_zona, p_subzona, p_recaud, NOW(), p_capturista);
END; $$;

CREATE OR REPLACE FUNCTION sp_zonaanuncio_update(p_anuncio INTEGER, p_zona SMALLINT, p_subzona SMALLINT, p_recaud SMALLINT, p_capturista VARCHAR)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE anuncios_zona SET zona = p_zona, subzona = p_subzona, recaud = p_recaud, feccap = NOW(), capturista = p_capturista
  WHERE anuncio = p_anuncio;
END; $$;

CREATE OR REPLACE FUNCTION sp_zonaanuncio_delete(p_anuncio INTEGER)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
  DELETE FROM anuncios_zona WHERE anuncio = p_anuncio;
END; $$;

CREATE OR REPLACE FUNCTION sp_save_licencias_zona(p_licencia INTEGER, p_zona SMALLINT, p_subzona SMALLINT, p_recaud SMALLINT, p_capturista VARCHAR)
RETURNS VOID AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM licencias_zona WHERE licencia = p_licencia) THEN
    UPDATE licencias_zona SET zona = p_zona, subzona = p_subzona, recaud = p_recaud, feccap = NOW(), capturista = p_capturista WHERE licencia = p_licencia;
  ELSE
    INSERT INTO licencias_zona (licencia, zona, subzona, recaud, feccap, capturista) VALUES (p_licencia, p_zona, p_subzona, p_recaud, NOW(), p_capturista);
  END IF;
END;
$$ LANGUAGE plpgsql;