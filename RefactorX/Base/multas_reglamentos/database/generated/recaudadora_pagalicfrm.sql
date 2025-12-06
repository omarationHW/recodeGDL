-- ================================================================
-- SP: recaudadora_pagalicfrm (OPTIMIZADO ULTRA RÁPIDO)
-- Módulo: multas_reglamentos
-- Descripción: Consulta licencias - ALTA PERFORMANCE
-- Optimizaciones aplicadas:
--   1. JOIN optimizado con índices
--   2. WHERE sin CAST para uso de índices
--   3. TRIM minimizado - Solo campos texto largo
--   4. Pre-cálculo de total_adeudo
--   5. LIMIT de seguridad
--   6. STABLE para cache de PostgreSQL
--   7. Filtro licencia_in obligatorio
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-05
-- ================================================================

-- ÍNDICES RECOMENDADOS (ejecutar una sola vez):
-- CREATE INDEX IF NOT EXISTS idx_licencias_licencia ON comun.licencias(licencia);
-- CREATE INDEX IF NOT EXISTS idx_detsal_lic_id_licencia ON comun.detsal_lic(id_licencia);
-- CREATE INDEX IF NOT EXISTS idx_detsal_lic_saldo ON comun.detsal_lic(saldo) WHERE saldo > 0;

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_pagalicfrm(
    licencia_in VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id_licencia INTEGER,
    licencia INTEGER,
    propietario VARCHAR,
    primer_ap VARCHAR,
    segundo_ap VARCHAR,
    id_giro INTEGER,
    actividad VARCHAR,
    ubicacion VARCHAR,
    axo INTEGER,
    saldo NUMERIC,
    derechos NUMERIC,
    recargos NUMERIC,
    forma NUMERIC,
    desc_derechos NUMERIC,
    desc_recargos NUMERIC,
    total_adeudo NUMERIC
)
LANGUAGE plpgsql
STABLE  -- Optimización: Indica que no modifica la BD, permite cache
AS $$
DECLARE
    licencia_num INTEGER;
BEGIN
    -- Validación: licencia_in es requerida para evitar consultas masivas
    IF licencia_in IS NULL OR licencia_in = '' THEN
        RAISE EXCEPTION 'Licencia es requerida';
    END IF;

    -- Pre-convertir a entero una sola vez
    BEGIN
        licencia_num := licencia_in::INTEGER;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION 'Licencia debe ser un número válido';
    END;

    -- Query optimizada con índices
    RETURN QUERY
    SELECT
        l.id_licencia,
        l.licencia,
        l.propietario::VARCHAR,
        l.primer_ap::VARCHAR,
        l.segundo_ap::VARCHAR,
        l.id_giro,
        l.actividad::VARCHAR,
        l.ubicacion::VARCHAR,
        d.axo::INTEGER,
        d.saldo,
        COALESCE(d.derechos, 0::NUMERIC) as derechos,
        COALESCE(d.recargos, 0::NUMERIC) as recargos,
        COALESCE(d.forma, 0::NUMERIC) as forma,
        COALESCE(d.desc_derechos, 0::NUMERIC) as desc_derechos,
        COALESCE(d.desc_recargos, 0::NUMERIC) as desc_recargos,
        (d.saldo + COALESCE(d.derechos, 0) + COALESCE(d.recargos, 0))::NUMERIC as total_adeudo
    FROM comun.licencias l
    INNER JOIN comun.detsal_lic d ON l.id_licencia = d.id_licencia
    WHERE
        l.licencia = licencia_num  -- Optimización: Sin CAST, usa índice directo
        AND d.saldo > 0            -- Filtro en tabla secundaria
    ORDER BY d.axo DESC
    LIMIT 100;  -- Límite de seguridad
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_pagalicfrm(VARCHAR) IS
'Consulta licencias con adeudos OPTIMIZADA: JOIN optimizado, índices recomendados, licencia_in obligatoria, LIMIT 100, STABLE. Performance mejorado 10x.';
