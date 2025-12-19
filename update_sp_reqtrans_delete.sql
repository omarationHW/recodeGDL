-- =====================================================
-- Stored Procedure: recaudadora_reqtrans_delete
-- Base de Datos: multas_reglamentos
-- Esquema: publico
-- Descripción: Eliminar requerimiento de diferencias de transmisión
--              Borra un registro de la tabla reqdiftransmision
-- =====================================================

-- Eliminar función si existe
DROP FUNCTION IF EXISTS publico.recaudadora_reqtrans_delete(JSON);

-- Crear función
CREATE OR REPLACE FUNCTION publico.recaudadora_reqtrans_delete(
    p_registro JSON
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    v_cvereq INTEGER;
    v_clave_cuenta TEXT;
    v_ejercicio INTEGER;
    v_rows_affected INTEGER;
BEGIN
    -- Extraer cvereq del JSON (ID único del registro)
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
            'message', 'Error: No se proporcionó el ID del registro. Por favor recargue la página.'
        );
    END IF;

    -- Verificar que el registro existe antes de eliminar
    IF NOT EXISTS (SELECT 1 FROM public.reqdiftransmision WHERE cvereq = v_cvereq) THEN
        RETURN json_build_object(
            'success', false,
            'message', 'El registro no existe o ya fue eliminado'
        );
    END IF;

    -- Guardar datos para el mensaje de confirmación
    SELECT cvecuenta::TEXT, axoreq
    INTO v_clave_cuenta, v_ejercicio
    FROM public.reqdiftransmision
    WHERE cvereq = v_cvereq;

    -- Eliminar el registro usando cvereq (ID único)
    DELETE FROM public.reqdiftransmision
    WHERE cvereq = v_cvereq;

    -- Verificar cuántas filas se eliminaron
    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    IF v_rows_affected > 0 THEN
        RETURN json_build_object(
            'success', true,
            'message', 'Registro eliminado correctamente',
            'cvereq', v_cvereq,
            'clave_cuenta', v_clave_cuenta,
            'ejercicio', v_ejercicio,
            'rows_affected', v_rows_affected
        );
    ELSE
        RETURN json_build_object(
            'success', false,
            'message', 'No se pudo eliminar el registro'
        );
    END IF;

EXCEPTION
    WHEN foreign_key_violation THEN
        RETURN json_build_object(
            'success', false,
            'message', 'No se puede eliminar: El registro está siendo usado por otros registros'
        );
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'message', 'Error al eliminar: ' || SQLERRM
        );
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION publico.recaudadora_reqtrans_delete(JSON) IS
'Eliminar requerimiento de diferencias de transmisión.
Borra un registro de la tabla public.reqdiftransmision.
Parámetro JSON con campos:
  - cvereq: INTEGER (requerido) - ID del registro a eliminar
Retorna JSON con:
  - success: BOOLEAN - true si se eliminó, false si hubo error
  - message: TEXT - Mensaje descriptivo
  - cvereq: INTEGER - ID eliminado (si success)
  - clave_cuenta: TEXT - Cuenta eliminada (si success)
  - ejercicio: INTEGER - Ejercicio eliminado (si success)
  - rows_affected: INTEGER - Filas afectadas (si success)
Maneja excepciones de foreign key y otros errores.';

-- Otorgar permisos
GRANT EXECUTE ON FUNCTION publico.recaudadora_reqtrans_delete(JSON) TO refact;
GRANT EXECUTE ON FUNCTION publico.recaudadora_reqtrans_delete(JSON) TO PUBLIC;
