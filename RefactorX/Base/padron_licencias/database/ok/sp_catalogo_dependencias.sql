-- ============================================
-- Stored Procedure: sp_catalogo_dependencias
-- Base de Datos: padron_licencias
-- Esquema: comun
-- Descripción: Devuelve el catálogo de dependencias ordenado por descripción
-- Tablas: comun.c_dependencias
-- Fecha: 2025-11-03
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_catalogo_dependencias()
RETURNS TABLE (
    id_dependencia INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id_dependencia,
        c.descripcion
    FROM comun.c_dependencias c
    ORDER BY c.descripcion;
END;
$$ LANGUAGE plpgsql;

-- Comentarios
COMMENT ON FUNCTION comun.sp_catalogo_dependencias() IS 'Devuelve el catálogo de dependencias ordenado por descripción';
