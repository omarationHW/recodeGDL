-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public (cementerio)
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: Duplicados (Gestión de Registros Duplicados)
-- Archivo: 37_SP_CEMENTERIOS_DUPLICADOS_COMPLETO_all_procedures.sql
-- Generado: 2025-11-30
-- Total SPs: 4
-- ============================================
--
-- CORRECCIONES POSTGRESQL - AGENTE CATALIZADOR
-- Fecha: 2025-12-04
-- Total Correcciones: 24
--
-- Correcciones aplicadas:
-- 1. cementerio: VARCHAR(2) → CHAR(1) (7 ocurrencias)
-- 2. nombre: VARCHAR(255) → VARCHAR(60) (3 ocurrencias)
-- 3. domicilio: VARCHAR(255) → VARCHAR(60) (3 ocurrencias)
-- 4. cajing: VARCHAR(1) → CHAR(2) (2 ocurrencias)
-- 5. linea_alfa: VARCHAR(10) → VARCHAR(20) (5 ocurrencias)
-- 6. fosa_alfa: VARCHAR(10) → VARCHAR(20) (5 ocurrencias)
-- 7. exterior: VARCHAR(20) → CHAR(6) (2 ocurrencias)
-- 8. interior: VARCHAR(20) → CHAR(6) (2 ocurrencias)
-- 9. colonia: VARCHAR(100) → VARCHAR(30) (2 ocurrencias)
-- 10. p_observaciones: TEXT → VARCHAR(60)
-- 11. tipo: VARCHAR(1) → CHAR(1)
-- 12. resultado: VARCHAR(1) → CHAR(1)
-- 13. existe_datos: VARCHAR(1) → CHAR(1)
-- 14. existe_pago: VARCHAR(1) → CHAR(1)
-- ============================================

