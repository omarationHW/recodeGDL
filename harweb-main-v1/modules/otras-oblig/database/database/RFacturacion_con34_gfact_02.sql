-- Stored Procedure: con34_gfact_02
-- Tipo: Report
-- Descripción: Genera el reporte de facturación del rastro filtrando por status de adeudo, recargos, año y mes.
-- Generado para formulario: RFacturacion
-- Fecha: 2025-08-28 13:40:36

-- PostgreSQL stored procedure equivalent for con34_gfact_02
-- Parámetros:
--   p_adeudo_status: 'A' (Adeudos y Pagos), 'B' (Solo Adeudos), 'C' (Solo Pagados)
--   p_adeudo_recargo: 'S' (con recargo), 'N' (sin recargo)
--   p_year: año a consultar
--   p_month: mes a consultar

CREATE OR REPLACE FUNCTION con34_gfact_02(
    p_adeudo_status VARCHAR(1),
    p_adeudo_recargo VARCHAR(1),
    p_year INTEGER,
    p_month INTEGER
)
RETURNS TABLE(
    control VARCHAR,
    concesionario VARCHAR,
    superficie NUMERIC,
    tipo VARCHAR,
    licencia VARCHAR,
    importe NUMERIC
) AS $$
BEGIN
    -- Ejemplo: la lógica real debe ajustarse a la estructura de la base de datos destino
    RETURN QUERY
    SELECT
        a.control,
        a.concesionario,
        a.superficie,
        a.tipo,
        a.licencia,
        a.importe
    FROM
        basephp.rastro_facturacion a
    WHERE
        (p_adeudo_status = 'A' OR (p_adeudo_status = 'B' AND a.pagado = false) OR (p_adeudo_status = 'C' AND a.pagado = true))
        AND (p_adeudo_recargo = 'N' OR (p_adeudo_recargo = 'S' AND a.recargo = true))
        AND a.anio = p_year
        AND a.mes = p_month;
END;
$$ LANGUAGE plpgsql;
