-- Stored Procedure: sp_emitir_requerimientos_aseo
-- Tipo: CRUD
-- Descripción: Emite requerimientos para aseo seleccionados.
-- Generado para formulario: Requerimientos
-- Fecha: 2025-08-27 14:28:57

CREATE OR REPLACE FUNCTION sp_emitir_requerimientos_aseo(
  p_tipo_aseo TEXT,
  p_contrato_desde INT,
  p_contrato_hasta INT,
  p_filtro_tipo TEXT,
  p_filtro_valor TEXT,
  p_adeudo_desde NUMERIC,
  p_adeudo_hasta NUMERIC,
  p_user_id INT
) RETURNS TABLE(
  folio INT,
  id_contrato INT,
  resultado TEXT
) AS $$
DECLARE
  r RECORD;
  v_folio INT;
BEGIN
  FOR r IN SELECT id_contrato FROM contratos_aseo WHERE tipo_aseo = p_tipo_aseo AND num_contrato BETWEEN p_contrato_desde AND p_contrato_hasta LOOP
    v_folio := nextval('seq_folio_requerimiento');
    INSERT INTO requerimientos_aseo (folio, id_contrato, user_id, fecha_emision)
    VALUES (v_folio, r.id_contrato, p_user_id, now());
    RETURN NEXT (v_folio, r.id_contrato, 'OK');
  END LOOP;
END;
$$ LANGUAGE plpgsql;