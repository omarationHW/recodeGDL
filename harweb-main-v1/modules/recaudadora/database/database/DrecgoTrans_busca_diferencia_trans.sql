-- Stored Procedure: busca_diferencia_trans
-- Tipo: Report
-- Descripción: Busca diferencias de transmisión con recargos pendientes
-- Generado para formulario: DrecgoTrans
-- Fecha: 2025-08-27 01:13:21

CREATE OR REPLACE FUNCTION busca_diferencia_trans(p_folio integer)
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
  RETURN QUERY
    SELECT i.foliot, i.baseimpuesto, i.recargos, i.multas, i.total,
      COALESCE(dt.estado, 'V') AS estado,
      dt.id_descto, dt.porcentaje, dt.observaciones
    FROM diferencias_glosa i
    LEFT JOIN descrectrans dt ON dt.folio = i.foliot AND dt.estado = 'V'
    WHERE i.foliot = p_folio AND i.recargos > 0 AND (i.cvepago = 0 OR i.cvepago IS NULL);
END;
$$ LANGUAGE plpgsql;