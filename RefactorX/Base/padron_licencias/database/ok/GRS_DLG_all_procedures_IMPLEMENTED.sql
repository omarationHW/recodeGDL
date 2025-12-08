-- ============================================
-- STORED PROCEDURES - BATCH 12
-- Component: grs_dlg
-- Description: Generic search dialog for giros (business activities)
-- Total SPs: 2
-- Schema: comun
-- Generated: 2025-11-21
-- Implements: Batch 12 - Component 73/95 (76.8%)
-- ============================================
-- DEPENDENCIES:
--   - comun.c_giros (giros/business activities catalog)
-- ============================================
-- SECURITY NOTE:
--   The original reference file used dynamic SQL with table/field parameters
--   which poses SQL injection risks. This implementation uses safe, specific
--   functions for giro searches with proper parameterization.
-- ============================================

-- ============================================
-- SP 1/2: sp_grs_dlg_get_giros
-- Description: Returns all active giros for dropdown/dialog selection
-- Type: Catalog/Query
-- Returns: List of giros with id, descripcion, tipo, clasificacion
-- ============================================
-- PURPOSE:
--   - Populate dropdown/dialog with available giros
--   - Filter only active (vigente='V') giros
--   - Order alphabetically by description for easy selection
-- PARAMETERS:
--   - p_tipo (optional): Filter by giro type (L=Licencia, A=Anuncio, etc.)
--   - p_clasificacion (optional): Filter by classification (A, B, C, D)
-- RETURNS:
--   - All columns needed for dialog display and selection
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_grs_dlg_get_giros(
    p_tipo CHAR(1) DEFAULT NULL,
    p_clasificacion CHAR(1) DEFAULT NULL
)
RETURNS TABLE (
    id_giro INT,
    descripcion TEXT,
    tipo CHAR(1),
    clasificacion CHAR(1),
    caracteristicas TEXT,
    vigente CHAR(1),
    cod_giro INT,
    cod_anun INT,
    reglamentada CHAR(1)
) AS $$
BEGIN
    -- Validation: If tipo provided, must be valid
    IF p_tipo IS NOT NULL AND p_tipo NOT IN ('L', 'A', 'E', 'P', 'T') THEN
        RAISE EXCEPTION 'Invalid p_tipo value. Must be L (Licencia), A (Anuncio), E, P, or T. Got: %', p_tipo;
    END IF;

    -- Validation: If clasificacion provided, must be valid
    IF p_clasificacion IS NOT NULL AND p_clasificacion NOT IN ('A', 'B', 'C', 'D') THEN
        RAISE EXCEPTION 'Invalid p_clasificacion value. Must be A, B, C, or D. Got: %', p_clasificacion;
    END IF;

    -- Return all active giros with optional filters
    RETURN QUERY
    SELECT
        g.id_giro,
        g.descripcion::TEXT,
        g.tipo,
        g.clasificacion,
        g.caracteristicas::TEXT,
        g.vigente,
        g.cod_giro,
        g.cod_anun,
        g.reglamentada
    FROM comun.c_giros g
    WHERE g.vigente = 'V'
      -- Optional filter by tipo
      AND (p_tipo IS NULL OR g.tipo = p_tipo)
      -- Optional filter by clasificacion
      AND (p_clasificacion IS NULL OR g.clasificacion = p_clasificacion)
    ORDER BY g.descripcion;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error in sp_grs_dlg_get_giros: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMMENTS: sp_grs_dlg_get_giros
-- ============================================
COMMENT ON FUNCTION comun.sp_grs_dlg_get_giros(CHAR, CHAR) IS
'Returns all active giros for dropdown/dialog selection.
Filters by vigente=V and optionally by tipo and clasificacion.
Used in generic search dialogs for giro selection.
Security: Uses parameterized queries, no dynamic SQL.';

