-- Stored Procedure: get_emision_energia
-- Tipo: Report
-- Descripción: Obtiene la emisión de energía para una recaudadora, mercado, año y periodo.
-- Generado para formulario: EmisionEnergia
-- Fecha: 2025-08-26 23:50:10

CREATE OR REPLACE FUNCTION get_emision_energia(p_oficina INT, p_mercado INT, p_axo INT, p_periodo INT)
RETURNS TABLE(
  id_local INT,
  oficina INT,
  num_mercado INT,
  categoria INT,
  seccion TEXT,
  local INT,
  letra_local TEXT,
  bloque TEXT,
  nombre TEXT,
  descripcion TEXT,
  cuenta_energia INT,
  local_adicional TEXT,
  axo INT,
  periodo INT,
  importe NUMERIC,
  id_energia INT,
  cve_consumo TEXT,
  cantidad NUMERIC,
  importe_energia NUMERIC
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque,
           a.nombre, b.descripcion, b.cuenta_energia, d.local_adicional, c.axo, c.periodo, c.importe,
           d.id_energia, d.cve_consumo, d.cantidad,
           (d.cantidad * c.importe) AS importe_energia
    FROM ta_11_locales a
    JOIN ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
    JOIN ta_11_kilowhatts c ON c.axo = p_axo AND c.periodo = p_periodo
    JOIN ta_11_energia d ON a.id_local = d.id_local
    WHERE a.oficina = p_oficina
      AND a.num_mercado = p_mercado
      AND a.vigencia = 'A'
      AND d.vigencia = 'E'
    ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque;
END;
$$ LANGUAGE plpgsql;