-- Stored Procedure: con34_1detade_02
-- Tipo: Report
-- Descripción: Obtiene los adeudos de otro periodo para un control y periodo dado.
-- Generado para formulario: RAdeudos
-- Fecha: 2025-08-28 13:29:07

CREATE OR REPLACE FUNCTION con34_1detade_02(par_Control integer, par_Rep varchar, par_Fecha varchar)
RETURNS TABLE(
    expression text,
    expression_1 integer,
    expression_2 numeric,
    expression_3 numeric
) AS $$
BEGIN
    -- Ejemplo: Debe adaptarse a la lógica real de adeudos por periodo
    RETURN QUERY
    SELECT 
        a.descripcion AS expression,
        a.cantidad AS expression_1,
        a.adeudo AS expression_2,
        a.recargo AS expression_3
    FROM t_adeudos_periodo a
    WHERE a.id_34_datos = par_Control
      AND a.tipo_reporte = par_Rep
      AND a.periodo = par_Fecha;
END;
$$ LANGUAGE plpgsql;