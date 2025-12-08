-- ============================================
-- DEPLOY: catalogogirosfrm.vue
-- Módulo: padron_licencias
-- Componente: Catálogo de Giros (ABC Completo)
-- Total SPs: 6
-- Fecha: 2025-11-20
-- ============================================

\echo ''
\echo '================================================'
\echo 'DESPLEGANDO: catalogogirosfrm (6 SPs)'
\echo '================================================'
\echo ''

-- ============================================
-- SP 1/6: sp_catalogogiros_estadisticas
-- Descripción: Obtiene estadísticas generales de giros
-- Tablas: comun.c_giros
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_catalogogiros_estadisticas()
RETURNS TABLE (
    total_giros BIGINT,
    giros_vigentes BIGINT,
    giros_licencias BIGINT,
    giros_anuncios BIGINT,
    giros_reglamentados BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*)::BIGINT as total_giros,
        COUNT(CASE WHEN vigente = 'V' THEN 1 END)::BIGINT as giros_vigentes,
        COUNT(CASE WHEN tipo = 'L' THEN 1 END)::BIGINT as giros_licencias,
        COUNT(CASE WHEN tipo = 'A' THEN 1 END)::BIGINT as giros_anuncios,
        COUNT(CASE WHEN reglamentada = 'S' THEN 1 END)::BIGINT as giros_reglamentados
    FROM comun.c_giros;
END;
$$ LANGUAGE plpgsql;

\echo 'SP 1/6: sp_catalogogiros_estadisticas creado exitosamente'

