-- =====================================================
-- SCRIPT MAESTRO COMPLETO - INSTALACIÓN CEMENTERIOS
-- =====================================================
-- Instala TODOS los 36 archivos de Stored Procedures
--
-- USO:
--   cd C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\Base\cementerios\database
--   psql -U postgres -d nombre_bd -f INSTALL_ALL_SPS_COMPLETO.sql
--
-- =====================================================

\echo ''
\echo '=========================================='
\echo 'INSTALACIÓN COMPLETA - MÓDULO CEMENTERIOS'
\echo 'Total: 36 archivos SQL'
\echo '=========================================='
\echo ''

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

\echo '[1/36] SP_CEMENTERIOS_CORE...'
\i ok/01_SP_CEMENTERIOS_CORE_all_procedures.sql

\echo '[2/36] SP_CEMENTERIOS_GESTION...'
\i ok/02_SP_CEMENTERIOS_GESTION_all_procedures.sql

\echo '[3/36] SP_CEMENTERIOS_ABC...'
\i ok/03_SP_CEMENTERIOS_ABC_all_procedures.sql

\echo '[4/36] SP_CEMENTERIOS_ACCESO_EXACTO...'
\i ok/03_SP_CEMENTERIOS_ACCESO_EXACTO_all_procedures.sql

\echo '[5/36] SP_CEMENTERIOS_BONIFICACIONES_EXACTO...'
\i ok/04_SP_CEMENTERIOS_BONIFICACIONES_EXACTO_all_procedures.sql

\echo '[6/36] SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO...'
\i ok/05_SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO_all_procedures.sql

\echo '[7/36] SP_CEMENTERIOS_CONSULTAGUAD_EXACTO...'
\i ok/06_SP_CEMENTERIOS_CONSULTAGUAD_EXACTO_all_procedures.sql

\echo '[8/36] SP_CEMENTERIOS_CONSULTAJARDIN_EXACTO...'
\i ok/07_SP_CEMENTERIOS_CONSULTAJARDIN_EXACTO_all_procedures.sql

\echo '[9/36] SP_CEMENTERIOS_CONSULTASANDRES_EXACTO...'
\i ok/08_SP_CEMENTERIOS_CONSULTASANDRES_EXACTO_all_procedures.sql

\echo '[10/36] SP_CEMENTERIOS_DESCUENTOS_EXACTO...'
\i ok/09_SP_CEMENTERIOS_DESCUENTOS_EXACTO_all_procedures.sql

\echo '[11/36] SP_CEMENTERIOS_ESTAD_ADEUDO_EXACTO...'
\i ok/10_SP_CEMENTERIOS_ESTAD_ADEUDO_EXACTO_all_procedures.sql

\echo '[12/36] SP_CEMENTERIOS_LIQUIDACIONES_EXACTO...'
\i ok/11_SP_CEMENTERIOS_LIQUIDACIONES_EXACTO_all_procedures.sql

\echo '[13/36] SP_CEMENTERIOS_LIST_MOV_EXACTO...'
\i ok/12_SP_CEMENTERIOS_LIST_MOV_EXACTO_all_procedures.sql

\echo '[14/36] SP_CEMENTERIOS_ABCFOLIO_EXACTO (13)...'
\i ok/13_SP_CEMENTERIOS_ABCFOLIO_EXACTO_all_procedures.sql

\echo '[15/36] SP_CEMENTERIOS_ABCRECARGOS_EXACTO (14)...'
\i ok/14_SP_CEMENTERIOS_ABCRECARGOS_EXACTO_all_procedures.sql

\echo '[16/36] SP_CEMENTERIOS_ACCESO_EXACTO (15)...'
\i ok/15_SP_CEMENTERIOS_ACCESO_EXACTO_all_procedures.sql

\echo '[17/36] SP_CEMENTERIOS_BONIFICACIONES_EXACTO (16)...'
\i ok/16_SP_CEMENTERIOS_BONIFICACIONES_EXACTO_all_procedures.sql

\echo '[18/36] SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO (17)...'
\i ok/17_SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO_all_procedures.sql

\echo '[19/36] SP_CEMENTERIOS_CONSULTAGUAD_EXACTO (18)...'
\i ok/18_SP_CEMENTERIOS_CONSULTAGUAD_EXACTO_all_procedures.sql