-- ============================================
-- SP 2/2: sp_grs_dlg_search_giros
-- Description: Search giros by description with ILIKE partial matching
-- Type: Search/Query
-- Returns: List of matching giros with full details
-- ============================================
-- PURPOSE:
--   - Search giros by partial description match (case-insensitive)
--   - Support filtering by tipo
--   - Support filtering by clasificacion
--   - Support exact vs partial matching
--   - Used for autocomplete and search dialogs
-- PARAMETERS:
--   - p_search_text: Search term for description (partial match with ILIKE)
--   - p_tipo (optional): Filter by giro type
--   - p_clasificacion (optional): Filter by classification
--   - p_exact_match: If TRUE, use exact match; if FALSE, use ILIKE partial (default)
--   - p_limit: Maximum results to return (default 100)
-- BUSINESS RULES:
--   - Only active giros (vigente='V')
--   - Case-insensitive search
--   - Partial match by default (contains)
--   - Limited results for performance
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_grs_dlg_search_giros(
    p_search_text TEXT,
    p_tipo CHAR(1) DEFAULT NULL,
    p_clasificacion CHAR(1) DEFAULT NULL,
    p_exact_match BOOLEAN DEFAULT FALSE,
    p_limit INT DEFAULT 100
)
RETURNS TABLE (
    id_giro INT,
    descripcion TEXT,
    tipo CHAR(1),
    clasificacion CHAR(1),
    caracteristicas TEXT,
    vigente CHAR(1),
    cod_giro INT,
    cod_anun INT,
    reglamentada CHAR(1)
) AS $$
DECLARE
    v_search_pattern TEXT;
BEGIN
    -- Validation: Search text required
    IF p_search_text IS NULL THEN
        RAISE EXCEPTION 'Parameter p_search_text is required. Use sp_grs_dlg_get_giros for unfiltered list.';
    END IF;

    -- Validation: If tipo provided, must be valid
    IF p_tipo IS NOT NULL AND p_tipo NOT IN ('L', 'A', 'E', 'P', 'T') THEN
        RAISE EXCEPTION 'Invalid p_tipo value. Must be L (Licencia), A (Anuncio), E, P, or T. Got: %', p_tipo;
    END IF;

    -- Validation: If clasificacion provided, must be valid
    IF p_clasificacion IS NOT NULL AND p_clasificacion NOT IN ('A', 'B', 'C', 'D') THEN
        RAISE EXCEPTION 'Invalid p_clasificacion value. Must be A, B, C, or D. Got: %', p_clasificacion;
    END IF;

    -- Validation: Limit must be positive and reasonable
    IF p_limit IS NULL OR p_limit < 1 THEN
        p_limit := 100;
    ELSIF p_limit > 1000 THEN
        p_limit := 1000;  -- Cap at 1000 for performance
    END IF;

    -- Build search pattern based on match type
    IF p_exact_match THEN
        v_search_pattern := p_search_text;
    ELSE
        -- Partial match: wrap with wildcards for ILIKE
        v_search_pattern := '%' || p_search_text || '%';
    END IF;

    -- Perform search with all filters
    RETURN QUERY
    SELECT
        g.id_giro,
        g.descripcion::TEXT,
        g.tipo,
        g.clasificacion,
        g.caracteristicas::TEXT,
        g.vigente,
        g.cod_giro,
        g.cod_anun,
        g.reglamentada
    FROM comun.c_giros g
    WHERE g.vigente = 'V'
      -- Search by description (case-insensitive)
      AND (
        CASE
          WHEN p_exact_match THEN g.descripcion = p_search_text
          ELSE g.descripcion ILIKE v_search_pattern
        END
      )
      -- Optional filter by tipo
      AND (p_tipo IS NULL OR g.tipo = p_tipo)
      -- Optional filter by clasificacion
      AND (p_clasificacion IS NULL OR g.clasificacion = p_clasificacion)
    ORDER BY
      -- Exact matches first, then by description
      CASE WHEN UPPER(g.descripcion) = UPPER(p_search_text) THEN 0 ELSE 1 END,
      g.descripcion
    LIMIT p_limit;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error in sp_grs_dlg_search_giros: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMMENTS: sp_grs_dlg_search_giros
-- ============================================
COMMENT ON FUNCTION comun.sp_grs_dlg_search_giros(TEXT, CHAR, CHAR, BOOLEAN, INT) IS
'Searches giros by description with ILIKE partial matching.
Supports optional filters for tipo and clasificacion.
Case-insensitive search with exact match option.
Returns results ordered by relevance (exact matches first).
Security: Uses parameterized queries, no dynamic SQL.
Performance: Limited to max 1000 results.';

