-- =====================================================
-- SP: sp_catalogogiros_cambiar_vigencia
-- Descripción: Cambia la vigencia de un giro (V/C)
-- Esquema: comun
-- Tabla: comun.c_giros
-- Fecha: 2025-11-05
-- =====================================================

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
    -- Validar que el giro exista
    SELECT EXISTS(
        SELECT 1 FROM comun.c_giros WHERE id_giro = p_id_giro
    ) INTO v_giro_existe;

    IF NOT v_giro_existe THEN
        RETURN QUERY SELECT FALSE, 'El giro no existe';
        RETURN;
    END IF;

    -- Validar parámetro vigente
    IF p_vigente NOT IN ('V', 'C') THEN
        RETURN QUERY SELECT FALSE, 'Vigencia inválida. Use V (Vigente) o C (Cancelado)';
        RETURN;
    END IF;

    -- Obtener descripción para el mensaje
    SELECT descripcion INTO v_descripcion
    FROM comun.c_giros
    WHERE id_giro = p_id_giro;

    -- Actualizar vigencia
    UPDATE comun.c_giros
    SET vigente = p_vigente
    WHERE id_giro = p_id_giro;

    RETURN QUERY SELECT
        TRUE,
        CASE
            WHEN p_vigente = 'V' THEN 'Giro "' || v_descripcion || '" reactivado exitosamente'
            ELSE 'Giro "' || v_descripcion || '" cancelado exitosamente'
        END;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE,
            'Error al cambiar vigencia: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_catalogogiros_cambiar_vigencia IS 'Cambia la vigencia de un giro';
