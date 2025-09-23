CREATE OR REPLACE FUNCTION sp_get_categorias()
RETURNS TABLE(categoria integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT categoria, descripcion FROM ta_11_categoria ORDER BY categoria;
END; $$;

CREATE OR REPLACE FUNCTION sp_get_secciones()
RETURNS TABLE(seccion varchar, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT seccion, descripcion FROM ta_11_secciones ORDER BY seccion;
END; $$;

CREATE OR REPLACE FUNCTION sp_get_cve_cuotas()
RETURNS TABLE(clave_cuota integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT clave_cuota, descripcion FROM ta_11_cve_cuota ORDER BY clave_cuota;
END; $$;

CREATE OR REPLACE FUNCTION sp_get_mercados()
RETURNS TABLE(oficina integer, num_mercado_nvo integer, categoria integer, descripcion varchar, cuenta_ingreso integer, cuenta_energia integer, id_zona integer, tipo_emision varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision FROM ta_11_mercados ORDER BY oficina, num_mercado_nvo;
END; $$;