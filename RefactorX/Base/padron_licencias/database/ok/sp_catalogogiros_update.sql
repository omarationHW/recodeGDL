-- =====================================================
-- SP: sp_catalogogiros_update
-- Descripción: Actualiza un giro existente
-- Esquema: comun
-- Tabla: comun.c_giros
-- Fecha: 2025-11-05
-- =====================================================

CREATE OR REPLACE FUNCTION comun.sp_catalogogiros_update(
    p_id_giro INTEGER,
    p_cod_giro INTEGER,
    p_cod_anun VARCHAR(5) DEFAULT NULL,
    p_descripcion VARCHAR(96),
    p_caracteristicas VARCHAR(130) DEFAULT NULL,
    p_clasificacion VARCHAR(1),
    p_tipo VARCHAR(1),
    p_reglamentada VARCHAR(1),
    p_vigente VARCHAR(1)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_giro_existe BOOLEAN;
    v_cod_giro_duplicado BOOLEAN;
BEGIN
    -- Validar que el giro exista
    SELECT EXISTS(
        SELECT 1 FROM comun.c_giros WHERE id_giro = p_id_giro
    ) INTO v_giro_existe;

    IF NOT v_giro_existe THEN
        RETURN QUERY SELECT FALSE, 'El giro no existe';
        RETURN;
    END IF;

    -- Validar que el cod_giro no esté duplicado (excepto el actual)
    SELECT EXISTS(
        SELECT 1 FROM comun.c_giros
        WHERE cod_giro = p_cod_giro
        AND id_giro != p_id_giro
    ) INTO v_cod_giro_duplicado;

    IF v_cod_giro_duplicado THEN
        RETURN QUERY SELECT FALSE, 'El código de giro ya existe en otro registro';
        RETURN;
    END IF;

    -- Validar campos obligatorios
    IF p_cod_giro IS NULL OR p_cod_giro <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El código de giro es requerido';
        RETURN;
    END IF;

    IF p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN
        RETURN QUERY SELECT FALSE, 'La descripción es requerida';
        RETURN;
    END IF;

    -- Actualizar el giro
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

    RETURN QUERY SELECT
        TRUE,
        'Giro actualizado exitosamente';

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE,
            'Error al actualizar el giro: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_catalogogiros_update IS 'Actualiza un giro existente';
