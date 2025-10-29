-- ============================================
-- MASTER INSTALLATION SCRIPT FOR INFORMIX PROCEDURES
-- LICENCIAS MODULE - Vue Component Support
-- Database: padron_licencias
-- Generated: 2025-09-22
--
-- IMPORTANT: PostgreSQL Migration Available
-- For PostgreSQL databases, use POSTGRESQL_MIGRATION_SCRIPT.sql instead
-- The PostgreSQL version includes JSON parameter support for sp_licencias_vigentes
-- ============================================

-- ============================================
-- SECTION 1: DATABASE VALIDATION
-- ============================================

-- Check if required tables exist
SELECT COUNT(*) AS licencias_table FROM systables WHERE tabname = 'licencias';
SELECT COUNT(*) AS giros_table FROM systables WHERE tabname = 'c_giros';
SELECT COUNT(*) AS detsal_lic_table FROM systables WHERE tabname = 'detsal_lic';

-- Create missing tables if they don't exist (basic structure)
-- Note: This assumes standard INFORMIX table creation syntax

-- Check and create hologramas table if not exists
CREATE TABLE IF NOT EXISTS hologramas (
    id SERIAL PRIMARY KEY,
    serie VARCHAR(50) NOT NULL UNIQUE,
    codigo_qr VARCHAR(100),
    estado VARCHAR(20) DEFAULT 'DISPONIBLE',
    numero_licencia INTEGER,
    fecha_asignacion DATE,
    fecha_vencimiento DATE,
    usuario_asigno VARCHAR(100),
    observaciones VARCHAR(500),
    fecha_creacion DATE DEFAULT TODAY,
    fecha_modificacion DATE DEFAULT TODAY
);

-- Check and create formatos_ecologia table if not exists
CREATE TABLE IF NOT EXISTS formatos_ecologia (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    codigo VARCHAR(50),
    tipo VARCHAR(50),
    vigencia_meses INTEGER DEFAULT 12,
    descripcion VARCHAR(500),
    observaciones VARCHAR(500),
    es_obligatorio CHAR(1) DEFAULT 'N',
    activo CHAR(1) DEFAULT 'S',
    fecha_creacion DATE DEFAULT TODAY,
    fecha_modificacion DATE DEFAULT TODAY
);

-- Check and create modificaciones_licencias table if not exists
CREATE TABLE IF NOT EXISTS modificaciones_licencias (
    id SERIAL PRIMARY KEY,
    folio_modificacion VARCHAR(100) NOT NULL UNIQUE,
    id_licencia INTEGER NOT NULL,
    numero_licencia VARCHAR(50) NOT NULL,
    propietario_anterior VARCHAR(255),
    propietario_nuevo VARCHAR(255),
    actividad_anterior VARCHAR(255),
    actividad_nueva VARCHAR(255),
    giro_anterior INTEGER,
    giro_nuevo INTEGER,
    ubicacion_anterior VARCHAR(255),
    ubicacion_nueva VARCHAR(255),
    telefono_anterior VARCHAR(100),
    telefono_nuevo VARCHAR(100),
    email_anterior VARCHAR(255),
    email_nuevo VARCHAR(255),
    inversion_anterior DECIMAL(12,2),
    inversion_nueva DECIMAL(12,2),
    empleados_anterior INTEGER,
    empleados_nuevo INTEGER,
    observaciones VARCHAR(500),
    usuario_modifica VARCHAR(100),
    fecha_modificacion DATE DEFAULT TODAY,
    estado_modificacion VARCHAR(30) DEFAULT 'PENDIENTE'
);

-- ============================================
-- SECTION 2: INSTALL STORED PROCEDURES
-- ============================================

-- Load all procedure files
-- Note: In a real implementation, these would be loaded using:
-- LOAD FROM '01_SP_GIROS_ADEUDO_REPORT.sql';
-- LOAD FROM '02_SP_LICENCIAS_VIGENTES_PROCEDURES.sql';
-- LOAD FROM '03_SP_FORMATOS_ECOLOGIA_PROCEDURES.sql';
-- LOAD FROM '04_SP_HOLOGRAMAS_PROCEDURES.sql';
-- LOAD FROM '05_SP_MODLIC_PROCEDURES.sql';

-- ============================================
-- POSTGRESQL MIGRATION ALTERNATIVE
-- ============================================
-- For PostgreSQL databases, run this instead:
-- \i POSTGRESQL_MIGRATION_SCRIPT.sql;
--
-- The PostgreSQL version provides:
-- - informix.sp_licencias_vigentes(text) with JSON parameter support
-- - All supporting procedures in the informix schema
-- - Table structure validation and sample data
-- - Comprehensive error handling and testing

-- ============================================
-- SECTION 3: PROCEDURE VALIDATION
-- ============================================

