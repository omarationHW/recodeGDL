-- Stored Procedure: sp_emitir_requerimientos_mercado
-- Tipo: CRUD
-- Descripción: Emite requerimientos para mercados seleccionados.
-- Generado para formulario: Requerimientos
-- Fecha: 2025-08-27 14:28:57

CREATE OR REPLACE FUNCTION sp_emitir_requerimientos_mercado(
  p_oficina INT,
  p_num_mercado_desde INT,
  p_num_mercado_hasta INT,
  p_local_desde INT,
  p_local_hasta INT,
  p_seccion TEXT,
  p_filtro_tipo TEXT,
  p_filtro_valor TEXT,
  p_adeudo_desde NUMERIC,
  p_adeudo_hasta NUMERIC,
  p_user_id INT
) RETURNS TABLE(
  folio INT,
  id_mercado INT,
  resultado TEXT
) AS $$
DECLARE
  r RECORD;
  v_folio INT;
BEGIN
  FOR r IN SELECT id_mercado FROM mercados WHERE oficina = p_oficina AND num_mercado BETWEEN p_num_mercado_desde AND p_num_mercado_hasta LOOP
    v_folio := nextval('seq_folio_requerimiento');
    INSERT INTO requerimientos (folio, id_mercado, user_id, fecha_emision)
    VALUES (v_folio, r.id_mercado, p_user_id, now());
    RETURN NEXT (v_folio, r.id_mercado, 'OK');
  END LOOP;
END;
$$ LANGUAGE plpgsql;