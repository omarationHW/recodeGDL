-- Stored Procedure: sp_get_actividades
-- Tipo: Catalog
-- Descripción: Obtiene el listado de actividades filtradas por texto.
-- Generado para formulario: CatalogoActividadesFrm
-- Fecha: 2025-08-26 15:14:33

CREATE OR REPLACE FUNCTION sp_get_actividades(p_search TEXT DEFAULT NULL)
RETURNS TABLE (
    id_actividad INTEGER,
    id_giro INTEGER,
    descripcion VARCHAR,
    observaciones VARCHAR,
    vigente CHAR(1),
    fecha_alta TIMESTAMP,
    usuario_alta VARCHAR,
    fecha_baja TIMESTAMP,
    usuario_baja VARCHAR,
    motivo_baja VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM c_actividades_lic
    WHERE (p_search IS NULL OR descripcion ILIKE '%'||p_search||'%' OR observaciones ILIKE '%'||p_search||'%')
    ORDER BY id_actividad DESC;
END;
$$ LANGUAGE plpgsql;