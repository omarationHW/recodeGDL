-- ============================================
-- STORED PROCEDURES PARA ActualizaFechaEmpresas
-- Modulo: multas_reglamentos
-- Fecha: 2025-11-25
-- ============================================

-- SP 1: actualizafechaempresas_sp_get_ejecutores
-- Obtiene la lista de ejecutores disponibles
-- --------------------------------------------
DROP FUNCTION IF EXISTS actualizafechaempresas_sp_get_ejecutores();

CREATE OR REPLACE FUNCTION actualizafechaempresas_sp_get_ejecutores()
RETURNS TABLE(
    cveejecutor INTEGER,
    empresa TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.cveejecutor,
        TRIM(COALESCE(e.paterno, '')) || ' ' || TRIM(COALESCE(e.materno, '')) || ' ' || TRIM(COALESCE(e.nombres, '')) AS empresa
    FROM ejecutor e
    WHERE COALESCE(e.vigencia, 'V') = 'V'
    ORDER BY e.paterno, e.materno, e.nombres;
END;
$$ LANGUAGE plpgsql;

-- SP 2: actualizafechaempresas_sp_actualizar_fecha
-- Actualiza la fecha de practica de un folio individual
-- --------------------------------------------
CREATE OR REPLACE FUNCTION actualizafechaempresas_sp_actualizar_fecha(
    p_params JSONB
)
RETURNS JSONB AS $$
DECLARE
    v_clave_cuenta INTEGER;
    v_folio INTEGER;
    v_anio INTEGER;
    v_fecha_practica DATE;
    v_rows_affected INTEGER;
BEGIN
    -- Extraer parametros
    v_clave_cuenta := (p_params->>'clave_cuenta')::INTEGER;
    v_folio := (p_params->>'folio')::INTEGER;
    v_anio := (p_params->>'anio')::INTEGER;
    v_fecha_practica := (p_params->>'fecha_practica')::DATE;

    -- Actualizar fecha de practica
    UPDATE reqpredial
    SET fecent = v_fecha_practica
    WHERE cvecuenta = v_clave_cuenta
      AND folio = v_folio
      AND anio = v_anio;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    IF v_rows_affected > 0 THEN
        RETURN jsonb_build_object(
            'aplicados', v_rows_affected,
            'mensaje', 'Fecha actualizada correctamente'
        );
    ELSE
        RETURN jsonb_build_object(
            'aplicados', 0,
            'mensaje', 'No se encontro el folio especificado'
        );
    END IF;
END;
$$ LANGUAGE plpgsql;

-- SP 3: actualizafechaempresas_sp_actualizar_batch
-- Actualiza la fecha de practica de multiples folios
-- --------------------------------------------
CREATE OR REPLACE FUNCTION actualizafechaempresas_sp_actualizar_batch(
    p_params JSONB
)
RETURNS JSONB AS $$
DECLARE
    v_fecha_practica DATE;
    v_ejecutor INTEGER;
    v_folios JSONB;
    v_folio JSONB;
    v_aplicados INTEGER := 0;
    v_errores JSONB := '[]'::JSONB;
    v_rows_affected INTEGER;
BEGIN
    -- Extraer parametros
    v_fecha_practica := (p_params->>'fecha_practica')::DATE;
    v_ejecutor := COALESCE((p_params->>'ejecutor')::INTEGER, 0);
    v_folios := (p_params->>'folios_json')::JSONB;

    -- Iterar sobre cada folio
    FOR v_folio IN SELECT * FROM jsonb_array_elements(v_folios)
    LOOP
        BEGIN
            UPDATE reqpredial
            SET fecent = v_fecha_practica
            WHERE cvecuenta = (v_folio->>'clave_cuenta')::INTEGER
              AND folio = (v_folio->>'folio')::INTEGER
              AND anio = (v_folio->>'anio_folio')::INTEGER;

            GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

            IF v_rows_affected > 0 THEN
                v_aplicados := v_aplicados + 1;
            ELSE
                v_errores := v_errores || jsonb_build_object(
                    'folio', v_folio->>'folio',
                    'clave_cuenta', v_folio->>'clave_cuenta',
                    'anio_folio', v_folio->>'anio_folio',
                    'error', 'Folio no encontrado'
                );
            END IF;
        EXCEPTION WHEN OTHERS THEN
            v_errores := v_errores || jsonb_build_object(
                'folio', v_folio->>'folio',
                'clave_cuenta', v_folio->>'clave_cuenta',
                'anio_folio', v_folio->>'anio_folio',
                'error', SQLERRM
            );
        END;
    END LOOP;

    RETURN jsonb_build_object(
        'aplicados', v_aplicados,
        'errores', v_errores
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIN DE STORED PROCEDURES
-- ============================================
