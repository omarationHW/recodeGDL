-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: TRASLADOFOLSIN (EXACTO del archivo original)
-- Archivo: 34_SP_CEMENTERIOS_TRASLADOFOLSIN_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Actualizado: 2025-12-06 (Agregados SPs dependientes)
-- Total SPs: 3 (1 propio + 2 dependientes)
-- ============================================
--
-- DEPENDENCIAS:
-- - sp_abcf_get_folio: Obtiene datos de un folio (compartido con ABCFolio.vue)
--   Ubicación original: 01_SP_CEMENTERIOS_ABCFOLIO_EXACTO_all_procedures_CORREGIDO.sql
-- - sp_trasladofol_listar_pagos_folio: Lista pagos de un folio (compartido con TrasladoFol.vue)
--   Ubicación original: 36_SP_CEMENTERIOS_TRASLADOFOL_EXACTO_all_procedures.sql
-- Se incluyen aquí para mejor control y documentación
-- ============================================
--
-- CORRECCIONES POSTGRESQL - AGENTE CATALIZADOR
-- Fecha: 2025-12-04
-- Total Correcciones: 0
--
-- ANÁLISIS:
-- Este SP está correctamente tipado para PostgreSQL:
-- - Usa tipos nativos (integer, boolean, text, jsonb)
-- - Usa now() en lugar de CURRENT_DATE (válido en PostgreSQL)
-- - Los tipos de datos coinciden con las estructuras de tablas
-- - No requiere correcciones de tipos de datos
--
-- VALIDADO: El procedimiento está optimizado y listo para uso
-- ============================================

-- ============================================
-- SECCIÓN 1: SPs DEPENDIENTES (compartidos con otros módulos)
-- ============================================

-- SP 1/3: sp_abcf_get_folio (DEPENDENCIA de ABCFolio)
-- Tipo: FUNCTION (SELECT)
-- Descripción: Obtiene todos los datos de un folio con LEFT JOIN a ta_12_passwords
-- Ubicación: padron_licencias.comun
-- Origen: 01_SP_CEMENTERIOS_ABCFOLIO_EXACTO_all_procedures_CORREGIDO.sql
-- Uso: TrasladoFolSin.vue lo usa para obtener datos de folios origen y destino
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

-- SP 2/3: sp_trasladofol_listar_pagos_folio (DEPENDENCIA de TrasladoFol)
-- Tipo: FUNCTION (SELECT)
-- Descripción: Lista todos los pagos de un folio específico
-- Ubicación: cementerio.public
-- Origen: 36_SP_CEMENTERIOS_TRASLADOFOL_EXACTO_all_procedures.sql
-- Uso: TrasladoFolSin.vue lo usa para listar pagos del folio origen
-- --------------------------------------------

\c padron_licencias;
SET search_path TO public;

