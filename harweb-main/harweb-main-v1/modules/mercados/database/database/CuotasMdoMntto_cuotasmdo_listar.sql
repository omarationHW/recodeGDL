-- Stored Procedure: cuotasmdo_listar
-- Tipo: Catalog
-- Descripción: Lista todas las cuotas de mercado por año
-- Generado para formulario: CuotasMdoMntto
-- Fecha: 2025-08-26 23:36:08

CREATE OR REPLACE FUNCTION cuotasmdo_listar() RETURNS TABLE (
  id_cuotas integer,
  axo integer,
  categoria integer,
  seccion varchar,
  clave_cuota integer,
  importe_cuota numeric,
  fecha_alta timestamp,
  id_usuario integer
) AS $$
BEGIN
  RETURN QUERY SELECT id_cuotas, axo, categoria, seccion, clave_cuota, importe_cuota, fecha_alta, id_usuario
    FROM ta_11_cuo_locales
    ORDER BY axo DESC, categoria, seccion, clave_cuota;
END;
$$ LANGUAGE plpgsql;