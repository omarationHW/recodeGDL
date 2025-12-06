-- ============================================
-- CORRECCIÓN SP: sp_pasomdos_insert_tianguis
-- Error: column reference "id_local" is ambiguous
-- Solución: Especificar alias de tabla en RETURNING
-- ============================================

\c padron_licencias;

CREATE OR REPLACE FUNCTION sp_pasomdos_insert_tianguis(
    p_folio INTEGER,
    p_nombre VARCHAR,
    p_domicilio VARCHAR,
    p_superficie NUMERIC,
    p_descuento NUMERIC,
    p_motivo_descuento VARCHAR,
    p_vigencia VARCHAR,
    p_id_usuario INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    id_local INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_local INTEGER;
    v_existe BOOLEAN;
BEGIN
    -- Verificar si el local ya existe
    SELECT EXISTS(
        SELECT 1
        FROM padron_licencias.comun.ta_11_locales
        WHERE oficina = 1
          AND num_mercado = 214
          AND local = p_folio
    ) INTO v_existe;

    IF v_existe THEN
        RETURN QUERY SELECT
            FALSE,
            'El local con folio ' || p_folio || ' ya existe'::TEXT,
            NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar el nuevo local
    BEGIN
        INSERT INTO padron_licencias.comun.ta_11_locales (
            oficina, num_mercado, categoria, seccion, local, letra_local, bloque,
            id_contribuy_prop, id_contribuy_renta, nombre, arrendatario, domicilio,
            sector, zona, descripcion_local, superficie, giro, fecha_alta, fecha_baja,
            fecha_modificacion, vigencia, id_usuario, clave_cuota, bloqueo
        ) VALUES (
            1, 214, 1, 'SS', p_folio, NULL, NULL,
            1, NULL, p_nombre, NULL, p_domicilio,
            'J', 5, NULL, p_superficie, 1, '2009-01-01'::DATE, NULL,
            CURRENT_TIMESTAMP, p_vigencia, p_id_usuario, 15, 0
        )
        RETURNING ta_11_locales.id_local INTO v_id_local;

        RETURN QUERY SELECT
            TRUE,
            'Local insertado correctamente'::TEXT,
            v_id_local;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT
                FALSE,
                'Error al insertar: ' || SQLERRM::TEXT,
                NULL::INTEGER;
    END;
END;
$$;
