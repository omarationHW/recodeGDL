-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: TRASLADOFOL (Traslado de Folios con adeudos)
-- Archivo: 36_SP_CEMENTERIOS_TRASLADOFOL_EXACTO_all_procedures.sql
-- Generado: 2025-12-01
-- Actualizado: 2025-12-06 (Agregado SP dependiente sp_abcf_get_folio)
-- Total SPs: 3 (2 propios + 1 dependiente de ABCFolio)
-- ============================================
--
-- DEPENDENCIAS:
-- - sp_abcf_get_folio: Obtiene datos de un folio (compartido con ABCFolio.vue)
--   Ubicación original: 01_SP_CEMENTERIOS_ABCFOLIO_EXACTO_all_procedures_CORREGIDO.sql
--   Se incluye aquí para mejor control y documentación
-- ============================================
--
-- CORRECCIONES POSTGRESQL - AGENTE CATALIZADOR
-- Fecha: 2025-12-04
-- Total Correcciones: 18
--
-- Correcciones aplicadas:
-- 1. recing: INTEGER → SMALLINT (2 ocurrencias)
-- 2. cajing: INTEGER → CHAR(2) (2 ocurrencias)
-- 3. vigencia: VARCHAR → CHAR(1) (2 ocurrencias)
-- 4. importe_anual: NUMERIC → NUMERIC(16,2)
-- 5. importe_recargos: NUMERIC → NUMERIC(16,2)
-- 6. resultado: VARCHAR → CHAR(1) (3 ocurrencias)
-- 7. v_cementerio: VARCHAR → CHAR(1)
-- 8. v_clase: INTEGER → SMALLINT
-- 9. v_clase_alfa: VARCHAR → VARCHAR(10)
-- 10. v_seccion_alfa: VARCHAR → VARCHAR(10)
-- 11. v_linea_alfa: VARCHAR → VARCHAR(20)
-- 12. v_fosa_alfa: VARCHAR → VARCHAR(20)
-- ============================================

-- ============================================
-- SECCIÓN 1: SP DEPENDIENTE (compartido con ABCFolio)
-- ============================================

-- SP 1/3: sp_abcf_get_folio (DEPENDENCIA)
-- Tipo: FUNCTION (SELECT)
-- Descripción: Obtiene todos los datos de un folio con LEFT JOIN a ta_12_passwords
-- Ubicación: padron_licencias.comun
-- Origen: 01_SP_CEMENTERIOS_ABCFOLIO_EXACTO_all_procedures_CORREGIDO.sql
-- Uso: TrasladoFol.vue lo usa para obtener datos de folios origen y destino
-- --------------------------------------------

\c padron_licencias;
SET search_path TO comun;

CREATE OR REPLACE FUNCTION public.sp_abcf_get_folio(p_folio integer)
 RETURNS TABLE(
    control_rcm integer,
    cementerio character,
    clase smallint,
    clase_alfa character varying,
    seccion smallint,
    seccion_alfa character varying,
    linea smallint,
    linea_alfa character varying,
    fosa smallint,
    fosa_alfa character varying,
    axo_pagado integer,
    metros numeric,
    nombre character varying,
    domicilio character varying,
    exterior character,
    interior character,
    colonia character varying,
    observaciones character varying,
    usuario integer,
    fecha_mov date,
    tipo character,
    fecha_alta date,
    vigencia character,
    usuario_nombre character varying,
    id_rec smallint
 )
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        a.control_rcm,
        a.cementerio,
        a.clase,
        a.clase_alfa,
        a.seccion,
        a.seccion_alfa,
        a.linea,
        a.linea_alfa,
        a.fosa,
        a.fosa_alfa,
        a.axo_pagado,
        a.metros,
        a.nombre,
        a.domicilio,
        a.exterior,
        a.interior,
        a.colonia,
        a.observaciones,
        a.usuario,
        a.fecha_mov,
        a.tipo,
        a.fecha_alta,
        a.vigencia,
        c.nombre AS usuario_nombre,
        c.id_rec
    FROM public.ta_13_datosrcm a
    LEFT JOIN public.ta_12_passwords c ON a.usuario = c.id_usuario
    WHERE a.control_rcm = p_folio;
END;
$function$;

-- ============================================
-- SECCIÓN 2: SPs PROPIOS DE TRASLADOFOL
-- ============================================

\c padron_licencias;
SET search_path TO public;

-- SP 2/3: sp_trasladofol_listar_pagos_folio
-- Tipo: FUNCTION (SELECT)
-- Descripción: Lista todos los pagos de un folio específico
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_trasladofol_listar_pagos_folio(
    p_control_rcm INTEGER
)
RETURNS TABLE (
    control_id INTEGER,
    control_rcm INTEGER,
    fecing DATE,
    recing SMALLINT,
    cajing CHAR(2),
    opcaja INTEGER,
    axo_pago_desde INTEGER,
    axo_pago_hasta INTEGER,
    importe_anual NUMERIC(16,2),
    importe_recargos NUMERIC(16,2),
    vigencia CHAR(1)
) AS $$
BEGIN
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
    FROM public.ta_13_pagosrcm p
    WHERE p.control_rcm = p_control_rcm
      AND p.vigencia = 'A'
    ORDER BY p.fecing DESC, p.axo_pago_hasta DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_trasladofol_trasladar_pagos
