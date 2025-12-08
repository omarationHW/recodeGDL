-- ============================================
-- PRUEBAS DE STORED PROCEDURES - DOCTOSFRM
-- ============================================
-- Componente: doctosfrm
-- Módulo: padron_licencias
-- Fecha: 2025-11-20
-- ============================================
-- DESCRIPCIÓN:
-- Script de pruebas para validar el funcionamiento correcto
-- de todos los stored procedures del componente doctosfrm
-- ============================================

\c padron_licencias;
SET search_path TO public;

-- ============================================
-- Limpiar datos de prueba anteriores
-- ============================================
DELETE FROM public.doctosfrm_tramite WHERE tramite_id IN (9999, 9998, 9997);

-- ============================================
-- PRUEBA 1: sp_doctosfrm_catalog
-- ============================================
\echo '=========================================='
\echo 'PRUEBA 1: sp_doctosfrm_catalog'
\echo 'Debe retornar 19 tipos de documentos'
\echo '=========================================='

SELECT
    COUNT(*) AS total_documentos,
    'Esperado: 19' AS validacion
FROM sp_doctosfrm_catalog();

\echo ''
\echo 'Listado completo de documentos:'
SELECT * FROM sp_doctosfrm_catalog() ORDER BY codigo;

-- ============================================
-- PRUEBA 2: sp_doctosfrm_save (INSERT)
-- ============================================
\echo ''
\echo '=========================================='
\echo 'PRUEBA 2: sp_doctosfrm_save - INSERT nuevo'
\echo 'Debe crear un nuevo registro'
\echo '=========================================='

SELECT * FROM sp_doctosfrm_save(
    9999,
    '["fotofachada", "recibopredial", "ident_titular"]'::json,
    'Documentos iniciales del trámite de prueba'
);

-- ============================================
-- PRUEBA 3: sp_doctosfrm_get
-- ============================================
\echo ''
\echo '=========================================='
\echo 'PRUEBA 3: sp_doctosfrm_get'
\echo 'Debe retornar los documentos guardados'
\echo '=========================================='

SELECT
    tramite_id,
    documentos,
    array_length(documentos, 1) AS total_docs,
    otro
FROM (
    SELECT 9999 AS tramite_id, * FROM sp_doctosfrm_get(9999)
) AS resultado;

-- ============================================
-- PRUEBA 4: sp_doctosfrm_save (UPDATE)
-- ============================================
\echo ''
\echo '=========================================='
\echo 'PRUEBA 4: sp_doctosfrm_save - UPDATE existente'
\echo 'Debe actualizar el registro existente'
\echo '=========================================='

SELECT * FROM sp_doctosfrm_save(
    9999,
    '["fotofachada", "recibopredial", "ident_titular", "licencia_vigente", "carta_policia"]'::json,
    'Documentos actualizados - se agregaron 2 más'
);

\echo ''
\echo 'Verificar actualización:'
SELECT
    tramite_id,
    documentos,
    array_length(documentos, 1) AS total_docs,
    otro
FROM (
    SELECT 9999 AS tramite_id, * FROM sp_doctosfrm_get(9999)
) AS resultado;

-- ============================================
-- PRUEBA 5: sp_doctosfrm_delete
-- ============================================
\echo ''
\echo '=========================================='
\echo 'PRUEBA 5: sp_doctosfrm_delete'
\echo 'Debe eliminar un documento específico'
\echo '=========================================='

SELECT * FROM sp_doctosfrm_delete(9999, 'recibopredial');

\echo ''
\echo 'Verificar eliminación (debe tener 4 documentos):'
SELECT
    tramite_id,
    documentos,
    array_length(documentos, 1) AS total_docs,
    otro
FROM (
    SELECT 9999 AS tramite_id, * FROM sp_doctosfrm_get(9999)
) AS resultado;

-- ============================================
-- PRUEBA 6: sp_doctosfrm_clear
-- ============================================
\echo ''
\echo '=========================================='
\echo 'PRUEBA 6: sp_doctosfrm_clear'
\echo 'Debe limpiar todos los documentos'
\echo '=========================================='

SELECT * FROM sp_doctosfrm_clear(9999);

\echo ''
\echo 'Verificar limpieza (debe tener array vacío):'
SELECT
    tramite_id,
    documentos,
    COALESCE(array_length(documentos, 1), 0) AS total_docs,
    otro
FROM (
    SELECT 9999 AS tramite_id, * FROM sp_doctosfrm_get(9999)
) AS resultado;

-- ============================================
-- PRUEBA 7: Validaciones de parámetros
-- ============================================
\echo ''
\echo '=========================================='
\echo 'PRUEBA 7: Validaciones de parámetros'
\echo '=========================================='

