-- Stored Procedure: sp_listar_subtipos_convenio_diversos
-- Tipo: Catalog
-- Descripción: Lista los subtipos de convenio diversos para un tipo dado
-- Generado para formulario: ModifConvDiversos
-- Fecha: 2025-08-27 20:52:39

CREATE OR REPLACE FUNCTION sp_listar_subtipos_convenio_diversos(p_tipo INTEGER) RETURNS TABLE (
    subtipo INTEGER,
    desc_subtipo VARCHAR
) AS $$
BEGIN
    RETURN QUERY SELECT subtipo, desc_subtipo FROM ta_17_subtipo_conv WHERE tipo = p_tipo ORDER BY subtipo;
END;
$$ LANGUAGE plpgsql;