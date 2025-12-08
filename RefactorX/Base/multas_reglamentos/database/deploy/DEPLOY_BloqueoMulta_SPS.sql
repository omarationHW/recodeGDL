-- ============================================
-- STORED PROCEDURES PARA BloqueoMulta
-- Modulo: multas_reglamentos
-- Fecha: 2025-11-25
-- ============================================

-- Tabla de bloqueos de multas
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS bloqueo_multas (
    id_bloqueo SERIAL PRIMARY KEY,
    clave_cuenta VARCHAR(50) NOT NULL,
    folio INTEGER NOT NULL,
    ejercicio INTEGER NOT NULL,
    fecha_bloqueo DATE NOT NULL DEFAULT CURRENT_DATE,
    usuario_bloqueo VARCHAR(50),
    motivo TEXT,
    estatus VARCHAR(20) DEFAULT 'BLOQUEADO',
    fecha_desbloqueo DATE,
    usuario_desbloqueo VARCHAR(50),
    motivo_desbloqueo TEXT,
    UNIQUE(clave_cuenta, folio, ejercicio)
);

-- SP 1: bloqueomulta_sp_list
-- Lista bloqueos con filtros y paginación
-- --------------------------------------------
CREATE OR REPLACE FUNCTION bloqueomulta_sp_list(p_params JSONB)
RETURNS TABLE(
    id_bloqueo INTEGER,
    clave_cuenta TEXT,
    folio INTEGER,
    ejercicio INTEGER,
    fecha_bloqueo DATE,
    usuario_bloqueo TEXT,
    motivo TEXT,
    estatus TEXT,
    fecha_desbloqueo DATE,
    usuario_desbloqueo TEXT,
    total BIGINT
) AS $$
DECLARE
    v_cuenta TEXT;
    v_ejercicio INTEGER;
    v_offset INTEGER;
    v_limit INTEGER;
BEGIN
    v_cuenta := p_params->>'cuenta';
    v_ejercicio := (p_params->>'ejercicio')::INTEGER;
    v_offset := COALESCE((p_params->>'offset')::INTEGER, 0);
    v_limit := COALESCE((p_params->>'limit')::INTEGER, 10);

    RETURN QUERY
    WITH filtered AS (
        SELECT
            b.id_bloqueo,
            b.clave_cuenta::TEXT,
            b.folio,
            b.ejercicio,
            b.fecha_bloqueo,
            b.usuario_bloqueo::TEXT,
            b.motivo::TEXT,
            b.estatus::TEXT,
            b.fecha_desbloqueo,
            b.usuario_desbloqueo::TEXT
        FROM bloqueo_multas b
        WHERE (v_cuenta IS NULL OR v_cuenta = '' OR b.clave_cuenta ILIKE '%' || v_cuenta || '%')
          AND (v_ejercicio IS NULL OR b.ejercicio = v_ejercicio)
        ORDER BY b.fecha_bloqueo DESC, b.id_bloqueo DESC
    ),
    counted AS (
        SELECT COUNT(*) AS cnt FROM filtered
    )
    SELECT
        f.id_bloqueo,
        f.clave_cuenta,
        f.folio,
        f.ejercicio,
        f.fecha_bloqueo,
        f.usuario_bloqueo,
        f.motivo,
        f.estatus,
        f.fecha_desbloqueo,
        f.usuario_desbloqueo,
        c.cnt AS total
    FROM filtered f
    CROSS JOIN counted c
    OFFSET v_offset
    LIMIT v_limit;
END;
$$ LANGUAGE plpgsql;

-- SP 2: bloqueomulta_sp_crear_bloqueo
-- Crea un nuevo bloqueo de multa
-- --------------------------------------------
CREATE OR REPLACE FUNCTION bloqueomulta_sp_crear_bloqueo(p_params JSONB)
RETURNS JSONB AS $$
DECLARE
    v_clave_cuenta TEXT;
    v_folio INTEGER;
    v_ejercicio INTEGER;
    v_motivo TEXT;
    v_usuario TEXT;
    v_id_bloqueo INTEGER;
BEGIN
    v_clave_cuenta := p_params->>'clave_cuenta';
    v_folio := (p_params->>'folio')::INTEGER;
    v_ejercicio := (p_params->>'ejercicio')::INTEGER;
    v_motivo := p_params->>'motivo';
    v_usuario := COALESCE(p_params->>'usuario', 'SISTEMA');

    -- Verificar si ya existe un bloqueo activo
    SELECT id_bloqueo INTO v_id_bloqueo
    FROM bloqueo_multas
    WHERE clave_cuenta = v_clave_cuenta
      AND folio = v_folio
      AND ejercicio = v_ejercicio
      AND estatus = 'BLOQUEADO';

    IF v_id_bloqueo IS NOT NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'id_bloqueo', 0,
            'mensaje', 'Ya existe un bloqueo activo para esta multa'
        );
    END IF;

    -- Insertar nuevo bloqueo
    INSERT INTO bloqueo_multas (
        clave_cuenta, folio, ejercicio, fecha_bloqueo,
        usuario_bloqueo, motivo, estatus
    ) VALUES (
        v_clave_cuenta, v_folio, v_ejercicio, CURRENT_DATE,
        v_usuario, v_motivo, 'BLOQUEADO'
    )
    ON CONFLICT (clave_cuenta, folio, ejercicio) DO UPDATE
    SET fecha_bloqueo = CURRENT_DATE,
        usuario_bloqueo = v_usuario,
        motivo = v_motivo,
        estatus = 'BLOQUEADO',
        fecha_desbloqueo = NULL,
        usuario_desbloqueo = NULL
    RETURNING id_bloqueo INTO v_id_bloqueo;

    RETURN jsonb_build_object(
        'success', true,
        'id_bloqueo', v_id_bloqueo,
        'mensaje', 'Bloqueo creado correctamente'
    );
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'success', false,
        'id_bloqueo', 0,
        'mensaje', SQLERRM
    );
END;
$$ LANGUAGE plpgsql;

-- SP 3: bloqueomulta_sp_quitar_bloqueo
-- Quita un bloqueo existente
-- --------------------------------------------
CREATE OR REPLACE FUNCTION bloqueomulta_sp_quitar_bloqueo(p_params JSONB)
RETURNS JSONB AS $$
DECLARE
    v_id_bloqueo INTEGER;
    v_usuario TEXT;
    v_motivo_desbloqueo TEXT;
    v_rows_affected INTEGER;
BEGIN
    v_id_bloqueo := (p_params->>'id_bloqueo')::INTEGER;
    v_usuario := COALESCE(p_params->>'usuario', 'SISTEMA');
    v_motivo_desbloqueo := p_params->>'motivo_desbloqueo';

    UPDATE bloqueo_multas
    SET estatus = 'DESBLOQUEADO',
        fecha_desbloqueo = CURRENT_DATE,
        usuario_desbloqueo = v_usuario,
        motivo_desbloqueo = v_motivo_desbloqueo
    WHERE id_bloqueo = v_id_bloqueo
      AND estatus = 'BLOQUEADO';

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    IF v_rows_affected > 0 THEN
        RETURN jsonb_build_object(
            'success', true,
            'mensaje', 'Multa desbloqueada correctamente'
        );
    ELSE
        RETURN jsonb_build_object(
            'success', false,
            'mensaje', 'No se encontro el bloqueo o ya esta desbloqueado'
        );
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'success', false,
        'mensaje', SQLERRM
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIN DE STORED PROCEDURES
-- ============================================
