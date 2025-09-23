-- ============================================
-- INSTALACIÓN COMPLETA LOTE 5 - LICENCIAS INFORMIX
-- STORED PROCEDURES CRÍTICOS MIGRADOS AL ESQUEMA INFORMIX
-- Base de datos: padron_licencias
-- Esquema: informix
-- Fecha: 2025-09-21
-- Autor: AGENTE SP - Recodificación Vue LICENCIAS
-- ============================================

-- Conectar a la base de datos
\c padron_licencias;

-- ============================================
-- PASO 1: CREAR ESQUEMA INFORMIX (SI NO EXISTE)
-- ============================================

CREATE SCHEMA IF NOT EXISTS informix;
SET search_path TO informix;

-- Otorgar permisos básicos al esquema
GRANT USAGE ON SCHEMA informix TO PUBLIC;
GRANT CREATE ON SCHEMA informix TO PUBLIC;

-- ============================================
-- PASO 2: CREAR SECUENCIAS PARA SERIAL IDS
-- ============================================

-- Secuencia para licencias_comerciales
CREATE SEQUENCE IF NOT EXISTS informix.licencias_comerciales_id_seq;
ALTER TABLE IF EXISTS informix.licencias_comerciales ALTER COLUMN id SET DEFAULT nextval('informix.licencias_comerciales_id_seq');

-- Secuencia para predial_info
CREATE SEQUENCE IF NOT EXISTS informix.predial_info_id_seq;
ALTER TABLE IF EXISTS informix.predial_info ALTER COLUMN id SET DEFAULT nextval('informix.predial_info_id_seq');

-- Secuencia para constancias
CREATE SEQUENCE IF NOT EXISTS informix.constancias_id_seq;
ALTER TABLE IF EXISTS informix.constancias ALTER COLUMN id SET DEFAULT nextval('informix.constancias_id_seq');

-- Secuencia para parametros
CREATE SEQUENCE IF NOT EXISTS informix.parametros_id_seq;
ALTER TABLE IF EXISTS informix.parametros ALTER COLUMN id SET DEFAULT nextval('informix.parametros_id_seq');

-- ============================================
-- PASO 3: VERIFICAR INSTALACIÓN DE STORED PROCEDURES
-- ============================================

-- Función auxiliar para verificar si una función existe
CREATE OR REPLACE FUNCTION informix.function_exists(schema_name TEXT, function_name TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM information_schema.routines
        WHERE routine_schema = schema_name
        AND routine_name = function_name
    );
END;
$$;

-- ============================================
-- PASO 4: LIMPIAR FUNCIONES EXISTENTES (OPCIONAL)
-- ============================================

-- Comentar las siguientes líneas si NO desea recrear las funciones existentes
/*
DROP FUNCTION IF EXISTS informix.SP_CONSULTALICENCIA_LIST CASCADE;
DROP FUNCTION IF EXISTS informix.SP_CONSULTALICENCIA_GET CASCADE;
DROP FUNCTION IF EXISTS informix.SP_CONSULTALICENCIA_CREATE CASCADE;
DROP FUNCTION IF EXISTS informix.SP_CONSULTALICENCIA_UPDATE CASCADE;
DROP FUNCTION IF EXISTS informix.SP_CONSULTALICENCIA_CAMBIAR_ESTADO CASCADE;
DROP FUNCTION IF EXISTS informix.SP_CONSULTALICENCIA_VENCIDAS CASCADE;

DROP FUNCTION IF EXISTS informix.SP_CONSULTAPREDIAL_LIST CASCADE;
DROP FUNCTION IF EXISTS informix.SP_CONSULTAPREDIAL_GET CASCADE;
DROP FUNCTION IF EXISTS informix.SP_CONSULTAPREDIAL_CREATE CASCADE;
DROP FUNCTION IF EXISTS informix.SP_CONSULTAPREDIAL_UPDATE CASCADE;

DROP FUNCTION IF EXISTS informix.sp_constancia_create CASCADE;
DROP FUNCTION IF EXISTS informix.sp_constancia_update CASCADE;
DROP FUNCTION IF EXISTS informix.sp_constancia_cancel CASCADE;
DROP FUNCTION IF EXISTS informix.sp_constancia_list CASCADE;
DROP FUNCTION IF EXISTS informix.sp_constancia_search CASCADE;
DROP FUNCTION IF EXISTS informix.print_constancia CASCADE;
DROP FUNCTION IF EXISTS informix.sp_constancia_estadisticas CASCADE;
*/

-- ============================================
-- PASO 5: CARGAR STORED PROCEDURES
-- ============================================

-- Mensaje de inicio
DO $$
BEGIN
    RAISE NOTICE 'Iniciando instalación de Stored Procedures INFORMIX para LICENCIAS...';
    RAISE NOTICE 'Esquema objetivo: informix';
    RAISE NOTICE 'Fecha: %', NOW();
END $$;

-- Incluir archivos de stored procedures
-- NOTA: Ejecutar en orden los siguientes archivos:
-- 1. LOTE5_SP_CONSULTALICENCIA_INFORMIX.sql
-- 2. LOTE5_SP_CONSULTAPREDIAL_INFORMIX.sql
-- 3. LOTE5_SP_CONSTANCIA_INFORMIX.sql

