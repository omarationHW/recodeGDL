-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: comun
-- ============================================
\c padron_licencias;
SET search_path TO comun, public;

-- ============================================
-- STORED PROCEDURES PARA CRUCES DE CALLES
-- Convención: SP_CRUCES_XXX
-- Implementado: 2025-11-21
-- Tablas: c_calles, c_calles_escondidas
-- Módulo: BATCH 11 - CRUCES (Street Intersections)
-- Total SPs: 3
-- ============================================

-- ============================================
-- ÍNDICES RECOMENDADOS
-- ============================================
-- Ejecutar estos índices para optimizar el rendimiento:
-- CREATE INDEX IF NOT EXISTS idx_c_calles_calle_upper ON c_calles (UPPER(calle));
-- CREATE INDEX IF NOT EXISTS idx_c_calles_cvecalle ON c_calles (cvecalle);
-- CREATE INDEX IF NOT EXISTS idx_c_calles_escondidas_cvecalle ON c_calles_escondidas (cvecalle) WHERE vigente = 'V' AND num_tag = 8000;
-- CREATE INDEX IF NOT EXISTS idx_c_calles_escondidas_vigente_tag ON c_calles_escondidas (vigente, num_tag);

-- ============================================
-- SP 1/3: sp_cruces_search_calle1
-- Tipo: Catalog
-- Descripción: Busca calles para el primer campo de cruce
-- Lógica de negocio:
--   - Búsqueda case-insensitive por nombre de calle
--   - Excluye calles escondidas (vigente='V' AND num_tag=8000)
--   - Devuelve datos completos de la calle (8 campos)
--   - Usa UPPER() para normalización de búsqueda
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_cruces_search_calle1(p_search_text TEXT)
RETURNS TABLE(
    cvecalle INTEGER,
    cvepoblacion INTEGER,
    desvial INTEGER,
    calle VARCHAR(40),
    cvevig CHAR(1),
    anterior INTEGER,
    feccap DATE,
    capturista VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validación de parámetros
    IF p_search_text IS NULL OR TRIM(p_search_text) = '' THEN
        RAISE EXCEPTION 'El parámetro p_search_text no puede ser nulo o vacío';
    END IF;

    -- Búsqueda de calles excluyendo las escondidas
    RETURN QUERY
    SELECT
        c.cvecalle,
        c.cvepoblacion,
        c.desvial,
        c.calle,
        c.cvevig,
        c.anterior,
        c.feccap,
        c.capturista
    FROM c_calles c
    WHERE UPPER(c.calle) LIKE '%' || UPPER(p_search_text) || '%'
      AND c.cvecalle NOT IN (
          SELECT ce.cvecalle
          FROM c_calles_escondidas ce
          WHERE ce.vigente = 'V'
            AND ce.num_tag = 8000
      )
    ORDER BY c.calle
    LIMIT 500;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en sp_cruces_search_calle1: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION comun.sp_cruces_search_calle1(TEXT) IS 'Busca calles para el primer campo de cruce, excluyendo calles escondidas';

-- ============================================
-- SP 2/3: sp_cruces_search_calle2
-- Tipo: Catalog
-- Descripción: Busca calles para el segundo campo de cruce
-- Lógica de negocio:
--   - Búsqueda case-insensitive por nombre de calle
--   - Excluye calles escondidas (vigente='V' AND num_tag=8000)
--   - Devuelve datos completos de la calle (8 campos)
--   - Usa UPPER() para normalización de búsqueda
--   - Idéntica lógica a search_calle1 (separadas para UI)
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_cruces_search_calle2(p_search_text TEXT)
RETURNS TABLE(
    cvecalle INTEGER,
    cvepoblacion INTEGER,
    desvial INTEGER,
    calle VARCHAR(40),
    cvevig CHAR(1),
    anterior INTEGER,
    feccap DATE,
    capturista VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validación de parámetros
    IF p_search_text IS NULL OR TRIM(p_search_text) = '' THEN
        RAISE EXCEPTION 'El parámetro p_search_text no puede ser nulo o vacío';
    END IF;

    -- Búsqueda de calles excluyendo las escondidas
    RETURN QUERY
    SELECT
        c.cvecalle,
        c.cvepoblacion,
        c.desvial,
        c.calle,
        c.cvevig,
        c.anterior,
        c.feccap,
        c.capturista
    FROM c_calles c
    WHERE UPPER(c.calle) LIKE '%' || UPPER(p_search_text) || '%'
      AND c.cvecalle NOT IN (
          SELECT ce.cvecalle
          FROM c_calles_escondidas ce
          WHERE ce.vigente = 'V'
            AND ce.num_tag = 8000
      )
    ORDER BY c.calle
    LIMIT 500;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en sp_cruces_search_calle2: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION comun.sp_cruces_search_calle2(TEXT) IS 'Busca calles para el segundo campo de cruce, excluyendo calles escondidas';

-- ============================================
-- SP 3/3: sp_cruces_localiza_calle
-- Tipo: CRUD (Read)
-- Descripción: Localiza datos completos de una o dos calles por cvecalle
-- Lógica de negocio:
--   - Acepta dos parámetros: cvecalle1 y cvecalle2
--   - Devuelve registros para las calles solicitadas
--   - Campo 'tipo' identifica: 1=calle1, 2=calle2
--   - Si cvecalle <= 0, se omite esa calle
--   - No aplica filtro de calles escondidas (localización directa por ID)
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_cruces_localiza_calle(
    p_cvecalle1 INTEGER,
    p_cvecalle2 INTEGER DEFAULT 0
)
RETURNS TABLE(
    tipo INTEGER,
    cvecalle INTEGER,
    cvepoblacion INTEGER,
    desvial INTEGER,
    calle VARCHAR(40),
    cvevig CHAR(1),
    anterior INTEGER,
    feccap DATE,
    capturista VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validación: al menos una calle debe ser proporcionada
    IF (p_cvecalle1 IS NULL OR p_cvecalle1 <= 0)
       AND (p_cvecalle2 IS NULL OR p_cvecalle2 <= 0) THEN
        RAISE EXCEPTION 'Al menos uno de los parámetros p_cvecalle1 o p_cvecalle2 debe ser mayor a 0';
    END IF;

    -- Localizar primera calle si es válida
    IF p_cvecalle1 IS NOT NULL AND p_cvecalle1 > 0 THEN
        RETURN QUERY
        SELECT
            1 AS tipo,
            c.cvecalle,
            c.cvepoblacion,
            c.desvial,
            c.calle,
            c.cvevig,
            c.anterior,
            c.feccap,
            c.capturista
        FROM c_calles c
        WHERE c.cvecalle = p_cvecalle1;
    END IF;

    -- Localizar segunda calle si es válida
    IF p_cvecalle2 IS NOT NULL AND p_cvecalle2 > 0 THEN
        RETURN QUERY
        SELECT
            2 AS tipo,
            c.cvecalle,
            c.cvepoblacion,
            c.desvial,
            c.calle,
            c.cvevig,
            c.anterior,
            c.feccap,
            c.capturista
        FROM c_calles c
        WHERE c.cvecalle = p_cvecalle2;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en sp_cruces_localiza_calle: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION comun.sp_cruces_localiza_calle(INTEGER, INTEGER) IS 'Localiza datos completos de una o dos calles por cvecalle, retornando tipo=1 para calle1 y tipo=2 para calle2';

-- ============================================
-- VERIFICACIÓN Y PRUEBAS
-- ============================================

-- Verificar que las funciones fueron creadas correctamente
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'comun'
      AND p.proname IN (
          'sp_cruces_search_calle1',
          'sp_cruces_search_calle2',
          'sp_cruces_localiza_calle'
      );

    IF v_count = 3 THEN
        RAISE NOTICE 'ÉXITO: Las 3 funciones de CRUCES fueron creadas correctamente en el esquema comun';
    ELSE
        RAISE EXCEPTION 'ERROR: Solo se crearon % de 3 funciones esperadas', v_count;
    END IF;
END $$;

-- ============================================
-- QUERIES DE PRUEBA (COMENTADAS)
-- ============================================
-- Descomentar para probar las funciones después del despliegue

-- PRUEBA 1: Búsqueda de calle para primer campo
-- SELECT * FROM comun.sp_cruces_search_calle1('JUAREZ') LIMIT 10;

-- PRUEBA 2: Búsqueda de calle para segundo campo
-- SELECT * FROM comun.sp_cruces_search_calle2('INDEPENDENCIA') LIMIT 10;

-- PRUEBA 3: Localizar una sola calle
-- SELECT * FROM comun.sp_cruces_localiza_calle(1, 0);

-- PRUEBA 4: Localizar dos calles
-- SELECT * FROM comun.sp_cruces_localiza_calle(1, 2);

-- PRUEBA 5: Verificar exclusión de calles escondidas
-- WITH calles_escondidas AS (
--     SELECT cvecalle FROM c_calles_escondidas WHERE vigente = 'V' AND num_tag = 8000
-- )
-- SELECT COUNT(*) as calles_visibles
-- FROM comun.sp_cruces_search_calle1('')
-- WHERE cvecalle NOT IN (SELECT cvecalle FROM calles_escondidas);

-- ============================================
-- RESUMEN DE IMPLEMENTACIÓN
-- ============================================
-- Total SPs implementados: 3/3 (100%)
-- Schema utilizado: comun
-- Patrón: FUNCTION con RETURNS TABLE
-- Búsqueda: UPPER() para case-insensitive
-- Exclusión: NOT IN subquery para calles escondidas
-- Validaciones: Parámetros no nulos/vacíos
-- Error handling: EXCEPTION con SQLERRM
-- Límites: 500 registros para búsquedas
-- Ordenamiento: Por nombre de calle
-- ============================================

-- FIN DEL ARCHIVO
