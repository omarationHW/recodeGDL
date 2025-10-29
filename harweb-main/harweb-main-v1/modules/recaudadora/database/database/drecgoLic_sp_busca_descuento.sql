-- Stored Procedure: sp_busca_descuento
-- Tipo: Catalog
-- Descripción: Busca descuentos de recargos/multas para licencia/anuncio
-- Generado para formulario: drecgoLic
-- Fecha: 2025-08-27 00:52:37

CREATE OR REPLACE FUNCTION sp_busca_descuento(p_id_gral INTEGER, p_tipo VARCHAR) RETURNS TABLE(
  id_descto INTEGER,
  tipo VARCHAR,
  licencia INTEGER,
  porcentaje SMALLINT,
  fecalta DATE,
  captalta VARCHAR,
  fecbaja DATE,
  captbaja VARCHAR,
  estado VARCHAR,
  cvepago INTEGER,
  axoini INTEGER,
  axofin INTEGER,
  autoriza SMALLINT
) AS $$
BEGIN
  RETURN QUERY
    SELECT id_descto, tipo, licencia, porcentaje, fecalta, captalta, fecbaja, captbaja, estado, cvepago, axoini, axofin, autoriza
    FROM descreclic
    WHERE licencia=p_id_gral AND tipo=p_tipo;
END;
$$ LANGUAGE plpgsql;