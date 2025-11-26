-- ================================================================
-- SP: recaudadora_req_frm_save
-- Módulo: multas_reglamentos
-- Descripción: Guardar/crear nuevo requerimiento
-- Tabla: catastro_gdl.reqdiftransmision
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-25
-- ================================================================

DROP FUNCTION IF EXISTS recaudadora_req_frm_save(TEXT);

CREATE OR REPLACE FUNCTION recaudadora_req_frm_save(
  p_registro TEXT DEFAULT NULL
)
RETURNS TABLE (
  success BOOLEAN,
  mensaje TEXT,
  cvereq INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_registro JSONB;
  v_cuenta INTEGER;
  v_folio INTEGER;
  v_ejercicio INTEGER;
  v_nuevo_id INTEGER;
  v_total NUMERIC := 1400.00; -- Importe por defecto
BEGIN
  -- Validar que se proporcione el registro
  IF p_registro IS NULL OR p_registro = '' THEN
    RETURN QUERY
    SELECT
      false,
      'Debe proporcionar los datos del requerimiento'::TEXT,
      NULL::INTEGER;
    RETURN;
  END IF;

  -- Convertir el string JSON a JSONB
  BEGIN
    v_registro := p_registro::JSONB;
  EXCEPTION WHEN OTHERS THEN
    RETURN QUERY
    SELECT
      false,
      'Error al procesar el JSON: formato inválido'::TEXT,
      NULL::INTEGER;
    RETURN;
  END;

  -- Extraer datos del registro
  v_cuenta := (v_registro->>'clave_cuenta')::INTEGER;
  v_folio := (v_registro->>'folio')::INTEGER;
  v_ejercicio := COALESCE((v_registro->>'ejercicio')::INTEGER, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER);

  -- Validar datos requeridos
  IF v_cuenta IS NULL OR v_folio IS NULL THEN
    RETURN QUERY
    SELECT
      false,
      'Cuenta y folio son campos requeridos'::TEXT,
      NULL::INTEGER;
    RETURN;
  END IF;

  -- Verificar si ya existe un requerimiento con la misma cuenta y folio
  IF EXISTS (
    SELECT 1
    FROM catastro_gdl.reqdiftransmision
    WHERE cvecuenta = v_cuenta
    AND folioreq = v_folio
    AND axoreq = v_ejercicio
  ) THEN
    RETURN QUERY
    SELECT
      false,
      'Ya existe un requerimiento con esta cuenta, folio y ejercicio'::TEXT,
      NULL::INTEGER;
    RETURN;
  END IF;

  -- Obtener el siguiente ID
  SELECT COALESCE(MAX(r.cvereq), 0) + 1
  INTO v_nuevo_id
  FROM catastro_gdl.reqdiftransmision r;

  -- Insertar nuevo requerimiento
  INSERT INTO catastro_gdl.reqdiftransmision (
    cvereq,
    axoreq,
    folioreq,
    cvecuenta,
    total,
    vigencia,
    fecemi,
    feccap
  ) VALUES (
    v_nuevo_id,
    v_ejercicio,
    v_folio,
    v_cuenta,
    v_total,
    'V',
    CURRENT_DATE,
    CURRENT_DATE
  );

  -- Retornar éxito
  RETURN QUERY
  SELECT
    true,
    'Requerimiento guardado exitosamente'::TEXT,
    v_nuevo_id;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION recaudadora_req_frm_save(TEXT) IS 'Guardar/crear nuevo requerimiento';
