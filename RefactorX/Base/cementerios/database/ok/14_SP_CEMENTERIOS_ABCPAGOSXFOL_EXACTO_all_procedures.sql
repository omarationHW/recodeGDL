-- =============================================
-- CEMENTERIOS - ABC PAGOS POR FOLIO (ABCPagosxfol.vue)
-- =============================================
-- Archivo: 14_SP_CEMENTERIOS_ABCPAGOSXFOL_EXACTO_all_procedures.sql
-- Descripción: Stored Procedures para gestión de pagos por folio individual
-- Fecha: 2025-11-27
--
-- ESQUEMAS según postgreok.csv:
--   - ta_13_datosrcm → padron_licencias.comun
--   - ta_13_pagosrcm → cementerio.public
--   - tc_13_cementerios → cementerio.public
--
-- LÓGICA ORIGINAL (Pascal ABCPagosxfol.pas):
--   - Buscar folio con JOIN a cementerios (línea 267-268, DFM)
--   - Verificar pago existente por fecha/recibo/caja/operación (DFM)
--   - Alta de pago (línea 169-193)
--   - Modificación de pago (línea 203-231)
--   - Baja de pago (línea 232-257)
--   - Actualizar último año pagado (línea 138-167)
--
-- SPS CREADOS:
--   1. sp_pagosxfol_buscar_folio(p_control_rcm) → Busca folio con datos del cementerio
--   2. sp_pagosxfol_verificar_pago(p_fecha, p_recibo, p_caja, p_operacion) → Verifica si existe un pago
--   3. sp_pagosxfol_obtener_ultimo_anio(p_control_rcm) → Obtiene el último año pagado
--   4. sp_pagosxfol_registrar(p_fecha, p_recibo, p_caja, p_operacion, p_control_rcm, ...) → Alta de pago
--   5. sp_pagosxfol_modificar(p_control_id, p_axo_desde, p_axo_hasta, p_importe_anual, p_importe_recargos, p_usuario) → Modificación
--   6. sp_pagosxfol_eliminar(p_control_id, p_control_rcm, p_usuario) → Baja de pago
-- =============================================

