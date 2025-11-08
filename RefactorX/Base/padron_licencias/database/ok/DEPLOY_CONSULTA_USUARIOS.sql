-- ============================================
-- Script de Despliegue: Consulta de Usuarios
-- Base de Datos: padron_licencias
-- Módulo: consultausuariosfrm
-- Descripción: Script maestro para crear los stored procedures
--              del módulo de consulta de usuarios
-- Esquema: comun
-- Fecha: 2025-11-03
-- ============================================

-- NOTA: Las tablas comun.usuarios, comun.deptos y comun.c_dependencias
--       ya deben existir en la base de datos antes de ejecutar este script

-- ============================================
-- Crear stored procedures en esquema comun
-- ============================================
\echo '=========================================='
\echo 'Creando stored procedures para consulta de usuarios...'
\echo '=========================================='

\i sp_catalogo_dependencias.sql
\i sp_catalogo_deptos_por_dependencia.sql
\i sp_consulta_usuario_por_usuario.sql
\i sp_consulta_usuario_por_nombre.sql
\i sp_consulta_usuario_por_dependencia_depto.sql

\echo '=========================================='
\echo 'Despliegue completado exitosamente!'
\echo '=========================================='

-- Verificar stored procedures creados
\echo ''
\echo 'Stored Procedures creados en esquema comun:'
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'comun'
  AND routine_name LIKE 'sp_%usuario%' OR routine_name LIKE 'sp_catalogo%'
ORDER BY routine_name;