-- Tipo: FUNCTION (UPDATE)
-- Descripción: Traslada pagos seleccionados de un folio a otro con actualización de adeudos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_trasladofol_trasladar_pagos(
    p_folio_origen INTEGER,
    p_folio_destino INTEGER,
    p_control_ids VARCHAR,
    p_usuario INTEGER
) RETURNS TABLE (resultado CHAR(1), mensaje TEXT, registros_actualizados INTEGER) AS $$
DECLARE
    v_axo INTEGER;
    v_uap INTEGER;
    v_count INTEGER := 0;
    v_control_id INTEGER;
    v_cementerio CHAR(1);
    v_clase SMALLINT;
    v_clase_alfa VARCHAR(10);
    v_seccion SMALLINT;
    v_seccion_alfa VARCHAR(10);
    v_linea SMALLINT;
    v_linea_alfa VARCHAR(20);
    v_fosa SMALLINT;
    v_fosa_alfa VARCHAR(20);
    v_id_array INTEGER[];
BEGIN
    -- Validaciones
    IF p_folio_origen IS NULL OR p_folio_destino IS NULL OR p_control_ids IS NULL OR p_usuario IS NULL THEN
        RETURN QUERY SELECT 'N'::CHAR(1), 'Parámetros incompletos'::TEXT, 0::INTEGER;
        RETURN;
    END IF;

    IF p_folio_origen = p_folio_destino THEN
        RETURN QUERY SELECT 'N'::CHAR(1), 'Los folios no pueden ser iguales'::TEXT, 0::INTEGER;
        RETURN;
    END IF;

    -- Obtener datos del folio destino
    SELECT d.cementerio, d.clase, d.clase_alfa, d.seccion, d.seccion_alfa,
           d.linea, d.linea_alfa, d.fosa, d.fosa_alfa
    INTO v_cementerio, v_clase, v_clase_alfa, v_seccion, v_seccion_alfa,
         v_linea, v_linea_alfa, v_fosa, v_fosa_alfa
    FROM public.ta_13_datosrcm d
    WHERE d.control_rcm = p_folio_destino;

    IF v_cementerio IS NULL THEN
        RETURN QUERY SELECT 'N'::CHAR(1), 'Folio destino no encontrado'::TEXT, 0::INTEGER;
        RETURN;
    END IF;

    -- Convertir string de IDs a array
    v_id_array := string_to_array(p_control_ids, ',')::INTEGER[];

    -- Procesar cada pago seleccionado
    FOREACH v_control_id IN ARRAY v_id_array LOOP
        -- Actualizar adeudos: poner id_pago=NULL, vigencia='V'
        UPDATE public.ta_13_adeudosrcm
        SET id_pago = NULL,
            vigencia = 'V',
            fecha_mov = CURRENT_DATE,
            usuario = p_usuario
        WHERE control_rcm = p_folio_origen
          AND id_pago = v_control_id
          AND vigencia = 'P';

        -- Actualizar el pago con los datos del folio destino
        UPDATE public.ta_13_pagosrcm
        SET cementerio = v_cementerio,
            clase = v_clase,
            clase_alfa = COALESCE(v_clase_alfa, ''),
            seccion = v_seccion,
            seccion_alfa = COALESCE(v_seccion_alfa, ''),
            linea = v_linea,
            linea_alfa = COALESCE(v_linea_alfa, ''),
            fosa = v_fosa,
            fosa_alfa = COALESCE(v_fosa_alfa, ''),
            control_rcm = p_folio_destino,
            usuario = p_usuario,
            fecha_mov = CURRENT_DATE
        WHERE control_id = v_control_id;

        IF FOUND THEN
            v_count := v_count + 1;
        END IF;
    END LOOP;

    -- Actualizar axo_pagado en datosrcm para folio destino
    SELECT EXTRACT(YEAR FROM CURRENT_DATE) INTO v_axo;

    SELECT COALESCE(MAX(axo_pago_hasta), 0)
    INTO v_uap
    FROM public.ta_13_pagosrcm
    WHERE control_rcm = p_folio_destino
      AND vigencia = 'A';

    IF v_uap = 0 OR v_uap IS NULL THEN
        v_uap := v_axo - 5;
    END IF;

    UPDATE public.ta_13_datosrcm
    SET axo_pagado = v_uap,
        fecha_mov = CURRENT_DATE,
        usuario = p_usuario
    WHERE control_rcm = p_folio_destino;

    -- Actualizar axo_pagado en datosrcm para folio origen
    SELECT COALESCE(MAX(axo_pago_hasta), 0)
    INTO v_uap
    FROM public.ta_13_pagosrcm
    WHERE control_rcm = p_folio_origen
      AND vigencia = 'A';

    IF v_uap = 0 OR v_uap IS NULL THEN
        v_uap := v_axo - 5;
    END IF;

    UPDATE public.ta_13_datosrcm
    SET axo_pagado = v_uap,
        fecha_mov = CURRENT_DATE,
        usuario = p_usuario
    WHERE control_rcm = p_folio_origen;

    -- Actualizar adeudos que quedaron vigentes en folio origen
    UPDATE public.ta_13_adeudosrcm
    SET vigencia = 'B',
        fecha_mov = CURRENT_DATE,
        usuario = p_usuario
    WHERE control_rcm = p_folio_origen
      AND vigencia = 'V'
      AND axo_adeudo <= v_uap;

    RETURN QUERY SELECT 'S'::CHAR(1), 'Traslado realizado correctamente'::TEXT, v_count;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 'N'::CHAR(1), ('Error al trasladar pagos: ' || SQLERRM)::TEXT, 0::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- ============================================
