-- ================================================================
-- SP: recaudadora_ligapagotra
-- Módulo: multas_reglamentos
-- Descripción: Genera liga de pago para trámites de licencias
-- Tabla: catastro_gdl.tramites
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-25
-- ================================================================

DROP FUNCTION IF EXISTS recaudadora_ligapagotra(VARCHAR);

CREATE OR REPLACE FUNCTION recaudadora_ligapagotra(
  p_tramite VARCHAR DEFAULT NULL
)
RETURNS TABLE (
  liga TEXT,
  tramite INTEGER,
  tipo_tramite TEXT,
  descripcion TEXT,
  propietario TEXT,
  actividad TEXT,
  cuenta INTEGER,
  total_importe NUMERIC,
  mensaje TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_tramite INTEGER;
  v_tipo_tramite TEXT;
  v_tipo_desc TEXT;
  v_propietario TEXT;
  v_actividad TEXT;
  v_cuenta INTEGER;
  v_liga TEXT;
  v_importe NUMERIC;
BEGIN
  -- Validar que se proporcione trámite
  IF p_tramite IS NULL OR p_tramite = '' THEN
    RETURN QUERY
    SELECT
      NULL::TEXT,
      NULL::INTEGER,
      NULL::TEXT,
      NULL::TEXT,
      NULL::TEXT,
      NULL::TEXT,
      NULL::INTEGER,
      NULL::NUMERIC,
      'Debe proporcionar un ID de trámite'::TEXT;
    RETURN;
  END IF;

  -- Convertir trámite a entero
  v_tramite := p_tramite::INTEGER;

  -- Obtener información del trámite
  SELECT
    t.tipo_tramite,
    TRIM(tt.descripcion),
    TRIM(t.propietario),
    TRIM(t.actividad),
    t.cvecuenta
  INTO v_tipo_tramite, v_tipo_desc, v_propietario, v_actividad, v_cuenta
  FROM catastro_gdl.tramites t
  LEFT JOIN catastro_gdl.c_tipotramite tt ON t.tipo_tramite = tt.id_tipotramite::text
  WHERE t.id_tramite = v_tramite;

  -- Validar que el trámite exista
  IF v_tipo_tramite IS NULL THEN
    RETURN QUERY
    SELECT
      NULL::TEXT,
      v_tramite,
      NULL::TEXT,
      NULL::TEXT,
      NULL::TEXT,
      NULL::TEXT,
      NULL::INTEGER,
      NULL::NUMERIC,
      'No se encontró el trámite especificado'::TEXT;
    RETURN;
  END IF;

  -- Calcular importe ficticio (basado en tipo de trámite)
  -- En producción esto debería calcularse desde una tabla de tarifas
  v_importe := CASE
    WHEN v_tipo_tramite = '1' THEN 2500.00  -- ALTA DE LICENCIA
    WHEN v_tipo_tramite = '2' THEN 1500.00  -- MODIFICACION DE LICENCIA
    WHEN v_tipo_tramite = '3' THEN 800.00   -- ALTA DE ANUNCIO
    WHEN v_tipo_tramite = '4' THEN 600.00   -- MODIFICACION DE ANUNCIO
    WHEN v_tipo_tramite = '5' THEN 3000.00  -- TRASPASO DE LICENCIA
    WHEN v_tipo_tramite = '6' THEN 1200.00  -- CAMBIO DE DOMICILIO
    WHEN v_tipo_tramite = '7' THEN 1800.00  -- CAMBIO DE GIRO
    WHEN v_tipo_tramite = '13' THEN 2000.00 -- ALTA DE LICENCIA WEB
    ELSE 1000.00
  END;

  -- Generar liga de pago
  v_liga := 'https://pagos.guadalajara.gob.mx/tramites?id=' || v_tramite ||
            '&tipo=' || v_tipo_tramite ||
            '&importe=' || ROUND(v_importe, 2) ||
            '&token=' || MD5(v_tramite::TEXT || v_tipo_tramite || v_importe::TEXT || NOW()::TEXT);

  -- Retornar resultado
  RETURN QUERY
  SELECT
    v_liga,
    v_tramite,
    v_tipo_tramite,
    v_tipo_desc,
    v_propietario,
    v_actividad,
    v_cuenta,
    v_importe,
    'Liga generada exitosamente'::TEXT;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION recaudadora_ligapagotra(VARCHAR) IS 'Genera liga de pago para trámites de licencias';
