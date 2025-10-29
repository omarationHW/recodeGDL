-- Stored Procedure: con34_1detade_01
-- Tipo: Report
-- Descripción: Obtiene los adeudos vencidos para un control y periodo dado.
-- Generado para formulario: RAdeudos
-- Fecha: 2025-08-28 13:29:07

CREATE OR REPLACE FUNCTION con34_1detade_01(par_Control integer, par_Rep varchar, par_Fecha varchar)
RETURNS TABLE(
    expression text,
    expression_1 numeric,
    expression_2 numeric
) AS $$
BEGIN
    -- Ejemplo: Debe adaptarse a la lógica real de adeudos vencidos
    RETURN QUERY
    SELECT 
        a.descripcion AS expression,
        a.adeudo AS expression_1,
        a.recargo AS expression_2
    FROM t_adeudos a
    WHERE a.id_34_datos = par_Control
      AND a.tipo_reporte = par_Rep
      AND a.periodo = par_Fecha;
END;
$$ LANGUAGE plpgsql;