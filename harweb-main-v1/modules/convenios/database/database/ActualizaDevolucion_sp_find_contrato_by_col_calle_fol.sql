-- Stored Procedure: sp_find_contrato_by_col_calle_fol
-- Tipo: Catalog
-- Descripción: Busca contrato por colonia, calle y folio
-- Generado para formulario: ActualizaDevolucion
-- Fecha: 2025-08-27 13:34:35

CREATE OR REPLACE FUNCTION sp_find_contrato_by_col_calle_fol(
    p_col SMALLINT, p_calle SMALLINT, p_fol INTEGER
) RETURNS TABLE(id_convenio INTEGER) AS $$
BEGIN
    RETURN QUERY SELECT id_convenio FROM ta_17_convenios WHERE colonia = p_col AND calle = p_calle AND folio = p_fol;
END;
$$ LANGUAGE plpgsql;