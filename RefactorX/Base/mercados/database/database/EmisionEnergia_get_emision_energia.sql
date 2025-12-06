-- Stored Procedure: get_emision_energia
-- Tipo: Report
-- Descripción: Obtiene la emisión de energía para una recaudadora, mercado, año y periodo.
-- Generado para formulario: EmisionEnergia
-- Fecha: 2025-08-26 23:50:10

DROP FUNCTION IF EXISTS get_emision_energia(SMALLINT, SMALLINT, SMALLINT, SMALLINT);

CREATE OR REPLACE FUNCTION get_emision_energia(p_oficina SMALLINT, p_mercado SMALLINT, p_axo SMALLINT, p_periodo SMALLINT)
RETURNS TABLE(
  id_local INTEGER,
  oficina SMALLINT,
  num_mercado SMALLINT,
  categoria SMALLINT,
  seccion CHAR(2),
  local INTEGER,
  letra_local VARCHAR(3),
  bloque VARCHAR(2),
  nombre VARCHAR(60),
  descripcion VARCHAR(30),
  local_adicional CHAR(50),
  axo SMALLINT,
  periodo SMALLINT,
  importe NUMERIC(16,2),
  id_energia INTEGER,
  cve_consumo CHAR(1),
  cantidad NUMERIC(16,2),
  importe_energia NUMERIC(16,2)
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque,
           a.nombre, b.descripcion, d.local_adicional, c.axo, c.periodo, c.importe,
           d.id_energia, d.cve_consumo, d.cantidad,
           (d.cantidad * c.importe)::NUMERIC(16,2) AS importe_energia
    FROM publico.ta_11_locales a
    LEFT JOIN public.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
    JOIN publico.ta_11_kilowhatts c ON c.axo = p_axo AND c.periodo = p_periodo
    JOIN publico.ta_11_energia d ON a.id_local = d.id_local
    WHERE a.oficina = p_oficina
      AND a.num_mercado = p_mercado
      AND a.vigencia = 'A'
      AND d.vigencia = 'E'
    ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque;
END;
$$ LANGUAGE plpgsql;