-- =============================================
-- SP 1/4: sp_duplicados_listar_cementerios
-- Descripción: Lista catálogo de cementerios
-- =============================================
CREATE OR REPLACE FUNCTION cementerio.sp_duplicados_listar_cementerios()
RETURNS TABLE(
    cementerio CHAR(1),
    nombre VARCHAR(60),
    domicilio VARCHAR(60)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.cementerio,
        c.nombre,
        c.domicilio
    FROM padron_licencias.comun.tc_13_cementerios c
    ORDER BY c.cementerio;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.sp_duplicados_listar_cementerios IS 'Lista catálogo de cementerios para selección';

-- =============================================
-- SP 2/4: sp_duplicados_buscar_por_nombre
-- Descripción: Busca registros duplicados por nombre
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_duplicados_buscar_por_nombre(
    p_nombre VARCHAR(60)
)
RETURNS TABLE(
    control_id INTEGER,
    fecing DATE,
    recing SMALLINT,
    cajing CHAR(2),
    opcaja INTEGER,
    cementerio CHAR(1),
    nombre_cementerio VARCHAR(60),
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
    exterior CHAR(6),
    interior CHAR(6),
    colonia VARCHAR(30),
    axo_pago_desde INTEGER,
    axo_pago_hasta INTEGER,
    importe_anual NUMERIC(16,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.control_id,
        d.fecing,
        d.recing,
        d.cajing,
        d.opcaja,
        d.cementerio,
        COALESCE(c.nombre, d.cementerio) as nombre_cementerio,
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
        d.exterior,
        d.interior,
        d.colonia,
        d.axo_pago_desde,
        d.axo_pago_hasta,
        d.importe_anual
    FROM public.ta_13_duplicarcm d
    LEFT JOIN public.tc_13_cementerios c
        ON d.cementerio = c.cementerio
    WHERE d.nombre ILIKE p_nombre
    ORDER BY d.nombre, d.fecing DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.sp_duplicados_buscar_por_nombre IS 'Busca registros duplicados por nombre (con LIKE)';

-- =============================================
-- SP 3/4: sp_duplicados_verificar_ubicacion
-- Descripción: Verifica si existe datos y pagos en la ubicación destino
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_duplicados_verificar_ubicacion(
    p_cementerio CHAR(1),
    p_clase SMALLINT,
    p_clase_alfa VARCHAR(10),
    p_seccion SMALLINT,
    p_seccion_alfa VARCHAR(10),
    p_linea SMALLINT,
    p_linea_alfa VARCHAR(20),
    p_fosa SMALLINT,
    p_fosa_alfa VARCHAR(20),
    p_fecing DATE,
    p_recing SMALLINT,
    p_cajing CHAR(2),
    p_opcaja INTEGER
)
RETURNS TABLE(
    existe_datos CHAR(1),
    existe_pago CHAR(1),
    control_rcm INTEGER
) AS $$
DECLARE
    v_control_rcm INTEGER;
    v_existe_datos CHAR(1) := 'N';
    v_existe_pago CHAR(1) := 'N';
BEGIN
    -- Verificar si existen datos en ta_13_datosrcm
    SELECT d.control_rcm INTO v_control_rcm
    FROM public.ta_13_datosrcm d
    WHERE d.cementerio = p_cementerio
      AND d.clase = p_clase
      AND COALESCE(d.clase_alfa, '') = COALESCE(p_clase_alfa, '')
      AND d.seccion = p_seccion
      AND COALESCE(d.seccion_alfa, '') = COALESCE(p_seccion_alfa, '')
      AND d.linea = p_linea
      AND COALESCE(d.linea_alfa, '') = COALESCE(p_linea_alfa, '')
      AND d.fosa = p_fosa
      AND COALESCE(d.fosa_alfa, '') = COALESCE(p_fosa_alfa, '')
    LIMIT 1;

    IF v_control_rcm IS NOT NULL THEN
        v_existe_datos := 'S';

        -- Verificar si existen pagos para este folio y recibo
        IF EXISTS (
            SELECT 1
            FROM public.ta_13_pagosrcm p
            WHERE p.control_rcm = v_control_rcm
              AND p.fecing = p_fecing
              AND p.recing = p_recing
              AND p.cajing = p_cajing
              AND p.opcaja = p_opcaja
        ) THEN
            v_existe_pago := 'S';
        END IF;
    END IF;

    -- Retornar resultados
    existe_datos := v_existe_datos;
    existe_pago := v_existe_pago;
    control_rcm := v_control_rcm;

    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.sp_duplicados_verificar_ubicacion IS 'Verifica existencia de datos y pagos en ubicación destino';

-- =============================================
-- SP 4/4: spd_trasladar_duplicado
-- Descripción: Traslada un registro duplicado a nueva ubicación
-- Operación: 1=Solo Pagos, 2=Todo (Datos + Pagos)
-- =============================================
CREATE OR REPLACE FUNCTION public.spd_trasladar_duplicado(
    p_control_id INTEGER,
    p_operacion INTEGER,
    p_cementerio CHAR(1),
    p_clase SMALLINT,
    p_clase_alfa VARCHAR(10),
    p_seccion SMALLINT,
    p_seccion_alfa VARCHAR(10),
    p_linea SMALLINT,
    p_linea_alfa VARCHAR(20),
    p_fosa SMALLINT,
    p_fosa_alfa VARCHAR(20),
    p_tipo CHAR(1),
    p_observaciones VARCHAR(60),
    p_usuario INTEGER
)
RETURNS TABLE(resultado CHAR(1), mensaje VARCHAR(255), control_rcm_nuevo INTEGER) AS $$
DECLARE
    v_duplicado RECORD;
    v_control_rcm_nuevo INTEGER;
    v_mensaje VARCHAR(255);
BEGIN
    -- Obtener datos del duplicado
    SELECT * INTO v_duplicado
    FROM public.ta_13_duplicarcm
    WHERE control_id = p_control_id;

    IF NOT FOUND THEN
        resultado := 'N';
        mensaje := 'No se encontró el registro duplicado';
        control_rcm_nuevo := NULL;
        RETURN NEXT;
        RETURN;
    END IF;

    IF p_operacion = 2 THEN
        -- Operación 2: Crear nuevo registro en ta_13_datosrcm
        INSERT INTO public.ta_13_datosrcm (
            cementerio, clase, clase_alfa, seccion, seccion_alfa,
            linea, linea_alfa, fosa, fosa_alfa, nombre, domicilio,
            exterior, interior, colonia, metros, axo_pagado, tipo,
            vigencia, usuario, fecha_alta, observaciones
        )
        VALUES (
            p_cementerio, p_clase, p_clase_alfa, p_seccion, p_seccion_alfa,
            p_linea, p_linea_alfa, p_fosa, p_fosa_alfa, v_duplicado.nombre,
            v_duplicado.domicilio, v_duplicado.exterior, v_duplicado.interior,
            v_duplicado.colonia, v_duplicado.metros, v_duplicado.axo_pago_hasta,
            p_tipo, 'V', p_usuario, CURRENT_DATE, p_observaciones
        )
        RETURNING control_rcm INTO v_control_rcm_nuevo;
    ELSE
        -- Operación 1: Solo pagos, buscar control_rcm existente
        SELECT d.control_rcm INTO v_control_rcm_nuevo
        FROM public.ta_13_datosrcm d
        WHERE d.cementerio = p_cementerio
          AND d.clase = p_clase
          AND COALESCE(d.clase_alfa, '') = COALESCE(p_clase_alfa, '')
          AND d.seccion = p_seccion
          AND COALESCE(d.seccion_alfa, '') = COALESCE(p_seccion_alfa, '')
          AND d.linea = p_linea
          AND COALESCE(d.linea_alfa, '') = COALESCE(p_linea_alfa, '')
          AND d.fosa = p_fosa
          AND COALESCE(d.fosa_alfa, '') = COALESCE(p_fosa_alfa, '')
        LIMIT 1;

        IF v_control_rcm_nuevo IS NULL THEN
            resultado := 'N';
            mensaje := 'No se encontró el folio destino para trasladar solo pagos';
            control_rcm_nuevo := NULL;
            RETURN NEXT;
            RETURN;
        END IF;
    END IF;

    -- Trasladar pagos del duplicado al nuevo folio
    UPDATE public.ta_13_pagosrcm
    SET control_rcm = v_control_rcm_nuevo
    WHERE fecing = v_duplicado.fecing
      AND recing = v_duplicado.recing
      AND cajing = v_duplicado.cajing
      AND opcaja = v_duplicado.opcaja;

    -- Eliminar registro duplicado
    DELETE FROM public.ta_13_duplicarcm
    WHERE control_id = p_control_id;

    -- Retornar éxito
    resultado := 'S';
    mensaje := 'Registro trasladado correctamente';
    control_rcm_nuevo := v_control_rcm_nuevo;
    RETURN NEXT;

EXCEPTION
    WHEN OTHERS THEN
        resultado := 'N';
        mensaje := 'Error al trasladar: ' || SQLERRM;
        control_rcm_nuevo := NULL;
        RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.spd_trasladar_duplicado IS 'Traslada registro duplicado - OPC: 1=Solo Pagos, 2=Todo';

-- ============================================
-- FIN DE STORED PROCEDURES - DUPLICADOS
-- ============================================
