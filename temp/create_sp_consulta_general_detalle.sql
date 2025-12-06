-- =====================================================================
-- STORED PROCEDURES PARA CONSULTA GENERAL - MODAL DE DETALLE
-- =====================================================================

-- 1. SP para obtener adeudos de un local
DROP FUNCTION IF EXISTS sp_consulta_general_adeudos(INTEGER);

CREATE OR REPLACE FUNCTION sp_consulta_general_adeudos(
    p_id_local INTEGER
) RETURNS TABLE(
    axo SMALLINT,
    periodo SMALLINT,
    importe NUMERIC(10,2),
    recargos NUMERIC(10,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.axo::SMALLINT,
        a.periodo::SMALLINT,
        COALESCE(a.importe, 0)::NUMERIC(10,2) as importe,
        COALESCE(a.recargos, 0)::NUMERIC(10,2) as recargos
    FROM publico.ta_11_adeudos_locales a
    WHERE a.id_local = p_id_local
    ORDER BY a.axo DESC, a.periodo DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- 2. SP para obtener pagos de un local
DROP FUNCTION IF EXISTS sp_consulta_general_pagos(INTEGER);

CREATE OR REPLACE FUNCTION sp_consulta_general_pagos(
    p_id_local INTEGER
) RETURNS TABLE(
    axo SMALLINT,
    periodo SMALLINT,
    fecha_pago DATE,
    importe_pago NUMERIC(10,2),
    folio VARCHAR(20),
    usuario VARCHAR(30)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.axo::SMALLINT,
        p.periodo::SMALLINT,
        p.fecha_pago::DATE,
        COALESCE(p.importe_pago, 0)::NUMERIC(10,2) as importe_pago,
        COALESCE(p.folio, '')::VARCHAR(20) as folio,
        COALESCE(p.usuario, '')::VARCHAR(30) as usuario
    FROM publico.ta_11_pago_local p
    WHERE p.id_local = p_id_local
    ORDER BY p.fecha_pago DESC, p.axo DESC, p.periodo DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- 3. SP para obtener requerimientos de un local
DROP FUNCTION IF EXISTS sp_consulta_general_requerimientos(INTEGER);

CREATE OR REPLACE FUNCTION sp_consulta_general_requerimientos(
    p_id_local INTEGER
) RETURNS TABLE(
    folio VARCHAR(20),
    fecha_emision DATE,
    importe_multa NUMERIC(10,2),
    importe_gastos NUMERIC(10,2),
    vigencia VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(r.folio, '')::VARCHAR(20) as folio,
        r.fecha_emision::DATE,
        COALESCE(r.importe_multa, 0)::NUMERIC(10,2) as importe_multa,
        COALESCE(r.importe_gastos, 0)::NUMERIC(10,2) as importe_gastos,
        COALESCE(r.vigencia, '')::VARCHAR(10) as vigencia
    FROM publico.ta_11_requerimientos_local r
    WHERE r.id_local = p_id_local
    ORDER BY r.fecha_emision DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- Verificar que los SPs se crearon correctamente
SELECT
    proname as nombre_sp,
    pg_get_function_arguments(oid) as argumentos
FROM pg_proc
WHERE proname IN (
    'sp_consulta_general_adeudos',
    'sp_consulta_general_pagos',
    'sp_consulta_general_requerimientos'
)
ORDER BY proname;
