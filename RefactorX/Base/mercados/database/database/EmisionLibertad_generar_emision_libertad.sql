-- Stored Procedure: generar_emision_libertad
-- Tipo: CRUD
-- Descripción: Genera la emisión de recibos para mercados con caja de cobro, devolviendo el detalle para la vista.
-- Generado para formulario: EmisionLibertad
-- Fecha: 2025-08-26 23:51:55

DROP FUNCTION IF EXISTS generar_emision_libertad(SMALLINT, JSON, SMALLINT, SMALLINT, INTEGER);

CREATE OR REPLACE FUNCTION generar_emision_libertad(
  p_oficina SMALLINT,
  p_mercados JSON,
  p_axo SMALLINT,
  p_periodo SMALLINT,
  p_usuario_id INTEGER
) RETURNS TABLE(
  id_local INTEGER,
  nombre VARCHAR(60),
  descripcion VARCHAR(30),
  descripcion_local CHAR(20),
  oficina SMALLINT,
  num_mercado SMALLINT,
  categoria SMALLINT,
  seccion CHAR(2),
  local INTEGER,
  letra_local VARCHAR(3),
  bloque VARCHAR(2),
  renta NUMERIC(16,2),
  descuento NUMERIC(16,2),
  adeudos NUMERIC(16,2),
  recargos NUMERIC(16,2),
  subtotal NUMERIC(16,2),
  multas NUMERIC(16,2),
  gastos NUMERIC(16,2),
  folios TEXT
) AS $$
DECLARE
  mercado_ids SMALLINT[];
  rec RECORD;
  meses TEXT;
  folios_req TEXT;
  total_adeudos NUMERIC(16,2);
  total_recargos NUMERIC(16,2);
  total_multas NUMERIC(16,2);
  total_gastos NUMERIC(16,2);
  subtotal NUMERIC(16,2);
  renta NUMERIC(16,2);
  descuento NUMERIC(16,2);
BEGIN
  SELECT ARRAY(SELECT json_array_elements_text(p_mercados)::SMALLINT) INTO mercado_ids;
  FOR rec IN
    SELECT a.*, b.descripcion as mercado_desc, c.importe_cuota, c.clave_cuota, c.seccion as cuo_seccion
    FROM publico.ta_11_locales a
    LEFT JOIN public.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
    JOIN publico.ta_11_cuo_locales c ON a.categoria = c.categoria AND a.seccion = c.seccion AND a.clave_cuota = c.clave_cuota AND c.axo = p_axo
    WHERE a.oficina = p_oficina
      AND a.num_mercado = ANY(mercado_ids)
      AND a.vigencia = 'A'
      AND a.bloqueo < 4
    ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque
  LOOP
    -- Calcular renta
    IF rec.seccion = 'PS' THEN
      IF rec.clave_cuota = 4 THEN
        renta := rec.superficie * rec.importe_cuota;
      ELSE
        renta := rec.importe_cuota * rec.superficie * 30;
      END IF;
    ELSE
      renta := rec.superficie * rec.importe_cuota;
    END IF;
    descuento := round(renta * 0.90, 2);
    -- Adeudos y recargos
    SELECT COALESCE(SUM(ade.importe),0),
           COALESCE(SUM(ade.importe * COALESCE((SELECT SUM(r.porcentaje_mes) FROM publico.ta_12_recargos r WHERE r.axo = ade.axo AND r.mes >= ade.periodo),0)/100), 0)
      INTO total_adeudos, total_recargos
      FROM publico.ta_11_adeudo_local ade
      WHERE ade.id_local = rec.id_local
        AND (ade.axo < p_axo OR (ade.axo = p_axo AND ade.periodo < p_periodo));
    -- Multas y gastos (requerimientos)
    SELECT string_agg(req.folio::TEXT, ','), COALESCE(SUM(req.importe_multa),0), COALESCE(SUM(req.importe_gastos),0)
      INTO folios_req, total_multas, total_gastos
      FROM publico.ta_15_apremios req
      WHERE req.modulo = 11 AND req.control_otr = rec.id_local AND req.vigencia = '1' AND req.clave_practicado = 'P';
    subtotal := total_adeudos + total_recargos;
    meses := (SELECT string_agg(ade2.periodo::TEXT, ',') FROM publico.ta_11_adeudo_local ade2 WHERE ade2.id_local = rec.id_local AND (ade2.axo < p_axo OR (ade2.axo = p_axo AND ade2.periodo < p_periodo)));

    id_local := rec.id_local;
    nombre := rec.nombre;
    descripcion := rec.mercado_desc;
    descripcion_local := rec.descripcion_local;
    oficina := rec.oficina;
    num_mercado := rec.num_mercado;
    categoria := rec.categoria;
    seccion := rec.seccion;
    local := rec.local;
    letra_local := rec.letra_local;
    bloque := rec.bloque;
    adeudos := total_adeudos;
    recargos := total_recargos;
    multas := total_multas;
    gastos := total_gastos;
    folios := folios_req;

    RETURN NEXT;
  END LOOP;
END;
$$ LANGUAGE plpgsql;