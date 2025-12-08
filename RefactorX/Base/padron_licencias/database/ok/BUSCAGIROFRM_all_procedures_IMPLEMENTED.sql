-- ============================================
-- STORED PROCEDURES - BATCH 10
-- Component: buscagirofrm
-- Description: Advanced search for giros (business types) with multiple filters
-- Total SPs: 2
-- Schema: comun
-- Generated: 2025-11-21
-- Implements: Batch 10 - Component 63/95 (66.3%)
-- ============================================
-- DEPENDENCIES:
--   - c_giros (giros catalog)
--   - c_valoreslic (license values by year)
--   - c_girosautoev (self-evaluation giros)
--   - lic_permisos (user permissions)
-- ============================================

-- ============================================
-- SP 1/2: sp_buscagiro_list
-- Description: Returns list of giros filtered by description, type, self-evaluation, pact and user permissions
-- Type: Query/Search
-- Returns: List of giros with costs and classifications
-- ============================================
-- FILTERS:
--   - p_descripcion: Partial match on description (case-insensitive)
--   - p_tipo: Giro type (A, B, C, D)
--   - p_autoev: Self-evaluation flag (S/N)
--   - p_pacto: Pact flag (S/N) - filters by classification 'B'
--   - p_usuario: User for permission validation
--   - p_year: Year for cost lookup in c_valoreslic
-- BUSINESS RULES:
--   - Only giros with id_giro > 500
--   - Only vigente = 'V' (valid)
--   - Exclude range 5000-99999
--   - Permission check: giro_a='S' or classification != 'A'
--   - Self-evaluation: check c_girosautoev table
--   - Pact: only classification 'B'
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_buscagiro_list(
    p_descripcion TEXT,
    p_tipo CHAR(1),
    p_autoev CHAR(1),
    p_pacto CHAR(1),
    p_usuario TEXT,
    p_year INT
)
RETURNS TABLE (
    id_giro INT,
    descripcion TEXT,
    costo NUMERIC(10,2),
    caracteristicas TEXT,
    clasificacion TEXT,
    vigente CHAR(1)
) AS $$
DECLARE
    v_user_exists BOOLEAN;
BEGIN
    -- Validation: Required parameters
    IF p_tipo IS NULL OR p_tipo = '' THEN
        RAISE EXCEPTION 'Parameter p_tipo is required';
    END IF;

    IF p_autoev IS NULL OR p_autoev = '' THEN
        RAISE EXCEPTION 'Parameter p_autoev is required (S/N)';
    END IF;

    IF p_pacto IS NULL OR p_pacto = '' THEN
        RAISE EXCEPTION 'Parameter p_pacto is required (S/N)';
    END IF;

    IF p_usuario IS NULL OR p_usuario = '' THEN
        RAISE EXCEPTION 'Parameter p_usuario is required';
    END IF;

    IF p_year IS NULL OR p_year < 2000 OR p_year > 2100 THEN
        RAISE EXCEPTION 'Parameter p_year must be a valid year (2000-2100)';
    END IF;

    -- Validation: Valid tipo values
    IF p_tipo NOT IN ('A', 'B', 'C', 'D') THEN
        RAISE EXCEPTION 'Parameter p_tipo must be A, B, C, or D';
    END IF;

    -- Validation: Valid autoev flag
    IF p_autoev NOT IN ('S', 'N') THEN
        RAISE EXCEPTION 'Parameter p_autoev must be S or N';
    END IF;

    -- Validation: Valid pacto flag
    IF p_pacto NOT IN ('S', 'N') THEN
        RAISE EXCEPTION 'Parameter p_pacto must be S or N';
    END IF;

    -- Validation: Check if user exists (optional, depends on requirements)
    -- This could be uncommented if strict validation is needed
    -- SELECT EXISTS(SELECT 1 FROM usuarios WHERE usuario = p_usuario) INTO v_user_exists;
    -- IF NOT v_user_exists THEN
    --     RAISE EXCEPTION 'User % does not exist', p_usuario;
    -- END IF;

    -- Main query with complex filters
    RETURN QUERY
    SELECT
        a.id_giro,
        a.descripcion,
        b.costo,
        a.caracteristicas,
        a.clasificacion,
        a.vigente
    FROM c_giros a
    LEFT JOIN c_valoreslic b ON a.id_giro = b.id_giro AND b.axo = p_year
    WHERE a.tipo = p_tipo
      AND a.id_giro > 500
      AND a.vigente = 'V'
      -- Filter by description (case-insensitive partial match)
      AND (
        p_descripcion IS NULL OR
        p_descripcion = '' OR
        UPPER(a.descripcion) LIKE '%' || UPPER(p_descripcion) || '%'
      )
      -- Filter by self-evaluation (autoevaluacion)
      AND (
        (p_autoev = 'S' AND a.id_giro IN (SELECT id_giro FROM c_girosautoev)) OR
        (p_autoev = 'N')
      )
      -- Filter by pact (only classification B)
      AND (
        (p_pacto = 'S' AND a.clasificacion = 'B') OR
        (p_pacto = 'N')
      )
      -- Exclude range 5000-99999
      AND NOT (a.id_giro BETWEEN 5000 AND 99999)
      -- Permission check: user has giro_a='S' OR giro classification is not 'A'
      AND (
        (
          SELECT giro_a
          FROM lic_permisos
          WHERE usuario = p_usuario
            AND id_permiso_catalogo = 2
          LIMIT 1
        ) = 'S'
        OR
        (a.clasificacion <> 'A' OR a.clasificacion IS NULL)
      )
    ORDER BY a.descripcion;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error in sp_buscagiro_list: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMMENTS: sp_buscagiro_list
