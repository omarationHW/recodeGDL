-- ================================================================
-- MANUAL DEPLOYMENT: recaudadora_drecgolic
-- ================================================================
-- INSTRUCCIONES:
-- 1. Abre este archivo en tu cliente de PostgreSQL favorito
--    (pgAdmin, DBeaver, DataGrip, etc.)
-- 2. Conéctate a la base de datos: padron_licencias
-- 3. Ejecuta todo el contenido de este archivo
-- ================================================================

-- Paso 1: Eliminar función existente
DROP FUNCTION IF EXISTS multas_reglamentos.recaudadora_drecgolic(VARCHAR) CASCADE;

-- Paso 2: Crear nueva función
CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_drecgolic(
    p_licencia VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id_licencia TEXT,
    licencia TEXT,
    empresa TEXT,
    recaud TEXT,
    id_giro TEXT,
    zona TEXT,
    subzona TEXT,
    tipo_registro TEXT,
    actividad TEXT,
    cvecuenta TEXT,
    fecha_otorgamiento TEXT,
    propietario TEXT,
    primer_ap TEXT,
    segundo_ap TEXT,
    rfc TEXT,
    curp TEXT,
    domicilio TEXT,
    numext_prop TEXT,
    coordenadas TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Retornar información de licencias
    RETURN QUERY
    SELECT
        CAST(h.id_licencia AS TEXT) AS id_licencia,
        CAST(h.licencia AS TEXT) AS licencia,
        CAST(h.empresa AS TEXT) AS empresa,
        CAST(h.recaud AS TEXT) AS recaud,
        CAST(h.id_giro AS TEXT) AS id_giro,
        CAST(h.zona AS TEXT) AS zona,
        CAST(h.subzona AS TEXT) AS subzona,
        CAST(TRIM(h.tipo_registro) AS TEXT) AS tipo_registro,
        CAST(TRIM(h.actividad) AS TEXT) AS actividad,
        CAST(h.cvecuenta AS TEXT) AS cvecuenta,
        CAST(h.fecha_otorgamiento AS TEXT) AS fecha_otorgamiento,
        CAST(TRIM(h.propietario) AS TEXT) AS propietario,
        CAST(TRIM(h.primer_ap) AS TEXT) AS primer_ap,
        CAST(TRIM(h.segundo_ap) AS TEXT) AS segundo_ap,
        CAST(TRIM(h.rfc) AS TEXT) AS rfc,
        CAST(TRIM(h.curp) AS TEXT) AS curp,
        CAST(TRIM(h.domicilio) AS TEXT) AS domicilio,
        CAST(h.numext_prop AS TEXT) AS numext_prop,
        CAST('(' || h.x || ', ' || h.y || ')' AS TEXT) AS coordenadas
    FROM catastro_gdl.h_licencias h
    WHERE
        (p_licencia IS NULL OR p_licencia = '' OR CAST(h.licencia AS VARCHAR) = p_licencia)
    ORDER BY h.licencia, h.id_licencia;
END;
$$;

-- Paso 3: Agregar comentario
COMMENT ON FUNCTION multas_reglamentos.recaudadora_drecgolic(VARCHAR) IS 'Consulta derechos de licencias comerciales desde catastro_gdl.h_licencias.';

-- ================================================================
-- PRUEBAS (Opcional - puedes ejecutar estas líneas para verificar)
-- ================================================================

-- Test 1: Listar primeras 5 licencias
SELECT * FROM multas_reglamentos.recaudadora_drecgolic(NULL) LIMIT 5;

-- Test 2: Buscar licencia específica '1'
SELECT * FROM multas_reglamentos.recaudadora_drecgolic('1');

-- Test 3: Buscar licencia específica '5'
SELECT * FROM multas_reglamentos.recaudadora_drecgolic('5');

-- Test 4: Buscar licencia específica '8'
SELECT * FROM multas_reglamentos.recaudadora_drecgolic('8');

-- ================================================================
-- DEPLOYMENT COMPLETO
-- ================================================================
