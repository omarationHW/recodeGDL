-- ================================================================
-- SP: recaudadora_pagosmultfrm
-- Módulo: multas_reglamentos
-- Descripción: Procesa múltiples pagos de requerimientos en lote
-- Tabla: catastro_gdl.reqdiftransmision
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-25
-- ================================================================

DROP FUNCTION IF EXISTS recaudadora_pagosmultfrm(TEXT);

CREATE OR REPLACE FUNCTION recaudadora_pagosmultfrm(
  p_registros TEXT DEFAULT NULL
)
RETURNS TABLE (
  success BOOLEAN,
  mensaje TEXT,
  procesados INTEGER,
  errores INTEGER,
  detalles JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_registros JSONB;
  v_registro JSONB;
  v_procesados INTEGER := 0;
  v_errores INTEGER := 0;
  v_detalles JSONB := '[]'::JSONB;
  v_cvereq INTEGER;
  v_cuenta INTEGER;
  v_folio INTEGER;
  v_importe NUMERIC;
  v_total_req NUMERIC;
  v_encontrado BOOLEAN;
  v_detalle JSONB;
BEGIN
  -- Validar que se proporcionen registros
  IF p_registros IS NULL OR p_registros = '' THEN
    RETURN QUERY
    SELECT
      false,
      'Debe proporcionar registros en formato JSON'::TEXT,
      0,
      0,
      '[]'::JSONB;
    RETURN;
  END IF;

  -- Convertir el string JSON a JSONB
  BEGIN
    v_registros := p_registros::JSONB;
  EXCEPTION WHEN OTHERS THEN
    RETURN QUERY
    SELECT
      false,
      'Error al procesar el JSON: formato inválido'::TEXT,
      0,
      0,
      '[]'::JSONB;
    RETURN;
  END;

  -- Validar que sea un array
  IF jsonb_typeof(v_registros) != 'array' THEN
    RETURN QUERY
    SELECT
      false,
      'El JSON debe ser un array de registros'::TEXT,
      0,
      0,
      '[]'::JSONB;
    RETURN;
  END IF;

  -- Procesar cada registro
  FOR v_registro IN SELECT * FROM jsonb_array_elements(v_registros)
  LOOP
    BEGIN
      -- Extraer datos del registro
      v_cvereq := (v_registro->>'cvereq')::INTEGER;
      v_cuenta := (v_registro->>'cuenta')::INTEGER;
      v_folio := (v_registro->>'folio')::INTEGER;
      v_importe := (v_registro->>'importe')::NUMERIC;

      -- Buscar el requerimiento
      SELECT
        r.total,
        true
      INTO v_total_req, v_encontrado
      FROM catastro_gdl.reqdiftransmision r
      WHERE (v_cvereq IS NOT NULL AND r.cvereq = v_cvereq)
         OR (r.cvecuenta = v_cuenta AND r.folioreq = v_folio)
      AND r.vigencia = 'V'
      LIMIT 1;

      IF NOT FOUND OR NOT v_encontrado THEN
        -- No se encontró el requerimiento
        v_errores := v_errores + 1;
        v_detalle := jsonb_build_object(
          'cuenta', v_cuenta,
          'folio', v_folio,
          'status', 'error',
          'mensaje', 'Requerimiento no encontrado o no vigente'
        );
        v_detalles := v_detalles || v_detalle;
      ELSE
        -- Validar que el importe coincida (con tolerancia de 0.01)
        IF ABS(v_total_req - v_importe) > 0.01 THEN
          v_errores := v_errores + 1;
          v_detalle := jsonb_build_object(
            'cuenta', v_cuenta,
            'folio', v_folio,
            'status', 'error',
            'mensaje', 'Importe no coincide. Esperado: ' || v_total_req || ', Recibido: ' || v_importe
          );
          v_detalles := v_detalles || v_detalle;
        ELSE
          -- Aplicar el pago (marcar como cancelado)
          UPDATE catastro_gdl.reqdiftransmision
          SET
            vigencia = 'C',
            feccan = CURRENT_DATE
          WHERE (v_cvereq IS NOT NULL AND cvereq = v_cvereq)
             OR (cvecuenta = v_cuenta AND folioreq = v_folio)
          AND vigencia = 'V';

          v_procesados := v_procesados + 1;
          v_detalle := jsonb_build_object(
            'cuenta', v_cuenta,
            'folio', v_folio,
            'importe', v_importe,
            'status', 'success',
            'mensaje', 'Pago aplicado correctamente'
          );
          v_detalles := v_detalles || v_detalle;
        END IF;
      END IF;

    EXCEPTION WHEN OTHERS THEN
      -- Error al procesar el registro
      v_errores := v_errores + 1;
      v_detalle := jsonb_build_object(
        'cuenta', COALESCE(v_cuenta, 0),
        'folio', COALESCE(v_folio, 0),
        'status', 'error',
        'mensaje', 'Error al procesar: ' || SQLERRM
      );
      v_detalles := v_detalles || v_detalle;
    END;
  END LOOP;

  -- Retornar resumen
  RETURN QUERY
  SELECT
    (v_errores = 0),
    CASE
      WHEN v_procesados = 0 AND v_errores > 0 THEN 'Todos los registros fallaron'
      WHEN v_procesados > 0 AND v_errores = 0 THEN 'Todos los pagos fueron aplicados exitosamente'
      ELSE 'Proceso completado con ' || v_procesados || ' éxitos y ' || v_errores || ' errores'
    END::TEXT,
    v_procesados,
    v_errores,
    v_detalles;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION recaudadora_pagosmultfrm(TEXT) IS 'Procesa múltiples pagos de requerimientos en lote';