\echo '[20/36] SP_CEMENTERIOS_CONSULTAJARDIN_EXACTO (19)...'
\i ok/19_SP_CEMENTERIOS_CONSULTAJARDIN_EXACTO_all_procedures.sql

\echo '[21/36] SP_CEMENTERIOS_CONSULTASANDRES_EXACTO (20)...'
\i ok/20_SP_CEMENTERIOS_CONSULTASANDRES_EXACTO_all_procedures.sql

\echo '[22/36] SP_CEMENTERIOS_DESCUENTOS_EXACTO (21)...'
\i ok/21_SP_CEMENTERIOS_DESCUENTOS_EXACTO_all_procedures.sql

\echo '[23/36] SP_CEMENTERIOS_ESTAD_ADEUDO_EXACTO (22)...'
\i ok/22_SP_CEMENTERIOS_ESTAD_ADEUDO_EXACTO_all_procedures.sql

\echo '[24/36] SP_CEMENTERIOS_LIQUIDACIONES_EXACTO (23)...'
\i ok/23_SP_CEMENTERIOS_LIQUIDACIONES_EXACTO_all_procedures.sql

\echo '[25/36] SP_CEMENTERIOS_LIST_MOV_EXACTO (24)...'
\i ok/24_SP_CEMENTERIOS_LIST_MOV_EXACTO_all_procedures.sql

\echo '[26/36] SP_CEMENTERIOS_MODULO_EXACTO...'
\i ok/25_SP_CEMENTERIOS_MODULO_EXACTO_all_procedures.sql

\echo '[27/36] SP_CEMENTERIOS_MULTIPLENOMBRE_EXACTO...'
\i ok/26_SP_CEMENTERIOS_MULTIPLENOMBRE_EXACTO_all_procedures.sql

\echo '[28/36] SP_CEMENTERIOS_MULTIPLERCM_EXACTO...'
\i ok/27_SP_CEMENTERIOS_MULTIPLERCM_EXACTO_all_procedures.sql

\echo '[29/36] SP_CEMENTERIOS_MULTIPLEFECHA_EXACTO...'
\i ok/28_SP_CEMENTERIOS_MULTIPLEFECHA_EXACTO_all_procedures.sql

\echo '[30/36] SP_CEMENTERIOS_REP_BON_EXACTO...'
\i ok/29_SP_CEMENTERIOS_REP_BON_EXACTO_all_procedures.sql

\echo '[31/36] SP_CEMENTERIOS_REP_A_COBRAR_EXACTO...'
\i ok/30_SP_CEMENTERIOS_REP_A_COBRAR_EXACTO_all_procedures.sql

\echo '[32/36] SP_CEMENTERIOS_RPTTITULOS_EXACTO...'
\i ok/31_SP_CEMENTERIOS_RPTTITULOS_EXACTO_all_procedures.sql

\echo '[33/36] SP_CEMENTERIOS_TITULOSSIN_EXACTO...'
\i ok/32_SP_CEMENTERIOS_TITULOSSIN_EXACTO_all_procedures.sql

\echo '[34/36] SP_CEMENTERIOS_TITULOS_EXACTO...'
\i ok/33_SP_CEMENTERIOS_TITULOS_EXACTO_all_procedures.sql

\echo '[35/36] SP_CEMENTERIOS_TRASLADOFOLSIN_EXACTO...'
\i ok/34_SP_CEMENTERIOS_TRASLADOFOLSIN_EXACTO_all_procedures.sql

\echo '[36/36] SP_CEMENTERIOS_TRASLADOS_EXACTO...'
\i ok/35_SP_CEMENTERIOS_TRASLADOS_EXACTO_all_procedures.sql

\echo ''
\echo '=========================================='
\echo 'VERIFICACIÓN FINAL'
\echo '=========================================='

SELECT
    COUNT(*) as total_sps_instalados,
    (SELECT COUNT(*) FROM information_schema.routines
     WHERE routine_schema = 'public'
       AND routine_name LIKE 'sp_cem%') as sps_cementerios
FROM information_schema.routines
WHERE routine_type = 'FUNCTION'
    AND routine_schema = 'public';

\echo ''
\echo '=========================================='
\echo 'INSTALACIÓN COMPLETADA EXITOSAMENTE'
\echo '=========================================='
\echo 'Módulo: CEMENTERIOS'
\echo 'Archivos instalados: 36'
\echo 'Esquema: public'
\echo ''
\echo 'Siguiente paso: Iniciar corrección de componentes Vue'
\echo '=========================================='
