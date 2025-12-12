CREATE OR REPLACE FUNCTION publico.recaudadora_proyecfrm(
    p_filtro VARCHAR
)
RETURNS TABLE (
    id_proyecto INTEGER,
    nombre_proyecto VARCHAR,
    descripcion TEXT,
    fecha_inicio DATE,
    fecha_fin DATE,
    estado VARCHAR,
    responsable VARCHAR,
    presupuesto NUMERIC,
    avance INTEGER,
    departamento VARCHAR,
    prioridad VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id_proyecto,
        p.nombre_proyecto::VARCHAR,
        p.descripcion,
        p.fecha_inicio,
        p.fecha_fin,
        p.estado::VARCHAR,
        p.responsable::VARCHAR,
        p.presupuesto,
        p.avance,
        p.departamento::VARCHAR,
        p.prioridad::VARCHAR
    FROM publico.proyectos p
    WHERE
        CASE
            WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
            ELSE (
                p.nombre_proyecto ILIKE '%' || p_filtro || '%'
                OR p.responsable ILIKE '%' || p_filtro || '%'
                OR p.departamento ILIKE '%' || p_filtro || '%'
                OR p.estado ILIKE '%' || p_filtro || '%'
                OR p.prioridad ILIKE '%' || p_filtro || '%'
            )
        END
    ORDER BY p.fecha_inicio DESC, p.id_proyecto DESC;
END; $$;
