-- =====================================================
-- Stored Procedure: recaudadora_reqtrans_create
-- Base de Datos: multas_reglamentos
-- Esquema: publico
-- Descripción: Crear nuevo requerimiento de diferencias de transmisión
--              Inserta un nuevo registro en la tabla reqdiftransmision
-- =====================================================

-- Eliminar función si existe
DROP FUNCTION IF EXISTS publico.recaudadora_reqtrans_create(JSON);

-- Crear función
CREATE OR REPLACE FUNCTION publico.recaudadora_reqtrans_create(
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
    v_max_cvereq INTEGER;
    v_recaud INTEGER;
    v_impuesto NUMERIC;
    v_recargos NUMERIC;
    v_multa NUMERIC;
    v_gastos NUMERIC;
    v_total NUMERIC;
BEGIN
    -- Extraer datos del JSON
    v_clave_cuenta := p_registro->>'clave_cuenta';
    v_folio := COALESCE((p_registro->>'folio')::INTEGER, 0);
    v_ejercicio := COALESCE((p_registro->>'ejercicio')::INTEGER, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER);
    v_estatus := COALESCE(p_registro->>'estatus', 'Vigente');
    v_recaud := COALESCE((p_registro->>'recaud')::INTEGER, 1);

    -- Extraer importes (opcionales)
    v_impuesto := COALESCE((p_registro->>'impuesto')::NUMERIC, 0);
    v_recargos := COALESCE((p_registro->>'recargos')::NUMERIC, 0);
    v_multa := COALESCE((p_registro->>'multa')::NUMERIC, 0);
    v_gastos := COALESCE((p_registro->>'gastos')::NUMERIC, 0);
    v_total := v_impuesto + v_recargos + v_multa + v_gastos;

    -- Validar datos requeridos
    IF v_clave_cuenta IS NULL OR v_clave_cuenta = '' THEN
        RETURN json_build_object(
            'success', false,
            'message', 'La cuenta es requerida'
        );
    END IF;

    -- Verificar si ya existe un registro con la misma cuenta y ejercicio
    SELECT COUNT(*) INTO v_max_cvereq
    FROM public.reqdiftransmision
    WHERE cvecuenta::TEXT = v_clave_cuenta
      AND axoreq = v_ejercicio;

    IF v_max_cvereq > 0 THEN
        RETURN json_build_object(
            'success', false,
            'message', 'Ya existe un requerimiento para esta cuenta en el año ' || v_ejercicio::TEXT
        );
    END IF;

    -- Generar nuevo cvereq (MAX + 1)
    SELECT COALESCE(MAX(cvereq), 0) + 1 INTO v_cvereq
    FROM public.reqdiftransmision;

    -- Convertir estatus a vigencia
    v_vigencia := CASE
        WHEN v_estatus = 'Vigente' THEN 'V'
        WHEN v_estatus = 'Cancelado' THEN 'C'
        WHEN v_estatus = 'Pendiente' THEN 'P'
        WHEN v_estatus = 'Activo' THEN '1'
        WHEN v_estatus = 'Inactivo' THEN '0'
        ELSE 'V'
    END;

    -- Insertar el nuevo registro
    INSERT INTO public.reqdiftransmision (
        cvereq,
        recaud,
        axoreq,
        folioreq,
        cveproceso,
        cvecuenta,
        foliotransm,
        impuesto,
        recargos,
        multa_imp,
        multa_ext,
        actualizacion,
        gastos,
        multa,
        gastos_req,
        total,
        zona,
        subzona,
        vigencia,
        fecemi,
        feccap,
        capturista
    ) VALUES (
        v_cvereq,
        v_recaud,
        v_ejercicio,
        v_cvereq,  -- folioreq = cvereq por defecto
        'N',       -- cveproceso = 'N' (Nuevo)
        v_clave_cuenta::INTEGER,
        v_folio,
        v_impuesto,
        v_recargos,
        0,         -- multa_imp
        0,         -- multa_ext
        0,         -- actualizacion
        v_gastos,
        v_multa,
        v_gastos,  -- gastos_req = gastos
        v_total,
        0,         -- zona
        0,         -- subzona
        v_vigencia,
        CURRENT_DATE,
        CURRENT_DATE,
        'SYSTEM'   -- capturista
    );

    RETURN json_build_object(
        'success', true,
        'message', 'Registro creado correctamente',
        'cvereq', v_cvereq
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'message', 'Error al crear el registro: ' || SQLERRM
        );
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION publico.recaudadora_reqtrans_create(JSON) IS
'Crear nuevo requerimiento de diferencias de transmisión.
Inserta un nuevo registro en la tabla public.reqdiftransmision.
Parámetro JSON con campos:
  - clave_cuenta: VARCHAR (requerido) - Cuenta del contribuyente
  - folio: INTEGER (opcional) - Folio de transmisión (default: 0)
  - ejercicio: INTEGER (opcional) - Año del requerimiento (default: año actual)
  - estatus: TEXT (opcional) - Estatus (default: Vigente)
  - recaud: INTEGER (opcional) - Recaudación (default: 1)
  - impuesto: NUMERIC (opcional) - Importe impuesto (default: 0)
  - recargos: NUMERIC (opcional) - Importe recargos (default: 0)
  - multa: NUMERIC (opcional) - Importe multa (default: 0)
  - gastos: NUMERIC (opcional) - Importe gastos (default: 0)
Retorna JSON con success, message y cvereq.';

-- Otorgar permisos
GRANT EXECUTE ON FUNCTION publico.recaudadora_reqtrans_create(JSON) TO refact;
GRANT EXECUTE ON FUNCTION publico.recaudadora_reqtrans_create(JSON) TO PUBLIC;
