-- Stored Procedure: sp_buscar_periodos_apremio
-- Tipo: CRUD
-- Descripción: Busca los periodos de un apremio.
-- Generado para formulario: ReqsCons
-- Fecha: 2025-08-27 20:45:14

CREATE OR REPLACE FUNCTION sp_buscar_periodos_apremio(p_id_apremio INTEGER)
RETURNS TABLE(id_control INTEGER, control_otr INTEGER, ayo SMALLINT, periodo SMALLINT, importe NUMERIC, recargos NUMERIC, cantidad NUMERIC, tipo INTEGER) AS $$
BEGIN
    RETURN QUERY SELECT id_control, control_otr, ayo, periodo, importe, recargos, cantidad, tipo FROM ta_15_periodos WHERE control_otr = p_id_apremio ORDER BY ayo, periodo;
END;
$$ LANGUAGE plpgsql;