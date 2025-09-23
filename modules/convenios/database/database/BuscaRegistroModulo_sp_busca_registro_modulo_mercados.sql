-- Stored Procedure: sp_busca_registro_modulo_mercados
-- Tipo: Catalog
-- Descripción: Busca registros de mercados
-- Generado para formulario: BuscaRegistroModulo
-- Fecha: 2025-08-27 13:53:23

CREATE OR REPLACE FUNCTION sp_busca_registro_modulo_mercados(oficina INT, num_mercado INT, categoria INT, seccion TEXT, local INT, letra_local TEXT, bloque TEXT)
RETURNS TABLE(control INT, oficina INT, num_mercado INT, categoria INT, seccion TEXT, local INT, letra_local TEXT, bloque TEXT, calcregistro TEXT, nombre TEXT, ubicacion TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque,
         oficina||'-'||num_mercado||'-'||categoria||'-'||seccion||'-'||local||'-'||COALESCE(letra_local,' ')||'-'||COALESCE(bloque,' ') AS calcregistro,
         nombre, domicilio
  FROM ta_11_locales
  WHERE oficina = oficina
    AND num_mercado = num_mercado
    AND categoria = categoria
    AND seccion = seccion
    AND local = local
    AND (letra_local = letra_local OR letra_local IS NULL)
    AND (bloque = bloque OR bloque IS NULL)
    AND vigencia = 'A'
    AND bloqueo = 0;
END;
$$ LANGUAGE plpgsql;