-- ============================================
-- SP 2/6: sp_catalogogiros_list
-- Descripción: Listado paginado de giros con filtros
-- Tablas: comun.c_giros
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_catalogogiros_list(
    p_page INTEGER DEFAULT 1,
    p_page_size INTEGER DEFAULT 20,
    p_codigo TEXT DEFAULT NULL,
    p_descripcion TEXT DEFAULT NULL,
    p_clasificacion TEXT DEFAULT NULL,
    p_tipo TEXT DEFAULT NULL,
    p_vigente TEXT DEFAULT NULL
)
RETURNS TABLE (
    id_giro INTEGER,
    cod_giro INTEGER,
    descripcion TEXT,
    cod_anun TEXT,
    caracteristicas TEXT,
    clasificacion TEXT,
    ctaaplic INTEGER,
    ctaaplic_rez INTEGER,
    reglamentada CHAR(1),
    tipo CHAR(1),
    vigente CHAR(1),
    total_registros BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
    v_total BIGINT;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    -- Calcular total de registros que cumplen los filtros
    SELECT COUNT(*) INTO v_total
    FROM comun.c_giros g
    WHERE (p_codigo IS NULL OR CAST(g.cod_giro AS TEXT) LIKE '%' || p_codigo || '%')
      AND (p_descripcion IS NULL OR UPPER(g.descripcion) LIKE '%' || UPPER(p_descripcion) || '%')
      AND (p_clasificacion IS NULL OR g.clasificacion = p_clasificacion)
      AND (p_tipo IS NULL OR g.tipo = p_tipo)
      AND (p_vigente IS NULL OR g.vigente = p_vigente);

    RETURN QUERY
    SELECT
        g.id_giro,
        g.cod_giro,
        g.descripcion,
        g.cod_anun,
        g.caracteristicas,
        g.clasificacion,
        g.ctaaplic,
        g.ctaaplic_rez,
        g.reglamentada,
        g.tipo,
        g.vigente,
        v_total as total_registros
    FROM comun.c_giros g
    WHERE (p_codigo IS NULL OR CAST(g.cod_giro AS TEXT) LIKE '%' || p_codigo || '%')
      AND (p_descripcion IS NULL OR UPPER(g.descripcion) LIKE '%' || UPPER(p_descripcion) || '%')
      AND (p_clasificacion IS NULL OR g.clasificacion = p_clasificacion)
      AND (p_tipo IS NULL OR g.tipo = p_tipo)
      AND (p_vigente IS NULL OR g.vigente = p_vigente)
    ORDER BY g.descripcion
    LIMIT p_page_size
    OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;

\echo 'SP 2/6: sp_catalogogiros_list creado exitosamente'

-- ============================================
-- SP 3/6: sp_catalogogiros_get
-- Descripción: Obtiene un giro por su ID
-- Tablas: comun.c_giros
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_catalogogiros_get(
    p_id_giro INTEGER
)
RETURNS TABLE (
    id_giro INTEGER,
    cod_giro INTEGER,
    descripcion TEXT,
    cod_anun TEXT,
    caracteristicas TEXT,
    clasificacion TEXT,
    ctaaplic INTEGER,
    ctaaplic_rez INTEGER,
    reglamentada CHAR(1),
    tipo CHAR(1),
    vigente CHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        g.id_giro,
        g.cod_giro,
        g.descripcion,
        g.cod_anun,
        g.caracteristicas,
        g.clasificacion,
        g.ctaaplic,
        g.ctaaplic_rez,
        g.reglamentada,
        g.tipo,
        g.vigente
    FROM comun.c_giros g
    WHERE g.id_giro = p_id_giro;
END;
$$ LANGUAGE plpgsql;

\echo 'SP 3/6: sp_catalogogiros_get creado exitosamente'

-- ============================================
-- SP 4/6: sp_catalogogiros_create
-- Descripción: Crea un nuevo giro
-- Tablas: comun.c_giros
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_catalogogiros_create(
    p_cod_giro INTEGER,
    p_descripcion TEXT,
    p_cod_anun TEXT DEFAULT NULL,
    p_caracteristicas TEXT DEFAULT NULL,
    p_clasificacion TEXT,
    p_ctaaplic INTEGER DEFAULT NULL,
    p_ctaaplic_rez INTEGER DEFAULT NULL,
    p_reglamentada CHAR(1) DEFAULT 'N',
    p_tipo CHAR(1),
    p_vigente CHAR(1) DEFAULT 'V'
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    id_giro INTEGER
) AS $$
DECLARE
    v_new_id INTEGER;
    v_exists BOOLEAN;
BEGIN
    -- Verificar si ya existe el código
    SELECT EXISTS(SELECT 1 FROM comun.c_giros WHERE cod_giro = p_cod_giro) INTO v_exists;

    IF v_exists THEN
        RETURN QUERY SELECT FALSE, 'Ya existe un giro con ese código', NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar nuevo giro
    INSERT INTO comun.c_giros (
        cod_giro,
        descripcion,
        cod_anun,
        caracteristicas,
        clasificacion,
        ctaaplic,
        ctaaplic_rez,
        reglamentada,
        tipo,
        vigente
    ) VALUES (
        p_cod_giro,
        p_descripcion,
        p_cod_anun,
        p_caracteristicas,
        p_clasificacion,
        p_ctaaplic,
        p_ctaaplic_rez,
        p_reglamentada,
        p_tipo,
        p_vigente
    ) RETURNING id_giro INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Giro creado exitosamente', v_new_id;
END;
$$ LANGUAGE plpgsql;

\echo 'SP 4/6: sp_catalogogiros_create creado exitosamente'

-- ============================================
-- SP 5/6: sp_catalogogiros_update
-- Descripción: Actualiza un giro existente
-- Tablas: comun.c_giros
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_catalogogiros_update(
    p_id_giro INTEGER,
    p_cod_giro INTEGER,
    p_descripcion TEXT,
    p_clasificacion TEXT,
    p_tipo CHAR(1),
    p_cod_anun TEXT DEFAULT NULL,
    p_caracteristicas TEXT DEFAULT NULL,
    p_reglamentada CHAR(1) DEFAULT 'N',
    p_vigente CHAR(1) DEFAULT 'V'
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_exists BOOLEAN;
    v_rows_affected INTEGER;
BEGIN
    -- Verificar que el giro existe
    SELECT EXISTS(SELECT 1 FROM comun.c_giros WHERE id_giro = p_id_giro) INTO v_exists;

    IF NOT v_exists THEN
        RETURN QUERY SELECT FALSE, 'El giro no existe'::TEXT;
        RETURN;
    END IF;

    -- Verificar si el código ya está en uso por otro giro
    SELECT EXISTS(
        SELECT 1 FROM comun.c_giros
        WHERE cod_giro = p_cod_giro
        AND id_giro <> p_id_giro
    ) INTO v_exists;

    IF v_exists THEN
        RETURN QUERY SELECT FALSE, 'El código ya está en uso por otro giro'::TEXT;
        RETURN;
    END IF;

    -- Actualizar giro
    UPDATE comun.c_giros SET
        cod_giro = p_cod_giro,
        descripcion = p_descripcion,
        clasificacion = p_clasificacion,
        tipo = p_tipo,
        cod_anun = p_cod_anun,
        caracteristicas = p_caracteristicas,
        reglamentada = p_reglamentada,
        vigente = p_vigente
    WHERE id_giro = p_id_giro;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    IF v_rows_affected > 0 THEN
        RETURN QUERY SELECT TRUE, 'Giro actualizado exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'No se pudo actualizar el giro'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

\echo 'SP 5/6: sp_catalogogiros_update creado exitosamente'

-- ============================================
-- SP 6/6: sp_catalogogiros_cambiar_vigencia
-- Descripción: Cambia la vigencia de un giro (V/C)
-- Tablas: comun.c_giros
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_catalogogiros_cambiar_vigencia(
    p_id_giro INTEGER,
    p_vigente CHAR(1)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_exists BOOLEAN;
    v_rows_affected INTEGER;
BEGIN
    -- Verificar que el giro existe
    SELECT EXISTS(SELECT 1 FROM comun.c_giros WHERE id_giro = p_id_giro) INTO v_exists;

    IF NOT v_exists THEN
        RETURN QUERY SELECT FALSE, 'El giro no existe'::TEXT;
        RETURN;
    END IF;

    -- Cambiar vigencia
    UPDATE comun.c_giros
    SET vigente = p_vigente
    WHERE id_giro = p_id_giro;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    IF v_rows_affected > 0 THEN
        RETURN QUERY SELECT
            TRUE,
            'Vigencia cambiada a ' || CASE WHEN p_vigente = 'V' THEN 'VIGENTE' ELSE 'CANCELADO' END || ' exitosamente';
    ELSE
        RETURN QUERY SELECT FALSE, 'No se pudo cambiar la vigencia'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

\echo 'SP 6/6: sp_catalogogiros_cambiar_vigencia creado exitosamente'

-- ============================================
-- VERIFICACIÓN
-- ============================================

\echo ''
\echo 'Verificando creación de SPs...'
\echo ''

SELECT
    CASE
        WHEN COUNT(*) = 6 THEN '✓ ÉXITO: Los 6 SPs fueron creados correctamente'
        ELSE '✗ ERROR: Faltan ' || (6 - COUNT(*)) || ' SPs'
    END as resultado
FROM pg_proc
WHERE proname IN (
    'sp_catalogogiros_estadisticas',
    'sp_catalogogiros_list',
    'sp_catalogogiros_get',
    'sp_catalogogiros_create',
    'sp_catalogogiros_update',
    'sp_catalogogiros_cambiar_vigencia'
)
AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');

\echo ''
\echo '================================================'
\echo 'DEPLOY COMPLETADO: catalogogirosfrm'
\echo '================================================'
\echo ''
