-- ================================================================
-- SP: recaudadora_ligapago
-- Módulo: multas_reglamentos
-- Descripción: Genera liga de pago para requerimientos vigentes de una cuenta
-- Tabla: catastro_gdl.reqdiftransmision
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-25
-- ================================================================

DROP FUNCTION IF EXISTS recaudadora_ligapago(VARCHAR);

CREATE OR REPLACE FUNCTION recaudadora_ligapago(
  p_clave_cuenta VARCHAR DEFAULT NULL
)
RETURNS TABLE (
  liga TEXT,
  cuenta INTEGER,
  total_adeudo NUMERIC,
  total_requerimientos INTEGER,
  mensaje TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_cuenta INTEGER;
  v_total_adeudo NUMERIC;
  v_total_reqs INTEGER;
  v_liga TEXT;
BEGIN
  -- Validar que se proporcione cuenta
  IF p_clave_cuenta IS NULL OR p_clave_cuenta = '' THEN
    RETURN QUERY
    SELECT
      NULL::TEXT,
      NULL::INTEGER,
      NULL::NUMERIC,
      NULL::INTEGER,
      'Debe proporcionar un número de cuenta'::TEXT;
    RETURN;
  END IF;

  -- Convertir cuenta a entero
  v_cuenta := p_clave_cuenta::INTEGER;

  -- Obtener total de adeudo y cantidad de requerimientos vigentes
  SELECT
    COALESCE(SUM(r.total), 0),
    COUNT(r.cvereq)
  INTO v_total_adeudo, v_total_reqs
  FROM catastro_gdl.reqdiftransmision r
  WHERE r.cvecuenta = v_cuenta
  AND r.vigencia = 'V';

  -- Validar que existan requerimientos
  IF v_total_reqs = 0 THEN
    RETURN QUERY
    SELECT
      NULL::TEXT,
      v_cuenta,
      0::NUMERIC,
      0::INTEGER,
      'No se encontraron requerimientos vigentes para esta cuenta'::TEXT;
    RETURN;
  END IF;

  -- Generar liga de pago (formato de ejemplo)
  v_liga := 'https://pagos.guadalajara.gob.mx/requerimientos?cuenta=' || v_cuenta ||
            '&importe=' || ROUND(v_total_adeudo, 2) ||
            '&token=' || MD5(v_cuenta::TEXT || v_total_adeudo::TEXT || NOW()::TEXT);

  -- Retornar resultado
  RETURN QUERY
  SELECT
    v_liga,
    v_cuenta,
    v_total_adeudo,
    v_total_reqs,
    'Liga generada exitosamente'::TEXT;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION recaudadora_ligapago(VARCHAR) IS 'Genera liga de pago para requerimientos vigentes de una cuenta';
