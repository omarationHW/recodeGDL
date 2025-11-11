-- Stored Procedure: sp_get_rec_info
-- Tipo: Catalog
-- Descripción: Obtiene información de la recaudadora y zona.
-- Generado para formulario: ReportAutor
-- Fecha: 2025-08-27 14:26:10

CREATE OR REPLACE FUNCTION sp_get_rec_info(p_reca integer)
RETURNS TABLE (
  id_rec smallint,
  zona varchar,
  nomre varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.id_rec, b.zona, c.nomre
  FROM padron_licencias.comun.ta_12_recaudadoras a
  JOIN padron_licencias.comun.ta_12_zonas b ON a.id_zona = b.id_zona
  JOIN padron_licencias.comun.ta_12_nombrerec c ON a.id_rec = c.recing
  WHERE a.id_rec = p_reca;
END;
$$ LANGUAGE plpgsql;