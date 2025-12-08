-- =============================================================================
-- STORED PROCEDURE: sp_afec_esta01
-- Base: estacionamiento_publico
-- Esquema: public
-- Formulario: Cga_ArcEdoEx / CargaEdoExPublicos.vue
-- Descripcion: Aplica/afecta la remesa por fecha
-- =============================================================================

DROP FUNCTION IF EXISTS public.sp_afec_esta01(date);

CREATE OR REPLACE FUNCTION public.sp_afec_esta01(
    p_fecha DATE
) RETURNS TABLE(success boolean, message text) AS $func$
DECLARE
    v_affected INTEGER;
BEGIN
    -- Validar fecha requerida
    IF p_fecha IS NULL THEN
        RETURN QUERY SELECT false::boolean, 'La fecha es requerida'::text;
        RETURN;
    END IF;

    -- Afectar registros de la remesa
    UPDATE public.ta14_datos_edo
    SET teso_cve = 'AFECTADO'
    WHERE fecharemesa = p_fecha
      AND (teso_cve IS NULL OR teso_cve = '');

    GET DIAGNOSTICS v_affected = ROW_COUNT;

    IF v_affected > 0 THEN
        RETURN QUERY SELECT true::boolean, ('Remesa afectada correctamente. Registros actualizados: ' || v_affected)::text;
    ELSE
        RETURN QUERY SELECT true::boolean, 'No se encontraron registros pendientes para afectar en la fecha indicada'::text;
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false::boolean, ('Error al afectar remesa: ' || SQLERRM)::text;
END;
$func$ LANGUAGE plpgsql;

-- =============================================================================
-- FIN STORED PROCEDURE
-- =============================================================================
