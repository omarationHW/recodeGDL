-- =============================================================================
-- STORED PROCEDURE: sp_insert_ta14_datos_edo
-- Base: estacionamiento_publico
-- Esquema: public
-- Formulario: Cga_ArcEdoEx / CargaEdoExPublicos.vue
-- Descripcion: Inserta un registro en ta14_datos_edo para la carga de pagos
-- =============================================================================

DROP FUNCTION IF EXISTS public.sp_insert_ta14_datos_edo(integer, varchar, integer, varchar, date, numeric, date, varchar, date);

CREATE OR REPLACE FUNCTION public.sp_insert_ta14_datos_edo(
    p_mpio INTEGER,
    p_tipoact VARCHAR,
    p_folio INTEGER,
    p_placa VARCHAR,
    p_fecpago DATE,
    p_importe NUMERIC,
    p_fecalta DATE,
    p_remesa VARCHAR,
    p_fecremesa DATE
) RETURNS TABLE(success boolean, message text) AS $func$
BEGIN
    -- Validar folio requerido
    IF p_folio IS NULL OR p_folio <= 0 THEN
        RETURN QUERY SELECT false::boolean, 'El folio es requerido y debe ser mayor a 0'::text;
        RETURN;
    END IF;

    -- Validar placa requerida
    IF p_placa IS NULL OR TRIM(p_placa) = '' THEN
        RETURN QUERY SELECT false::boolean, 'La placa es requerida'::text;
        RETURN;
    END IF;

    -- Insertar registro con nombres de columna correctos
    INSERT INTO public.ta14_datos_edo (
        idrmunicipio,
        tipoact,
        folio,
        placa,
        fechapago,
        importe,
        fechaalta,
        remesa,
        fecharemesa
    ) VALUES (
        COALESCE(p_mpio, 0),
        COALESCE(p_tipoact, ''),
        p_folio,
        UPPER(TRIM(p_placa)),
        p_fecpago,
        COALESCE(p_importe, 0),
        COALESCE(p_fecalta, CURRENT_DATE),
        COALESCE(p_remesa, ''),
        p_fecremesa
    );

    RETURN QUERY SELECT true::boolean, ('Registro insertado correctamente. Folio: ' || p_folio || ', Placa: ' || p_placa)::text;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false::boolean, ('Error al insertar: ' || SQLERRM)::text;
END;
$func$ LANGUAGE plpgsql;

-- =============================================================================
-- FIN STORED PROCEDURE
-- =============================================================================
