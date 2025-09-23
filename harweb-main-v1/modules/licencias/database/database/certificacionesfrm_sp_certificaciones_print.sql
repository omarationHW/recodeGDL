-- Stored Procedure: sp_certificaciones_print
-- Tipo: Report
-- Descripción: Devuelve los datos de la certificación y pagos para impresión
-- Generado para formulario: certificacionesfrm
-- Fecha: 2025-08-27 17:08:49

CREATE OR REPLACE FUNCTION sp_certificaciones_print(p_id INT)
RETURNS TABLE(certificacion JSON, licencia JSON, pagos JSON) AS $$
DECLARE
  cert JSON;
  lic JSON;
  pgs JSON;
BEGIN
  SELECT row_to_json(c) INTO cert FROM (SELECT * FROM certificaciones WHERE id = p_id) c;
  SELECT row_to_json(l) INTO lic FROM (SELECT * FROM licencias WHERE id_licencia = (SELECT id_licencia FROM certificaciones WHERE id = p_id)) l;
  SELECT json_agg(row_to_json(p)) INTO pgs FROM (SELECT * FROM pagos WHERE cvecuenta = (SELECT id_licencia FROM certificaciones WHERE id = p_id) AND cveconcepto = 8 ORDER BY fecha DESC, hora DESC) p;
  RETURN QUERY SELECT cert, lic, pgs;
END;
$$ LANGUAGE plpgsql;