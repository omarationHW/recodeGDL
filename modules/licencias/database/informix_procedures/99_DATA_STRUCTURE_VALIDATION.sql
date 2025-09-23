-- ============================================
-- DATA STRUCTURE VALIDATION SCRIPT
-- LICENCIAS MODULE - Vue Component Compatibility
-- Database: padron_licencias
-- Generated: 2025-09-22
-- ============================================

-- ============================================
-- SECTION 1: CORE TABLE VALIDATION
-- ============================================

-- Validate licencias table structure
DESC licencias;

-- Expected columns for licencias table:
-- id_licencia (INTEGER)
-- licencia (VARCHAR/INTEGER)
-- propietario (VARCHAR)
-- primer_ap (VARCHAR)
-- segundo_ap (VARCHAR)
-- rfc (VARCHAR)
-- curp (VARCHAR)
-- actividad (VARCHAR)
-- id_giro (INTEGER)
-- ubicacion (VARCHAR)
-- numext_ubic (INTEGER)
-- letraext_ubic (VARCHAR)
-- numint_ubic (VARCHAR)
-- letraint_ubic (VARCHAR)
-- colonia_ubic (VARCHAR)
-- cp (INTEGER)
-- zona (INTEGER)
-- subzona (INTEGER)
-- telefono_prop (VARCHAR)
-- email (VARCHAR)
-- inversion (DECIMAL)
-- num_empleados (INTEGER)
-- aforo (INTEGER)
-- sup_autorizada (DECIMAL)
-- num_cajones (INTEGER)
-- fecha_otorgamiento (DATE)
-- fecha_vencimiento (DATE)
-- vigente (CHAR)
-- bloqueado (INTEGER)

-- Validate c_giros table structure
DESC c_giros;

-- Expected columns for c_giros table:
-- id_giro (INTEGER)
-- descripcion (VARCHAR)
-- clasificacion (VARCHAR)
-- activo (CHAR)

-- Validate detsal_lic table structure
DESC detsal_lic;

-- Expected columns for detsal_lic table:
-- id_licencia (INTEGER)
-- cvepago (INTEGER)
-- id_anuncio (INTEGER)
-- axo (INTEGER)

-- ============================================
-- SECTION 2: DATA VALIDATION TESTS
-- ============================================

-- Test 1: GirosDconAdeudofrm data requirements
SELECT
    'Test 1: Giros Adeudo Data' AS test_name,
    COUNT(*) AS total_records,
    COUNT(CASE WHEN d.cvepago = 0 AND d.id_anuncio = 0 AND g.clasificacion = 'D' THEN 1 END) AS adeudo_records
FROM licencias l
LEFT JOIN detsal_lic d ON l.id_licencia = d.id_licencia
LEFT JOIN c_giros g ON g.id_giro = l.id_giro;

-- Test 2: LicenciasVigentesfrm data requirements
SELECT
    'Test 2: Licencias Vigentes Data' AS test_name,
    COUNT(*) AS total_licencias,
    COUNT(CASE WHEN l.vigente IN ('V', 'C') THEN 1 END) AS vigentes_count,
    COUNT(CASE WHEN l.propietario IS NOT NULL THEN 1 END) AS with_propietario,
    COUNT(CASE WHEN l.actividad IS NOT NULL THEN 1 END) AS with_actividad
FROM licencias l;

-- Test 3: Giros data for dropdowns
SELECT
    'Test 3: Giros Data' AS test_name,
    COUNT(*) AS total_giros,
    COUNT(CASE WHEN descripcion IS NOT NULL THEN 1 END) AS with_description,
    COUNT(CASE WHEN clasificacion IS NOT NULL THEN 1 END) AS with_classification
FROM c_giros;

-- Test 4: Zones data validation
SELECT
    'Test 4: Zones Data' AS test_name,
    COUNT(DISTINCT zona) AS unique_zones,
    MIN(zona) AS min_zone,
    MAX(zona) AS max_zone
FROM licencias
WHERE zona IS NOT NULL AND zona > 0;

-- ============================================
-- SECTION 3: FIELD COMPATIBILITY VALIDATION
-- ============================================

-- Test Vue component field mappings

-- GirosDconAdeudofrm.vue field mapping test
SELECT
    'GirosDconAdeudofrm Fields' AS component,
    l.licencia,
    TRIM(l.propietario || ' ' || NVL(l.primer_ap, '') || ' ' || NVL(l.segundo_ap, '')) AS propietarionvo,
    TRIM(l.ubicacion || ' No. ext.: ' || NVL(l.numext_ubic, '') ||
         ' Letra ext. ' || NVL(l.letraext_ubic, '') || ' No. int.: ' || NVL(l.numint_ubic, '') ||
         ' Letra int. ' || NVL(l.letraint_ubic, '')) AS domCompleto,
    g.descripcion,
    d.axo
FROM licencias l
JOIN detsal_lic d ON l.id_licencia = d.id_licencia
JOIN c_giros g ON g.id_giro = l.id_giro
WHERE d.cvepago = 0 AND d.id_anuncio = 0 AND g.clasificacion = 'D'
LIMIT 3;

