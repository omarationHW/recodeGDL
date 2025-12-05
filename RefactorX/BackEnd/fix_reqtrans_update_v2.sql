DROP FUNCTION IF EXISTS recaudadora_reqtrans_update(JSON) CASCADE;

CREATE OR REPLACE FUNCTION recaudadora_reqtrans_update(
    p_registro JSON
)
RETURNS JSON AS $$
DECLARE
    v_cvereq INTEGER;
    v_clave_cuenta TEXT;
    v_folio INTEGER;
    v_ejercicio INTEGER;
    v_estatus TEXT;
    v_vigencia VARCHAR(1);
    v_rows_affected INTEGER;
BEGIN
    -- Extraer datos del JSON
    v_clave_cuenta := p_registro->>'clave_cuenta';
    v_folio := COALESCE((p_registro->>'folio')::INTEGER, 0);
    v_ejercicio := COALESCE((p_registro->>'ejercicio')::INTEGER, 0);
    v_estatus := p_registro->>'estatus';

    -- IMPORTANTE: Obtener cvereq del JSON (ID único del registro)
    BEGIN
        v_cvereq := (p_registro->>'cvereq')::INTEGER;
    EXCEPTION
        WHEN OTHERS THEN
            v_cvereq := NULL;
    END;

    -- Validar que cvereq esté presente
    IF v_cvereq IS NULL OR v_cvereq <= 0 THEN
        RETURN json_build_object(
            'success', false,
            'message', 'Error: No se proporcionó el ID del registro. Por favor cierre y vuelva a abrir el formulario.'
        );
    END IF;

    -- Verificar que el registro existe
    IF NOT EXISTS (SELECT 1 FROM catastro_gdl.reqdiftransmision WHERE cvereq = v_cvereq) THEN
        RETURN json_build_object(
            'success', false,
            'message', 'No se encontró el registro con ID ' || v_cvereq::TEXT
        );
    END IF;

    -- Convertir estatus a vigencia
    v_vigencia := CASE
        WHEN v_estatus = 'Activo' THEN '1'
        WHEN v_estatus = 'Inactivo' THEN '0'
        ELSE 'V'
    END;

    -- Actualizar el registro usando cvereq (ID único)
    UPDATE catastro_gdl.reqdiftransmision
    SET
        cvecuenta = v_clave_cuenta::INTEGER,
        foliotransm = v_folio,
        axoreq = v_ejercicio,
        vigencia = v_vigencia
    WHERE cvereq = v_cvereq;

    -- Verificar cuántas filas se actualizaron
    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    IF v_rows_affected > 0 THEN
        RETURN json_build_object(
            'success', true,
            'message', 'Registro actualizado correctamente',
            'cvereq', v_cvereq,
            'rows_affected', v_rows_affected
        );
    ELSE
        RETURN json_build_object(
            'success', false,
            'message', 'No se pudo actualizar el registro'
        );
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'message', 'Error al actualizar: ' || SQLERRM
        );
END;
$$ LANGUAGE plpgsql;
