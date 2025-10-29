-- Stored Procedure: sp_recargos_list
-- Tipo: Catalog
-- Descripción: Lista todos los recargos con información de usuario.
-- Generado para formulario: Recargos
-- Fecha: 2025-08-27 00:32:58

CREATE OR REPLACE FUNCTION sp_recargos_list()
RETURNS TABLE(
    axo SMALLINT,
    periodo SMALLINT,
    porcentaje NUMERIC(8,2),
    fecha_alta TIMESTAMP,
    usuario TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.axo, r.periodo, r.porcentaje, r.fecha_alta, u.usuario
    FROM ta_11_recargos r
    LEFT JOIN ta_passwords u ON r.id_usuario = u.id_usuario
    ORDER BY r.axo DESC, r.periodo DESC;
END;
$$ LANGUAGE plpgsql;