-- Stored Procedure: sp_list_recargos
-- Tipo: Catalog
-- Descripción: Lista todos los recargos de mantenimiento.
-- Generado para formulario: RecargosMntto
-- Fecha: 2025-08-27 00:34:42

CREATE OR REPLACE FUNCTION sp_list_recargos()
RETURNS TABLE(axo integer, periodo integer, porcentaje numeric, fecha_alta timestamp, id_usuario integer, usuario text) AS $$
BEGIN
    RETURN QUERY
    SELECT r.axo, r.periodo, r.porcentaje, r.fecha_alta, r.id_usuario, u.usuario
    FROM ta_11_recargos r
    LEFT JOIN ta_12_passwords u ON r.id_usuario = u.id_usuario
    ORDER BY r.axo DESC, r.periodo DESC;
END;
$$ LANGUAGE plpgsql;