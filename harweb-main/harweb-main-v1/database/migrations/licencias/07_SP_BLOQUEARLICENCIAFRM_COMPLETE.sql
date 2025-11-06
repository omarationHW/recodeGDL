-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: catastro_gdl
-- ============================================
\c padron_licencias;
SET search_path TO catastro_gdl;

-- ============================================
-- STORED PROCEDURES COMPLETOS - LICENCIAS
-- Formulario: BLOQUEARLICENCIAFRM
-- Archivo: 07_SP_BLOQUEARLICENCIAFRM_COMPLETE.sql
-- Fecha: 2025-11-05
-- Total SPs: 7 (COMPLETO)
-- ============================================

-- SP 1/7: buscar_licencia
-- Tipo: Catalog
-- Descripción: Busca una licencia por su número y devuelve todos sus datos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION buscar_licencia(numero_licencia INTEGER)
RETURNS TABLE(
    id_licencia INTEGER,
    licencia INTEGER,
    giro TEXT,
    fecha_expedicion DATE,
    vigencia_hasta DATE,
    nombre_propietario TEXT,
    ubicacion TEXT,
    bloqueado INTEGER,
    dias_vigencia INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_licencia,
        l.licencia,
        COALESCE(g.descripcion, 'Sin giro') AS giro,
        l.fecha_expedicion,
        l.vigencia_hasta,
        COALESCE(
            TRIM(CONCAT(p.nombre, ' ', p.apellido_paterno, ' ', p.apellido_materno)),
            'Sin propietario'
        ) AS nombre_propietario,
        COALESCE(pu.ubicacion, 'Sin ubicación') AS ubicacion,
        COALESCE(l.bloqueado, 0) AS bloqueado,
        CASE
            WHEN l.vigencia_hasta IS NOT NULL THEN
                (l.vigencia_hasta - CURRENT_DATE)::INTEGER
            ELSE
                NULL
        END AS dias_vigencia
    FROM licencias l
    LEFT JOIN giros g ON l.id_giro = g.id_giro
    LEFT JOIN public pu ON l.id_licencia = pu.id_licencia
    LEFT JOIN propietarios p ON l.id_propietario = p.id_propietario
    WHERE l.licencia = numero_licencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 2/7: sp_tipobloqueo_list
-- Tipo: Catalog
-- Descripción: Lista todos los tipos de bloqueo disponibles.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipobloqueo_list()
RETURNS TABLE(
    id INTEGER,
    descripcion TEXT,
    multa_base NUMERIC,
    requiere_apelacion CHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        id_tipo_bloqueo AS id,
        descripcion,
        COALESCE(multa_base, 0.00) AS multa_base,
        COALESCE(requiere_apelacion, 'N') AS requiere_apelacion
    FROM tipos_bloqueo
    WHERE activo = 1
    ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 3/7: sp_bloquear_licencia
-- Tipo: CRUD
-- Descripción: Bloquea una licencia, registra el movimiento y actualiza el estado de la licencia y domicilio si aplica.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_bloquear_licencia(
    p_id_licencia INTEGER,
    p_tipo_bloqueo INTEGER,
    p_motivo TEXT,
    p_usuario TEXT
) RETURNS TABLE(
    success INTEGER,
    message TEXT
) AS $$
DECLARE
    v_calle TEXT;
    v_cvecalle INTEGER;
    v_noext TEXT;
    v_noint TEXT;
    v_letext TEXT;
    v_letint TEXT;
    v_bloqueos INT;
    v_bloqueado_actual INTEGER;
BEGIN
    -- Verificar si la licencia existe
    SELECT bloqueado INTO v_bloqueado_actual FROM licencias WHERE id_licencia = p_id_licencia;

    IF NOT FOUND THEN
        RETURN QUERY SELECT 0 AS success, 'Licencia no encontrada'::TEXT AS message;
        RETURN;
    END IF;

    -- Verificar si ya está bloqueada
    IF v_bloqueado_actual > 0 THEN
        RETURN QUERY SELECT 0 AS success, 'La licencia ya está bloqueada. Primero debe desbloquearse.'::TEXT AS message;
        RETURN;
    END IF;

    -- Actualiza la licencia
    UPDATE licencias SET bloqueado = p_tipo_bloqueo WHERE id_licencia = p_id_licencia;

    -- Cancela bloqueos vigentes del mismo tipo
    UPDATE bloqueo SET vigente = 'C'
    WHERE id_licencia = p_id_licencia AND vigente = 'V' AND bloqueado = p_tipo_bloqueo;

    -- Inserta el nuevo bloqueo
    INSERT INTO bloqueo (bloqueado, id_licencia, observa, capturista, fecha_mov, vigente)
    VALUES (p_tipo_bloqueo, p_id_licencia, p_motivo, p_usuario, CURRENT_TIMESTAMP, 'V');

    -- Si el tipo de bloqueo no es 'responsiva' (5), bloquea domicilio si no hay otro bloqueo activo
    IF p_tipo_bloqueo <> 5 THEN
        SELECT ubicacion, cvecalle, numext_ubic::TEXT, numint_ubic::TEXT, letraext_ubic, letraint_ubic
        INTO v_calle, v_cvecalle, v_noext, v_noint, v_letext, v_letint
        FROM public WHERE id_licencia = p_id_licencia;

        SELECT COUNT(*) INTO v_bloqueos FROM bloqueo
        WHERE id_licencia = p_id_licencia AND vigente = 'V' AND bloqueado > 0;

        IF v_bloqueos = 1 THEN
            INSERT INTO bloqueo_dom (calle, cvecalle, num_ext, let_ext, num_int, let_int, observacion, vig, fecha, capturista)
            VALUES (v_calle, v_cvecalle, v_noext, v_letext, v_noint, v_letint, p_motivo, 'V', CURRENT_DATE, p_usuario);
        END IF;
    END IF;

    RETURN QUERY SELECT 1 AS success, 'Licencia bloqueada correctamente'::TEXT AS message;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 4/7: sp_desbloquear_licencia
-- Tipo: CRUD
-- Descripción: Desbloquea una licencia, registra el movimiento y actualiza el estado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_desbloquear_licencia(
    p_id_licencia INTEGER,
    p_tipo_bloqueo INTEGER,
    p_motivo TEXT,
    p_usuario TEXT
) RETURNS TABLE(
    success INTEGER,
    message TEXT
) AS $$
DECLARE
    v_bloqueado INTEGER;
    v_calle TEXT;
    v_cvecalle INTEGER;
    v_noext TEXT;
    v_noint TEXT;
    v_letext TEXT;
    v_letint TEXT;
    v_bloqueos INTEGER;
BEGIN
    -- Verificar si la licencia existe y está bloqueada con ese tipo
    SELECT bloqueado INTO v_bloqueado FROM licencias WHERE id_licencia = p_id_licencia;

    IF NOT FOUND THEN
        RETURN QUERY SELECT 0 AS success, 'Licencia no encontrada'::TEXT AS message;
        RETURN;
    END IF;

    IF v_bloqueado = 0 THEN
        RETURN QUERY SELECT 0 AS success, 'La licencia no está bloqueada'::TEXT AS message;
        RETURN;
    END IF;

    -- Actualiza la licencia a desbloqueada
    UPDATE licencias SET bloqueado = 0 WHERE id_licencia = p_id_licencia;

    -- Cancela todos los bloqueos vigentes
    UPDATE bloqueo SET vigente = 'C'
    WHERE id_licencia = p_id_licencia AND vigente = 'V' AND bloqueado > 0;

    -- Inserta el movimiento de desbloqueo
    INSERT INTO bloqueo (bloqueado, id_licencia, observa, capturista, fecha_mov, vigente)
    VALUES (0, p_id_licencia, p_motivo, p_usuario, CURRENT_TIMESTAMP, 'V');

    -- Verificar si hay otros bloqueos activos
    SELECT COUNT(*) INTO v_bloqueos FROM bloqueo
    WHERE id_licencia = p_id_licencia AND vigente = 'V' AND bloqueado > 0;

    -- Si no hay más bloqueos activos, desbloquear el domicilio
    IF v_bloqueos = 0 THEN
        SELECT ubicacion, cvecalle, numext_ubic::TEXT, numint_ubic::TEXT, letraext_ubic, letraint_ubic
        INTO v_calle, v_cvecalle, v_noext, v_noint, v_letext, v_letint
        FROM public WHERE id_licencia = p_id_licencia;

        -- Cancelar bloqueos de domicilio vigentes
        UPDATE bloqueo_dom SET vig = 'C'
        WHERE calle = v_calle AND cvecalle = v_cvecalle
          AND num_ext = v_noext AND let_ext = v_letext
          AND num_int = v_noint AND let_int = v_letint
          AND vig = 'V';
    END IF;

    RETURN QUERY SELECT 1 AS success, 'Licencia desbloqueada correctamente'::TEXT AS message;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 5/7: sp_validar_bloqueo_licencia
-- Tipo: Validation
-- Descripción: Valida si se puede bloquear/desbloquear una licencia.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_validar_bloqueo_licencia(
    p_id_licencia INTEGER,
    p_accion TEXT,
    p_tipo_bloqueo INTEGER
) RETURNS TABLE(
    puede_proceder INTEGER,
    mensaje TEXT
) AS $$
DECLARE
    v_bloqueado INTEGER;
    v_tiene_adeudos BOOLEAN;
BEGIN
    -- Verificar si la licencia existe
    SELECT bloqueado INTO v_bloqueado FROM licencias WHERE id_licencia = p_id_licencia;

    IF NOT FOUND THEN
        RETURN QUERY SELECT 0 AS puede_proceder, 'Licencia no encontrada'::TEXT AS mensaje;
        RETURN;
    END IF;

    IF p_accion = 'BLOQUEAR' THEN
        IF v_bloqueado > 0 THEN
            RETURN QUERY SELECT 0 AS puede_proceder, 'La licencia ya está bloqueada. Primero debe desbloquearse.'::TEXT AS mensaje;
            RETURN;
        END IF;

        RETURN QUERY SELECT 1 AS puede_proceder, 'La licencia puede bloquearse'::TEXT AS mensaje;
    ELSE
        -- DESBLOQUEAR
        IF v_bloqueado = 0 THEN
            RETURN QUERY SELECT 0 AS puede_proceder, 'La licencia no está bloqueada'::TEXT AS mensaje;
            RETURN;
        END IF;

        RETURN QUERY SELECT 1 AS puede_proceder, 'La licencia puede desbloquearse'::TEXT AS mensaje;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 6/7: sp_consultar_historial_licencia
-- Tipo: Report
-- Descripción: Consulta el historial completo de bloqueos de una licencia.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consultar_historial_licencia(
    p_id_licencia INTEGER
) RETURNS TABLE(
    id_bloqueo INTEGER,
    bloqueado INTEGER,
    fecha_mov TIMESTAMP,
    observa TEXT,
    capturista TEXT,
    vigente CHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.id_bloqueo,
        b.bloqueado,
        b.fecha_mov,
        COALESCE(b.observa, '') AS observa,
        COALESCE(b.capturista, 'Sistema') AS capturista,
        COALESCE(b.vigente, 'C') AS vigente
    FROM bloqueo b
    WHERE b.id_licencia = p_id_licencia
    ORDER BY b.fecha_mov DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 7/7: sp_consultar_historial_licencia_paginado
-- Tipo: Report
-- Descripción: Consulta el historial de bloqueos de una licencia con paginación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consultar_historial_licencia_paginado(
    p_id_licencia INTEGER,
    limit_records INTEGER DEFAULT 10,
    offset_records INTEGER DEFAULT 0
) RETURNS TABLE(
    id_bloqueo INTEGER,
    bloqueado INTEGER,
    fecha_mov TIMESTAMP,
    observa TEXT,
    capturista TEXT,
    vigente CHAR(1),
    total_registros BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.id_bloqueo,
        b.bloqueado,
        b.fecha_mov,
        COALESCE(b.observa, '') AS observa,
        COALESCE(b.capturista, 'Sistema') AS capturista,
        COALESCE(b.vigente, 'C') AS vigente,
        COUNT(*) OVER() AS total_registros
    FROM bloqueo b
    WHERE b.id_licencia = p_id_licencia
    ORDER BY b.fecha_mov DESC
    LIMIT limit_records
    OFFSET offset_records;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- GRANTS
-- ============================================
GRANT EXECUTE ON FUNCTION buscar_licencia(INTEGER) TO PUBLIC;
GRANT EXECUTE ON FUNCTION sp_tipobloqueo_list() TO PUBLIC;
GRANT EXECUTE ON FUNCTION sp_bloquear_licencia(INTEGER, INTEGER, TEXT, TEXT) TO PUBLIC;
GRANT EXECUTE ON FUNCTION sp_desbloquear_licencia(INTEGER, INTEGER, TEXT, TEXT) TO PUBLIC;
GRANT EXECUTE ON FUNCTION sp_validar_bloqueo_licencia(INTEGER, TEXT, INTEGER) TO PUBLIC;
GRANT EXECUTE ON FUNCTION sp_consultar_historial_licencia(INTEGER) TO PUBLIC;
GRANT EXECUTE ON FUNCTION sp_consultar_historial_licencia_paginado(INTEGER, INTEGER, INTEGER) TO PUBLIC;

-- ============================================
-- FIN DEL ARCHIVO
-- ============================================
