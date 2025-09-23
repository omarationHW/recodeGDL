-- Stored Procedure: get_cajas
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de cajas/operaciones.
-- Generado para formulario: GAdeudos_OpcMult_RA
-- Fecha: 2025-08-27 23:39:10

CREATE OR REPLACE FUNCTION get_cajas()
RETURNS SETOF ta_12_operaciones AS $$
BEGIN
    RETURN QUERY SELECT * FROM ta_12_operaciones ORDER BY id_rec, caja;
END;
$$ LANGUAGE plpgsql;