-- ============================================
-- RECOMMENDED INDEXES
-- ============================================
-- These indexes optimize the search and filter operations

-- Index for filtering active giros (most queries filter by vigente)
-- CREATE INDEX IF NOT EXISTS idx_c_giros_vigente
--   ON comun.c_giros(vigente)
--   WHERE vigente = 'V';

-- Index for description search (ILIKE benefits from trigram index)
-- CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- CREATE INDEX IF NOT EXISTS idx_c_giros_descripcion_trgm
--   ON comun.c_giros USING gin (descripcion gin_trgm_ops);

-- Index for tipo filter
-- CREATE INDEX IF NOT EXISTS idx_c_giros_tipo
--   ON comun.c_giros(tipo)
--   WHERE vigente = 'V';

-- Index for clasificacion filter
-- CREATE INDEX IF NOT EXISTS idx_c_giros_clasificacion
--   ON comun.c_giros(clasificacion)
--   WHERE vigente = 'V';

-- Composite index for common filter combinations
-- CREATE INDEX IF NOT EXISTS idx_c_giros_vigente_tipo_clasif
--   ON comun.c_giros(vigente, tipo, clasificacion)
--   INCLUDE (descripcion, caracteristicas);

-- Index for case-insensitive exact match
-- CREATE INDEX IF NOT EXISTS idx_c_giros_descripcion_upper
--   ON comun.c_giros(UPPER(descripcion))
--   WHERE vigente = 'V';

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Test 1: Get all active giros (no filters)
-- SELECT * FROM comun.sp_grs_dlg_get_giros();

-- Test 2: Get giros filtered by tipo (Licencias only)
-- SELECT * FROM comun.sp_grs_dlg_get_giros('L', NULL);

-- Test 3: Get giros filtered by clasificacion
-- SELECT * FROM comun.sp_grs_dlg_get_giros(NULL, 'A');

-- Test 4: Get giros filtered by both tipo and clasificacion
-- SELECT * FROM comun.sp_grs_dlg_get_giros('L', 'B');

-- Test 5: Search giros by partial description
-- SELECT * FROM comun.sp_grs_dlg_search_giros('restaurant');

-- Test 6: Search giros with tipo filter
-- SELECT * FROM comun.sp_grs_dlg_search_giros('venta', 'L');

-- Test 7: Search giros with clasificacion filter
-- SELECT * FROM comun.sp_grs_dlg_search_giros('comercio', NULL, 'B');

-- Test 8: Search giros with exact match
-- SELECT * FROM comun.sp_grs_dlg_search_giros('RESTAURANTE CON VENTA DE BEBIDAS ALCOHOLICAS', NULL, NULL, TRUE);

-- Test 9: Search giros with all filters
-- SELECT * FROM comun.sp_grs_dlg_search_giros('tienda', 'L', 'A', FALSE, 50);

-- Test 10: Search with limited results
-- SELECT * FROM comun.sp_grs_dlg_search_giros('a', NULL, NULL, FALSE, 10);

-- Test 11: Validate error handling - invalid tipo
-- SELECT * FROM comun.sp_grs_dlg_get_giros('X', NULL);
-- Expected: ERROR - Invalid p_tipo value

-- Test 12: Validate error handling - invalid clasificacion
-- SELECT * FROM comun.sp_grs_dlg_search_giros('test', NULL, 'Z');
-- Expected: ERROR - Invalid p_clasificacion value

-- Test 13: Validate error handling - null search text
-- SELECT * FROM comun.sp_grs_dlg_search_giros(NULL);
-- Expected: ERROR - Parameter p_search_text is required

