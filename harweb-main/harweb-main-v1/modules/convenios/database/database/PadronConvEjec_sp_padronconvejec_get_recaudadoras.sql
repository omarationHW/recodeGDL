-- Stored Procedure: sp_padronconvejec_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Obtiene la lista de recaudadoras.
-- Generado para formulario: PadronConvEjec
-- Fecha: 2025-08-27 15:03:48

CREATE OR REPLACE FUNCTION sp_padronconvejec_get_recaudadoras()
RETURNS TABLE(id_rec smallint, recaudadora varchar) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;
END; $$ LANGUAGE plpgsql;