-- Fix para sp_catalogogiros_update
-- Solo validar duplicados si el código está siendo cambiado

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
    v_cod_giro_actual INTEGER;
    v_cod_giro_duplicado BOOLEAN;
BEGIN
    -- Verificar que el giro existe y obtener el código actual
    SELECT EXISTS(SELECT 1 FROM comun.c_giros WHERE id_giro = p_id_giro) INTO v_giro_existe;
    IF NOT v_giro_existe THEN
        RETURN QUERY SELECT FALSE, 'El giro no existe';
        RETURN;
    END IF;

    -- Obtener el código actual del giro
    SELECT cod_giro INTO v_cod_giro_actual FROM comun.c_giros WHERE id_giro = p_id_giro;

    -- Solo validar duplicados si el código está siendo cambiado
    IF v_cod_giro_actual != p_cod_giro THEN
        SELECT EXISTS(SELECT 1 FROM comun.c_giros WHERE cod_giro = p_cod_giro AND id_giro != p_id_giro) INTO v_cod_giro_duplicado;
        IF v_cod_giro_duplicado THEN
            RETURN QUERY SELECT FALSE, 'El código de giro ya existe en otro registro. Si desea mantener el mismo código, no lo modifique.';
            RETURN;
        END IF;
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
