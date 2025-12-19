-- =====================================================
-- Stored Procedure: recaudadora_reqtrans_update
-- Base de Datos: multas_reglamentos
-- Esquema: publico
-- Descripción: Actualizar requerimiento de diferencias de transmisión
--              Modifica un registro existente en la tabla reqdiftransmision
-- =====================================================

-- Eliminar función si existe
DROP FUNCTION IF EXISTS publico.recaudadora_reqtrans_update(JSON);

-- Crear función
CREATE OR REPLACE FUNCTION publico.recaudadora_reqtrans_update(
    p_registro JSON
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    v_cvereq INTEGER;
    v_clave_cuenta TEXT;
    v_folio INTEGER;
    v_ejercicio INTEGER;
    v_estatus TEXT;
    v_vigencia VARCHAR(1);
    v_rows_affected INTEGER;
    v_impuesto NUMERIC;
    v_recargos NUMERIC;
    v_multa NUMERIC;
    v_gastos NUMERIC;
    v_total NUMERIC;
BEGIN
    -- Extraer datos del JSON
    v_clave_cuenta := p_registro->>'clave_cuenta';
    v_folio := COALESCE((p_registro->>'folio')::INTEGER, 0);
    v_ejercicio := COALESCE((p_registro->>'ejercicio')::INTEGER, 0);
    v_estatus := COALESCE(p_registro->>'estatus', 'Vigente');

    -- Extraer importes (opcionales)
    v_impuesto := COALESCE((p_registro->>'impuesto')::NUMERIC, 0);
    v_recargos := COALESCE((p_registro->>'recargos')::NUMERIC, 0);
    v_multa := COALESCE((p_registro->>'multa')::NUMERIC, 0);
    v_gastos := COALESCE((p_registro->>'gastos')::NUMERIC, 0);
    v_total := v_impuesto + v_recargos + v_multa + v_gastos;

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
    IF NOT EXISTS (SELECT 1 FROM public.reqdiftransmision WHERE cvereq = v_cvereq) THEN
        RETURN json_build_object(
            'success', false,
            'message', 'No se encontró el registro con ID ' || v_cvereq::TEXT
        );
    END IF;

    -- Convertir estatus a vigencia
    v_vigencia := CASE
        WHEN v_estatus = 'Vigente' THEN 'V'
        WHEN v_estatus = 'Cancelado' THEN 'C'
        WHEN v_estatus = 'Pendiente' THEN 'P'
        WHEN v_estatus = 'Activo' THEN '1'
        WHEN v_estatus = 'Inactivo' THEN '0'
        ELSE 'V'
    END;

    -- Actualizar el registro usando cvereq (ID único)
    UPDATE public.reqdiftransmision
    SET
        cvecuenta = v_clave_cuenta::INTEGER,
        foliotransm = v_folio,
        axoreq = v_ejercicio,
        vigencia = v_vigencia,
        impuesto = v_impuesto,
        recargos = v_recargos,
        multa = v_multa,
        gastos = v_gastos,
        gastos_req = v_gastos,
        total = v_total
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
$$;

-- Comentario de la función
COMMENT ON FUNCTION publico.recaudadora_reqtrans_update(JSON) IS
'Actualizar requerimiento de diferencias de transmisión existente.
Modifica un registro en la tabla public.reqdiftransmision.
Parámetro JSON con campos:
  - cvereq: INTEGER (requerido) - ID del registro a actualizar
  - clave_cuenta: VARCHAR (opcional) - Cuenta del contribuyente
  - folio: INTEGER (opcional) - Folio de transmisión
  - ejercicio: INTEGER (opcional) - Año del requerimiento
  - estatus: TEXT (opcional) - Estatus
  - impuesto: NUMERIC (opcional) - Importe impuesto
  - recargos: NUMERIC (opcional) - Importe recargos
  - multa: NUMERIC (opcional) - Importe multa
  - gastos: NUMERIC (opcional) - Importe gastos
Retorna JSON con success, message, cvereq y rows_affected.';

-- Otorgar permisos
GRANT EXECUTE ON FUNCTION publico.recaudadora_reqtrans_update(JSON) TO refact;
GRANT EXECUTE ON FUNCTION publico.recaudadora_reqtrans_update(JSON) TO PUBLIC;
