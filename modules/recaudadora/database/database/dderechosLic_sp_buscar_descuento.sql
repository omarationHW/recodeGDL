-- Stored Procedure: sp_buscar_descuento
-- Tipo: Catalog
-- Descripción: Busca descuentos vigentes para licencia/anuncio/forma
-- Generado para formulario: dderechosLic
-- Fecha: 2025-08-26 23:58:23

CREATE OR REPLACE FUNCTION sp_buscar_descuento(p_tipo TEXT, p_folio INTEGER)
RETURNS TABLE(id_descto INTEGER, tipo TEXT, licencia INTEGER, porcentaje INTEGER, fecalta DATE, captalta TEXT, fecbaja DATE, captbaja TEXT, estado TEXT, cvepago INTEGER, axoini INTEGER, axofin INTEGER, autoriza INTEGER) AS $$
BEGIN
  RETURN QUERY
    SELECT id_descto, tipo, licencia, porcentaje, fecalta, captalta, fecbaja, captbaja, estado, cvepago, axoini, axofin, autoriza
    FROM descderlic
    WHERE tipo=p_tipo AND licencia=p_folio AND estado='V';
END;
$$ LANGUAGE plpgsql;