-- ============================================
-- STORED PROCEDURES - BusquedaActividadFrm
-- Módulo: padron_licencias
-- Base de Datos: padron_licencias
-- Esquema: comun
-- Fecha: 2025-11-20
-- Total SPs: 2
-- ============================================

-- Tabla involucrada: actividades (comun)

CREATE OR REPLACE FUNCTION public.sp_buscar_actividades(p_texto VARCHAR)
RETURNS TABLE (
    id_actividad INTEGER,
    clave_actividad VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_actividad, a.clave_actividad, a.descripcion
    FROM comun.actividades a
    WHERE UPPER(a.descripcion) LIKE '%' || UPPER(p_texto) || '%'
    OR UPPER(a.clave_actividad) LIKE '%' || UPPER(p_texto) || '%'
    ORDER BY a.descripcion
    LIMIT 50;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_buscar_actividad_por_id(p_id_actividad INTEGER)
RETURNS TABLE (
    id_actividad INTEGER,
    clave_actividad VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_actividad, a.clave_actividad, a.descripcion
    FROM comun.actividades a
    WHERE a.id_actividad = p_id_actividad;
END;
$$ LANGUAGE plpgsql;

SELECT 'Funciones creadas correctamente' as status;
