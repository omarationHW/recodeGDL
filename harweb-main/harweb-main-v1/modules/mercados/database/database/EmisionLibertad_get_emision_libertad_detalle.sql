-- Stored Procedure: get_emision_libertad_detalle
-- Tipo: Report
-- Descripción: Devuelve el detalle de la emisión para mostrar en la tabla.
-- Generado para formulario: EmisionLibertad
-- Fecha: 2025-08-26 23:51:55

CREATE OR REPLACE FUNCTION get_emision_libertad_detalle(
  p_oficina INT,
  p_mercados JSON,
  p_axo INT,
  p_periodo INT
) RETURNS TABLE(
  id_local INT,
  nombre TEXT,
  descripcion TEXT,
  descripcion_local TEXT,
  oficina INT,
  num_mercado INT,
  categoria INT,
  seccion TEXT,
  local INT,
  letra_local TEXT,
  bloque TEXT,
  renta NUMERIC,
  descuento NUMERIC,
  adeudos NUMERIC,
  recargos NUMERIC,
  subtotal NUMERIC,
  multas NUMERIC,
  gastos NUMERIC,
  folios TEXT
) AS $$
BEGIN
  RETURN QUERY SELECT * FROM generar_emision_libertad(p_oficina, p_mercados, p_axo, p_periodo, 0);
END;
$$ LANGUAGE plpgsql;