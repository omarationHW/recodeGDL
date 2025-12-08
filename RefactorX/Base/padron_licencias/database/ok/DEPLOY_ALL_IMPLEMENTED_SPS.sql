-- ============================================
-- SCRIPT DE DESPLIEGUE CONSOLIDADO
-- STORED PROCEDURES IMPLEMENTADOS - BATCH 5-10
-- ============================================
-- Fecha: 2025-11-20
-- Total SPs: 35
-- Componentes: 5
-- Base de datos: padron_licencias
-- Schemas: public, comun
-- ============================================

\echo '=========================================='
\echo 'INICIANDO DESPLIEGUE DE STORED PROCEDURES'
\echo 'Batch 5-10: 35 SPs en 5 componentes'
\echo '=========================================='

-- Conectar a la base de datos
\c padron_licencias;

-- Configurar search path
SET search_path TO public, comun;

-- Habilitar extensiones necesarias
\echo 'Habilitando extensión pgcrypto...'
CREATE EXTENSION IF NOT EXISTS pgcrypto;

\echo ''
\echo '=========================================='
\echo 'COMPONENTE 1/5: BUSQUE (11 SPs)'
\echo 'Sistema de Búsqueda Catastral'
\echo '=========================================='
\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/02_SP_BUSQUE_all_procedures_IMPLEMENTED.sql

\echo ''
\echo '=========================================='
\echo 'COMPONENTE 2/5: FIRMA (4 SPs)'
\echo 'Sistema de Firmas Digitales'
\echo '=========================================='
\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/FIRMA_all_procedures_IMPLEMENTED.sql

\echo ''
\echo '=========================================='
\echo 'COMPONENTE 3/5: FIRMAUSUARIO (3 SPs)'
\echo 'Validación de Firma Usuario'
\echo '=========================================='
\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/FIRMAUSUARIO_all_procedures_IMPLEMENTED.sql

\echo ''
\echo '=========================================='
\echo 'COMPONENTE 4/5: SFRM_CHGPASS (7 SPs)'
\echo 'Cambio de Contraseña'
\echo '=========================================='
\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/SFRM_CHGPASS_all_procedures_IMPLEMENTED.sql

\echo ''
\echo '=========================================='
\echo 'COMPONENTE 5/5: MODTRAMITEFRM (10 SPs)'
\echo 'Modificación de Trámites'
\echo '=========================================='
\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/MODTRAMITEFRM_all_procedures_IMPLEMENTED.sql

\echo ''
\echo '=========================================='
\echo 'VERIFICANDO DESPLIEGUE'
\echo '=========================================='

-- Verificar funciones creadas
\echo 'Funciones BUSQUE creadas:'
SELECT proname as nombre_funcion, pronargs as parametros
FROM pg_proc
WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
  AND proname LIKE '%busque%'
ORDER BY proname;

\echo ''
\echo 'Funciones FIRMA creadas:'
SELECT proname as nombre_funcion, pronargs as parametros
FROM pg_proc
WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
  AND (proname LIKE '%firma%' OR proname LIKE '%chgpass%')
ORDER BY proname;

\echo ''
\echo 'Funciones MODTRAMITE creadas:'
SELECT proname as nombre_funcion, pronargs as parametros
FROM pg_proc
WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
  AND (proname LIKE '%tramite%' OR proname LIKE '%giro%' OR proname LIKE '%calle%')
ORDER BY proname;

\echo ''
\echo '=========================================='
\echo 'CONTEO TOTAL DE FUNCIONES CREADAS'
\echo '=========================================='

SELECT
    COUNT(*) FILTER (WHERE proname LIKE '%busque%') as busque_sps,
    COUNT(*) FILTER (WHERE proname LIKE '%firma%' AND proname NOT LIKE '%chgpass%') as firma_sps,
    COUNT(*) FILTER (WHERE proname LIKE '%chgpass%') as chgpass_sps,
    COUNT(*) FILTER (WHERE proname LIKE '%tramite%' OR proname LIKE '%giro%' OR proname LIKE '%calle%') as modtramite_sps,
    COUNT(*) as total_sps
FROM pg_proc
WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
  AND (
    proname LIKE '%busque%' OR
    proname LIKE '%firma%' OR
    proname LIKE '%chgpass%' OR
    proname LIKE '%tramite%' OR
    proname LIKE '%giro%' OR
    proname LIKE '%calle%'
  );

\echo ''
\echo '=========================================='
\echo 'PRUEBAS FUNCIONALES BÁSICAS'
\echo '=========================================='

\echo 'Probando sp_busqueda_por_nombre...'
-- SELECT * FROM public.sp_busqueda_por_nombre('GARCIA') LIMIT 1;

\echo 'Probando sp_firma_validate...'
-- SELECT * FROM public.sp_firma_validate('FIRMA_TEST');

\echo 'Probando sp_validate_user_password...'
-- SELECT * FROM public.sp_validate_user_password('admin', 'test123');

\echo 'Probando modtramitefrm_get_giros_search...'
-- SELECT * FROM public.modtramitefrm_get_giros_search('') LIMIT 1;

\echo ''
\echo '=========================================='
\echo 'DESPLIEGUE COMPLETADO EXITOSAMENTE'
\echo '=========================================='
\echo 'Total SPs implementados: 35'
\echo 'Componentes actualizados: 5'
\echo ''
\echo 'Archivos desplegados:'
\echo '  1. 02_SP_BUSQUE_all_procedures_IMPLEMENTED.sql (11 SPs)'
\echo '  2. FIRMA_all_procedures_IMPLEMENTED.sql (4 SPs)'
\echo '  3. FIRMAUSUARIO_all_procedures_IMPLEMENTED.sql (3 SPs)'
\echo '  4. SFRM_CHGPASS_all_procedures_IMPLEMENTED.sql (7 SPs)'
\echo '  5. MODTRAMITEFRM_all_procedures_IMPLEMENTED.sql (10 SPs)'
\echo ''
\echo 'NOTA: Descomentar las pruebas funcionales para ejecutarlas'
\echo 'IMPORTANTE: Validar contra esquema real de BD antes de usar'
\echo '=========================================='

-- ============================================
-- INSTRUCCIONES DE USO
-- ============================================

/*
EJECUCIÓN DEL SCRIPT:

1. Desde línea de comandos:
   psql -U postgres -d padron_licencias -f DEPLOY_ALL_IMPLEMENTED_SPS.sql

2. Desde pgAdmin:
   - Abrir Query Tool
   - Cargar este archivo
   - Ejecutar (F5)

3. Validaciones post-despliegue:
   - Verificar que las 35 funciones estén creadas
   - Probar cada función con datos de prueba
   - Validar desde API genérico Laravel
   - Revisar logs de errores

4. En caso de error:
   - Revisar que las tablas existan en la BD
   - Verificar nombres de columnas coincidan
   - Ajustar schemas (public vs comun)
   - Validar extensión pgcrypto instalada

PRÓXIMOS PASOS:

1. Validar funcionamiento con datos reales
2. Integrar con API genérico Laravel
3. Probar desde frontend Vue
4. Implementar SPs faltantes (~92 adicionales)
5. Optimizar performance con índices

SOPORTE:

- Revisar comentarios en archivos SQL individuales
- Consultar REPORTE_IMPLEMENTACION_SPS_BATCH_5-10.md
- Validar contra RESUMEN_IMPLEMENTACION_SPS.json
*/
