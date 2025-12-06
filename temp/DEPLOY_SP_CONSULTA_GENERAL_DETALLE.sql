-- =====================================================================
-- STORED PROCEDURES PARA CONSULTA GENERAL - MODAL DE DETALLE
-- Basado en las estructuras reales de las tablas
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
        0::NUMERIC(10,2) as recargos  -- Por ahora en 0, agregar si existe la columna
    FROM publico.ta_11_adeudo_local a
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
    folio VARCHAR(30),
    usuario VARCHAR(30)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.axo::SMALLINT,
        p.periodo::SMALLINT,
        p.fecha_pago::DATE,
        COALESCE(p.importe_pago, 0)::NUMERIC(10,2) as importe_pago,
        COALESCE(TRIM(p.folio), '')::VARCHAR(30) as folio,
        COALESCE(u.usuario, '')::VARCHAR(30) as usuario
    FROM publico.ta_11_pagos_local p
    LEFT JOIN publico.ta_usuario u ON p.id_usuario = u.id_usuario
    WHERE p.id_local = p_id_local
    ORDER BY p.fecha_pago DESC, p.axo DESC, p.periodo DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- 3. SP para obtener requerimientos de un local (stub - retorna vacío por ahora)
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
    -- Por ahora retorna vacío ya que no existe la tabla específica
    -- Se puede actualizar cuando se identifique la tabla correcta
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- Comentarios sobre el SP
COMMENT ON FUNCTION sp_consulta_general_adeudos(INTEGER) IS 'Obtiene los adeudos de un local específico';
COMMENT ON FUNCTION sp_consulta_general_pagos(INTEGER) IS 'Obtiene los pagos realizados de un local específico';
COMMENT ON FUNCTION sp_consulta_general_requerimientos(INTEGER) IS 'Obtiene los requerimientos de un local - pendiente tabla específica';

-- Verificar creación de los SPs
SELECT
    proname as nombre_sp,
    pg_get_function_arguments(oid) as argumentos,
    obj_description(oid) as descripcion
FROM pg_proc
WHERE proname IN (
    'sp_consulta_general_adeudos',
    'sp_consulta_general_pagos',
    'sp_consulta_general_requerimientos'
)
ORDER BY proname;
