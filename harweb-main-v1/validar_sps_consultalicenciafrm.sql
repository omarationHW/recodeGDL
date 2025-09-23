-- ============================================
-- VALIDACIÓN DE STORED PROCEDURES CONSULTALICENCIAFRM
-- Base: PostgreSQL 192.168.6.146:5432 "padron_licencias"
-- Esquema: informix
-- Fecha: 2025-09-20
-- ============================================

\c padron_licencias;
SET search_path TO informix, public;

-- ============================================
-- VERIFICAR SPs INSTALADOS
-- ============================================

SELECT
    'SPs INSTALADOS EN ESQUEMA INFORMIX:' as titulo;

SELECT
    n.nspname as esquema,
    p.proname as nombre_sp,
    pg_get_function_arguments(p.oid) as parametros
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'informix'
AND (
    p.proname ILIKE '%sp_consultalicencia%' OR
    p.proname ILIKE '%spget_lic_adeudos%'
)
ORDER BY p.proname;

-- ============================================
-- VERIFICAR DATOS DE PRUEBA EN TABLA LICENCIAS
-- ============================================

SELECT
    'DATOS DE MUESTRA EN TABLA LICENCIAS:' as titulo;

SELECT
    id_licencia,
    licencia,
    propietario,
    razon_social,
    rfc,
    ubicacion,
    actividad,
    estado,
    bloqueado,
    vigente,
    fecha_otorgamiento
FROM public.licencias
LIMIT 5;

-- ============================================
-- PRUEBA 1: SP_CONSULTALICENCIA_LIST
-- ============================================

SELECT
    'PRUEBA 1: SP_CONSULTALICENCIA_LIST (existente)' as titulo;

-- Verificar que el SP existe y funciona
SELECT * FROM informix.sp_consultalicencia_list(
    p_numero_licencia := null,
    p_razon_social := null,
    p_giro_comercial := null,
    p_estatus := null,
    p_limite := 5,
    p_offset := 0
);

-- ============================================
-- PRUEBA 2: SP_CONSULTALICENCIA_GET
-- ============================================

SELECT
    'PRUEBA 2: SP_CONSULTALICENCIA_GET' as titulo;

-- Obtener primera licencia para prueba
DO $$
DECLARE
    v_primera_licencia VARCHAR(100);
BEGIN
    SELECT licencia INTO v_primera_licencia
    FROM public.licencias
    WHERE licencia IS NOT NULL
    LIMIT 1;

    IF v_primera_licencia IS NOT NULL THEN
        RAISE NOTICE 'Probando con licencia: %', v_primera_licencia;
        -- La prueba se hace después en consulta separada
    ELSE
        RAISE NOTICE 'No se encontraron licencias para probar';
    END IF;
END $$;

-- Probar SP_CONSULTALICENCIA_GET con primera licencia disponible
SELECT * FROM informix.SP_CONSULTALICENCIA_GET(
    (SELECT licencia FROM public.licencias WHERE licencia IS NOT NULL LIMIT 1)
) LIMIT 1;

-- ============================================
-- PRUEBA 3: SP_CONSULTALICENCIA_VENCIDAS
-- ============================================

SELECT
    'PRUEBA 3: SP_CONSULTALICENCIA_VENCIDAS' as titulo;

SELECT * FROM informix.SP_CONSULTALICENCIA_VENCIDAS(
    p_dias_anticipacion := 365, -- Amplio rango para encontrar datos
    p_limite := 5,
    p_offset := 0
);

-- ============================================
-- PRUEBA 4: spget_lic_adeudos
-- ============================================

SELECT
    'PRUEBA 4: spget_lic_adeudos' as titulo;

-- Verificar tabla detsal_lic
SELECT COUNT(*) as total_adeudos FROM public.detsal_lic;

-- Probar con primer ID disponible
SELECT * FROM informix.spget_lic_adeudos(
    (SELECT id_licencia FROM public.licencias LIMIT 1),
    'L'
) LIMIT 3;

-- ============================================
-- PRUEBA 5: VERIFICAR BLOQUEOS
-- ============================================

SELECT
    'VERIFICAR FUNCIONES DE BLOQUEO EXISTENTES:' as titulo;

SELECT
    n.nspname as esquema,
    p.proname as nombre_sp
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'informix'
AND (
    p.proname ILIKE '%bloquear%' OR
    p.proname ILIKE '%desbloquear%'
)
ORDER BY p.proname;

-- ============================================
-- RESUMEN DE VALIDACIÓN
-- ============================================

SELECT
    'RESUMEN DE VALIDACIÓN:' as titulo;

SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
                    WHERE n.nspname = 'informix' AND p.proname = 'sp_consultalicencia_get')
        THEN '✅ SP_CONSULTALICENCIA_GET'
        ELSE '❌ SP_CONSULTALICENCIA_GET'
    END as status_get,

    CASE
        WHEN EXISTS (SELECT 1 FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
                    WHERE n.nspname = 'informix' AND p.proname = 'sp_consultalicencia_create')
        THEN '✅ SP_CONSULTALICENCIA_CREATE'
        ELSE '❌ SP_CONSULTALICENCIA_CREATE'
    END as status_create,

    CASE
        WHEN EXISTS (SELECT 1 FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
                    WHERE n.nspname = 'informix' AND p.proname = 'sp_consultalicencia_cambiar_estado')
        THEN '✅ SP_CONSULTALICENCIA_CAMBIAR_ESTADO'
        ELSE '❌ SP_CONSULTALICENCIA_CAMBIAR_ESTADO'
    END as status_cambiar_estado,

    CASE
        WHEN EXISTS (SELECT 1 FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
                    WHERE n.nspname = 'informix' AND p.proname = 'sp_consultalicencia_vencidas')
        THEN '✅ SP_CONSULTALICENCIA_VENCIDAS'
        ELSE '❌ SP_CONSULTALICENCIA_VENCIDAS'
    END as status_vencidas,

    CASE
        WHEN EXISTS (SELECT 1 FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid
                    WHERE n.nspname = 'informix' AND p.proname = 'spget_lic_adeudos')
        THEN '✅ spget_lic_adeudos'
        ELSE '❌ spget_lic_adeudos'
    END as status_adeudos;

-- ============================================
-- INFORMACIÓN ADICIONAL
-- ============================================

SELECT
    'INFORMACIÓN DE TABLAS:' as titulo;

SELECT
    schemaname,
    tablename,
    rowcount as filas_estimadas
FROM (
    SELECT
        schemaname,
        tablename,
        n_tup_ins - n_tup_del as rowcount
    FROM pg_stat_user_tables
    WHERE schemaname = 'public'
    AND tablename IN ('licencias', 'detsal_lic', 'bloqueo', 'pagos')
) t
ORDER BY tablename;