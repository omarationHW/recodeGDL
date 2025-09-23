-- Stored Procedure: sp_consultar_cajas
-- Tipo: Catalog
-- Descripción: Devuelve las cajas disponibles para una oficina
-- Generado para formulario: CargaPagEnergiaElec
-- Fecha: 2025-08-26 22:53:19

CREATE OR REPLACE FUNCTION sp_consultar_cajas(
    p_oficina integer
) RETURNS TABLE(
    caja varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT caja FROM ta_12_operaciones WHERE id_rec = p_oficina ORDER BY caja ASC;
END;
$$ LANGUAGE plpgsql;