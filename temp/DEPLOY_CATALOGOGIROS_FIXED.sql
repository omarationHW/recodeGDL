-- =====================================================
-- SCRIPT MAESTRO DE DESPLIEGUE - CORREGIDO
-- Componente: catalogogirosfrm.vue
-- Módulo: padron_licencias
-- Esquema: comun
-- Fecha: 2025-11-05
-- =====================================================

-- LIMPIAR SPs EXISTENTES
DROP FUNCTION IF EXISTS comun.sp_catalogogiros_list(INTEGER,INTEGER,TEXT,TEXT,VARCHAR,VARCHAR,VARCHAR);
DROP FUNCTION IF EXISTS comun.sp_catalogogiros_get(INTEGER);
DROP FUNCTION IF EXISTS comun.sp_catalogogiros_create(INTEGER,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,INTEGER,VARCHAR);
DROP FUNCTION IF EXISTS comun.sp_catalogogiros_update(INTEGER,INTEGER,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR);
DROP FUNCTION IF EXISTS comun.sp_catalogogiros_cambiar_vigencia(INTEGER,VARCHAR);
DROP FUNCTION IF EXISTS comun.sp_catalogogiros_estadisticas();

-- 1. SP: sp_catalogogiros_list
CREATE OR REPLACE FUNCTION comun.sp_catalogogiros_list(
    p_page INTEGER DEFAULT 1,
    p_page_size INTEGER DEFAULT 10,
    p_codigo TEXT DEFAULT NULL,
    p_descripcion TEXT DEFAULT NULL,
    p_clasificacion VARCHAR(1) DEFAULT NULL,
    p_tipo VARCHAR(1) DEFAULT NULL,
    p_vigente VARCHAR(1) DEFAULT NULL
)
RETURNS TABLE (
    id_giro INTEGER,
    cod_giro INTEGER,
    cod_anun CHAR(5),
    descripcion CHAR(96),
    caracteristicas CHAR(130),
    clasificacion CHAR(1),
    tipo CHAR(1),
    reglamentada CHAR(1),
    vigente CHAR(1),
    ctaaplic INTEGER,
    ctaaplic_rez INTEGER,
    total_count BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    RETURN QUERY
    WITH filtered_giros AS (
        SELECT
            g.id_giro,
            g.cod_giro,
            g.cod_anun,
            g.descripcion,
            g.caracteristicas,
            g.clasificacion,
            g.tipo,
            g.reglamentada,
            g.vigente,
            g.ctaaplic,
            g.ctaaplic_rez,
            COUNT(*) OVER() as total_count
        FROM comun.c_giros g
        WHERE 1=1
            AND (p_codigo IS NULL OR g.cod_giro::TEXT ILIKE '%' || p_codigo || '%')
            AND (p_descripcion IS NULL OR g.descripcion ILIKE '%' || p_descripcion || '%')
            AND (p_clasificacion IS NULL OR g.clasificacion = p_clasificacion)
            AND (p_tipo IS NULL OR g.tipo = p_tipo)
            AND (p_vigente IS NULL OR g.vigente = p_vigente)
        ORDER BY g.descripcion ASC
        LIMIT p_page_size
        OFFSET v_offset
    )
    SELECT * FROM filtered_giros;
END;
$$ LANGUAGE plpgsql STABLE;

-- 2. SP: sp_catalogogiros_get
CREATE OR REPLACE FUNCTION comun.sp_catalogogiros_get(
    p_id_giro INTEGER
)
RETURNS TABLE (
    id_giro INTEGER,
    cod_giro INTEGER,
    cod_anun CHAR(5),
    descripcion CHAR(96),
    caracteristicas CHAR(130),
    clasificacion CHAR(1),
    tipo CHAR(1),
    reglamentada CHAR(1),
    vigente CHAR(1),
    ctaaplic INTEGER,
    ctaaplic_rez INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        g.id_giro, g.cod_giro, g.cod_anun, g.descripcion, g.caracteristicas,
        g.clasificacion, g.tipo, g.reglamentada, g.vigente, g.ctaaplic, g.ctaaplic_rez
    FROM comun.c_giros g
    WHERE g.id_giro = p_id_giro;
END;
$$ LANGUAGE plpgsql STABLE;

-- 3. SP: sp_catalogogiros_create
-- CORREGIDO: parámetros obligatorios primero, luego opcionales
CREATE OR REPLACE FUNCTION comun.sp_catalogogiros_create(
    p_cod_giro INTEGER,
    p_descripcion VARCHAR(96),
    p_cod_anun VARCHAR(5) DEFAULT NULL,
    p_caracteristicas VARCHAR(130) DEFAULT NULL,
    p_clasificacion VARCHAR(1) DEFAULT 'B',
    p_tipo VARCHAR(1) DEFAULT 'L',
    p_reglamentada VARCHAR(1) DEFAULT 'N',
    p_ctaaplic INTEGER DEFAULT 216000000,
    p_vigente VARCHAR(1) DEFAULT 'V'
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    id_giro INTEGER
) AS $$
DECLARE
    v_id_giro INTEGER;
    v_cod_giro_existe BOOLEAN;
BEGIN
    SELECT EXISTS(SELECT 1 FROM comun.c_giros WHERE cod_giro = p_cod_giro) INTO v_cod_giro_existe;
    IF v_cod_giro_existe THEN
        RETURN QUERY SELECT FALSE, 'El código de giro ya existe', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_cod_giro IS NULL OR p_cod_giro <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El código de giro es requerido', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN
        RETURN QUERY SELECT FALSE, 'La descripción es requerida', NULL::INTEGER;
        RETURN;
    END IF;

    INSERT INTO comun.c_giros (
        cod_giro, cod_anun, descripcion, caracteristicas, clasificacion,
        tipo, reglamentada, vigente, ctaaplic, ctaaplic_rez
    ) VALUES (
        p_cod_giro, p_cod_anun, p_descripcion, p_caracteristicas, p_clasificacion,
        p_tipo, p_reglamentada, p_vigente, p_ctaaplic, p_ctaaplic + 1
    ) RETURNING c_giros.id_giro INTO v_id_giro;

    RETURN QUERY SELECT TRUE, 'Giro creado exitosamente con ID: ' || v_id_giro::TEXT, v_id_giro;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Error al crear el giro: ' || SQLERRM, NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- 4. SP: sp_catalogogiros_update
-- CORREGIDO: parámetros obligatorios primero, luego opcionales
CREATE OR REPLACE FUNCTION comun.sp_catalogogiros_update(
    p_id_giro INTEGER,
    p_cod_giro INTEGER,
    p_descripcion VARCHAR(96),
    p_clasificacion VARCHAR(1),
    p_tipo VARCHAR(1),
    p_reglamentada VARCHAR(1),
    p_vigente VARCHAR(1),
    p_cod_anun VARCHAR(5) DEFAULT NULL,
    p_caracteristicas VARCHAR(130) DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_giro_existe BOOLEAN;
    v_cod_giro_duplicado BOOLEAN;
BEGIN
    SELECT EXISTS(SELECT 1 FROM comun.c_giros WHERE id_giro = p_id_giro) INTO v_giro_existe;
    IF NOT v_giro_existe THEN
        RETURN QUERY SELECT FALSE, 'El giro no existe';
        RETURN;
    END IF;

    SELECT EXISTS(SELECT 1 FROM comun.c_giros WHERE cod_giro = p_cod_giro AND id_giro != p_id_giro) INTO v_cod_giro_duplicado;
    IF v_cod_giro_duplicado THEN
        RETURN QUERY SELECT FALSE, 'El código de giro ya existe en otro registro';
        RETURN;
    END IF;

    IF p_cod_giro IS NULL OR p_cod_giro <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El código de giro es requerido';
        RETURN;
    END IF;

    IF p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN
        RETURN QUERY SELECT FALSE, 'La descripción es requerida';
        RETURN;
    END IF;

    UPDATE comun.c_giros SET
        cod_giro = p_cod_giro,
        cod_anun = p_cod_anun,
        descripcion = p_descripcion,
        caracteristicas = p_caracteristicas,
        clasificacion = p_clasificacion,
        tipo = p_tipo,
        reglamentada = p_reglamentada,
        vigente = p_vigente
    WHERE id_giro = p_id_giro;

    RETURN QUERY SELECT TRUE, 'Giro actualizado exitosamente';

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Error al actualizar el giro: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- 5. SP: sp_catalogogiros_cambiar_vigencia
CREATE OR REPLACE FUNCTION comun.sp_catalogogiros_cambiar_vigencia(
    p_id_giro INTEGER,
    p_vigente VARCHAR(1)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_giro_existe BOOLEAN;
    v_descripcion VARCHAR(96);
BEGIN
    SELECT EXISTS(SELECT 1 FROM comun.c_giros WHERE id_giro = p_id_giro) INTO v_giro_existe;
    IF NOT v_giro_existe THEN
        RETURN QUERY SELECT FALSE, 'El giro no existe';
        RETURN;
    END IF;

    IF p_vigente NOT IN ('V', 'C') THEN
        RETURN QUERY SELECT FALSE, 'Vigencia inválida. Use V (Vigente) o C (Cancelado)';
        RETURN;
    END IF;

    SELECT descripcion INTO v_descripcion FROM comun.c_giros WHERE id_giro = p_id_giro;

    UPDATE comun.c_giros SET vigente = p_vigente WHERE id_giro = p_id_giro;

    RETURN QUERY SELECT
        TRUE,
        CASE
            WHEN p_vigente = 'V' THEN 'Giro "' || v_descripcion || '" reactivado exitosamente'
            ELSE 'Giro "' || v_descripcion || '" cancelado exitosamente'
        END;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Error al cambiar vigencia: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- 6. SP: sp_catalogogiros_estadisticas
CREATE OR REPLACE FUNCTION comun.sp_catalogogiros_estadisticas()
RETURNS TABLE (
    total_giros BIGINT,
    giros_vigentes BIGINT,
    giros_cancelados BIGINT,
    giros_licencias BIGINT,
    giros_anuncios BIGINT,
    giros_reglamentados BIGINT,
    clasificacion_a BIGINT,
    clasificacion_b BIGINT,
    clasificacion_c BIGINT,
    clasificacion_d BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*)::BIGINT as total_giros,
        COUNT(*) FILTER (WHERE vigente = 'V')::BIGINT as giros_vigentes,
        COUNT(*) FILTER (WHERE vigente = 'C')::BIGINT as giros_cancelados,
        COUNT(*) FILTER (WHERE tipo = 'L')::BIGINT as giros_licencias,
        COUNT(*) FILTER (WHERE tipo = 'A')::BIGINT as giros_anuncios,
        COUNT(*) FILTER (WHERE reglamentada = 'S')::BIGINT as giros_reglamentados,
        COUNT(*) FILTER (WHERE clasificacion = 'A')::BIGINT as clasificacion_a,
        COUNT(*) FILTER (WHERE clasificacion = 'B')::BIGINT as clasificacion_b,
        COUNT(*) FILTER (WHERE clasificacion = 'C')::BIGINT as clasificacion_c,
        COUNT(*) FILTER (WHERE clasificacion = 'D')::BIGINT as clasificacion_d
    FROM comun.c_giros;
END;
$$ LANGUAGE plpgsql STABLE;
