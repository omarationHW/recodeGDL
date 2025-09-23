-- Stored Procedure: sp_get_dia_limite
-- Tipo: Catalog
-- Descripción: Obtiene el día límite para un mes dado.
-- Generado para formulario: uDM_Procesos
-- Fecha: 2025-08-27 15:45:14

CREATE OR REPLACE FUNCTION sp_get_dia_limite(mes integer)
RETURNS TABLE (
    mes integer,
    dia integer
) AS $$
BEGIN
    RETURN QUERY SELECT mes, dia FROM ta_16_dia_limite WHERE mes = $1;
END;
$$ LANGUAGE plpgsql;