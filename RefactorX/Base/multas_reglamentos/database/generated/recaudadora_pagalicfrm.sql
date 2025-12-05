-- ================================================================
-- SP: recaudadora_pagalicfrm
-- Módulo: multas_reglamentos
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-04
-- Descripción: Busca información de licencias y sus adeudos pendientes
-- ================================================================

CREATE OR REPLACE FUNCTION recaudadora_pagalicfrm(
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
AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_licencia,
        l.licencia,
        TRIM(l.propietario)::VARCHAR as propietario,
        TRIM(l.primer_ap)::VARCHAR as primer_ap,
        TRIM(l.segundo_ap)::VARCHAR as segundo_ap,
        l.id_giro,
        TRIM(l.actividad)::VARCHAR as actividad,
        TRIM(l.ubicacion)::VARCHAR as ubicacion,
        d.axo::INTEGER,
        d.saldo,
        d.derechos,
        d.recargos,
        d.forma,
        d.desc_derechos,
        d.desc_recargos,
        (d.saldo + COALESCE(d.derechos, 0) + COALESCE(d.recargos, 0)) as total_adeudo
    FROM comun.licencias l
    INNER JOIN comun.detsal_lic d ON l.id_licencia = d.id_licencia
    WHERE d.saldo > 0
    AND (licencia_in IS NULL OR l.licencia::VARCHAR = licencia_in)
    ORDER BY l.licencia, d.axo DESC;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION recaudadora_pagalicfrm IS 'Busca información de licencias y sus adeudos pendientes de pago';
