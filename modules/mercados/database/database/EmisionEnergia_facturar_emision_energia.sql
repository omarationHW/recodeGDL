-- Stored Procedure: facturar_emision_energia
-- Tipo: Report
-- Descripción: Devuelve los datos para la facturación de la emisión de energía.
-- Generado para formulario: EmisionEnergia
-- Fecha: 2025-08-26 23:50:10

CREATE OR REPLACE FUNCTION facturar_emision_energia(p_oficina INT, p_mercado INT, p_axo INT, p_periodo INT)
RETURNS TABLE(
  oficina INT,
  num_mercado INT,
  categoria INT,
  seccion TEXT,
  local INT,
  letra_local TEXT,
  bloque TEXT,
  nombre TEXT,
  local_adicional TEXT,
  cantidad NUMERIC,
  importe NUMERIC,
  descripcion TEXT,
  importe_1 NUMERIC
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque,
           a.nombre, d.local_adicional, d.cantidad, c.importe, b.descripcion, (d.cantidad * c.importe) AS importe_1
    FROM ta_11_locales a
    JOIN ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
    JOIN ta_11_kilowhatts c ON c.axo = p_axo AND c.periodo = p_periodo
    JOIN ta_11_energia d ON a.id_local = d.id_local
    WHERE a.oficina = p_oficina
      AND a.num_mercado = p_mercado
      AND a.vigencia = 'A'
      AND d.vigencia = 'E';
END;
$$ LANGUAGE plpgsql;