-- Stored Procedure: sp_get_recargo
-- Tipo: Catalog
-- Descripción: Obtiene un recargo específico por año y periodo.
-- Generado para formulario: RecargosMntto
-- Fecha: 2025-08-27 00:34:42

CREATE OR REPLACE FUNCTION sp_get_recargo(p_axo integer, p_periodo integer)
RETURNS TABLE(axo integer, periodo integer, porcentaje numeric, fecha_alta timestamp, id_usuario integer, usuario text) AS $$
BEGIN
    RETURN QUERY
    SELECT r.axo, r.periodo, r.porcentaje, r.fecha_alta, r.id_usuario, u.usuario
    FROM ta_11_recargos r
    LEFT JOIN ta_12_passwords u ON r.id_usuario = u.id_usuario
    WHERE r.axo = p_axo AND r.periodo = p_periodo;
END;
$$ LANGUAGE plpgsql;