-- Stored Procedure: generar_emision_libertad
-- Tipo: CRUD
-- Descripción: Genera la emisión de recibos para mercados con caja de cobro, devolviendo el detalle para la vista.
-- Generado para formulario: EmisionLibertad
-- Fecha: 2025-08-26 23:51:55

CREATE OR REPLACE FUNCTION generar_emision_libertad(
  p_oficina INT,
  p_mercados JSON,
  p_axo INT,
  p_periodo INT,
  p_usuario_id INT
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
DECLARE
  mercado_ids INT[];
  rec RECORD;
  meses TEXT;
  folios_req TEXT;
  total_adeudos NUMERIC;
  total_recargos NUMERIC;
  total_multas NUMERIC;
  total_gastos NUMERIC;
  subtotal NUMERIC;
  renta NUMERIC;
  descuento NUMERIC;
BEGIN
  SELECT ARRAY(SELECT json_array_elements_text(p_mercados)::INT) INTO mercado_ids;
  FOR rec IN
    SELECT a.*, b.descripcion as mercado_desc, c.importe_cuota, c.clave_cuota, c.seccion as cuo_seccion
    FROM ta_11_locales a
    JOIN ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
    JOIN ta_11_cuo_locales c ON a.categoria = c.categoria AND a.seccion = c.seccion AND a.clave_cuota = c.clave_cuota AND c.axo = p_axo
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
    SELECT COALESCE(SUM(importe),0), COALESCE(SUM(recargos),0)
      INTO total_adeudos, total_recargos
      FROM ta_11_adeudo_local
      WHERE id_local = rec.id_local
        AND (axo < p_axo OR (axo = p_axo AND periodo < p_periodo));
    -- Multas y gastos (requerimientos)
    SELECT string_agg(folio::TEXT, ','), COALESCE(SUM(importe_multa),0), COALESCE(SUM(importe_gastos),0)
      INTO folios_req, total_multas, total_gastos
      FROM ta_15_apremios
      WHERE modulo = 11 AND control_otr = rec.id_local AND vigencia = '1' AND clave_practicado = 'P';
    subtotal := total_adeudos + total_recargos;
    meses := (SELECT string_agg(periodo::TEXT, ',') FROM ta_11_adeudo_local WHERE id_local = rec.id_local AND (axo < p_axo OR (axo = p_axo AND periodo < p_periodo)));
    RETURN NEXT (
      rec.id_local, rec.nombre, rec.mercado_desc, rec.descripcion_local, rec.oficina, rec.num_mercado, rec.categoria, rec.seccion, rec.local, rec.letra_local, rec.bloque,
      renta, descuento, total_adeudos, total_recargos, subtotal, total_multas, total_gastos, folios_req
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql;