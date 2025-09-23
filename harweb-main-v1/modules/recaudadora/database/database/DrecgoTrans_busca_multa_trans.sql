-- Stored Procedure: busca_multa_trans
-- Tipo: Report
-- Descripción: Busca folios de transmisión con recargos pendientes (completa o diferencia)
-- Generado para formulario: DrecgoTrans
-- Fecha: 2025-08-27 01:13:21

CREATE OR REPLACE FUNCTION busca_multa_trans(p_folio integer, p_tipo text)
RETURNS TABLE(
  folio integer,
  baseimpuesto numeric,
  recargos numeric,
  multas numeric,
  total numeric,
  estado text,
  id_descto integer,
  porcentaje numeric,
  observaciones text
) AS $$
BEGIN
  IF p_tipo = 'completa' THEN
    RETURN QUERY
      SELECT i.folio, i.baseimpuesto, i.recargos, i.multas, i.total,
        COALESCE(dt.estado, 'V') AS estado,
        dt.id_descto, dt.porcentaje, dt.observaciones
      FROM impuestoTransp i
      LEFT JOIN descrectrans dt ON dt.folio = i.folio AND dt.estado = 'V'
      WHERE i.folio = p_folio AND i.recargos > 0 AND (i.cvepago = 0 OR i.cvepago IS NULL);
  ELSE
    RETURN QUERY
      SELECT i.folio, i.baseimpuesto, i.recargos, i.multas, i.total,
        COALESCE(dt.estado, 'V') AS estado,
        dt.id_descto, dt.porcentaje, dt.observaciones
      FROM diferencias_glosa i
      LEFT JOIN descrectrans dt ON dt.folio = i.foliot AND dt.estado = 'V'
      WHERE i.foliot = p_folio AND i.recargos > 0 AND (i.cvepago = 0 OR i.cvepago IS NULL);
  END IF;
END;
$$ LANGUAGE plpgsql;