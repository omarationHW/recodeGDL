-- =============================================================================
-- STORED PROCEDURE: sp_insert_folio_adeudo
-- Base: estacionamiento_publico
-- Esquema: public
-- Descripción: Inserta un nuevo folio de adeudo en ta14_folios_adeudo
-- =============================================================================

DROP FUNCTION IF EXISTS public.sp_insert_folio_adeudo(integer, integer, date, varchar, integer, integer, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION public.sp_insert_folio_adeudo(
    p_axo INTEGER,
    p_folio INTEGER,
    p_fecha_folio DATE,
    p_placa VARCHAR,
    p_infraccion INTEGER,
    p_estado INTEGER,
    p_vigilante INTEGER,
    p_usu_inicial INTEGER,
    p_zona INTEGER,
    p_espacio INTEGER
) RETURNS TABLE(success boolean, message text) AS $func$
BEGIN
    -- Verificar si ya existe
    IF EXISTS (SELECT 1 FROM public.ta14_folios_adeudo WHERE axo = p_axo AND folio = p_folio) THEN
        RETURN QUERY SELECT false::boolean, 'El folio ' || p_folio || ' del año ' || p_axo || ' ya existe en el sistema';
        RETURN;
    END IF;

    -- Insertar nuevo folio
    INSERT INTO public.ta14_folios_adeudo (
        axo, folio, fecha_folio, placa, infraccion, estado, vigilante, fec_cap, usu_inicial, zona, espacio
    ) VALUES (
        p_axo::smallint, p_folio, p_fecha_folio, UPPER(TRIM(p_placa)), p_infraccion::smallint, p_estado::smallint, p_vigilante, CURRENT_DATE, p_usu_inicial, p_zona::smallint, p_espacio::smallint
    );

    RETURN QUERY SELECT true::boolean, 'Folio ' || p_folio || ' del año ' || p_axo || ' registrado correctamente';
EXCEPTION
    WHEN unique_violation THEN
        RETURN QUERY SELECT false::boolean, 'El folio ' || p_folio || ' del año ' || p_axo || ' ya existe (duplicado)';
    WHEN OTHERS THEN
        RETURN QUERY SELECT false::boolean, 'Error: ' || SQLERRM;
END;
$func$ LANGUAGE plpgsql;

-- =============================================================================
-- FIN STORED PROCEDURE
-- =============================================================================
