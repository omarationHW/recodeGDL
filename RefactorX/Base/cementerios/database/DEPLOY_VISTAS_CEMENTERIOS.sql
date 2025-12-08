-- =====================================================
-- DEPLOYMENT: Vistas necesarias para SPs de Cementerios
-- Base de datos: cementerio.public
-- Fecha: 2025-11-26
-- =====================================================
-- Vistas creadas:
-- 1. v_ta_13_pagosrcm - Vista sobre pagos RCM
-- 2. v_tc_13_cementerios - Vista sobre catálogo de cementerios
-- =====================================================

-- Vista 1: v_ta_13_pagosrcm
-- Proporciona acceso simplificado a la tabla de pagos RCM
-- Usada por: sp_cem_consultar_pagos_folio, sp_cem_consultar_pagos_por_fecha, sp_cem_obtener_pagos_folio
CREATE OR REPLACE VIEW public.v_ta_13_pagosrcm AS
SELECT
    fecing,
    recing,
    cajing,
    opcaja,
    control_id,
    control_rcm,
    cementerio,
    clase,
    clase_alfa,
    seccion,
    seccion_alfa,
    linea,
    linea_alfa,
    fosa,
    fosa_alfa,
    axo_pago_desde,
    axo_pago_hasta,
    importe_anual,
    importe_recargos,
    vigencia,
    usuario,
    fecha_mov
FROM public.ta_13_pagosrcm;

-- Comentario
COMMENT ON VIEW public.v_ta_13_pagosrcm IS 'Vista sobre tabla de pagos de cementerios RCM - Usada por SPs de consulta';

-- Vista 2: v_tc_13_cementerios
-- Proporciona acceso simplificado al catálogo de cementerios
-- Usada por: sp_cem_consultar_folios_por_nombre
CREATE OR REPLACE VIEW public.v_tc_13_cementerios AS
SELECT
    cementerio,
    nombre,
    domicilio,
    cta_aplicacion,
    cta_vencido,
    cta_descto,
    cta_desctopens,
    cta_desctopens_rez,
    cta_actualizacion
FROM public.tc_13_cementerios;

-- Comentario
COMMENT ON VIEW public.v_tc_13_cementerios IS 'Vista sobre catálogo de cementerios - Usada por SPs de consulta';

-- =====================================================
-- Verificación de vistas creadas
-- =====================================================
-- SELECT viewname, definition FROM pg_views WHERE schemaname = 'public' AND viewname LIKE 'v_%13_%';

-- =====================================================
-- FIN DEL DEPLOYMENT
-- =====================================================
