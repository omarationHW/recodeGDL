-- Stored Procedure: get_cuotas
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de claves de cuota
-- Generado para formulario: LocalesMtto
-- Fecha: 2025-08-27 00:12:40

CREATE OR REPLACE FUNCTION get_cuotas() RETURNS TABLE(clave_cuota integer, descripcion text) AS $$
BEGIN
  RETURN QUERY SELECT clave_cuota, descripcion FROM ta_11_cve_cuota ORDER BY clave_cuota;
END; $$ LANGUAGE plpgsql;