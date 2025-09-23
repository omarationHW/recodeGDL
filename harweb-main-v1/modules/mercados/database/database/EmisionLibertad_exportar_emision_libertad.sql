-- Stored Procedure: exportar_emision_libertad
-- Tipo: CRUD
-- Descripción: Genera y guarda el archivo TXT de la emisión, devuelve la URL de descarga.
-- Generado para formulario: EmisionLibertad
-- Fecha: 2025-08-26 23:51:55

CREATE OR REPLACE FUNCTION exportar_emision_libertad(
  p_oficina INT,
  p_mercados JSON,
  p_axo INT,
  p_periodo INT,
  p_usuario_id INT
) RETURNS TABLE(file_url TEXT) AS $$
DECLARE
  row RECORD;
  file_path TEXT;
  file_name TEXT;
  f TEXT;
  out_txt TEXT;
  meses TEXT;
  folios_req TEXT;
  total_adeudos NUMERIC;
  total_recargos NUMERIC;
  total_multas NUMERIC;
  total_gastos NUMERIC;
  subtotal NUMERIC;
  renta NUMERIC;
  descuento NUMERIC;
  fh TEXT;
BEGIN
  file_name := 'RecibosMdo_' || p_oficina || '_' || p_axo || '-' || p_periodo || '.txt';
  file_path := '/var/www/html/exports/' || file_name;
  out_txt := '';
  FOR row IN SELECT * FROM generar_emision_libertad(p_oficina, p_mercados, p_axo, p_periodo, p_usuario_id) LOOP
    -- Formatear línea (puede mejorarse según reglas de negocio)
    out_txt := out_txt || lpad(row.id_local::TEXT,6,'0') || lpad(coalesce(row.nombre,''),30,' ') || lpad(coalesce(row.descripcion,''),30,' ') || lpad(coalesce(row.descripcion_local,''),20,' ') || lpad(row.oficina::TEXT,3,'0') || lpad(row.num_mercado::TEXT,3,'0') || lpad(row.categoria::TEXT,1,'0') || lpad(row.seccion,2,' ') || lpad(row.local::TEXT,5,'0') || lpad(coalesce(row.letra_local,''),1,' ') || lpad(coalesce(row.bloque,''),1,' ') || to_char(row.descuento,'FM000000.00') || to_char(row.adeudos,'FM000000.00') || to_char(row.renta,'FM000000.00') || to_char(row.subtotal,'FM000000.00') || to_char(row.recargos,'FM000000.00') || to_char(row.multas,'FM000000.00') || to_char(row.gastos,'FM000000.00') || coalesce(row.folios,'') || E'\n';
  END LOOP;
  -- Guardar archivo
  PERFORM pg_catalog.pg_file_write(file_path, out_txt, false);
  RETURN QUERY SELECT '/exports/' || file_name;
END;
$$ LANGUAGE plpgsql;