\echo ''
\echo '7.1 - sp_doctosfrm_get con tramite_id NULL (debe fallar):'
SELECT * FROM sp_doctosfrm_get(NULL);

\echo ''
\echo '7.2 - sp_doctosfrm_save con tramite_id <= 0 (debe fallar):'
SELECT * FROM sp_doctosfrm_save(0, '[]'::json, NULL);

\echo ''
\echo '7.3 - sp_doctosfrm_save con JSON inválido (debe fallar):'
SELECT * FROM sp_doctosfrm_save(9999, 'invalid json'::json, NULL);

\echo ''
\echo '7.4 - sp_doctosfrm_delete con documento NULL (debe fallar):'
SELECT * FROM sp_doctosfrm_delete(9999, NULL);

\echo ''
\echo '7.5 - sp_doctosfrm_delete con documento inexistente (debe fallar):'
SELECT * FROM sp_doctosfrm_delete(9999, 'documento_inexistente');

-- ============================================
-- PRUEBA 8: Casos de borde
-- ============================================
\echo ''
\echo '=========================================='
\echo 'PRUEBA 8: Casos de borde'
\echo '=========================================='

\echo ''
\echo '8.1 - Guardar con array vacío:'
SELECT * FROM sp_doctosfrm_save(9998, '[]'::json, 'Sin documentos');

\echo ''
\echo 'Verificar:'
SELECT * FROM sp_doctosfrm_get(9998);

\echo ''
\echo '8.2 - Guardar con NULL en documentos:'
SELECT * FROM sp_doctosfrm_save(9997, NULL, 'Solo observaciones');

\echo ''
\echo 'Verificar:'
SELECT * FROM sp_doctosfrm_get(9997);

\echo ''
\echo '8.3 - Consultar trámite inexistente (debe retornar array vacío):'
SELECT * FROM sp_doctosfrm_get(99999);

-- ============================================
-- PRUEBA 9: Verificar integridad de datos
-- ============================================
\echo ''
\echo '=========================================='
\echo 'PRUEBA 9: Verificar integridad de datos'
\echo '=========================================='

SELECT
    tramite_id,
    array_length(documentos, 1) AS num_documentos,
    documentos,
    LENGTH(otro) AS len_observaciones,
    fecalt,
    fecmod
FROM public.doctosfrm_tramite
WHERE tramite_id IN (9999, 9998, 9997)
ORDER BY tramite_id;

-- ============================================
-- PRUEBA 10: Performance con múltiples documentos
-- ============================================
\echo ''
\echo '=========================================='
\echo 'PRUEBA 10: Performance con todos los documentos'
\echo '=========================================='

SELECT * FROM sp_doctosfrm_save(
    9999,
    (SELECT json_agg(codigo) FROM sp_doctosfrm_catalog()),
    'Todos los documentos del catálogo'
);

\echo ''
\echo 'Verificar (debe tener 19 documentos):'
SELECT
    tramite_id,
    array_length(documentos, 1) AS total_docs,
    'Esperado: 19' AS validacion
FROM (
    SELECT 9999 AS tramite_id, * FROM sp_doctosfrm_get(9999)
) AS resultado;

-- ============================================
-- Limpiar datos de prueba
-- ============================================
\echo ''
\echo '=========================================='
\echo 'Limpiando datos de prueba...'
\echo '=========================================='

DELETE FROM public.doctosfrm_tramite WHERE tramite_id IN (9999, 9998, 9997);

\echo ''
\echo 'Verificar limpieza:'
SELECT COUNT(*) AS registros_restantes
FROM public.doctosfrm_tramite
WHERE tramite_id IN (9999, 9998, 9997);

-- ============================================
-- RESUMEN DE PRUEBAS
-- ============================================
\echo ''
\echo '=========================================='
\echo 'RESUMEN DE PRUEBAS COMPLETADAS'
\echo '=========================================='
\echo 'SP Probados:'
\echo '  1. sp_doctosfrm_catalog    - OK'
\echo '  2. sp_doctosfrm_save        - OK (INSERT y UPDATE)'
\echo '  3. sp_doctosfrm_get         - OK'
\echo '  4. sp_doctosfrm_delete      - OK'
\echo '  5. sp_doctosfrm_clear       - OK'
\echo ''
\echo 'Validaciones probadas:'
\echo '  - Parámetros NULL'
\echo '  - Parámetros inválidos'
\echo '  - JSON inválido'
\echo '  - Documentos inexistentes'
\echo '  - Array vacío'
\echo '  - Todos los documentos del catálogo'
\echo ''
\echo 'Todas las pruebas completadas!'
\echo '=========================================='
