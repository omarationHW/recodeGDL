-- ============================================
-- STORED PROCEDURES PARA Exclusivos_Upd.vue
-- Módulo: multas_reglamentos
-- Fecha: 2025-11-25
-- Descripción: SPs para actualización de exclusivos
-- ============================================

-- ============================================
-- SP 1/3: exclusivos_upd_sp_get_zonas
-- Obtiene catálogo de zonas para exclusivos
-- ============================================
DROP FUNCTION IF EXISTS exclusivos_upd_sp_get_zonas();

CREATE OR REPLACE FUNCTION exclusivos_upd_sp_get_zonas()
RETURNS TABLE (
    id VARCHAR,
    nombre VARCHAR
) AS $$
BEGIN
    -- Las zonas de exclusivos son A, B, C
    RETURN QUERY
    SELECT DISTINCT
        c.zona::VARCHAR AS id,
        CASE c.zona
            WHEN 'A' THEN 'Zona A - Centro'
            WHEN 'B' THEN 'Zona B - Minerva'
            WHEN 'C' THEN 'Zona C - Otros'
            ELSE COALESCE(c.zona, 'Sin zona')
        END::VARCHAR AS nombre
    FROM comun.ex_contrato c
    WHERE c.zona IS NOT NULL AND c.zona != ''
    ORDER BY 1;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION exclusivos_upd_sp_get_zonas() IS 'Obtiene catálogo de zonas para módulo de exclusivos';

-- ============================================
-- SP 2/3: exclusivos_upd_sp_buscar
-- Busca exclusivo por folio y/o zona
-- ============================================
DROP FUNCTION IF EXISTS exclusivos_upd_sp_buscar(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION exclusivos_upd_sp_buscar(
    p_folio INTEGER DEFAULT 0,
    p_zona INTEGER DEFAULT 0
)
RETURNS TABLE (
    folio INTEGER,
    titular VARCHAR,
    domicilio VARCHAR,
    id_zona VARCHAR,
    estado VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.no_exclusivo::INTEGER AS folio,
        COALESCE(p.propietario, '')::VARCHAR AS titular,
        COALESCE(c.vialidad, '')::VARCHAR AS domicilio,
        COALESCE(c.zona, '')::VARCHAR AS id_zona,
        COALESCE(c.estatus, 'V')::VARCHAR AS estado
    FROM comun.ex_contrato c
    LEFT JOIN dbestacion.ex_propietario p ON c.ex_propietario_id = p.id
    WHERE
        (p_folio = 0 OR c.no_exclusivo = p_folio)
    ORDER BY c.no_exclusivo
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION exclusivos_upd_sp_buscar(INTEGER, INTEGER) IS 'Busca exclusivos por folio y/o zona';

-- ============================================
-- SP 3/3: exclusivos_upd_sp_update
-- Actualiza datos de un exclusivo
-- ============================================
DROP FUNCTION IF EXISTS exclusivos_upd_sp_update(INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION exclusivos_upd_sp_update(
    p_folio INTEGER,
    p_titular VARCHAR DEFAULT '',
    p_domicilio VARCHAR DEFAULT '',
    p_id_zona VARCHAR DEFAULT '',
    p_estado VARCHAR DEFAULT 'V'
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR,
    rows_affected INTEGER
) AS $$
DECLARE
    v_propietario_id INTEGER;
    v_rows INTEGER := 0;
BEGIN
    -- Validar que el folio exista
    IF NOT EXISTS (SELECT 1 FROM comun.ex_contrato WHERE no_exclusivo = p_folio) THEN
        RETURN QUERY SELECT FALSE, 'El folio no existe'::VARCHAR, 0;
        RETURN;
    END IF;

    -- Obtener el id del propietario asociado
    SELECT ex_propietario_id INTO v_propietario_id
    FROM comun.ex_contrato
    WHERE no_exclusivo = p_folio;

    -- Actualizar nombre del propietario si existe
    IF v_propietario_id IS NOT NULL AND p_titular != '' THEN
        UPDATE dbestacion.ex_propietario
        SET propietario = p_titular
        WHERE id = v_propietario_id;
    END IF;

    -- Actualizar el contrato exclusivo
    UPDATE comun.ex_contrato
    SET
        vialidad = CASE WHEN p_domicilio != '' THEN p_domicilio ELSE vialidad END,
        zona = CASE WHEN p_id_zona != '' THEN p_id_zona ELSE zona END,
        estatus = CASE WHEN p_estado != '' THEN p_estado ELSE estatus END,
        fecha_at = NOW()
    WHERE no_exclusivo = p_folio;

    GET DIAGNOSTICS v_rows = ROW_COUNT;

    IF v_rows > 0 THEN
        RETURN QUERY SELECT TRUE, 'Registro actualizado correctamente'::VARCHAR, v_rows;
    ELSE
        RETURN QUERY SELECT FALSE, 'No se pudo actualizar el registro'::VARCHAR, 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION exclusivos_upd_sp_update(INTEGER, VARCHAR, VARCHAR, INTEGER, VARCHAR) IS 'Actualiza datos de un exclusivo';

-- ============================================
-- Verificación de SPs creados
-- ============================================
SELECT 'SPs Exclusivos_Upd creados correctamente' AS status;
