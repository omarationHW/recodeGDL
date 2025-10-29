-- Stored Procedure: sp_busca_registro_modulo_multas
-- Tipo: Catalog
-- Descripción: Busca registros de multas municipales y federales según parámetros
-- Generado para formulario: BuscaRegistroModulo
-- Fecha: 2025-08-27 13:53:23

CREATE OR REPLACE FUNCTION sp_busca_registro_modulo_multas(abrevia TEXT, axo_acta INT, num_acta INT)
RETURNS TABLE(control INT, abrevia TEXT, axo_acta INT, num_acta INT, nombre TEXT, calcregistro TEXT, ubicacion TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT b.id_multa, a.abrevia, b.axo_acta, b.num_acta, b.contribuyente,
         TRIM(a.abrevia)||'-'||b.axo_acta||'-'||b.num_acta AS calcregistro,
         b.domicilio
  FROM c_dependencias a, multas b
  WHERE a.abrevia = abrevia
    AND b.id_dependencia = a.id_dependencia
    AND b.axo_acta = axo_acta
    AND b.num_acta = num_acta
    AND b.fecha_cancelacion IS NULL;
END;
$$ LANGUAGE plpgsql;