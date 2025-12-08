-- ============================================
-- STORED PROCEDURES IMPLEMENTADOS
-- Formulario: consLic400frm
-- Módulo: padron_licencias
-- Generado: 2025-11-20
-- Total SPs: 2
-- ============================================
-- DESCRIPCIÓN:
-- Componente para consulta de licencias modelo 400 (históricas)
-- - Consulta datos completos de licencias 400
-- - Consulta pagos asociados a licencias 400
-- ============================================

-- ============================================
-- SP 1/2: sp_cons_lic_400_get_lic_400
-- Tipo: CONSULTA
-- Schema: comun
-- Descripción: Obtiene los datos completos de una licencia modelo 400 por número de licencia
-- Tablas: lic_400
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_cons_lic_400_get_lic_400(
    p_numlic INTEGER
)
RETURNS TABLE(
    ofna VARCHAR(20),
    numlic INTEGER,
    inirfc VARCHAR(10),
    fnarfc VARCHAR(20),
    homono VARCHAR(20),
    dighom VARCHAR(1),
    codgir VARCHAR(10),
    ilgir1 VARCHAR(100),
    ilgir2 VARCHAR(100),
    ilgir3 VARCHAR(100),
    nocars VARCHAR(100),
    nugrub VARCHAR(10),
    nuext VARCHAR(10),
    letext VARCHAR(5),
    numint VARCHAR(10),
    letint VARCHAR(5),
    piso VARCHAR(5),
    letsec VARCHAR(5),
    numzon VARCHAR(10),
    zonpos VARCHAR(10),
    fecalt DATE,
    fecbaj DATE,
    nomcal VARCHAR(100),
    tomesu DECIMAL(10,2),
    numanu VARCHAR(20),
    nuayt VARCHAR(20),
    reint DECIMAL(10,2),
    reclt DECIMAL(10,2),
    imlit DECIMAL(10,2),
    liimt DECIMAL(10,2),
    vigenc VARCHAR(1),
    actgrl VARCHAR(200),
    grabo VARCHAR(1),
    resta VARCHAR(1),
    fut1 VARCHAR(50),
    fut2 VARCHAR(50)
) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Validación de parámetros requeridos
    IF p_numlic IS NULL OR p_numlic <= 0 THEN
        RAISE EXCEPTION 'El número de licencia es requerido y debe ser mayor a cero';
    END IF;

    -- Verificar que existe la licencia
    SELECT COUNT(*) INTO v_count
    FROM comun.lic_400
    WHERE numlic = p_numlic;

    IF v_count = 0 THEN
        RAISE EXCEPTION 'No se encontró la licencia número %', p_numlic;
    END IF;

    -- Retornar datos de la licencia
    RETURN QUERY
    SELECT
        l.ofna,
        l.numlic,
        l.inirfc,
        l.fnarfc,
        l.homono,
        l.dighom,
        l.codgir,
        l.ilgir1,
        l.ilgir2,
        l.ilgir3,
        l.nocars,
        l.nugrub,
        l.nuext,
        l.letext,
        l.numint,
        l.letint,
        l.piso,
        l.letsec,
        l.numzon,
        l.zonpos,
        l.fecalt,
        l.fecbaj,
        l.nomcal,
        l.tomesu,
        l.numanu,
        l.nuayt,
        l.reint,
        l.reclt,
        l.imlit,
        l.liimt,
        l.vigenc,
        l.actgrl,
        l.grabo,
        l.resta,
        l.fut1,
        l.fut2
    FROM comun.lic_400 l
    WHERE l.numlic = p_numlic;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al consultar licencia 400: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Comentario del SP
COMMENT ON FUNCTION comun.sp_cons_lic_400_get_lic_400(INTEGER) IS
'Consulta datos completos de una licencia modelo 400 por número de licencia';

-- ============================================
-- SP 2/2: sp_cons_lic_400_get_pago_lic_400
-- Tipo: CONSULTA
-- Schema: comun
-- Descripción: Obtiene todos los pagos asociados a una licencia modelo 400
-- Tablas: pago_lic_400
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_cons_lic_400_get_pago_lic_400(
    p_numlic INTEGER
)
RETURNS TABLE(
    numlic INTEGER,
    anio VARCHAR(4),
    mes VARCHAR(2),
    fecha_pago DATE,
    importe DECIMAL(10,2),
    recibo VARCHAR(20),
    caja VARCHAR(10),
    cajero VARCHAR(50),
    concepto VARCHAR(200),
    observaciones TEXT,
    estatus VARCHAR(1),
    fecha_registro TIMESTAMP,
    usuario_registro VARCHAR(50)
) AS $$
DECLARE
    v_count_lic INTEGER;
    v_count_pagos INTEGER;
