-- ================================================================
-- SP: recaudadora_sdosfavor_ctrlexp
-- Módulo: multas_reglamentos
-- Descripción: Consulta expedientes de saldos a favor por cuenta
-- Tabla: catastro_gdl.solic_sdosfavor
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-25
-- ================================================================

CREATE OR REPLACE FUNCTION recaudadora_sdosfavor_ctrlexp(
  p_clave_cuenta VARCHAR DEFAULT NULL
)
RETURNS TABLE (
  id_solic INTEGER,
  axofol SMALLINT,
  folio INTEGER,
  cvecuenta INTEGER,
  domicilio TEXT,
  solicitante VARCHAR,
  status VARCHAR,
  observaciones TEXT,
  feccap DATE,
  capturista VARCHAR,
  fecha_termino DATE,
  inconf SMALLINT,
  peticionario SMALLINT
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    s.id_solic,
    s.axofol,
    s.folio,
    s.cvecuenta,
    TRIM(CONCAT_WS(' ',
      TRIM(s.domp),
      TRIM(s.extp),
      TRIM(s.intp),
      TRIM(s.colp)
    )) AS domicilio,
    TRIM(s.solicitante)::VARCHAR AS solicitante,
    TRIM(s.status)::VARCHAR AS status,
    s.observaciones,
    s.feccap,
    TRIM(s.capturista)::VARCHAR AS capturista,
    s.fecha_termino,
    s.inconf,
    s.peticionario
  FROM catastro_gdl.solic_sdosfavor s
  WHERE (
    p_clave_cuenta IS NULL
    OR p_clave_cuenta = ''
    OR s.cvecuenta::TEXT LIKE '%' || p_clave_cuenta || '%'
  )
  ORDER BY s.id_solic DESC
  LIMIT 100;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION recaudadora_sdosfavor_ctrlexp(VARCHAR) IS 'Consulta expedientes de saldos a favor por cuenta';
