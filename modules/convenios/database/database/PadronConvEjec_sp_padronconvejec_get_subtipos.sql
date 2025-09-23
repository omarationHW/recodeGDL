-- Stored Procedure: sp_padronconvejec_get_subtipos
-- Tipo: Catalog
-- Descripción: Obtiene los subtipos de convenio para un tipo dado.
-- Generado para formulario: PadronConvEjec
-- Fecha: 2025-08-27 15:03:48

CREATE OR REPLACE FUNCTION sp_padronconvejec_get_subtipos(p_tipo smallint)
RETURNS TABLE(subtipo smallint, desc_subtipo varchar) AS $$
BEGIN
  RETURN QUERY SELECT subtipo, desc_subtipo FROM ta_17_subtipo_conv WHERE tipo = p_tipo ORDER BY subtipo;
END; $$ LANGUAGE plpgsql;