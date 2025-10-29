-- Stored Procedure: get_derechos2
-- Tipo: CRUD
-- Descripción: Obtiene el valor de derechos2 para una licencia o anuncio
-- Generado para formulario: CatastroDM
-- Fecha: 2025-08-26 15:24:46

CREATE OR REPLACE FUNCTION get_derechos2(p_id_licencia integer, p_id_anuncio integer)
RETURNS TABLE(derechos2 numeric) AS $$
BEGIN
  IF p_id_licencia > 0 THEN
    RETURN QUERY SELECT derechos2 FROM detsal_lic WHERE derechos2 > 0 AND cvepago = 0 AND id_licencia = p_id_licencia LIMIT 1;
  ELSIF p_id_anuncio > 0 THEN
    RETURN QUERY SELECT derechos2 FROM detsal_lic WHERE derechos2 > 0 AND cvepago = 0 AND id_anuncio = p_id_anuncio LIMIT 1;
  ELSE
    RETURN QUERY SELECT 0;
  END IF;
END;
$$ LANGUAGE plpgsql;