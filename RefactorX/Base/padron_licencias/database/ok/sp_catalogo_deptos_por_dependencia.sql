-- ============================================
-- Stored Procedure: sp_catalogo_deptos_por_dependencia
-- Base de Datos: padron_licencias
-- Esquema: comun
-- Descripción: Devuelve el catálogo de departamentos para una dependencia
-- Tablas: comun.deptos
-- Fecha: 2025-11-03
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_catalogo_deptos_por_dependencia(
    p_id_dependencia INTEGER
)
RETURNS TABLE (
    cvedepto INTEGER,
    nombredepto VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.cvedepto,
        TRIM(d.nombredepto)::VARCHAR
    FROM comun.deptos d
    WHERE d.cvedependencia = p_id_dependencia
    ORDER BY d.nombredepto;
END;
$$ LANGUAGE plpgsql;

-- Comentarios
COMMENT ON FUNCTION comun.sp_catalogo_deptos_por_dependencia(INTEGER) IS 'Devuelve el catálogo de departamentos para una dependencia';
