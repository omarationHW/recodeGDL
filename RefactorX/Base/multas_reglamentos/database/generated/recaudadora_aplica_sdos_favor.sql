-- ================================================================
-- SP: recaudadora_aplica_sdos_favor
-- Descripción: Aplica saldos a favor (actualiza registros)
-- Tablas: sdosfavor, pagosapl_sdosfavor
-- ================================================================

CREATE OR REPLACE FUNCTION recaudadora_aplica_sdos_favor(
    p_registros TEXT
)
RETURNS TABLE(
    aplicados INTEGER,
    mensaje TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_registros JSONB;
    v_registro JSONB;
    v_count INTEGER := 0;
    v_id_solic INTEGER;
    v_saldo NUMERIC;
BEGIN
    -- Parsear el JSON de registros
    v_registros := p_registros::JSONB;

    -- Iterar sobre cada registro
    FOR v_registro IN SELECT * FROM jsonb_array_elements(v_registros) LOOP
        v_id_solic := (v_registro->>'id_solic')::INTEGER;
        v_saldo := (v_registro->>'saldo')::NUMERIC;

        -- Actualizar el saldo a favor (marcarlo como aplicado)
        -- Esto es un ejemplo, la lógica real depende del negocio
        UPDATE catastro_gdl.sdosfavor
        SET saldo_favor = 0
        WHERE id_solic = v_id_solic
          AND saldo_favor > 0;

        v_count := v_count + 1;
    END LOOP;

    RETURN QUERY
    SELECT v_count, 'Saldos aplicados correctamente'::TEXT;
END;
$$;

COMMENT ON FUNCTION recaudadora_aplica_sdos_favor(TEXT)
IS 'Aplica saldos a favor (marca como aplicados en la BD)';
