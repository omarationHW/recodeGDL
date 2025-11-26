-- ================================================================
-- SP: recaudadora_listareq
-- Módulo: multas_reglamentos
-- Descripción: Listar requerimientos por cuenta
-- Tabla: catastro_gdl.reqdiftransmision
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-25
-- ================================================================

DROP FUNCTION IF EXISTS recaudadora_listareq(TEXT);

CREATE OR REPLACE FUNCTION recaudadora_listareq(
  p_clave_cuenta TEXT DEFAULT NULL
)
RETURNS TABLE (
  cvereq INTEGER,
  cvecuenta INTEGER,
  folioreq INTEGER,
  axoreq INTEGER,
  total NUMERIC,
  vigencia CHARACTER(1),
  fecemi DATE,
  feccap DATE,
  cveproceso CHARACTER(1),
  recaud INTEGER,
  impuesto NUMERIC,
  recargos NUMERIC,
  multa_imp NUMERIC,
  multa_ext NUMERIC,
  actualizacion NUMERIC,
  gastos NUMERIC,
  multa NUMERIC,
  gastos_req NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
  -- Listar requerimientos filtrados por cuenta (opcional)
  RETURN QUERY
  SELECT
    r.cvereq,
    r.cvecuenta,
    r.folioreq,
    r.axoreq,
    r.total,
    r.vigencia,
    r.fecemi,
    r.feccap,
    r.cveproceso,
    r.recaud,
    r.impuesto,
    r.recargos,
    r.multa_imp,
    r.multa_ext,
    r.actualizacion,
    r.gastos,
    r.multa,
    r.gastos_req
  FROM catastro_gdl.reqdiftransmision r
  WHERE
    (p_clave_cuenta IS NULL OR p_clave_cuenta = '' OR r.cvecuenta::TEXT = p_clave_cuenta)
  ORDER BY r.cvereq DESC
  LIMIT 100;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION recaudadora_listareq(TEXT) IS 'Listar requerimientos por cuenta';