BEGIN
    -- Validación de parámetros requeridos
    IF p_numlic IS NULL OR p_numlic <= 0 THEN
        RAISE EXCEPTION 'El número de licencia es requerido y debe ser mayor a cero';
    END IF;

    -- Verificar que existe la licencia
    SELECT COUNT(*) INTO v_count_lic
    FROM comun.lic_400
    WHERE numlic = p_numlic;

    IF v_count_lic = 0 THEN
        RAISE EXCEPTION 'No se encontró la licencia número %', p_numlic;
    END IF;

    -- Contar pagos asociados
    SELECT COUNT(*) INTO v_count_pagos
    FROM comun.pago_lic_400
    WHERE numlic = p_numlic;

    -- Si no hay pagos, retornar conjunto vacío (no error)
    IF v_count_pagos = 0 THEN
        RAISE NOTICE 'La licencia % no tiene pagos registrados', p_numlic;
        RETURN;
    END IF;

    -- Retornar datos de pagos ordenados por fecha descendente
    RETURN QUERY
    SELECT
        p.numlic,
        p.anio,
        p.mes,
        p.fecha_pago,
        p.importe,
        p.recibo,
        p.caja,
        p.cajero,
        p.concepto,
        p.observaciones,
        p.estatus,
        p.fecha_registro,
        p.usuario_registro
    FROM comun.pago_lic_400 p
    WHERE p.numlic = p_numlic
    ORDER BY p.fecha_pago DESC, p.fecha_registro DESC;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al consultar pagos de licencia 400: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Comentario del SP
COMMENT ON FUNCTION comun.sp_cons_lic_400_get_pago_lic_400(INTEGER) IS
'Consulta todos los pagos asociados a una licencia modelo 400';

-- ============================================
-- ÍNDICES RECOMENDADOS PARA OPTIMIZACIÓN
-- ============================================

-- Índice en lic_400 por número de licencia (si no existe)
CREATE INDEX IF NOT EXISTS idx_lic_400_numlic ON comun.lic_400(numlic);

-- Índice en pago_lic_400 por número de licencia (si no existe)
CREATE INDEX IF NOT EXISTS idx_pago_lic_400_numlic ON comun.pago_lic_400(numlic);

-- Índice compuesto para ordenamiento eficiente de pagos
CREATE INDEX IF NOT EXISTS idx_pago_lic_400_numlic_fecha
ON comun.pago_lic_400(numlic, fecha_pago DESC, fecha_registro DESC);

-- ============================================
-- GRANTS - PERMISOS DE EJECUCIÓN
-- ============================================

-- Otorgar permisos de ejecución al rol de aplicación
GRANT EXECUTE ON FUNCTION comun.sp_cons_lic_400_get_lic_400(INTEGER) TO app_padron_licencias;
GRANT EXECUTE ON FUNCTION comun.sp_cons_lic_400_get_pago_lic_400(INTEGER) TO app_padron_licencias;

-- ============================================
-- EJEMPLOS DE USO
-- ============================================

/*
-- Ejemplo 1: Consultar datos de licencia 400
SELECT * FROM comun.sp_cons_lic_400_get_lic_400(12345);

-- Ejemplo 2: Consultar pagos de licencia 400
SELECT * FROM comun.sp_cons_lic_400_get_pago_lic_400(12345);

-- Ejemplo 3: Consulta completa de licencia con sus pagos
WITH licencia AS (
    SELECT * FROM comun.sp_cons_lic_400_get_lic_400(12345)
),
pagos AS (
    SELECT * FROM comun.sp_cons_lic_400_get_pago_lic_400(12345)
)
SELECT
    l.*,
    COALESCE(COUNT(p.recibo), 0) as total_pagos,
    COALESCE(SUM(p.importe), 0) as total_pagado
FROM licencia l
LEFT JOIN pagos p ON l.numlic = p.numlic
GROUP BY l.numlic, l.ofna, l.inirfc, l.fnarfc, l.homono, l.dighom,
         l.codgir, l.ilgir1, l.ilgir2, l.ilgir3, l.nocars, l.nugrub,
         l.nuext, l.letext, l.numint, l.letint, l.piso, l.letsec,
         l.numzon, l.zonpos, l.fecalt, l.fecbaj, l.nomcal, l.tomesu,
         l.numanu, l.nuayt, l.reint, l.reclt, l.imlit, l.liimt,
         l.vigenc, l.actgrl, l.grabo, l.resta, l.fut1, l.fut2;

-- Ejemplo 4: Manejo de errores
DO $$
BEGIN
    -- Intentar consultar licencia que no existe
    PERFORM * FROM comun.sp_cons_lic_400_get_lic_400(99999999);
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error capturado: %', SQLERRM;
END $$;
*/

-- ============================================
-- INFORMACIÓN DE DEPLOYMENT
-- ============================================
-- Archivo: CONSLIC400FRM_all_procedures_IMPLEMENTED.sql
-- Módulo: padron_licencias
-- Componente: consLic400frm
-- Total SPs: 2
-- Schema: comun
-- Fecha: 2025-11-20
-- ============================================
