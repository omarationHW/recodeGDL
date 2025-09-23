-- Stored Procedure: repavance_generate_report
-- Tipo: Report
-- Descripción: Genera el reporte de avance de recaudación de multas para un mes, año, recaudadora y tipo (municipal/federal). Devuelve un JSON con el detalle por dependencia.
-- Generado para formulario: repavance
-- Fecha: 2025-08-27 15:59:58

-- PostgreSQL stored procedure for repavance report
CREATE OR REPLACE FUNCTION repavance_generate_report(
    p_recaudadora_id INTEGER,
    p_minimo DATE,
    p_maximo DATE,
    p_tipo CHAR(1),
    p_anio INTEGER
) RETURNS TABLE(report_data JSON) AS $$
DECLARE
    v_detalle JSON;
BEGIN
    -- Simulación de la lógica de procesamiento y agregación
    -- Se asume que existen tablas: multas, dependencias, etc.
    -- El resultado es un array de objetos por dependencia
    v_detalle := (
        SELECT json_agg(row_to_json(t)) FROM (
            SELECT
                d.id AS id_dependencia,
                d.descripcion,
                -- Actas y totales del periodo
                COALESCE(SUM(CASE WHEN m.fecha_recepcion BETWEEN p_minimo AND p_maximo AND m.tipo = p_tipo THEN 1 ELSE 0 END),0) AS cuantos1,
                COALESCE(SUM(CASE WHEN m.fecha_recepcion BETWEEN p_minimo AND p_maximo AND m.tipo = p_tipo THEN m.calificacion ELSE 0 END),0) AS total1,
                -- Actas y totales de otro criterio (ejemplo: pagadas)
                COALESCE(SUM(CASE WHEN m.fecha_pago BETWEEN p_minimo AND p_maximo AND m.tipo = p_tipo THEN 1 ELSE 0 END),0) AS cuantos2,
                COALESCE(SUM(CASE WHEN m.fecha_pago BETWEEN p_minimo AND p_maximo AND m.tipo = p_tipo THEN m.calificacion ELSE 0 END),0) AS total2,
                -- Actas y totales de otro criterio (ejemplo: canceladas)
                COALESCE(SUM(CASE WHEN m.fecha_cancelacion BETWEEN p_minimo AND p_maximo AND m.tipo = p_tipo THEN 1 ELSE 0 END),0) AS cuantos3,
                COALESCE(SUM(CASE WHEN m.fecha_cancelacion BETWEEN p_minimo AND p_maximo AND m.tipo = p_tipo THEN m.calificacion ELSE 0 END),0) AS total3,
                -- Actas y totales de saldo actual (simulado)
                COALESCE(SUM(CASE WHEN m.fecha_recepcion <= p_maximo AND m.tipo = p_tipo THEN 1 ELSE 0 END),0) AS cuantos4,
                COALESCE(SUM(CASE WHEN m.fecha_recepcion <= p_maximo AND m.tipo = p_tipo THEN m.calificacion ELSE 0 END),0) AS total4
            FROM dependencias d
            LEFT JOIN multas m ON m.id_dependencia = d.id AND m.recaud = p_recaudadora_id
            GROUP BY d.id, d.descripcion
            ORDER BY d.descripcion
        ) t
    );
    RETURN QUERY SELECT json_build_object('detalle', v_detalle);
END;
$$ LANGUAGE plpgsql;