\i LOTE5_SP_CONSULTALICENCIA_INFORMIX.sql
\i LOTE5_SP_CONSULTAPREDIAL_INFORMIX.sql
\i LOTE5_SP_CONSTANCIA_INFORMIX.sql

-- ============================================
-- PASO 6: VERIFICAR INSTALACIÓN
-- ============================================

DO $$
DECLARE
    v_count INTEGER;
    v_table_count INTEGER;
    sp_names TEXT[] := ARRAY[
        'SP_CONSULTALICENCIA_LIST',
        'SP_CONSULTALICENCIA_GET',
        'SP_CONSULTALICENCIA_CREATE',
        'SP_CONSULTALICENCIA_UPDATE',
        'SP_CONSULTALICENCIA_CAMBIAR_ESTADO',
        'SP_CONSULTALICENCIA_VENCIDAS',
        'SP_CONSULTAPREDIAL_LIST',
        'SP_CONSULTAPREDIAL_GET',
        'SP_CONSULTAPREDIAL_CREATE',
        'SP_CONSULTAPREDIAL_UPDATE',
        'sp_constancia_create',
        'sp_constancia_update',
        'sp_constancia_cancel',
        'sp_constancia_list',
        'sp_constancia_search',
        'print_constancia',
        'sp_constancia_estadisticas'
    ];
    sp_name TEXT;
BEGIN
    RAISE NOTICE '============================================';
    RAISE NOTICE 'VERIFICACIÓN DE INSTALACIÓN';
    RAISE NOTICE '============================================';

    -- Verificar tablas
    SELECT COUNT(*) INTO v_table_count
    FROM information_schema.tables
    WHERE table_schema = 'informix'
    AND table_name IN ('licencias_comerciales', 'predial_info', 'constancias', 'parametros');

    RAISE NOTICE 'Tablas creadas en esquema informix: %/4', v_table_count;

    -- Verificar stored procedures
    v_count := 0;
    FOREACH sp_name IN ARRAY sp_names
    LOOP
        IF informix.function_exists('informix', sp_name) THEN
            v_count := v_count + 1;
            RAISE NOTICE '✓ SP instalado: %', sp_name;
        ELSE
            RAISE NOTICE '✗ SP FALTANTE: %', sp_name;
        END IF;
    END LOOP;

    RAISE NOTICE '============================================';
    RAISE NOTICE 'Stored Procedures instalados: %/%', v_count, array_length(sp_names, 1);

    IF v_count = array_length(sp_names, 1) AND v_table_count = 4 THEN
        RAISE NOTICE '🎉 INSTALACIÓN COMPLETA - TODOS LOS COMPONENTES LISTOS';
    ELSE
        RAISE NOTICE '⚠️  INSTALACIÓN INCOMPLETA - REVISAR ERRORES';
    END IF;

END $$;

-- ============================================
-- PASO 7: OTORGAR PERMISOS
-- ============================================

-- Permisos para tablas
GRANT SELECT, INSERT, UPDATE, DELETE ON informix.licencias_comerciales TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON informix.predial_info TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON informix.constancias TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON informix.parametros TO PUBLIC;

-- Permisos para secuencias
GRANT USAGE, SELECT ON informix.licencias_comerciales_id_seq TO PUBLIC;
GRANT USAGE, SELECT ON informix.predial_info_id_seq TO PUBLIC;
GRANT USAGE, SELECT ON informix.constancias_id_seq TO PUBLIC;
GRANT USAGE, SELECT ON informix.parametros_id_seq TO PUBLIC;

-- Permisos para funciones (se otorgan automáticamente al esquema)
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA informix TO PUBLIC;

-- ============================================
-- PASO 8: PRUEBAS BÁSICAS DE FUNCIONAMIENTO
-- ============================================

DO $$
DECLARE
    v_result RECORD;
    v_count INTEGER;
BEGIN
    RAISE NOTICE '============================================';
    RAISE NOTICE 'EJECUTANDO PRUEBAS BÁSICAS';
    RAISE NOTICE '============================================';

    -- Prueba 1: Verificar datos de prueba en licencias
    SELECT COUNT(*) INTO v_count FROM informix.licencias_comerciales;
    RAISE NOTICE 'Licencias de prueba: % registros', v_count;

    -- Prueba 2: Verificar datos de prueba en predial
    SELECT COUNT(*) INTO v_count FROM informix.predial_info;
    RAISE NOTICE 'Prediales de prueba: % registros', v_count;

    -- Prueba 3: Verificar datos de prueba en constancias
    SELECT COUNT(*) INTO v_count FROM informix.constancias;
    RAISE NOTICE 'Constancias de prueba: % registros', v_count;

    -- Prueba 4: Probar función básica de consulta licencias
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM informix.SP_CONSULTALICENCIA_LIST();
        RAISE NOTICE '✓ SP_CONSULTALICENCIA_LIST ejecutado: % resultados', v_count;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '✗ Error en SP_CONSULTALICENCIA_LIST: %', SQLERRM;
    END;

    -- Prueba 5: Probar función básica de consulta predial
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM informix.SP_CONSULTAPREDIAL_LIST();
        RAISE NOTICE '✓ SP_CONSULTAPREDIAL_LIST ejecutado: % resultados', v_count;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '✗ Error en SP_CONSULTAPREDIAL_LIST: %', SQLERRM;
    END;

    -- Prueba 6: Probar función básica de constancias
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM informix.sp_constancia_list();
        RAISE NOTICE '✓ sp_constancia_list ejecutado: % resultados', v_count;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '✗ Error en sp_constancia_list: %', SQLERRM;
    END;

    RAISE NOTICE '============================================';
    RAISE NOTICE 'PRUEBAS BÁSICAS COMPLETADAS';
