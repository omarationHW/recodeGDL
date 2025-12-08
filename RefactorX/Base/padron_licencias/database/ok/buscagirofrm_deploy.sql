-- ============================================
-- DEPLOY: buscagirofrm.vue
-- Módulo: padron_licencias
-- Componente: Búsqueda de Giros
-- Total SPs: 4
-- Fecha: 2025-11-20
-- ============================================

\echo ''
\echo '================================================'
\echo 'DESPLEGANDO: buscagirofrm (4 SPs)'
\echo '================================================'
\echo ''

-- ============================================
-- SP 1/4: sp_buscagiro_list
-- Descripción: Listado de giros con filtros
-- Tablas: comun.c_giros, public.c_valoreslic,
--         public.c_girosautoev, public.lic_permisos
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_buscagiro_list(
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
    costo NUMERIC,
    caracteristicas TEXT,
    clasificacion TEXT,
    vigente CHAR(1),
    tipo CHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_giro, a.descripcion, b.costo, a.caracteristicas, a.clasificacion, a.vigente, a.tipo
    FROM comun.c_giros a
    LEFT JOIN public.c_valoreslic b ON a.id_giro = b.id_giro AND b.axo = p_year
    WHERE a.tipo = p_tipo
      AND a.id_giro > 500
      AND a.vigente = 'V'
      AND (
        p_descripcion IS NULL OR p_descripcion = '' OR
        UPPER(a.descripcion) LIKE '%' || UPPER(p_descripcion) || '%'
      )
      AND (
        (p_autoev = 'S' AND a.id_giro IN (SELECT id_giro FROM public.c_girosautoev)) OR
        (p_autoev = 'N')
      )
      AND (
        (p_pacto = 'S' AND a.clasificacion IN ('B')) OR
        (p_pacto = 'N')
      )
      AND (
        a.id_giro NOT BETWEEN 5000 AND 99999
      )
      AND (
        (
          SELECT giro_a FROM public.lic_permisos WHERE usuario = p_usuario AND id_permiso_catalogo = 2
        ) = 'S' OR (a.clasificacion <> 'A' OR a.clasificacion IS NULL)
      )
    ORDER BY a.descripcion;
END;
$$ LANGUAGE plpgsql;

\echo 'SP 1/4: sp_buscagiro_list creado exitosamente'

-- ============================================
-- SP 2/4: sp_buscagiro_permisos
-- Descripción: Obtiene permisos de giros del usuario
-- Tablas: public.lic_permisos
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_buscagiro_permisos(
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
    RETURN QUERY
    SELECT id, usuario, giro_a, giro_b, giro_c, giro_d, id_permiso_catalogo
    FROM public.lic_permisos
    WHERE usuario = p_usuario AND id_permiso_catalogo = p_id_permiso_catalogo;
END;
$$ LANGUAGE plpgsql;

\echo 'SP 2/4: sp_buscagiro_permisos creado exitosamente'

-- ============================================
-- SP 3/4: sp_buscagiro_search
-- Descripción: Búsqueda avanzada de giros con filtros dinámicos
-- Tablas: comun.c_giros, public.c_valoreslic,
--         public.c_girosautoev, public.lic_permisos
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_buscagiro_search(
    p_descripcion TEXT,
    p_tipo TEXT,
    p_usuario TEXT,
    p_autoev TEXT DEFAULT NULL,
    p_pacto TEXT DEFAULT NULL
) RETURNS TABLE(
    id_giro INTEGER,
    descripcion TEXT,
    costo NUMERIC,
    caracteristicas TEXT,
    clasificacion TEXT,
    vigente TEXT,
    tipo TEXT
) AS $$
DECLARE
    v_giro_a TEXT;
    v_filtroClasificacion TEXT := '';
    v_extraFiltro TEXT := '';
BEGIN
    -- Obtener permisos del usuario
    SELECT giro_a INTO v_giro_a
    FROM public.lic_permisos
    WHERE usuario = p_usuario AND id_permiso_catalogo = 2
    LIMIT 1;

    -- Construir filtro de clasificación
    IF v_giro_a IS NULL OR v_giro_a <> 'S' THEN
        v_filtroClasificacion := ' AND (a.clasificacion <> ''A'' OR a.clasificacion IS NULL) ';
    END IF;

    -- Filtro de autoevaluación
    IF p_autoev = 'Autoevaluacion' THEN
        v_extraFiltro := v_extraFiltro || ' AND a.id_giro IN (SELECT id_giro FROM public.c_girosautoev) ';
    END IF;

    -- Filtro de pacto
    IF p_pacto = 'Pacto para homologar los requisitos' THEN
        v_extraFiltro := v_extraFiltro || ' AND a.clasificacion IN (''B'') ';
    END IF;

    RETURN QUERY EXECUTE format('
        SELECT a.id_giro, a.descripcion, b.costo, a.caracteristicas, a.clasificacion, a.vigente, a.tipo
        FROM comun.c_giros a
        LEFT JOIN public.c_valoreslic b ON a.id_giro = b.id_giro AND b.axo = $1
        WHERE a.id_giro > 500
          AND a.vigente = ''V''
          AND a.tipo = $2
          AND a.descripcion ILIKE $3
          AND a.id_giro NOT BETWEEN 5000 AND 99999
          %s %s
        ORDER BY a.descripcion', v_filtroClasificacion, v_extraFiltro)
    USING extract(year from current_date), p_tipo, '%' || p_descripcion || '%';
END;
$$ LANGUAGE plpgsql;

\echo 'SP 3/4: sp_buscagiro_search creado exitosamente'

-- ============================================
-- SP 4/4: sp_buscagiro_detalle
-- Descripción: Obtiene detalle de un giro por ID
-- Tablas: comun.c_giros, public.c_valoreslic
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_buscagiro_detalle(
    p_id_giro INTEGER
) RETURNS TABLE(
    id_giro INTEGER,
    descripcion TEXT,
    costo NUMERIC,
    caracteristicas TEXT,
    clasificacion TEXT,
    vigente TEXT,
    tipo TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_giro, a.descripcion, b.costo, a.caracteristicas, a.clasificacion, a.vigente, a.tipo
    FROM comun.c_giros a
    LEFT JOIN public.c_valoreslic b ON a.id_giro = b.id_giro
    WHERE a.id_giro = p_id_giro;
END;
$$ LANGUAGE plpgsql;

\echo 'SP 4/4: sp_buscagiro_detalle creado exitosamente'

-- ============================================
-- VERIFICACIÓN
-- ============================================

\echo ''
\echo 'Verificando creación de SPs...'
\echo ''

SELECT
    CASE
        WHEN COUNT(*) = 4 THEN '✓ ÉXITO: Los 4 SPs fueron creados correctamente'
        ELSE '✗ ERROR: Faltan ' || (4 - COUNT(*)) || ' SPs'
    END as resultado
FROM pg_proc
WHERE proname IN (
    'sp_buscagiro_list',
    'sp_buscagiro_permisos',
    'sp_buscagiro_search',
    'sp_buscagiro_detalle'
)
AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');

\echo ''
\echo '================================================'
\echo 'DEPLOY COMPLETADO: buscagirofrm'
\echo '================================================'
\echo ''
