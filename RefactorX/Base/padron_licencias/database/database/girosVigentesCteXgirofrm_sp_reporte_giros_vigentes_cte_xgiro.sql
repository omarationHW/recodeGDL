-- Stored Procedure: sp_reporte_giros_vigentes_cte_xgiro
-- Tipo: Report
-- Descripción: Obtiene el reporte de giros vigentes/cancelados agrupados por giro, con filtros por año, rango de fechas, clasificación y orden.
-- Generado para formulario: girosVigentesCteXgirofrm
-- Fecha: 2025-08-27 18:12:19

-- PostgreSQL stored procedure for giros vigentes/cancelados agrupados por giro
CREATE OR REPLACE FUNCTION sp_reporte_giros_vigentes_cte_xgiro(
    p_vigente CHAR(1),
    p_year INTEGER DEFAULT NULL,
    p_date_from DATE DEFAULT NULL,
    p_date_to DATE DEFAULT NULL,
    p_clasificacion CHAR(1) DEFAULT NULL,
    p_order_by TEXT DEFAULT 'cuantos'
)
RETURNS TABLE(
    cuantos INTEGER,
    id_giro INTEGER,
    cod_giro INTEGER,
    descripcion TEXT
) AS $$
DECLARE
    v_sql TEXT;
BEGIN
    v_sql := 'SELECT COUNT(l.licencia) AS cuantos, l.id_giro, g.cod_giro, g.descripcion '
           || 'FROM licencias l JOIN c_giros g ON g.id_giro = l.id_giro '
           || 'WHERE l.vigente = $1';
    IF p_year IS NOT NULL THEN
        IF p_vigente = 'V' THEN
            v_sql := v_sql || ' AND l.fecha_otorgamiento >= $2 AND l.fecha_otorgamiento <= $3';
        ELSE
            v_sql := v_sql || ' AND l.fecha_baja >= $2 AND l.fecha_baja <= $3';
        END IF;
    ELSIF p_date_from IS NOT NULL AND p_date_to IS NOT NULL THEN
        IF p_vigente = 'V' THEN
            v_sql := v_sql || ' AND l.fecha_otorgamiento >= $2 AND l.fecha_otorgamiento <= $3';
        ELSE
            v_sql := v_sql || ' AND l.fecha_baja >= $2 AND l.fecha_baja <= $3';
        END IF;
    END IF;
    IF p_clasificacion IS NOT NULL AND p_clasificacion <> '' THEN
        v_sql := v_sql || ' AND g.clasificacion = $4';
    END IF;
    v_sql := v_sql || ' GROUP BY l.id_giro, g.cod_giro, g.descripcion';
    IF p_order_by = 'descripcion' THEN
        v_sql := v_sql || ' ORDER BY g.descripcion';
    ELSE
        v_sql := v_sql || ' ORDER BY cuantos DESC';
    END IF;

    RETURN QUERY EXECUTE v_sql
        USING p_vigente,
              COALESCE(p_year::TEXT, p_date_from::TEXT),
              COALESCE((p_year::TEXT || '-12-31')::DATE, p_date_to),
              p_clasificacion;
END;
$$ LANGUAGE plpgsql;