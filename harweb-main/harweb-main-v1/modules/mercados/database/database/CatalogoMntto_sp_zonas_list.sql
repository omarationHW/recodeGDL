-- Stored Procedure: sp_zonas_list
-- Tipo: Catalog
-- Descripción: Lista de zonas
-- Generado para formulario: CatalogoMntto
-- Fecha: 2025-08-26 23:06:58

CREATE OR REPLACE FUNCTION sp_zonas_list()
RETURNS TABLE (id_zona INTEGER, zona VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT id_zona, zona FROM ta_12_zonas ORDER BY id_zona;
END;
$$ LANGUAGE plpgsql;