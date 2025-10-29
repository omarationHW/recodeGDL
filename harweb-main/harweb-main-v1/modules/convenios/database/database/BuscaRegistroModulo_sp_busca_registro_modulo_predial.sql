-- Stored Procedure: sp_busca_registro_modulo_predial
-- Tipo: Catalog
-- Descripción: Busca registros de predial
-- Generado para formulario: BuscaRegistroModulo
-- Fecha: 2025-08-27 13:53:23

CREATE OR REPLACE FUNCTION sp_busca_registro_modulo_predial(recaud TEXT, urbrus TEXT, cuenta TEXT)
RETURNS TABLE(control INT, nombre TEXT, calcregistro TEXT, ubicacion TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT e.cvecuenta, c.nombre_completo, e.recaud||'-'||e.urbrus||'-'||e.cuenta, d.calle||d.noexterior
  FROM convcta e, catastro a, regprop b, contrib c, ubicacion d
  WHERE e.recaud = recaud
    AND e.urbrus = urbrus
    AND e.cuenta = cuenta
    AND e.vigente = 'V'
    AND a.cvecuenta = e.cvecuenta
    AND b.cvecuenta = a.cvecuenta
    AND b.cveregprop = a.cveregprop
    AND c.cvecont = b.cvecont
    AND b.encabeza = 'S'
    AND d.cvecuenta = e.cvecuenta;
END;
$$ LANGUAGE plpgsql;