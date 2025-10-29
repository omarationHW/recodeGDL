-- Stored Procedure: sp_cons_uem400_by_cuenta
-- Tipo: Report
-- Descripción: Consulta historico y comp_400 por recaud, ur, cuenta
-- Generado para formulario: ConsUem400
-- Fecha: 2025-08-26 23:48:20

CREATE OR REPLACE FUNCTION sp_cons_uem400_by_cuenta(recaud integer, ur text, cuenta integer)
RETURNS TABLE(
  historico jsonb,
  comp_400 jsonb
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      (SELECT jsonb_agg(row_to_json(h)) FROM historico h WHERE h.recaud = LPAD(recaud::text, 3, '0') AND h.ur = ur AND h.cuenta = LPAD(cuenta::text, 6, '0')) AS historico,
      (SELECT jsonb_agg(row_to_json(c)) FROM comp_400 c WHERE c.recaud = LPAD(recaud::text, 3, '0') AND c.urbrus = ur AND c.cuenta = LPAD(cuenta::text, 6, '0')) AS comp_400;
END;
$$ LANGUAGE plpgsql;