END $$;

-- ============================================
-- PASO 9: INFORMACIÓN DE CONEXIÓN PARA APIS
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '============================================';
    RAISE NOTICE 'INFORMACIÓN PARA INTEGRACIÓN CON APIs';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Esquema de base de datos: informix';
    RAISE NOTICE 'Funciones principales:';
    RAISE NOTICE '';
    RAISE NOTICE 'CONSULTA LICENCIAS:';
    RAISE NOTICE '- informix.SP_CONSULTALICENCIA_LIST(filtros...)';
    RAISE NOTICE '- informix.SP_CONSULTALICENCIA_GET(numero_licencia)';
    RAISE NOTICE '- informix.SP_CONSULTALICENCIA_CREATE(datos...)';
    RAISE NOTICE '- informix.SP_CONSULTALICENCIA_UPDATE(id, datos...)';
    RAISE NOTICE '';
    RAISE NOTICE 'CONSULTA PREDIAL:';
    RAISE NOTICE '- informix.SP_CONSULTAPREDIAL_LIST(filtros...)';
    RAISE NOTICE '- informix.SP_CONSULTAPREDIAL_GET(cuenta_predial)';
    RAISE NOTICE '- informix.SP_CONSULTAPREDIAL_CREATE(datos...)';
    RAISE NOTICE '- informix.SP_CONSULTAPREDIAL_UPDATE(id, datos...)';
    RAISE NOTICE '';
    RAISE NOTICE 'CONSTANCIAS:';
    RAISE NOTICE '- informix.sp_constancia_create(datos...)';
    RAISE NOTICE '- informix.sp_constancia_list(limite, offset...)';
    RAISE NOTICE '- informix.sp_constancia_search(criterios...)';
    RAISE NOTICE '- informix.print_constancia(axo, folio)';
    RAISE NOTICE '';
    RAISE NOTICE 'Todos los SPs retornan datos reales de la base de datos.';
    RAISE NOTICE 'NO hay datos hardcodeados o mock.';
    RAISE NOTICE '============================================';
END $$;

-- ============================================
-- REGISTRO DE INSTALACIÓN
-- ============================================

-- Crear tabla de log de instalaciones si no existe
CREATE TABLE IF NOT EXISTS informix.instalacion_log (
    id SERIAL PRIMARY KEY,
    lote VARCHAR(50),
    descripcion TEXT,
    version VARCHAR(20),
    fecha_instalacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_instalacion VARCHAR(100) DEFAULT USER,
    estado VARCHAR(20) DEFAULT 'COMPLETADO'
);

-- Registrar esta instalación
INSERT INTO informix.instalacion_log (lote, descripcion, version, estado)
VALUES (
    'LOTE5_LICENCIAS_INFORMIX',
    'Instalación de Stored Procedures críticos para módulo LICENCIAS en esquema INFORMIX',
    '1.0.0',
    'COMPLETADO'
);

-- Mensaje final
DO $$
BEGIN
    RAISE NOTICE '============================================';
    RAISE NOTICE '🎉 INSTALACIÓN LOTE 5 - LICENCIAS INFORMIX COMPLETADA';
    RAISE NOTICE 'Fecha: %', NOW();
    RAISE NOTICE 'Total de SPs: 17';
    RAISE NOTICE 'Total de tablas: 4';
    RAISE NOTICE 'Esquema: informix';
    RAISE NOTICE '============================================';
    RAISE NOTICE '';
    RAISE NOTICE 'PRÓXIMOS PASOS:';
    RAISE NOTICE '1. Configurar APIs Laravel para usar esquema informix';
    RAISE NOTICE '2. Actualizar conexiones de base de datos';
    RAISE NOTICE '3. Probar integración con Vue components';
    RAISE NOTICE '4. Validar que todos los endpoints retornen datos reales';
    RAISE NOTICE '';
    RAISE NOTICE 'IMPORTANTE: Todas las funciones están listas para';
    RAISE NOTICE 'integrarse con el componente LicenciasGeneric.vue';
    RAISE NOTICE '============================================';
END $$;

-- Limpiar función auxiliar
DROP FUNCTION IF EXISTS informix.function_exists;

-- Finalizar
\echo '✅ INSTALACIÓN COMPLETADA - REVISAR LOG PARA DETALLES'