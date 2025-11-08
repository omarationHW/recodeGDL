-- =====================================================
-- SP: sp_catalogogiros_create
-- Descripción: Crea un nuevo giro en el catálogo
-- Esquema: comun
-- Tabla: comun.c_giros
-- Fecha: 2025-11-05
-- =====================================================

CREATE OR REPLACE FUNCTION comun.sp_catalogogiros_create(
    p_cod_giro INTEGER,
    p_cod_anun VARCHAR(5) DEFAULT NULL,
    p_descripcion VARCHAR(96),
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
    -- Validar que el cod_giro no exista
    SELECT EXISTS(
        SELECT 1 FROM comun.c_giros WHERE cod_giro = p_cod_giro
    ) INTO v_cod_giro_existe;

    IF v_cod_giro_existe THEN
        RETURN QUERY SELECT FALSE, 'El código de giro ya existe', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar campos obligatorios
    IF p_cod_giro IS NULL OR p_cod_giro <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El código de giro es requerido', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN
        RETURN QUERY SELECT FALSE, 'La descripción es requerida', NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar el nuevo giro
    INSERT INTO comun.c_giros (
        cod_giro,
        cod_anun,
        descripcion,
        caracteristicas,
        clasificacion,
        tipo,
        reglamentada,
        vigente,
        ctaaplic,
        ctaaplic_rez
    ) VALUES (
        p_cod_giro,
        p_cod_anun,
        p_descripcion,
        p_caracteristicas,
        p_clasificacion,
        p_tipo,
        p_reglamentada,
        p_vigente,
        p_ctaaplic,
        p_ctaaplic + 1  -- ctaaplic_rez = ctaaplic + 1
    )
    RETURNING id_giro INTO v_id_giro;

    RETURN QUERY SELECT
        TRUE,
        'Giro creado exitosamente con ID: ' || v_id_giro::TEXT,
        v_id_giro;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE,
            'Error al crear el giro: ' || SQLERRM,
            NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_catalogogiros_create IS 'Crea un nuevo giro en el catálogo';
