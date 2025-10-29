-- ============================================
-- SCRIPT MAESTRO DE MIGRACIÓN DE STORED PROCEDURES
-- Módulo: LICENCIAS - Próximos 5 archivos Vue
-- Base de datos: padron_licencias
-- Host: 192.168.6.146
-- Esquema: informix
-- Generado: 2025-09-22
-- ============================================

\c padron_licencias;

-- Crear esquema informix si no existe
CREATE SCHEMA IF NOT EXISTS informix;
SET search_path TO informix;

-- ============================================
-- EJECUCIÓN DE MIGRACIONES POR ARCHIVO
-- ============================================

-- 1. AGENDAVISITASFRM (3 SPs)
\i 'C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\harweb-main\database\migrations\SP_AGENDAVISITASFRM_MIGRATION.sql'

-- 2. BUSQUEDAACTIVIDADFRM (1 SP)
\i 'C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\harweb-main\database\migrations\SP_BUSQUEDAACTIVIDADFRM_MIGRATION.sql'

-- 3. BLOQUEARANUNCIORM (2 SPs)
\i 'C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\harweb-main\database\migrations\SP_BLOQUEARANUNCIORM_MIGRATION.sql'

-- 4. BLOQUEARLICENCIAFRM (1 SP)
\i 'C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\harweb-main\database\migrations\SP_BLOQUEARLICENCIAFRM_MIGRATION.sql'

-- 5. BLOQUEARTRAMITEFRM (3 SPs)
\i 'C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\harweb-main\database\migrations\SP_BLOQUEARTRAMITEFRM_MIGRATION.sql'

-- ============================================
-- RESUMEN DE STORED PROCEDURES MIGRADOS
-- ============================================

-- AGENDAVISITASFRM (3 SPs):
--   - informix.sp_get_dependencias()
--   - informix.sp_get_agenda_visitas(id_dependencia, fechaini, fechafin)
--   - informix.fn_dialetra(dia)

-- BUSQUEDAACTIVIDADFRM (1 SP):
--   - informix.buscar_actividades(scian, descripcion)

-- BLOQUEARANUNCIORM (2 SPs):
--   - informix.buscar_anuncio(numero_anuncio)
--   - informix.bloquear_anuncio(id_anuncio, observa, usuario)

-- BLOQUEARLICENCIAFRM (1 SP):
--   - informix.sp_bloquear_licencia(id_licencia, tipo_bloqueo, motivo, usuario)

-- BLOQUEARTRAMITEFRM (3 SPs):
--   - informix.get_tramite(id_tramite)
--   - informix.get_giro_descripcion(id_giro)
--   - informix.desbloquear_tramite(id_tramite, observa, capturista)

-- ============================================
-- TOTAL: 10 STORED PROCEDURES MIGRADOS
-- ============================================

SELECT 'Migración de Stored Procedures completada exitosamente' AS status;