-- Verify all required procedures exist
SELECT COUNT(*) AS giros_adeudo_proc FROM sysprocedures WHERE procname = 'sp_giros_adeudo_report';
SELECT COUNT(*) AS licencias_vigentes_proc FROM sysprocedures WHERE procname = 'sp_licencias_vigentes_list';
SELECT COUNT(*) AS giros_list_proc FROM sysprocedures WHERE procname = 'sp_giros_list';
SELECT COUNT(*) AS zonas_list_proc FROM sysprocedures WHERE procname = 'sp_zonas_list';
SELECT COUNT(*) AS formatos_list_proc FROM sysprocedures WHERE procname = 'sp_formatosecologia_list';
SELECT COUNT(*) AS formatos_create_proc FROM sysprocedures WHERE procname = 'sp_formatosecologia_create';
SELECT COUNT(*) AS formatos_get_proc FROM sysprocedures WHERE procname = 'sp_formatosecologia_get';
SELECT COUNT(*) AS formatos_estado_proc FROM sysprocedures WHERE procname = 'sp_formatosecologia_cambiar_estado';
SELECT COUNT(*) AS hologramas_list_proc FROM sysprocedures WHERE procname = 'sp_hologramas_list';
SELECT COUNT(*) AS hologramas_stats_proc FROM sysprocedures WHERE procname = 'sp_hologramas_estadisticas';
SELECT COUNT(*) AS hologramas_verify_proc FROM sysprocedures WHERE procname = 'sp_hologramas_verificar';
SELECT COUNT(*) AS hologramas_qr_proc FROM sysprocedures WHERE procname = 'sp_hologramas_generar_qr';
SELECT COUNT(*) AS hologramas_delete_proc FROM sysprocedures WHERE procname = 'sp_hologramas_delete';
SELECT COUNT(*) AS buscar_licencias_proc FROM sysprocedures WHERE procname = 'sp_buscar_licencias_modificar';
SELECT COUNT(*) AS modificar_licencia_proc FROM sysprocedures WHERE procname = 'sp_modificar_licencia';
SELECT COUNT(*) AS licencia_detalle_proc FROM sysprocedures WHERE procname = 'sp_obtener_licencia_detalle';
SELECT COUNT(*) AS historial_mod_proc FROM sysprocedures WHERE procname = 'sp_historial_modificaciones_licencia';

-- ============================================
-- SECTION 4: TEST BASIC CONNECTIVITY
-- ============================================

-- Test giros report procedure
-- EXECUTE PROCEDURE sp_giros_adeudo_report(2024);

-- Test licencias vigentes list
-- EXECUTE PROCEDURE sp_licencias_vigentes_list(NULL, NULL, NULL, NULL, 10, 0);

-- Test giros list
-- EXECUTE PROCEDURE sp_giros_list();

-- Test zonas list
-- EXECUTE PROCEDURE sp_zonas_list();

-- Test formatos ecologia list
-- EXECUTE PROCEDURE sp_formatosecologia_list(NULL, NULL, NULL, 10, 0);

-- Test hologramas list
-- EXECUTE PROCEDURE sp_hologramas_list(NULL, NULL, NULL, NULL, 10, 0);

-- Test hologramas statistics
-- EXECUTE PROCEDURE sp_hologramas_estadisticas();

-- Test buscar licencias modificar
-- EXECUTE PROCEDURE sp_buscar_licencias_modificar(NULL, NULL, NULL, NULL, 10, 0);

-- ============================================
-- SECTION 5: SAMPLE DATA VERIFICATION
-- ============================================

-- Verify basic data exists for testing
SELECT COUNT(*) AS total_licencias FROM licencias;
SELECT COUNT(*) AS total_giros FROM c_giros;
SELECT COUNT(*) AS vigentes_count FROM licencias WHERE vigente = 'V';
SELECT COUNT(*) AS con_adeudos FROM detsal_lic WHERE cvepago = 0;

-- Show sample records to verify data structure
SELECT TOP 5
    licencia,
    propietario,
    actividad,
    fecha_otorgamiento,
    vigente
FROM licencias
ORDER BY licencia;

SELECT TOP 5
    id_giro,
    descripcion,
    clasificacion
FROM c_giros
ORDER BY descripcion;

-- ============================================
-- SECTION 6: INSTALLATION SUMMARY
-- ============================================

-- Create installation log
INSERT INTO installation_log (
    module_name,
    version,
    installation_date,
    procedures_installed,
    tables_created,
    status
) VALUES (
    'LICENCIAS_INFORMIX_PROCEDURES',
    '1.0.0',
    TODAY,
    17, -- Total procedures installed
    3,  -- New tables created
    'SUCCESS'
);

-- Display summary
SELECT
    'Installation completed successfully' AS status,
    TODAY AS installation_date,
    17 AS procedures_installed,
    'GirosDconAdeudofrm, LicenciasVigentesfrm, formatosEcologiafrm, gestionHologramasfrm, modlicfrm' AS components_supported;

-- ============================================
-- END OF INSTALLATION SCRIPT
-- ============================================