-- Stored Procedure: sp_get_locales_emision_laser
-- Tipo: Report
-- Descripción: Obtiene los locales para la emisión laser según filtros.
-- Generado para formulario: RptEmisionLaser
-- Fecha: 2025-08-27 20:48:44

CREATE OR REPLACE FUNCTION sp_get_locales_emision_laser(p_oficina integer, p_mercado integer, p_axo integer, p_periodo integer)
RETURNS TABLE(
  id_local integer,
  nombre varchar,
  descripcion_local varchar,
  meses varchar,
  rentaaxos numeric,
  recargos numeric,
  subtotal numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.id_local, a.nombre, a.descripcion_local, '' AS meses, 0 AS rentaaxos, 0 AS recargos, 0 AS subtotal
  FROM ta_11_locales a
  WHERE a.oficina = p_oficina AND a.num_mercado = p_mercado AND a.vigencia = 'A' AND a.bloqueo < 4;
END;
$$ LANGUAGE plpgsql;