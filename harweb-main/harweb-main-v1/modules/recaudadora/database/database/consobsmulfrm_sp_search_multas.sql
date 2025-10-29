-- Stored Procedure: sp_search_multas
-- Tipo: Report
-- Descripción: Busca multas por criterio y valor (contribuyente, domicilio, num_acta, axo_acta)
-- Generado para formulario: consobsmulfrm
-- Fecha: 2025-08-26 23:35:31

CREATE OR REPLACE FUNCTION sp_search_multas(p_criterio TEXT, p_valor TEXT)
RETURNS TABLE(id_multa INTEGER, contribuyente TEXT, domicilio TEXT, axo_acta INTEGER, num_acta INTEGER, observacion TEXT, comentario TEXT) AS $$
DECLARE
  sql TEXT;
BEGIN
  IF p_criterio NOT IN ('contribuyente', 'domicilio', 'num_acta', 'axo_acta') THEN
    RAISE EXCEPTION 'Criterio no permitido';
  END IF;
  sql := format('SELECT id_multa, contribuyente, domicilio, axo_acta, num_acta, observacion, comentario FROM multas WHERE %I ILIKE $1 LIMIT 50', p_criterio);
  RETURN QUERY EXECUTE sql USING '%' || p_valor || '%';
END;
$$ LANGUAGE plpgsql;