-- Stored Procedure: get_recaudadoras
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de recaudadoras.
-- Generado para formulario: GAdeudos_OpcMult_RA
-- Fecha: 2025-08-27 23:39:10

CREATE OR REPLACE FUNCTION get_recaudadoras()
RETURNS SETOF ta_12_recaudadoras AS $$
BEGIN
    RETURN QUERY SELECT * FROM ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;