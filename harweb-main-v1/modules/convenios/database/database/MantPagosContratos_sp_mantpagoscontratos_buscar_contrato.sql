-- Stored Procedure: sp_mantpagoscontratos_buscar_contrato
-- Tipo: Catalog
-- Descripción: Busca un contrato por colonia, calle y folio.
-- Generado para formulario: MantPagosContratos
-- Fecha: 2025-08-27 14:54:01

CREATE OR REPLACE FUNCTION sp_mantpagoscontratos_buscar_contrato(
    p_colonia SMALLINT,
    p_calle SMALLINT,
    p_folio INTEGER
) RETURNS TABLE (
    id_convenio INTEGER,
    colonia SMALLINT,
    calle SMALLINT,
    folio INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_convenio, colonia, calle, folio
    FROM ta_17_convenios
    WHERE colonia = p_colonia AND calle = p_calle AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;