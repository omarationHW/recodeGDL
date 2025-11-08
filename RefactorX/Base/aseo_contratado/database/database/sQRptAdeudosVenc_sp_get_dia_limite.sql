-- Stored Procedure: sp_get_dia_limite
-- Tipo: Catalog
-- Descripción: Obtiene el día límite para el mes dado de la tabla ta_16_Dia_Limite.
-- Generado para formulario: sQRptAdeudosVenc
-- Fecha: 2025-08-27 15:24:46

CREATE OR REPLACE FUNCTION sp_get_dia_limite(p_mes integer)
RETURNS TABLE(mes smallint, dia smallint) AS $$
BEGIN
    RETURN QUERY
    SELECT mes, dia FROM ta_16_dia_limite WHERE mes = p_mes;
END;
$$ LANGUAGE plpgsql;