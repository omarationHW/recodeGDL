-- ================================================================
-- SP: recaudadora_sdosfavor_pagos
-- Módulo: multas_reglamentos
-- Descripción: Consulta pagos de saldos a favor por cuenta
-- Tabla: catastro_gdl.sdosfavor, catastro_gdl.solic_sdosfavor
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-25
-- ================================================================

DROP FUNCTION IF EXISTS recaudadora_sdosfavor_pagos(VARCHAR);

CREATE OR REPLACE FUNCTION recaudadora_sdosfavor_pagos(
  p_clave_cuenta VARCHAR DEFAULT NULL
)
RETURNS TABLE (
  id_pago_favor INTEGER,
  id_solic INTEGER,
  cvecuenta INTEGER,
  folio INTEGER,
  ejercicio SMALLINT,
  imp_inconform NUMERIC,
  numpago INTEGER,
  imp_pago NUMERIC,
  saldo_favor NUMERIC,
  fecha_pago DATE,
  observaciones TEXT,
  capturista VARCHAR,
  solicitante VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    sf.id_pago_favor,
    sf.id_solic,
    sf.cvecuenta,
    s.folio,
    s.axofol AS ejercicio,
    sf.imp_inconform,
    sf.numpago,
    sf.imp_pago,
    sf.saldo_favor,
    sf.fecha_pago,
    sf.observaciones,
    TRIM(sf.capturista)::VARCHAR AS capturista,
    TRIM(s.solicitante)::VARCHAR AS solicitante
  FROM catastro_gdl.sdosfavor sf
  LEFT JOIN catastro_gdl.solic_sdosfavor s ON sf.id_solic = s.id_solic
  WHERE (
    p_clave_cuenta IS NULL
    OR p_clave_cuenta = ''
    OR sf.cvecuenta::TEXT LIKE '%' || p_clave_cuenta || '%'
  )
  ORDER BY sf.id_pago_favor DESC
  LIMIT 100;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION recaudadora_sdosfavor_pagos(VARCHAR) IS 'Consulta pagos de saldos a favor por cuenta';
