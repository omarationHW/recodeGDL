-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: frmselcalle
-- Componente: Formulario de seleccion de calles
-- Esquema: comun
-- Total SPs: 2
-- Batch: 13
-- Generado: 2025-11-21
-- ============================================
-- MANDATORY PATTERNS:
-- - Parameters: prefix p_
-- - Variables: prefix v_
-- - Schema: comun
-- - Return: RETURNS TABLE(...)
-- ============================================

-- ============================================
-- CONFIGURACION BASE DE DATOS
-- ============================================
SET search_path TO comun, public;

-- ============================================
-- SP 1/2: sp_frmselcalle_get_calles
-- Tipo: Catalog
-- Descripcion: Obtiene todas las calles o filtra por nombre usando prefijo (ILIKE p_filter || '%').
--              Si el filtro es NULL o vacio, retorna todas las calles.
--              Usa prefix matching (no %filter%).
-- Tabla: c_calles
-- --------------------------------------------

DROP FUNCTION IF EXISTS comun.sp_frmselcalle_get_calles(TEXT);

CREATE OR REPLACE FUNCTION comun.sp_frmselcalle_get_calles(
    p_filter TEXT DEFAULT NULL
)
RETURNS TABLE (
    cvecalle INTEGER,
    calle TEXT
) AS $$
DECLARE
    v_filter_trimmed TEXT;
BEGIN
    -- Trim and handle null/empty filter
    v_filter_trimmed := COALESCE(TRIM(p_filter), '');

    IF v_filter_trimmed = '' THEN
        -- Return all streets when filter is empty or null
        RETURN QUERY
        SELECT
            c.cvecalle,
            c.calle::TEXT
        FROM c_calles c
        ORDER BY c.calle;
    ELSE
        -- Return streets matching the prefix (ILIKE filter || '%')
        RETURN QUERY
        SELECT
            c.cvecalle,
            c.calle::TEXT
        FROM c_calles c
        WHERE c.calle ILIKE v_filter_trimmed || '%'
        ORDER BY c.calle;
    END IF;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION comun.sp_frmselcalle_get_calles(TEXT) IS
'Obtiene todas las calles o filtra por nombre usando prefijo.
Parametros:
  - p_filter: Filtro de texto para buscar calles (prefix matching con ILIKE).
              Si es NULL o vacio, retorna todas las calles.
Retorna: Lista de calles (cvecalle, calle) ordenadas por nombre.';

-- ============================================
-- SP 2/2: sp_frmselcalle_get_calle_by_ids
-- Tipo: Catalog
-- Descripcion: Obtiene las calles por una lista de IDs separados por coma.
--              Usa string_to_array() y ANY() para parsear la lista de IDs.
-- Tabla: c_calles
-- --------------------------------------------

DROP FUNCTION IF EXISTS comun.sp_frmselcalle_get_calle_by_ids(TEXT);

CREATE OR REPLACE FUNCTION comun.sp_frmselcalle_get_calle_by_ids(
    p_ids_csv TEXT
)
RETURNS TABLE (
    cvecalle INTEGER,
    calle TEXT
) AS $$
DECLARE
    v_ids_array INTEGER[];
BEGIN
    -- Handle null or empty input
    IF p_ids_csv IS NULL OR TRIM(p_ids_csv) = '' THEN
        -- Return empty result set
        RETURN;
    END IF;

    -- Parse comma-separated IDs into array
    v_ids_array := string_to_array(TRIM(p_ids_csv), ',')::INTEGER[];

    -- Return streets matching the IDs
    RETURN QUERY
    SELECT
        c.cvecalle,
        c.calle::TEXT
    FROM c_calles c
    WHERE c.cvecalle = ANY(v_ids_array)
    ORDER BY c.calle;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION comun.sp_frmselcalle_get_calle_by_ids(TEXT) IS
'Obtiene las calles por una lista de IDs separados por coma.
Parametros:
  - p_ids_csv: Lista de IDs de calles separados por coma (ej: "1,2,3,4").
Retorna: Lista de calles (cvecalle, calle) correspondientes a los IDs proporcionados.';

-- ============================================
-- VERIFICACION DE FUNCIONES CREADAS
-- ============================================
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'comun'
      AND p.proname IN ('sp_frmselcalle_get_calles', 'sp_frmselcalle_get_calle_by_ids');

    IF v_count = 2 THEN
        RAISE NOTICE 'FRMSELCALLE: 2/2 stored procedures creados exitosamente en esquema comun';
    ELSE
        RAISE WARNING 'FRMSELCALLE: Solo % de 2 stored procedures fueron creados', v_count;
    END IF;
END $$;

-- ============================================
-- EJEMPLOS DE USO
-- ============================================
-- Obtener todas las calles:
-- SELECT * FROM comun.sp_frmselcalle_get_calles();
-- SELECT * FROM comun.sp_frmselcalle_get_calles(NULL);
-- SELECT * FROM comun.sp_frmselcalle_get_calles('');

-- Filtrar calles por prefijo:
-- SELECT * FROM comun.sp_frmselcalle_get_calles('AV');
-- SELECT * FROM comun.sp_frmselcalle_get_calles('JUAREZ');

-- Obtener calles por IDs:
-- SELECT * FROM comun.sp_frmselcalle_get_calle_by_ids('1,2,3');
-- SELECT * FROM comun.sp_frmselcalle_get_calle_by_ids('100,200,300');

-- ============================================
-- FIN DEL ARCHIVO
-- ============================================