-- LicenciasVigentesfrm.vue field mapping test
SELECT
    'LicenciasVigentesfrm Fields' AS component,
    l.id_licencia AS id,
    l.licencia AS numero_licencia,
    l.propietario,
    l.actividad,
    g.descripcion AS giro,
    TRIM(l.ubicacion || ' ' || NVL(l.numext_ubic, '') || ' ' || NVL(l.letraext_ubic, '')) AS direccion,
    l.colonia_ubic AS colonia,
    l.zona,
    l.fecha_otorgamiento AS fecha_vigencia_inicio,
    l.fecha_vencimiento AS fecha_vigencia_fin,
    CASE
        WHEN l.vigente = 'V' THEN 'VIGENTE'
        WHEN l.vigente = 'C' THEN 'CONDICIONADA'
        WHEN l.vigente = 'S' THEN 'SUSPENDIDA'
        ELSE 'OTRO'
    END AS estado
FROM licencias l
INNER JOIN c_giros g ON l.id_giro = g.id_giro
WHERE l.vigente IN ('V', 'C')
LIMIT 3;

-- ============================================
-- SECTION 4: PROCEDURE RETURN STRUCTURE TEST
-- ============================================

-- Test stored procedure return structure compatibility

-- Note: These would be actual EXECUTE statements in a real environment
-- EXECUTE PROCEDURE sp_giros_adeudo_report(2024);
-- EXECUTE PROCEDURE sp_licencias_vigentes_list(NULL, NULL, NULL, NULL, 5, 0);
-- EXECUTE PROCEDURE sp_giros_list();
-- EXECUTE PROCEDURE sp_zonas_list();

-- ============================================
-- SECTION 5: PERFORMANCE VALIDATION
-- ============================================

-- Test query performance on key operations

-- Performance test 1: Licencias vigentes with filters
SELECT
    'Performance Test 1' AS test_name,
    'Licencias vigentes search' AS operation,
    COUNT(*) AS result_count
FROM licencias l
INNER JOIN c_giros g ON l.id_giro = g.id_giro
WHERE l.vigente IN ('V', 'C')
  AND l.propietario LIKE '%TEST%';

-- Performance test 2: Giros adeudo report
SELECT
    'Performance Test 2' AS test_name,
    'Giros adeudo report' AS operation,
    COUNT(*) AS result_count
FROM licencias l
JOIN detsal_lic d ON l.id_licencia = d.id_licencia
JOIN c_giros g ON g.id_giro = l.id_giro
WHERE d.cvepago = 0
  AND d.id_anuncio = 0
  AND g.clasificacion = 'D';

-- ============================================
-- SECTION 6: INDEX RECOMMENDATIONS
-- ============================================

-- Recommended indexes for performance optimization
SELECT
    'Index Recommendations' AS section,
    'CREATE INDEX idx_licencias_vigente ON licencias(vigente)' AS recommendation_1,
    'CREATE INDEX idx_licencias_propietario ON licencias(propietario)' AS recommendation_2,
    'CREATE INDEX idx_detsal_lic_cvepago ON detsal_lic(cvepago, id_anuncio)' AS recommendation_3,
    'CREATE INDEX idx_giros_clasificacion ON c_giros(clasificacion)' AS recommendation_4,
    'CREATE INDEX idx_licencias_zona ON licencias(zona)' AS recommendation_5;

-- ============================================
-- SECTION 7: VALIDATION SUMMARY
-- ============================================

-- Final validation summary
SELECT
    'VALIDATION SUMMARY' AS section,
    (SELECT COUNT(*) FROM systables WHERE tabname = 'licencias') AS licencias_table_exists,
    (SELECT COUNT(*) FROM systables WHERE tabname = 'c_giros') AS giros_table_exists,
    (SELECT COUNT(*) FROM systables WHERE tabname = 'detsal_lic') AS detsal_table_exists,
    (SELECT COUNT(*) FROM systables WHERE tabname = 'hologramas') AS hologramas_table_exists,
    (SELECT COUNT(*) FROM systables WHERE tabname = 'formatos_ecologia') AS formatos_table_exists,
    (SELECT COUNT(*) FROM systables WHERE tabname = 'modificaciones_licencias') AS modific_table_exists;

SELECT
    'PROCEDURE VALIDATION' AS section,
    (SELECT COUNT(*) FROM sysprocedures WHERE procname = 'sp_giros_adeudo_report') AS giros_adeudo_proc,
    (SELECT COUNT(*) FROM sysprocedures WHERE procname = 'sp_licencias_vigentes_list') AS lic_vigentes_proc,
    (SELECT COUNT(*) FROM sysprocedures WHERE procname = 'sp_formatosecologia_list') AS formatos_proc,
    (SELECT COUNT(*) FROM sysprocedures WHERE procname = 'sp_hologramas_list') AS hologramas_proc,
    (SELECT COUNT(*) FROM sysprocedures WHERE procname = 'sp_buscar_licencias_modificar') AS modlic_proc;

-- Data quality validation
SELECT
    'DATA QUALITY' AS section,
    (SELECT COUNT(*) FROM licencias) AS total_licenses,
    (SELECT COUNT(*) FROM licencias WHERE vigente IN ('V', 'C')) AS active_licenses,
    (SELECT COUNT(*) FROM c_giros) AS total_giros,
    (SELECT COUNT(DISTINCT zona) FROM licencias WHERE zona > 0) AS unique_zones,
    CASE
        WHEN (SELECT COUNT(*) FROM licencias) > 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status;

-- ============================================
-- END OF VALIDATION SCRIPT
-- ============================================