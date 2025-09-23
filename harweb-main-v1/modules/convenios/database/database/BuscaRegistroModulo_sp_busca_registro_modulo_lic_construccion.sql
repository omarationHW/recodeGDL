-- Stored Procedure: sp_busca_registro_modulo_lic_construccion
-- Tipo: Catalog
-- Descripción: Busca registros de licencias de construcción usando segmentos
-- Generado para formulario: BuscaRegistroModulo
-- Fecha: 2025-08-27 13:53:23

CREATE OR REPLACE FUNCTION sp_busca_registro_modulo_lic_construccion(segmento1 TEXT, segmento2 TEXT, segmento3 TEXT)
RETURNS TABLE(control INT, nombre TEXT, calcregistro TEXT, modulo INT, ubicacion TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM sp_encabezado(0, segmento1, segmento2, segmento3, ' ', ' ', ' ');
END;
$$ LANGUAGE plpgsql;