-- ============================================
COMMENT ON FUNCTION comun.sp_buscagiro_list(TEXT, CHAR, CHAR, CHAR, TEXT, INT) IS
'Returns list of giros filtered by description, type, self-evaluation, pact and user permissions.
Used for advanced giro search in buscagirofrm component.
Includes cost lookup by year and complex permission validation.';

-- ============================================
-- SP 2/2: sp_buscagiro_permisos
-- Description: Get user permissions for giros
-- Type: Query
-- Returns: User permission record for giro catalog access
-- ============================================
-- PURPOSE:
--   - Validates user access to giro classifications (A, B, C, D)
--   - Returns permission flags for each giro type
--   - Used for UI permission control
-- PARAMETERS:
--   - p_usuario: Username to check permissions
--   - p_id_permiso_catalogo: Permission catalog ID (usually 2 for giros)
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_buscagiro_permisos(
    p_usuario TEXT,
    p_id_permiso_catalogo INT
)
RETURNS TABLE (
    id INT,
    usuario TEXT,
    giro_a CHAR(1),
    giro_b CHAR(1),
    giro_c CHAR(1),
    giro_d CHAR(1),
    id_permiso_catalogo INT
) AS $$
BEGIN
    -- Validation: Required parameters
    IF p_usuario IS NULL OR p_usuario = '' THEN
        RAISE EXCEPTION 'Parameter p_usuario is required';
    END IF;

    IF p_id_permiso_catalogo IS NULL THEN
        RAISE EXCEPTION 'Parameter p_id_permiso_catalogo is required';
    END IF;

    -- Validation: Valid permission catalog ID
    IF p_id_permiso_catalogo < 1 THEN
        RAISE EXCEPTION 'Parameter p_id_permiso_catalogo must be positive';
    END IF;

    -- Return user permissions
    RETURN QUERY
    SELECT
        lp.id,
        lp.usuario,
        lp.giro_a,
        lp.giro_b,
        lp.giro_c,
        lp.giro_d,
        lp.id_permiso_catalogo
    FROM lic_permisos lp
    WHERE lp.usuario = p_usuario
      AND lp.id_permiso_catalogo = p_id_permiso_catalogo;

    -- Note: Returns empty result set if no permissions found (valid behavior)

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error in sp_buscagiro_permisos: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMMENTS: sp_buscagiro_permisos
-- ============================================
COMMENT ON FUNCTION comun.sp_buscagiro_permisos(TEXT, INT) IS
'Returns user permissions for giro catalog access.
Used to validate which giro classifications (A, B, C, D) a user can view.
Returns empty result if user has no permissions.';

-- ============================================
-- RECOMMENDED INDEXES
-- ============================================
-- These indexes optimize the search and filter operations in sp_buscagiro_list

-- Index for c_giros main filters (type, vigente, id_giro range)
-- CREATE INDEX IF NOT EXISTS idx_c_giros_tipo_vigente_id
--   ON c_giros(tipo, vigente, id_giro)
--   WHERE id_giro > 500 AND NOT (id_giro BETWEEN 5000 AND 99999);

-- Index for c_giros description search (case-insensitive)
-- CREATE INDEX IF NOT EXISTS idx_c_giros_descripcion_upper
--   ON c_giros(UPPER(descripcion) text_pattern_ops);

-- Index for c_giros classification filter
-- CREATE INDEX IF NOT EXISTS idx_c_giros_clasificacion
--   ON c_giros(clasificacion)
--   WHERE clasificacion IS NOT NULL;

