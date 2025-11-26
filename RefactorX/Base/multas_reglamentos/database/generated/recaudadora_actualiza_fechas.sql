-- ================================================================
-- SP: recaudadora_actualiza_fechas
-- Descripción: Actualiza fecha de práctica de folios (individual o lote)
-- Tabla: catastro_gdl.reqdiftransmision
-- Parámetros:
--   - p_clave_cuenta: Clave de cuenta (opcional si se usa folios_json)
--   - p_folio: Número de folio (opcional si se usa folios_json)
--   - p_anio_folio: Año del folio (opcional si se usa folios_json)
--   - p_fecha_practica: Fecha de práctica a aplicar (requerido)
--   - p_ejecutor: Ejecutor (opcional)
--   - p_folios_json: JSON con array de folios para actualización en lote (opcional)
-- ================================================================

CREATE OR REPLACE FUNCTION recaudadora_actualiza_fechas(
    p_clave_cuenta VARCHAR DEFAULT NULL,
    p_folio INTEGER DEFAULT NULL,
    p_anio_folio INTEGER DEFAULT NULL,
    p_fecha_practica DATE DEFAULT NULL,
    p_ejecutor INTEGER DEFAULT NULL,
    p_folios_json TEXT DEFAULT NULL
)
RETURNS TABLE(
    aplicados INTEGER,
    errores JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_aplicados INTEGER := 0;
    v_errores JSONB := '[]'::JSONB;
    v_folios JSONB;
    v_folio JSONB;
    v_cvecuenta VARCHAR;
    v_folio_num INTEGER;
    v_anio INTEGER;
    v_rows_affected INTEGER;
BEGIN
    -- Validar que se proporcionó fecha de práctica
    IF p_fecha_practica IS NULL THEN
        v_errores := v_errores || jsonb_build_object(
            'error', 'Fecha de práctica es requerida',
            'folio', NULL,
            'clave_cuenta', NULL,
            'anio_folio', NULL
        );
        RETURN QUERY SELECT 0, v_errores;
        RETURN;
    END IF;

    -- Modo 1: Actualización en lote (JSON)
    IF p_folios_json IS NOT NULL AND p_folios_json != '' THEN
        BEGIN
            v_folios := p_folios_json::JSONB;

            -- Iterar sobre cada folio en el JSON
            FOR v_folio IN SELECT * FROM jsonb_array_elements(v_folios) LOOP
                BEGIN
                    v_cvecuenta := v_folio->>'clave_cuenta';
                    v_folio_num := (v_folio->>'folio')::INTEGER;
                    v_anio := (v_folio->>'anio_folio')::INTEGER;

                    -- Actualizar directamente en reqdiftransmision
                    UPDATE catastro_gdl.reqdiftransmision
                    SET fecprac = p_fecha_practica,
                        cveejecut = COALESCE(p_ejecutor, cveejecut),
                        fecentejec = CASE WHEN p_ejecutor IS NOT NULL THEN p_fecha_practica ELSE fecentejec END
                    WHERE cvecuenta::TEXT = v_cvecuenta
                      AND folioreq = v_folio_num
                      AND axoreq = v_anio;

                    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

                    IF v_rows_affected > 0 THEN
                        v_aplicados := v_aplicados + v_rows_affected;
                    ELSE
                        v_errores := v_errores || jsonb_build_object(
                            'error', 'Folio no encontrado en reqdiftransmision',
                            'folio', v_folio_num,
                            'clave_cuenta', v_cvecuenta,
                            'anio_folio', v_anio
                        );
                    END IF;
                EXCEPTION WHEN OTHERS THEN
                    v_errores := v_errores || jsonb_build_object(
                        'error', SQLERRM,
                        'folio', v_folio_num,
                        'clave_cuenta', v_cvecuenta,
                        'anio_folio', v_anio
                    );
                END;
            END LOOP;
        EXCEPTION WHEN OTHERS THEN
            v_errores := v_errores || jsonb_build_object(
                'error', 'Error procesando JSON: ' || SQLERRM,
                'folio', NULL,
                'clave_cuenta', NULL,
                'anio_folio', NULL
            );
        END;

    -- Modo 2: Actualización individual
    ELSIF p_clave_cuenta IS NOT NULL AND p_folio IS NOT NULL AND p_anio_folio IS NOT NULL THEN
        BEGIN
            -- Actualizar directamente en reqdiftransmision
            UPDATE catastro_gdl.reqdiftransmision
            SET fecprac = p_fecha_practica,
                cveejecut = COALESCE(p_ejecutor, cveejecut),
                fecentejec = CASE WHEN p_ejecutor IS NOT NULL THEN p_fecha_practica ELSE fecentejec END
            WHERE cvecuenta::TEXT = p_clave_cuenta
              AND folioreq = p_folio
              AND axoreq = p_anio_folio;

            GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

            IF v_rows_affected > 0 THEN
                v_aplicados := v_rows_affected;
            ELSE
                v_errores := v_errores || jsonb_build_object(
                    'error', 'Folio no encontrado en reqdiftransmision',
                    'folio', p_folio,
                    'clave_cuenta', p_clave_cuenta,
                    'anio_folio', p_anio_folio
                );
            END IF;
        EXCEPTION WHEN OTHERS THEN
            v_errores := v_errores || jsonb_build_object(
                'error', SQLERRM,
                'folio', p_folio,
                'clave_cuenta', p_clave_cuenta,
                'anio_folio', p_anio_folio
            );
        END;
    ELSE
        v_errores := v_errores || jsonb_build_object(
            'error', 'Debe proporcionar clave_cuenta, folio y anio_folio, o folios_json',
            'folio', NULL,
            'clave_cuenta', NULL,
            'anio_folio', NULL
        );
    END IF;

    RETURN QUERY SELECT v_aplicados, v_errores;
END;
$$;

COMMENT ON FUNCTION recaudadora_actualiza_fechas(VARCHAR, INTEGER, INTEGER, DATE, INTEGER, TEXT)
IS 'Actualiza fecha de práctica (fecprac) de folios en reqdiftransmision (individual o lote)';
