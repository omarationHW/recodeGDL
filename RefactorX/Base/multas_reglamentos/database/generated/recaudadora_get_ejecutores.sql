-- ================================================================
-- SP: recaudadora_get_ejecutores
-- Módulo: multas_reglamentos
-- Descripción: Obtiene lista de ejecutores (empresas) activos
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-24
-- ================================================================

DROP FUNCTION IF EXISTS recaudadora_get_ejecutores();

CREATE OR REPLACE FUNCTION recaudadora_get_ejecutores()
RETURNS TABLE (
  cveejecutor SMALLINT,
  empresa TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
  -- Retornar ejecutores desde la tabla catastro_gdl.ejecutor
  -- Se retornan todos los ejecutores vigentes
  -- La tabla contiene personas (paterno, materno, nombres)
  RETURN QUERY
  SELECT
    e.cveejecutor,
    TRIM(CONCAT_WS(' ',
      TRIM(e.paterno),
      TRIM(e.materno),
      TRIM(e.nombres)
    )) AS empresa
  FROM catastro_gdl.ejecutor e
  WHERE e.vigencia = 'V'  -- Solo ejecutores vigentes
  ORDER BY e.cveejecutor;

EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Error al consultar ejecutores: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION recaudadora_get_ejecutores() IS 'Obtiene lista de ejecutores (empresas) para el módulo de actualización de fechas';