-- Index for c_valoreslic year lookup
-- CREATE INDEX IF NOT EXISTS idx_c_valoreslic_giro_year
--   ON c_valoreslic(id_giro, axo);

-- Index for c_girosautoev lookup
-- CREATE INDEX IF NOT EXISTS idx_c_girosautoev_id_giro
--   ON c_girosautoev(id_giro);

-- Index for lic_permisos user permission lookup
-- CREATE INDEX IF NOT EXISTS idx_lic_permisos_usuario_catalogo
--   ON lic_permisos(usuario, id_permiso_catalogo);

-- Composite index for optimal join performance
-- CREATE INDEX IF NOT EXISTS idx_c_giros_search_composite
--   ON c_giros(tipo, vigente, id_giro, clasificacion)
--   INCLUDE (descripcion, caracteristicas);

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Test 1: Search all giros of type 'A' for year 2024, no filters
-- SELECT * FROM comun.sp_buscagiro_list('', 'A', 'N', 'N', 'admin', 2024);

-- Test 2: Search with description filter
-- SELECT * FROM comun.sp_buscagiro_list('restaurant', 'A', 'N', 'N', 'admin', 2024);

-- Test 3: Search only self-evaluation giros
-- SELECT * FROM comun.sp_buscagiro_list('', 'B', 'S', 'N', 'admin', 2024);

-- Test 4: Search only pact giros (classification B)
-- SELECT * FROM comun.sp_buscagiro_list('', 'B', 'N', 'S', 'admin', 2024);

-- Test 5: Combined filters - self-evaluation AND pact
-- SELECT * FROM comun.sp_buscagiro_list('', 'B', 'S', 'S', 'admin', 2024);

-- Test 6: Get user permissions
-- SELECT * FROM comun.sp_buscagiro_permisos('admin', 2);

-- Test 7: Search with different year for cost comparison
-- SELECT * FROM comun.sp_buscagiro_list('', 'A', 'N', 'N', 'admin', 2023);

-- Test 8: Validate error handling - invalid tipo
-- SELECT * FROM comun.sp_buscagiro_list('', 'X', 'N', 'N', 'admin', 2024);
-- Expected: ERROR - Parameter p_tipo must be A, B, C, or D

-- Test 9: Validate error handling - invalid year
-- SELECT * FROM comun.sp_buscagiro_list('', 'A', 'N', 'N', 'admin', 1999);
-- Expected: ERROR - Parameter p_year must be a valid year (2000-2100)

-- Test 10: Validate error handling - missing usuario
-- SELECT * FROM comun.sp_buscagiro_list('', 'A', 'N', 'N', '', 2024);
-- Expected: ERROR - Parameter p_usuario is required

-- ============================================
-- PERFORMANCE NOTES
-- ============================================
/*
1. LEFT JOIN with c_valoreslic allows giros without cost records to be returned
2. Subquery for permission check is executed once per row (could be optimized with CTE)
3. UPPER() function on descripcion requires functional index for optimal performance
4. Complex WHERE conditions are evaluated in order for short-circuit optimization
5. NOT (BETWEEN) clause excludes specific ID range efficiently
6. ORDER BY descripcion benefits from index on that column

OPTIMIZATION SUGGESTIONS:
- Consider materializing c_girosautoev as a boolean column in c_giros
- Consider caching user permissions in application layer
- For heavy usage, consider adding computed column for UPPER(descripcion)
- Monitor query plans and adjust indexes based on actual usage patterns
*/

-- ============================================
-- USAGE EXAMPLES IN APPLICATION
-- ============================================
/*
// Laravel Controller Example
$giros = DB::select('SELECT * FROM comun.sp_buscagiro_list(?, ?, ?, ?, ?, ?)', [
    $request->descripcion ?? '',
    $request->tipo,
    $request->autoev,
    $request->pacto,
    auth()->user()->username,
    $request->year ?? date('Y')
]);

// Vue 3 Component Example
const searchGiros = async (filters) => {
  const response = await api.post('/giros/search', {
    descripcion: filters.descripcion || '',
    tipo: filters.tipo,
    autoev: filters.autoev ? 'S' : 'N',
    pacto: filters.pacto ? 'S' : 'N',
    year: filters.year || new Date().getFullYear()
  });
  return response.data;
};

// Permission Check Example
const userPermisos = await api.get('/giros/permisos');
if (userPermisos.giro_a === 'S') {
  // User can view classification A giros
}
*/

-- ============================================
-- END OF FILE
-- Component: buscagirofrm
-- Total Functions: 2
-- Status: IMPLEMENTED
-- Date: 2025-11-21
-- Batch: 10
-- Progress: 63/95 (66.3%)
-- ============================================
