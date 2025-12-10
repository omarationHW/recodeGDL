-- =============================================
-- CEMENTERIOS - CONSULTA DE FOLIO (ConsultaFol.vue)
-- =============================================
-- Archivo: 09_SP_CEMENTERIOS_CONSULTAFOL_EXACTO_all_procedures.sql
-- Descripción: Stored Procedures para consulta completa de folio/cuenta RCM
-- Fecha: 2025-11-25
--
-- ESQUEMAS según postgreok.csv:
--   - ta_13_datosrcm → padron_licencias.comun
--   - ta_13_pagosrcm → cementerio.public
--   - ta_13_adeudosrcm → cementerio.public
--   - ta_13_bonifrcm → cementerio.public
--   - ta_13_datosrcmadic → cementerio.public
--   - ta_13_datosrcmextra → cementerio.public
--   - tc_13_cementerios → cementerio.public
--
-- SPs CREADOS:
--   1. sp_consultafol_buscar_folio(p_control_rcm) → Búsqueda principal del folio con todos los datos
--   2. sp_consultafol_listar_pagos(p_control_rcm) → Historial de pagos
--   3. sp_consultafol_listar_adeudos(p_control_rcm, p_anio) → Adeudos del folio
-- =============================================

-- =============================================
-- 1. sp_consultafol_buscar_folio
-- Descripción: Busca información completa del folio incluyendo:
--              - Datos de la fosa (ubicación, tipo, metros)
--              - Datos del propietario (nombre, domicilio, RFC, CURP)
--              - Datos adicionales (teléfono, IFE)
--              - Resumen financiero (totales de pagos, adeudos, bonificaciones)
-- Parámetros:
--   - p_control_rcm: Número de folio a consultar
-- Retorna: TABLE con información completa del folio
-- =============================================

 CREATE OR REPLACE FUNCTION public.sp_consultafol_buscar_folio(
    p_control_rcm INTEGER
)
RETURNS TABLE (
    -- Datos básicos del folio
    control_rcm INTEGER,
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
    axo_pagado INTEGER,
    metros NUMERIC,
    tipo CHAR(1),
    tipo_nombre VARCHAR(20),
    fecha_alta DATE,
    vigencia CHAR(1),
    -- Datos del propietario
    nombre VARCHAR(60),
    domicilio VARCHAR(60),
    exterior CHAR(6),
    interior CHAR(6),
    colonia VARCHAR(30),
    observaciones VARCHAR(60),
    usuario INTEGER,
    fecha_mov DATE,
    -- Datos adicionales
    rfc VARCHAR(13),
    curp VARCHAR(18),
    telefono VARCHAR(10),
    clave_ife VARCHAR(18),
    -- Resumen financiero
    cuenta_pagos INTEGER,
    total_pagos NUMERIC(16,2),
    cuenta_adeudos INTEGER,
    total_adeudos NUMERIC(16,2),
    total_bonificaciones NUMERIC(16,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_tipo_nombre VARCHAR(20);
    v_cuenta_pagos INTEGER := 0;
    v_total_pagos NUMERIC(16,2) := 0.00;
    v_cuenta_adeudos INTEGER := 0;
    v_total_adeudos NUMERIC(16,2) := 0.00;
    v_total_bonificaciones NUMERIC(16,2) := 0.00;
BEGIN
    -- Query original Pascal (línea 405-411):
    -- Qryestoy.ParamByName('contr').AsInteger:=StrToInt(mxFlatFloatEdit1.Text);
    -- Qryestoy.Open;
    -- Query original Vue (líneas 427-436):
    -- execute('sp_cem_consultar_folio', 'cementerios', { p_control_rcm: folioABuscar.value }, '', null, 'comun')

    -- Calcular resumen de pagos (solo vigentes)
    SELECT
        COALESCE(COUNT(*), 0),
        COALESCE(SUM(p.importe_anual + p.importe_recargos), 0.00)
    INTO v_cuenta_pagos, v_total_pagos
    FROM public.ta_13_pagosrcm p
    WHERE p.control_rcm = p_control_rcm
      AND p.vigencia = 'S';

    -- Calcular resumen de adeudos (solo sin pagar)
    SELECT
        COALESCE(COUNT(*), 0),
        COALESCE(SUM(ad.importe + ad.importe_recargos - COALESCE(ad.descto_impote, 0) - COALESCE(ad.descto_recargos, 0)), 0.00)
    INTO v_cuenta_adeudos, v_total_adeudos
    FROM public.ta_13_adeudosrcm ad
    WHERE ad.control_rcm = p_control_rcm
      AND ad.vigencia = 'V'
      AND ad.id_pago IS NULL;

    -- Calcular total de bonificaciones
    SELECT COALESCE(SUM(b.importe_resto), 0.00)
    INTO v_total_bonificaciones
    FROM public.ta_13_bonifrcm b
    WHERE b.control_rcm = p_control_rcm;
      --AND vigencia = 'S';

    -- Retornar datos completos del folio con JOINs
    RETURN QUERY
    SELECT
        d.control_rcm,
        d.cementerio,
        COALESCE(c.nombre, 'N/A')::VARCHAR(60) AS nombre_cementerio,
        d.clase,
        d.clase_alfa,
        d.seccion,
        d.seccion_alfa,
        d.linea,
        d.linea_alfa,
        d.fosa,
        d.fosa_alfa,
        d.axo_pagado,
        d.metros,
        d.tipo,
        -- Determinar nombre del tipo (líneas 498-507 Pascal)
        CASE
            WHEN d.tipo = 'F' THEN 'Fosa'::VARCHAR(20)
            WHEN d.tipo = 'U' THEN 'Urna'::VARCHAR(20)
            WHEN d.tipo = 'G' THEN 'Gaveta'::VARCHAR(20)
            ELSE 'Sin Tipo'::VARCHAR(20)
        END AS tipo_nombre,
        d.fecha_alta,
        d.vigencia,
        d.nombre,
        d.domicilio,
        d.exterior,
        d.interior,
        d.colonia,
        d.observaciones,
        d.usuario,
        d.fecha_mov,
        -- Datos adicionales
        COALESCE(a.rfc, '')::VARCHAR(13),
        COALESCE(a.curp, '')::VARCHAR(18),
        COALESCE(a.telefono, '')::VARCHAR(20),
        COALESCE(a.clave_ife, '')::VARCHAR(20),
        -- Resumen financiero
        v_cuenta_pagos,
        v_total_pagos,
        v_cuenta_adeudos,
        v_total_adeudos,
        v_total_bonificaciones
    FROM public.ta_13_datosrcm d
    LEFT JOIN public.tc_13_cementerios c ON d.cementerio = c.cementerio
    LEFT JOIN public.ta_13_datosrcmadic a ON d.control_rcm = a.control_rcm
    WHERE d.control_rcm = p_control_rcm
      AND d.vigencia = 'S';

END;
$$;

COMMENT ON FUNCTION cementerio.sp_consultafol_buscar_folio IS 'Consulta información completa de un folio RCM incluyendo datos de fosa, propietario, adicionales y resumen financiero';

-- =============================================
-- 2. sp_consultafol_listar_pagos
-- Descripción: Lista historial de pagos de un folio
-- Parámetros:
--   - p_control_rcm: Número de folio
-- Retorna: TABLE con historial de pagos ordenado por fecha DESC
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_consultfol_listar_pagos(
    p_control_rcm INTEGER
)
RETURNS TABLE (
    -- columnas comunes y prácticas para UI
    tipopag        VARCHAR(10),  -- 'Manten' | 'Titulo'
    fecha          DATE,
    id_rec         SMALLINT,
    caja           CHAR(2),
    operacion      INTEGER,
    control_rcm    INTEGER,
    axo_desde      INTEGER,
    axo_hasta      INTEGER,
    concepto       INTEGER, -- libre: '-' o 'Titulo'
    importe        NUMERIC(16,2),
    usuario        INTEGER,
    vigencia       CHAR(1),
    --foliorecibo    VARCHAR(40),
    obser          VARCHAR(70)
)
LANGUAGE plpgsql
AS $$
BEGIN
  /*
    Equivalente a QryPagos del DFM:
    - UNION de ta_13_pagosrcm con ta_13_titulos
    - LEFT JOIN a ta_12_recibos para obtener foliorecibo
    - ORDER BY fecha, id_rec, caja, operacion
    - Sin filtro de vigencia (Delphi no lo aplica aquí)
  */

  RETURN QUERY
  SELECT
      'Manten'::VARCHAR(10) AS tipopag,
      p.fecing              AS fecha,
      p.recing              AS id_rec,
      p.cajing              AS caja,
      p.opcaja              AS operacion,
      p.control_rcm,
      p.axo_pago_desde      AS axo_desde,
      p.axo_pago_hasta      AS axo_hasta,
      NULL::INTEGER      AS concepto,
      (COALESCE(p.importe_anual,0) + COALESCE(p.importe_recargos,0)) AS importe,
      p.usuario,
      p.vigencia,
      --COALESCE(r.foliorecibo, '')::VARCHAR(40) AS foliorecibo,
      ' '::VARCHAR(70)       AS obser
  FROM public.ta_13_pagosrcm p
  --LEFT JOIN public.ta_12_recibos r
  --      ON r.fecha     = p.fecing
  --      AND r.id_rec    = p.recing
  --      AND r.caja      = p.cajing
  --      AND r.operacion = p.opcaja
  WHERE p.control_rcm = p_control_rcm

  UNION ALL

  SELECT
      'Titulo'::VARCHAR(10) AS tipopag,
      t.fecha               AS fecha,
      t.id_rec              AS id_rec,
      t.caja                AS caja,
      t.operacion           AS operacion,
      t.control_rcm,
      NULL::INTEGER         AS axo_desde,
      NULL::INTEGER         AS axo_hasta,
      t.titulo              AS concepto,               -- equivalente semántico
      COALESCE(t.importe,0) AS importe,
      NULL::INTEGER         AS usuario,
      NULL::CHAR(1)         AS vigencia,
     -- COALESCE(r2.foliorecibo,'')::VARCHAR(40) AS foliorecibo,
      COALESCE(t.observaciones,'')::VARCHAR(70) AS obser
  FROM public.ta_13_titulos t
 -- LEFT JOIN public.ta_12_recibos r2
  --       ON r2.fecha     = t.fecha
  --      AND r2.id_rec    = t.id_rec
  --      AND r2.caja      = t.caja
  --      AND r2.operacion = t.operacion
  WHERE t.control_rcm = p_control_rcm

  ORDER BY fecha DESC, id_rec DESC, caja DESC, operacion DESC;

END;
$$;
-- CREATE OR REPLACE FUNCTION punlic.sp_consultafol_listar_pagos(
--     p_control_rcm INTEGER
-- )
-- RETURNS TABLE (
--     control_id INTEGER,
--     fecha DATE,
--     id_rec SMALLINT,
--     caja CHAR(2),
--     operacion INTEGER,
--     axo INTEGER,
--     concepto VARCHAR(255),
--     importe NUMERIC(16,2),
--     usuario INTEGER,
--     vigencia CHAR(1)
-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     -- Query original Pascal (líneas 437-439):
--     -- QryPagos.ParamByName('folp').AsInteger:=Qryestoycontrol_rcm.Value;
--     -- QryPagos.Open;
--     -- Query original Vue (líneas 468-477):
--     -- execute('sp_cem_obtener_pagos_folio', 'cementerios', { p_control_rcm: folioABuscar.value }, '', null, 'comun')

--     RETURN QUERY
--     SELECT
--         p.control_id,
--         p.fecing AS fecha,
--         p.recing AS id_rec,
--         p.cajing AS caja,
--         p.opcaja AS operacion,
--         p.axo_pago_desde AS axo,
--         '-'::VARCHAR(255) AS concepto,
--         (p.importe_anual + p.importe_recargos) AS importe,
--         p.usuario,
--         p.vigencia
--     FROM punlic.ta_13_pagosrcm p
--     WHERE p.control_rcm = p_control_rcm
--     ORDER BY p.fecing DESC, p.control_id DESC;

-- END;
-- $$;

COMMENT ON FUNCTION cementerio.sp_consultafol_listar_pagos IS 'Lista historial completo de pagos de un folio RCM ordenado por fecha descendente';

-- =============================================
-- 3. sp_consultafol_listar_adeudos
-- Descripción: Lista adeudos de un folio filtrados por año
-- Parámetros:
--   - p_control_rcm: Número de folio
--   - p_anio: Año para filtrar adeudos (si es NULL o 0, trae todos)
-- Retorna: TABLE con adeudos y su estado de pago
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_consultafol_listar_adeudos(
    p_control_rcm INTEGER,
    p_anio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    id_adeudo INTEGER,
    axo INTEGER,
    --fecha_venc DATE,
    importe NUMERIC(16,2),
    recargos NUMERIC(16,2),
    descuento_importe NUMERIC(16,2),
    descuento_recargos NUMERIC(16,2),
    total NUMERIC(16,2),
    pagado CHAR(1),
    --fecha_pago DATE,
    vigencia CHAR(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Query original Pascal (líneas 440-442, 523-524):
    -- Qryadeudo.ParamByName('vaxo').AsInteger:=Year;
    -- Qryadeudo.Open;
    -- Query original Vue (líneas 486-497):
    -- execute('sp_cem_obtener_adeudos_folio', 'cementerios', { p_control_rcm: folioABuscar.value }, '', null, 'comun')

    -- Cálculo de totales (líneas 456-469 Pascal)
    RETURN QUERY
    SELECT
        a.id_adeudo,
        a.axo_adeudo AS axo,
        --NULL::DATE AS fecha_venc, -- No existe en la tabla actual
        a.importe,
        a.importe_recargos AS recargos,
        COALESCE(a.descto_impote, 0.00) AS descuento_importe,
        COALESCE(a.descto_recargos, 0.00) AS descuento_recargos,
        (a.importe + a.importe_recargos - COALESCE(a.descto_impote, 0) - COALESCE(a.descto_recargos, 0)) AS total,
		CASE WHEN a.id_pago IS NULL THEN 'N' ELSE 'S' END::CHAR(1) AS pagado,

       -- NULL::DATE AS fecha_pago, -- No disponible directamente, se obtiene del pago
        a.vigencia
    FROM public.ta_13_adeudosrcm a
    WHERE a.control_rcm = 2025
      AND a.vigencia = 'V'
      AND (2025 IS NULL OR 2025= 0 OR a.axo_adeudo <= 2025)
    ORDER BY a.axo_adeudo DESC;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_consultafol_listar_adeudos IS 'Lista adeudos de un folio RCM con su estado de pago y totales calculados';

-- =============================================
-- PERMISOS
-- =============================================
-- GRANT EXECUTE ON FUNCTION cementerio.sp_consultafol_buscar_folio TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_consultafol_listar_pagos TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_consultafol_listar_adeudos TO role_cementerio;

-- =============================================
-- FIN DE ARCHIVO
-- =============================================
