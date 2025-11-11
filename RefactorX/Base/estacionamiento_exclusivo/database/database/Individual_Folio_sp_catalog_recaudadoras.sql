-- Stored Procedure: sp_catalog_recaudadoras
-- Tipo: Catalog
-- Descripción: Catálogo de recaudadoras disponibles.
-- Generado para formulario: Individual_Folio
-- Fecha: 2025-08-27 13:54:03

CREATE OR REPLACE FUNCTION sp_catalog_recaudadoras()
RETURNS TABLE (id integer, descripcion varchar) AS $$
BEGIN
    RETURN QUERY SELECT id_rec, recaudadora FROM padron_licencias.comun.ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;