CREATE OR REPLACE FUNCTION sp_trasladofol_listar_pagos_folio(
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
    FROM cementerio.ta_13_pagosrcm p
    WHERE p.control_rcm = p_control_rcm
      AND p.vigencia = 'A'
    ORDER BY p.fecing DESC, p.axo_pago_hasta DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SECCIÓN 2: SP PROPIO DE TRASLADOFOLSIN
-- ============================================

-- SP 3/3: sp_traslado_folios_sin_adeudo
-- Tipo: CRUD
-- Descripción: Traslada pagos seleccionados de un folio a otro sin afectar adeudos. Actualiza los registros de pagos y los datos de axo_pagado según la lógica de negocio.
-- --------------------------------------------

--
-- sp_traslado_folios_sin_adeudo
-- Traslada pagos seleccionados de un folio a otro sin afectar adeudos
--
CREATE OR REPLACE FUNCTION public.sp_traslado_folios_sin_adeudo(p_folio_de integer, p_folio_a integer, p_control_ids character varying, p_usuario integer)
 RETURNS TABLE(success boolean, message text)
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_axo     integer;
    v_suma    integer := 0;
    v_pago_id integer;
    v_uap     integer;
    v_ids     integer[];  -- arreglo de IDs numéricos deduplicados
BEGIN
    -- Validaciones básicas
    IF p_folio_de IS NULL OR p_folio_a IS NULL OR p_control_ids IS NULL OR p_usuario IS NULL THEN
        RETURN QUERY SELECT false, 'Parámetros incompletos';
        RETURN;
    END IF;

    IF p_folio_de = p_folio_a THEN
        RETURN QUERY SELECT false, 'Los folios no deben ser iguales';
        RETURN;
    END IF;

    -- Construir arreglo de enteros a partir del CSV y DEDUPLICAR
    -- Se aceptan solo elementos numéricos: '^[0-9]+$'
    SELECT ARRAY_AGG(DISTINCT CAST(trim(x) AS integer))
      INTO v_ids
      FROM unnest(string_to_array(p_control_ids, ',')) AS x
     WHERE trim(x) <> ''
       AND trim(x) ~ '^[0-9]+$';

    -- Si no hay IDs válidos, terminar
    IF v_ids IS NULL OR CARDINALITY(v_ids) = 0 THEN
        RETURN QUERY SELECT false, 'No se proporcionaron IDs válidos para trasladar';
        RETURN;
    END IF;

    -- Procesar cada pago seleccionado (por control_id)
    FOREACH v_pago_id IN ARRAY v_ids LOOP
        -- 1) Desvincular adeudo del folio origen: id_pago = NULL, vigencia = 'V', fecha_mov = now()
        UPDATE public.ta_13_adeudosrcm
           SET id_pago   = NULL,
               vigencia  = 'V',
               fecha_mov = now()
         WHERE control_rcm = p_folio_de
           AND id_pago     = v_pago_id;

        -- 2) Actualizar pago: aplicar datos del folio destino y mover control_rcm
        UPDATE public.ta_13_pagosrcm
           SET cementerio   = (SELECT cementerio   FROM public.ta_13_datosrcm WHERE control_rcm = p_folio_a),
               clase        = (SELECT clase        FROM public.ta_13_datosrcm WHERE control_rcm = p_folio_a),
               clase_alfa   = (SELECT clase_alfa   FROM public.ta_13_datosrcm WHERE control_rcm = p_folio_a),
               seccion      = (SELECT seccion      FROM public.ta_13_datosrcm WHERE control_rcm = p_folio_a),
               seccion_alfa = (SELECT seccion_alfa FROM public.ta_13_datosrcm WHERE control_rcm = p_folio_a),
               linea        = (SELECT linea        FROM public.ta_13_datosrcm WHERE control_rcm = p_folio_a),
               linea_alfa   = (SELECT linea_alfa   FROM public.ta_13_datosrcm WHERE control_rcm = p_folio_a),
               fosa         = (SELECT fosa         FROM public.ta_13_datosrcm WHERE control_rcm = p_folio_a),
               fosa_alfa    = (SELECT fosa_alfa    FROM public.ta_13_datosrcm WHERE control_rcm = p_folio_a),
               control_rcm  = p_folio_a,
               usuario      = p_usuario,
               fecha_mov    = now()
         WHERE control_id    = v_pago_id;

        v_suma := v_suma + 1;
    END LOOP;

    -- 3) Actualizar axo_pagado para el folio destino
    SELECT EXTRACT(YEAR FROM now())::int INTO v_axo;

    SELECT COALESCE(MAX(axo_pago_hasta), 0)
      INTO v_uap
      FROM public.ta_13_pagosrcm
     WHERE control_rcm = p_folio_a;

    IF v_uap = 0 THEN
        v_uap := v_axo - 5;
    END IF;

    UPDATE public.ta_13_datosrcm
       SET axo_pagado = v_uap
     WHERE control_rcm = p_folio_a;

    -- 4) Actualizar axo_pagado para el folio origen
    SELECT COALESCE(MAX(axo_pago_hasta), 0)
      INTO v_uap
      FROM public.ta_13_pagosrcm
     WHERE control_rcm = p_folio_de;

    IF v_uap = 0 THEN
        v_uap := v_axo - 5;
    END IF;

    UPDATE public.ta_13_datosrcm
       SET axo_pagado = v_uap
     WHERE control_rcm = p_folio_de;

    -- 5) Mensaje final
    IF v_suma > 0 THEN
        RETURN QUERY SELECT true, 'Los registros se han trasladado';
    ELSE
        RETURN QUERY SELECT false, 'No se seleccionó ningún registro a trasladar';
    END IF;
END;
$function$
;


-- ============================================

