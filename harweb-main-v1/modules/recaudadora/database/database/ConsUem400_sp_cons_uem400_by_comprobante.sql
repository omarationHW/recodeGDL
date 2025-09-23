-- Stored Procedure: sp_cons_uem400_by_comprobante
-- Tipo: Report
-- Descripción: Consulta historico y comp_400 por año y comprobante
-- Generado para formulario: ConsUem400
-- Fecha: 2025-08-26 23:48:20

CREATE OR REPLACE FUNCTION sp_cons_uem400_by_comprobante(anio integer, comprob integer)
RETURNS TABLE(
  historico jsonb,
  comp_400 jsonb
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      (SELECT jsonb_agg(row_to_json(h)) FROM historico h WHERE h.recaud = 0) AS historico,
      (SELECT jsonb_agg(row_to_json(c)) FROM comp_400 c WHERE c.axocomc = LPAD(anio::text, 4, '0') AND c.comproc = LPAD(comprob::text, 6, '0')) AS comp_400;
END;
$$ LANGUAGE plpgsql;