-- ============================================
-- PERFORMANCE NOTES
-- ============================================
/*
1. ILIKE with % wildcards cannot use standard B-tree indexes efficiently
   - Recommend pg_trgm extension with GIN index for production
   - Alternative: Add UPPER(descripcion) column with index for case-insensitive

2. ORDER BY with CASE expression prioritizes exact matches
   - Slight performance impact but improved UX
   - Consider removing for large datasets if not needed

3. LIMIT clause ensures bounded response times
   - Default 100, max 1000 for safety
   - Frontend should implement pagination if more needed

4. Partial index on vigente='V' reduces index size
   - Most queries only need active giros
   - Significant improvement for large catalogs

5. Composite index optimization
   - Covers common filter combinations
   - INCLUDE clause for covering index benefits

COMPARISON WITH ORIGINAL IMPLEMENTATION:
- Original: Dynamic SQL with table/field parameters (security risk)
- New: Specific functions with parameterized queries (safe)
- Original: Generic, works with any table
- New: Specific to c_giros, but secure and optimized
*/

-- ============================================
-- USAGE EXAMPLES IN APPLICATION
-- ============================================
/*
// Laravel Controller Example - Get all giros for dropdown
public function getGirosForDropdown(Request $request)
{
    $tipo = $request->input('tipo');
    $clasificacion = $request->input('clasificacion');

    $giros = DB::select(
        'SELECT * FROM comun.sp_grs_dlg_get_giros(?, ?)',
        [$tipo, $clasificacion]
    );

    return response()->json($giros);
}

// Laravel Controller Example - Search giros
public function searchGiros(Request $request)
{
    $searchText = $request->input('search', '');
    $tipo = $request->input('tipo');
    $clasificacion = $request->input('clasificacion');
    $exactMatch = $request->boolean('exact', false);
    $limit = $request->input('limit', 100);

    $giros = DB::select(
        'SELECT * FROM comun.sp_grs_dlg_search_giros(?, ?, ?, ?, ?)',
        [$searchText, $tipo, $clasificacion, $exactMatch, $limit]
    );

    return response()->json($giros);
}

// Vue 3 Component Example - Autocomplete
const searchGiros = async (searchText) => {
  if (!searchText || searchText.length < 2) {
    return [];
  }

  const response = await api.get('/giros/search', {
    params: {
      search: searchText,
      tipo: selectedTipo.value,
      limit: 20
    }
  });

  return response.data;
};

// Vue 3 Component Example - Dropdown
const loadGirosDropdown = async () => {
  const response = await api.get('/giros/list', {
    params: {
      tipo: 'L',  // Only Licencias
      clasificacion: 'A'  // Only classification A
    }
  });

  girosOptions.value = response.data.map(g => ({
    value: g.id_giro,
    label: g.descripcion,
    tipo: g.tipo,
    clasificacion: g.clasificacion
  }));
};

// Vue 3 Component - Dialog with search
const grsDialog = {
  setup() {
    const searchText = ref('');
    const results = ref([]);
    const loading = ref(false);

    const debouncedSearch = useDebounceFn(async (text) => {
      if (text.length < 2) {
        results.value = [];
        return;
      }

      loading.value = true;
      try {
        results.value = await searchGiros(text);
      } finally {
        loading.value = false;
      }
    }, 300);

    watch(searchText, debouncedSearch);

    return { searchText, results, loading };
  }
};
*/

-- ============================================
-- MIGRATION FROM ORIGINAL DYNAMIC SQL FUNCTION
-- ============================================
/*
The original sp_grs_dlg_search function used dynamic SQL:
  - format('SELECT * FROM %I WHERE %I ILIKE $1', p_table, p_field)

This was flexible but posed security risks and was hard to optimize.

Migration path for existing code:
1. Replace calls to sp_grs_dlg_search('c_giros', 'descripcion', 'value')
   with: sp_grs_dlg_search_giros('value')

2. If using for other tables, create specific functions for each table
   following the same pattern (sp_search_TABLE_NAME)

3. The new functions provide:
   - Type safety with explicit parameters
   - Better query plans (no dynamic SQL)
   - Additional filters (tipo, clasificacion)
   - Relevance ordering (exact matches first)
   - Built-in pagination via LIMIT
*/

-- ============================================
-- END OF FILE
-- Component: grs_dlg
-- Total Functions: 2
-- Status: IMPLEMENTED
-- Date: 2025-11-21
-- Batch: 12
-- Progress: 73/95 (76.8%)
-- ============================================
