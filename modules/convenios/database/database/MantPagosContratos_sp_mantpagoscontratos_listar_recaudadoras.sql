-- Stored Procedure: sp_mantpagoscontratos_listar_recaudadoras
-- Tipo: Catalog
-- Descripción: Lista todas las recaudadoras disponibles.
-- Generado para formulario: MantPagosContratos
-- Fecha: 2025-08-27 14:54:01

CREATE OR REPLACE FUNCTION sp_mantpagoscontratos_listar_recaudadoras()
RETURNS TABLE (id_rec SMALLINT, nombre VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;