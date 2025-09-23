-- Stored Procedure: sp_giros_vigentes_cte_x_giro
-- Tipo: Report
-- Descripción: Obtiene el conteo de licencias agrupadas por giro, filtrando por año o rango de fechas, vigencia y clasificación.
-- Generado para formulario: girosVigentesCteXgirofrm
-- Fecha: 2025-08-26 16:41:30

CREATE OR REPLACE FUNCTION sp_giros_vigentes_cte_x_giro(
    p_year INTEGER DEFAULT NULL,
    p_date_from DATE DEFAULT NULL,
    p_date_to DATE DEFAULT NULL,
    p_vigente CHAR(1) DEFAULT 'V',
    p_clasificacion CHAR(1) DEFAULT NULL,
    p_order_by TEXT DEFAULT 'descripcion'
)
RETURNS TABLE(
    cuantos INTEGER,
    id_giro INTEGER,
    cod_giro INTEGER,
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(l.licencia) AS cuantos, l.id_giro, g.cod_giro, g.descripcion
    FROM licencias l
    JOIN c_giros g ON g.id_giro = l.id_giro
    WHERE
        (
            (p_year IS NOT NULL AND (
                (p_vigente = 'V' AND l.fecha_otorgamiento >= TO_DATE(p_year || '-01-01', 'YYYY-MM-DD') AND l.fecha_otorgamiento <= TO_DATE(p_year || '-12-31', 'YYYY-MM-DD'))
                OR
                (p_vigente <> 'V' AND l.fecha_baja >= TO_DATE(p_year || '-01-01', 'YYYY-MM-DD') AND l.fecha_baja <= TO_DATE(p_year || '-12-31', 'YYYY-MM-DD'))
            ))
            OR
            (p_year IS NULL AND p_date_from IS NOT NULL AND p_date_to IS NOT NULL AND (
                (p_vigente = 'V' AND l.fecha_otorgamiento >= p_date_from AND l.fecha_otorgamiento <= p_date_to)
                OR
                (p_vigente <> 'V' AND l.fecha_baja >= p_date_from AND l.fecha_baja <= p_date_to)
            ))
            OR
            (p_year IS NULL AND p_date_from IS NULL AND p_date_to IS NULL)
        )
        AND (
            (p_vigente = 'V' AND l.vigente = 'V')
            OR
            (p_vigente <> 'V' AND l.vigente <> 'V')
        )
        AND (p_clasificacion IS NULL OR g.clasificacion = p_clasificacion)
    GROUP BY l.id_giro, g.cod_giro, g.descripcion
    ORDER BY
        CASE WHEN p_order_by = 'cuantos' THEN COUNT(l.licencia) END DESC,
        CASE WHEN p_order_by = 'descripcion' THEN g.descripcion END;
END;
$$ LANGUAGE plpgsql;