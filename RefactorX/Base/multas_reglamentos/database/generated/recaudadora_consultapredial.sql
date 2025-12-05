-- ================================================================
-- SP: recaudadora_consultapredial
-- Módulo: multas_reglamentos
-- Descripción: Consulta información predial por clave catastral
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-28
-- ================================================================

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_consultapredial(
    p_cvecat VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    cvecatnva CHARACTER(11),
    cvecuenta INTEGER,
    vigente CHARACTER(1),
    saldo NUMERIC(16),
    axoadeudo INTEGER,
    val_fiscal NUMERIC(16),
    area_terreno INTEGER,
    area_construccion INTEGER,
    tipo_predio CHARACTER(10),
    urbano_rustico CHARACTER(1),
    exenta CHARACTER(1),
    bloqueado CHARACTER(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Retornar información predial de la tabla controladora
    RETURN QUERY
    SELECT
        ctrl.cvecatnva,
        ctrl.cvecuenta,
        ctrl.vigente,
        ctrl.saldo,
        ctrl.axoadeudo,
        ctrl.val1_valfiscal AS val_fiscal,
        ctrl.val1_areaterr AS area_terreno,
        ctrl.val1_areaconst AS area_construccion,
        ctrl.tipo AS tipo_predio,
        ctrl.urbrus AS urbano_rustico,
        ctrl.exenta,
        ctrl.bloqmov AS bloqueado
    FROM catastro_gdl.controladora ctrl
    WHERE
        (p_cvecat IS NULL OR p_cvecat = '' OR ctrl.cvecatnva = p_cvecat)
        AND ctrl.vigente = 'V'
    LIMIT 1;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_consultapredial(VARCHAR) IS 'Consulta información predial por clave catastral desde la tabla controladora.';
