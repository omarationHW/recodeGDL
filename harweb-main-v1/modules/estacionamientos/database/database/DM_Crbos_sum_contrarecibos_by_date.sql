-- Stored Procedure: sum_contrarecibos_by_date
-- Tipo: Report
-- Descripción: Suma de importes de contrarecibos por fecha de ingreso
-- Generado para formulario: DM_Crbos
-- Fecha: 2025-08-27 13:33:33

-- PostgreSQL function for sum by date
CREATE OR REPLACE FUNCTION sum_contrarecibos_by_date(p_fecha DATE)
RETURNS NUMERIC(18,2) AS $$
DECLARE
    total NUMERIC(18,2);
BEGIN
    SELECT COALESCE(SUM(importe),0) INTO total FROM ta_contrarecibos WHERE fecha_ingreso = p_fecha;
    RETURN total;
END;
$$ LANGUAGE plpgsql;