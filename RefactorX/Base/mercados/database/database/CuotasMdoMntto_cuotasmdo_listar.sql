-- Stored Procedure: cuotasmdo_listar
-- Tipo: Catalog
-- Descripción: Lista todas las cuotas de mercado por año
-- Generado para formulario: CuotasMdoMntto
-- Fecha: 2025-08-26 23:36:08

DROP FUNCTION IF EXISTS cuotasmdo_listar();

CREATE OR REPLACE FUNCTION cuotasmdo_listar() RETURNS TABLE (
  id_cuotas integer,
  axo smallint,
  categoria smallint,
  seccion char(2),
  clave_cuota smallint,
  importe_cuota numeric(16,2),
  fecha_alta timestamp,
  id_usuario integer
) AS $$
BEGIN
  RETURN QUERY SELECT t.id_cuotas, t.axo, t.categoria, t.seccion, t.clave_cuota, t.importe_cuota, t.fecha_alta, t.id_usuario
    FROM ta_11_cuo_locales t
    ORDER BY t.axo DESC, t.categoria, t.seccion, t.clave_cuota;
END;
$$ LANGUAGE plpgsql;