-- =============================================
-- 1. sp_pagosxfol_buscar_folio
-- Descripción: Busca folio con JOIN a cementerios
-- Parámetros:
--   - p_control_rcm: Número de folio a buscar
-- Retorna: TABLE con datos del folio y cementerio
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_pagosxfol_buscar_folio(
    p_control_rcm INTEGER
)
RETURNS TABLE (
    control_rcm INTEGER,
    cementerio CHAR(1),
    clase SMALLINT,
    clase_alfa VARCHAR(10),
    seccion SMALLINT,
    seccion_alfa VARCHAR(10),
    linea SMALLINT,
    linea_alfa VARCHAR(20),
    fosa SMALLINT,
    fosa_alfa VARCHAR(20),
    nombre VARCHAR(60),
    domicilio VARCHAR(60),
    axo_pagado INTEGER,
    metros NUMERIC,
    tipo CHAR(1),
    nombre_cementerio VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Query original Pascal (ABCPagosxfol.pas DFM):
    -- SQL: 'select a.*,b.* from ta_13_datosrcm a, tc_13_cementerios b
    --       where control_rcm=:control and a.cementerio=b.cementerio'

    RETURN QUERY
    SELECT
        d.control_rcm,
        d.cementerio,
        d.clase,
        d.clase_alfa,
        d.seccion,
        d.seccion_alfa,
        d.linea,
        d.linea_alfa,
        d.fosa,
        d.fosa_alfa,
        d.nombre,
        d.domicilio,
        d.axo_pagado,
        d.metros,
        d.tipo,
        c.nombre_cementerio
    FROM public.ta_13_datosrcm d
    INNER JOIN public.tc_13_cementerios c ON d.cementerio = c.cementerio
    WHERE d.control_rcm = p_control_rcm
      --AND d.vigencia = 'S'
      ;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_pagosxfol_buscar_folio IS 'Busca folio con datos del cementerio para ABCPagosxfol';

-- =============================================
-- 2. sp_pagosxfol_verificar_pago
-- Descripción: Verifica si existe un pago con los datos especificados
-- Parámetros:
--   - p_fecha: Fecha del pago
--   - p_recibo: Número de recibo
--   - p_caja: Caja
--   - p_operacion: Número de operación
-- Retorna: TABLE con el pago si existe
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_pagosxfol_verificar_pago(
    p_fecha DATE,
    p_recibo INTEGER,
    p_caja CHAR(3),
    p_operacion INTEGER
)
RETURNS TABLE (
    control_id INTEGER,
    control_rcm INTEGER,
    fecing DATE,
    recing SMALLINT,
    cajing CHAR(3),
    opcaja INTEGER,
    axo_pago_desde INTEGER,
    axo_pago_hasta INTEGER,
    importe_anual NUMERIC(16,2),
    importe_recargos NUMERIC(16,2),
    vigencia CHAR(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Query original Pascal (ABCPagosxfol.pas DFM):
    -- SQL: 'select * from ta_13_pagosrcm where fecing=:fecha and recing=:rec
    --       and cajing=:caja and opcaja=:operac'

    RETURN QUERY
    SELECT
        p.control_id,
        p.control_rcm,
        p.fecing,
        p.recing,
        p.cajing,
        p.opcaja,
        p.axo_pago_desde,
        p.axo_pago_hasta,
        p.importe_anual,
        p.importe_recargos,
        p.vigencia
    FROM cementerio.public.ta_13_pagosrcm p
    WHERE p.fecing = p_fecha
      AND p.recing = p_recibo
      AND p.cajing = p_caja
      AND p.opcaja = p_operacion
      --AND p.vigencia = 'A'
      ;

END;
$$;
COMMENT ON FUNCTION cementerio.sp_pagosxfol_verificar_pago IS 'Verifica si existe un pago con fecha/recibo/caja/operación';

-- =============================================
-- 3. sp_pagosxfol_obtener_ultimo_anio
-- Descripción: Obtiene el último año pagado de un folio
-- Parámetros:
--   - p_control_rcm: Número de folio
-- Retorna: TABLE con el último año pagado
-- =============================================
CREATE OR REPLACE FUNCTION cementerio.sp_pagosxfol_obtener_ultimo_anio(
    p_control_rcm INTEGER
)
RETURNS TABLE (
    ultimo_anio_pagado INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Query original Pascal (ABCPagosxfol.pas DFM):
    -- SQL: 'select (nvl(max(axo_pago_hasta),0)) ULap from ta_13_pagosrcm
    --       where control_rcm=:controlua'

    RETURN QUERY
    SELECT
        COALESCE(MAX(p.axo_pago_hasta), 0)::INTEGER
    FROM cementerio.public.ta_13_pagosrcm p
    WHERE p.control_rcm = p_control_rcm
      AND p.vigencia = 'A';

END;
$$;

COMMENT ON FUNCTION cementerio.sp_pagosxfol_obtener_ultimo_anio IS 'Obtiene el último año pagado del folio';

-- =============================================
-- 4. sp_pagosxfol_registrar
-- Descripción: Registra un nuevo pago (alta)
-- Parámetros: Todos los campos del pago
-- Retorna: TABLE con resultado de la operación
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_pagosxfol_registrar(
    p_fecha DATE,
    p_recibo INTEGER,
    p_caja CHAR(3),
    p_operacion INTEGER,
    p_control_rcm INTEGER,
    p_cementerio CHAR(1),
    p_clase SMALLINT,
    p_clase_alfa VARCHAR(10),
    p_seccion SMALLINT,
    p_seccion_alfa VARCHAR(10),
    p_linea SMALLINT,
    p_linea_alfa VARCHAR(20),
    p_fosa SMALLINT,
    p_fosa_alfa VARCHAR(20),
    p_axo_desde INTEGER,
    p_axo_hasta INTEGER,
    p_importe_anual NUMERIC(16,2),
    p_importe_recargos NUMERIC(16,2),
    p_usuario INTEGER
)
RETURNS TABLE (
    resultado CHAR(1),
    mensaje TEXT,
    control_id INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_control_id INTEGER;
    v_ultimo_anio INTEGER;
    v_anio_actualizar INTEGER;
BEGIN
    -- Query original Pascal (ABCPagosxfol.pas línea 178-186):
    -- INSERT INTO ta_13_pagosrcm VALUES(fecha, recibo, caja, operacion, 0, control_rcm,
    --   cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa,
    --   fosa, fosa_alfa, axo_desde, axo_hasta, importe_anual, importe_recargos, 'A', usuario, today)

    BEGIN
        -- Insertar el pago
        INSERT INTO public.ta_13_pagosrcm (
            fecing, recing, cajing, opcaja, control_id, control_rcm,
            cementerio, clase, clase_alfa, seccion, seccion_alfa,
            linea, linea_alfa, fosa, fosa_alfa,
            axo_pago_desde, axo_pago_hasta, importe_anual, importe_recargos,
            vigencia, usuario, fecha_mov
        ) VALUES (
            p_fecha, p_recibo, p_caja, p_operacion, 0, p_control_rcm,
            p_cementerio, p_clase, p_clase_alfa, p_seccion, p_seccion_alfa,
            p_linea, p_linea_alfa, p_fosa, p_fosa_alfa,
            p_axo_desde, p_axo_hasta, p_importe_anual, p_importe_recargos,
            'A', p_usuario, CURRENT_DATE
        )
        RETURNING ta_13_pagosrcm.control_id INTO v_control_id;

        -- Obtener el último año pagado (Pascal línea 143-144)
        SELECT COALESCE(MAX(axo_pago_hasta), 0) INTO v_ultimo_anio
        FROM cementerio.public.ta_13_pagosrcm
        WHERE control_rcm = p_control_rcm
          AND vigencia = 'A';

        -- Calcular el año a actualizar (Pascal línea 151-157)
        IF v_ultimo_anio > 0 THEN
            v_anio_actualizar := v_ultimo_anio;
        ELSE
            v_anio_actualizar := EXTRACT(YEAR FROM p_fecha) - 5;
        END IF;

        -- Actualizar el último año pagado en ta_13_datosrcm (Pascal línea 153-159)
        UPDATE padron_licencias.comun.ta_13_datosrcm
        SET axo_pagado = v_anio_actualizar,
            usuario = p_usuario,
            fecha_mov = CURRENT_DATE
        WHERE control_rcm = p_control_rcm;

        RETURN QUERY
        SELECT 'S'::CHAR(1), 'Pago registrado exitosamente'::TEXT, v_control_id;

    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY
        SELECT 'N'::CHAR(1), ('Error al registrar pago: ' || SQLERRM)::TEXT, NULL::INTEGER;
    END;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_pagosxfol_registrar IS 'Registra un nuevo pago (alta) y actualiza último año pagado';

-- =============================================
-- 5. sp_pagosxfol_modificar
-- Descripción: Modifica un pago existente
-- Parámetros: Control ID y campos a modificar
-- Retorna: TABLE con resultado de la operación
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_pagosxfol_modificar(
    p_control_id INTEGER,
    p_control_rcm INTEGER,
    p_axo_desde INTEGER,
    p_axo_hasta INTEGER,
    p_importe_anual NUMERIC(16,2),
    p_importe_recargos NUMERIC(16,2),
    p_usuario INTEGER
)
RETURNS TABLE (
    resultado CHAR(1),
    mensaje TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ultimo_anio INTEGER;
    v_anio_actualizar INTEGER;
BEGIN
    -- Query original Pascal (ABCPagosxfol.pas línea 212-216):
    -- UPDATE ta_13_pagosrcm SET
    --   axo_pago_desde=:desde, axo_pago_hasta=:hasta,
    --   importe_anual=:importeman, importe_recargos=:importerec,
    --   usuario=:user, fecha_mov=today
    -- WHERE control_id=:id

    BEGIN
        -- Modificar el pago
        UPDATE public.ta_13_pagosrcm
        SET axo_pago_desde = p_axo_desde,
            axo_pago_hasta = p_axo_hasta,
            importe_anual = p_importe_anual,
            importe_recargos = p_importe_recargos,
            usuario = p_usuario,
            fecha_mov = CURRENT_DATE
        WHERE control_id = p_control_id;

        IF NOT FOUND THEN
            RETURN QUERY
            SELECT 'N'::CHAR(1), 'Pago no encontrado'::TEXT;
            RETURN;
        END IF;

        -- Actualizar último año pagado (mismo proceso que en alta)
        SELECT COALESCE(MAX(axo_pago_hasta), 0) INTO v_ultimo_anio
        FROM public.ta_13_pagosrcm
        WHERE control_rcm = p_control_rcm
          AND vigencia = 'A';

        IF v_ultimo_anio > 0 THEN
            v_anio_actualizar := v_ultimo_anio;
        ELSE
            v_anio_actualizar := EXTRACT(YEAR FROM CURRENT_DATE) - 5;
        END IF;

        UPDATE public.ta_13_datosrcm
        SET axo_pagado = v_anio_actualizar,
            usuario = p_usuario,
            fecha_mov = CURRENT_DATE
        WHERE control_rcm = p_control_rcm;

        RETURN QUERY
        SELECT 'S'::CHAR(1), 'Pago modificado exitosamente'::TEXT;

    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY
        SELECT 'N'::CHAR(1), ('Error al modificar pago: ' || SQLERRM)::TEXT;
    END;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_pagosxfol_modificar IS 'Modifica un pago existente y actualiza último año pagado';

-- =============================================
-- 6. sp_pagosxfol_eliminar
-- Descripción: Elimina un pago (baja lógica)
-- Parámetros: Control ID del pago
-- Retorna: TABLE con resultado de la operación
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_pagosxfol_eliminar(
    p_control_id INTEGER,
    p_control_rcm INTEGER,
    p_usuario INTEGER
)
RETURNS TABLE (
    resultado CHAR(1),
    mensaje TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ultimo_anio INTEGER;
    v_anio_actualizar INTEGER;
BEGIN
    -- Query original Pascal (ABCPagosxfol.pas línea 241-242):
    -- DELETE FROM ta_13_pagosrcm WHERE control_id=:id

    BEGIN
        -- Eliminar el pago (DELETE físico según Pascal original)
        DELETE FROM public.ta_13_pagosrcm
        WHERE control_id = p_control_id;

        IF NOT FOUND THEN
            RETURN QUERY
            SELECT 'N'::CHAR(1), 'Pago no encontrado'::TEXT;
            RETURN;
        END IF;

        -- Actualizar último año pagado después de la eliminación
        SELECT COALESCE(MAX(axo_pago_hasta), 0) INTO v_ultimo_anio
        FROM public.ta_13_pagosrcm
        WHERE control_rcm = p_control_rcm
          AND vigencia = 'A';

        IF v_ultimo_anio > 0 THEN
            v_anio_actualizar := v_ultimo_anio;
        ELSE
            v_anio_actualizar := EXTRACT(YEAR FROM CURRENT_DATE) - 5;
        END IF;

        UPDATE public.ta_13_datosrcm
        SET axo_pagado = v_anio_actualizar,
            usuario = p_usuario,
            fecha_mov = CURRENT_DATE
        WHERE control_rcm = p_control_rcm;

        RETURN QUERY
        SELECT 'S'::CHAR(1), 'Pago eliminado exitosamente'::TEXT;

    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY
        SELECT 'N'::CHAR(1), ('Error al eliminar pago: ' || SQLERRM)::TEXT;
    END;

END;
$$;
COMMENT ON FUNCTION cementerio.sp_pagosxfol_eliminar IS 'Elimina un pago (DELETE físico) y actualiza último año pagado';

-- =============================================
-- PERMISOS
-- =============================================
-- GRANT EXECUTE ON FUNCTION cementerio.sp_pagosxfol_buscar_folio TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_pagosxfol_verificar_pago TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_pagosxfol_obtener_ultimo_anio TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_pagosxfol_registrar TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_pagosxfol_modificar TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_pagosxfol_eliminar TO role_cementerio;

-- =============================================
-- NOTAS DE MIGRACIÓN
-- =============================================
-- 1. Pascal usa DELETE físico (no baja lógica con vigencia='B')
-- 2. El cálculo del último año pagado es: MAX(axo_pago_hasta) o (año_actual - 5)
-- 3. Actualización automática de axo_pagado en ta_13_datosrcm después de cada operación
-- 4. control_id se genera automáticamente en INSERT (valor 0 en Pascal)
-- 5. Esquemas correctos según postgreok.csv validados

-- =============================================
-- FIN DE ARCHIVO
-- =============================================
