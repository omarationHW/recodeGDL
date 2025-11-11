-- =====================================================
-- SP: sp_cambiar_fase
-- Descripción: Cambia la fase de un expediente de apremio
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- =====================================================

CREATE OR REPLACE FUNCTION sp_cambiar_fase(
  p_expediente VARCHAR(50),
  p_fase VARCHAR(50)
)
RETURNS TABLE (
  success BOOLEAN,
  message VARCHAR(255),
  rows_affected INTEGER
) AS $$
DECLARE
  v_rows INTEGER;
  v_fase_anterior VARCHAR(50);
BEGIN
  -- Validar que la fase sea válida
  IF p_fase NOT IN ('REQUERIMIENTO', 'EMBARGO', 'REMATE', 'ADJUDICACION', 'CONCLUIDO') THEN
    RETURN QUERY SELECT FALSE, 'Fase inválida. Use: REQUERIMIENTO, EMBARGO, REMATE, ADJUDICACION, CONCLUIDO'::VARCHAR(255), 0;
    RETURN;
  END IF;

  -- Obtener fase anterior
  SELECT fase INTO v_fase_anterior
  FROM ta_15_apremios
  WHERE expediente = p_expediente
  LIMIT 1;

  -- Actualizar la fase
  UPDATE ta_15_apremios
  SET
    fase = p_fase,
    fase_anterior = COALESCE(v_fase_anterior, fase),
    fecha_fase = CURRENT_DATE,
    fecha_modificacion = CURRENT_TIMESTAMP
  WHERE expediente = p_expediente;

  GET DIAGNOSTICS v_rows = ROW_COUNT;

  IF v_rows > 0 THEN
    RETURN QUERY SELECT TRUE, ('Fase actualizada correctamente. ' || v_rows || ' registro(s) afectado(s).')::VARCHAR(255), v_rows;
  ELSE
    RETURN QUERY SELECT FALSE, 'No se encontró el expediente especificado'::VARCHAR(255), 0;
  END IF;

  RETURN;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Notas:
-- - Cambia la fase de un expediente
-- - Fases válidas: REQUERIMIENTO, EMBARGO, REMATE, ADJUDICACION, CONCLUIDO
-- - Guarda la fase anterior para historial
-- - Actualiza fecha de modificación automáticamente
-- =====================================================

-- Ejemplo de uso:
-- SELECT * FROM sp_cambiar_fase('EXP-001', 'EMBARGO');
