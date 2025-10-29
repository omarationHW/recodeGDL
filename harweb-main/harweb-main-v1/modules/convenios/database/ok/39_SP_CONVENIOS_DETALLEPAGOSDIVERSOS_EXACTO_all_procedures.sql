-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: DETALLEPAGOSDIVERSOS (EXACTO del archivo original)
-- Archivo: 39_SP_CONVENIOS_DETALLEPAGOSDIVERSOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_get_pagos_diversos_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de pagos diversos para un id_conv_resto
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_pagos_diversos_detalle(p_id_conv_resto INTEGER)
RETURNS TABLE (
    id_conv_pago INTEGER,
    id_conv_resto INTEGER,
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago VARCHAR(1),
    operacion_pago INTEGER,
    pago_parcial SMALLINT,
    total_parciales SMALLINT,
    importe_pago NUMERIC(18,2),
    importe_recargo NUMERIC(18,2),
    cve_venc SMALLINT,
    cve_descuento SMALLINT,
    cve_bonificacion SMALLINT,
    id_usuario INTEGER,
    fecha_actual TIMESTAMP,
    usuario VARCHAR(50),
    nombre VARCHAR(100),
    estado VARCHAR(1),
    id_rec SMALLINT,
    nivel SMALLINT,
    datosConvenio VARCHAR(100),
    parcialidades VARCHAR(20),
    descParcial VARCHAR(20),
    cve_parcialidad VARCHAR(1),
    intereses NUMERIC(18,2),
    axo_desde SMALLINT,
    mes_desde SMALLINT,
    axo_hasta SMALLINT,
    mes_hasta SMALLINT,
    periodos VARCHAR(50),
    foliorecibo VARCHAR(15),
    id_adeudo INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_conv_pago, a.id_conv_resto, a.fecha_pago, a.oficina_pago, a.caja_pago, a.operacion_pago,
           a.pago_parcial, a.total_parciales, a.importe_pago, a.importe_recargo, a.cve_venc, a.cve_descuento, a.cve_bonificacion,
           a.id_usuario, a.fecha_actual, b.usuario, b.nombre, b.estado, b.id_rec, b.nivel,
           -- datosConvenio
           CASE WHEN a.tipo = 14 THEN CONCAT(a.manzana, '-', a.lote, '-', a.letra)
                ELSE CONCAT(a.letras_exp, '-', a.numero_exp, '-', a.axo_exp) END AS datosConvenio,
           CONCAT(a.pago_parcial, '-', a.total_parciales) AS parcialidades,
           CASE WHEN a.cve_parcialidad = 'I' THEN 'INICIAL' WHEN a.cve_parcialidad = 'P' THEN 'PARCIAL' ELSE 'FINAL' END AS descParcial,
           a.cve_parcialidad,
           (SELECT COALESCE(SUM(importe),0) FROM public.ta_12_recibosdet WHERE fecha=a.fecha_pago AND id_rec=a.oficina_pago AND caja=a.caja_pago AND operacion=a.operacion_pago AND cuenta IN (46508,550200000,551100000)) AS intereses,
           a.axo_desde, a.mes_desde, a.axo_hasta, a.mes_hasta,
           CONCAT(a.mes_desde, '/', a.axo_desde, ' - ', a.mes_hasta, '/', a.axo_hasta) AS periodos,
           a.foliorecibo, a.id_adeudo
    FROM public.ta_17_conv_pagos a
    LEFT JOIN public.ta_12_passwords b ON a.id_usuario = b.id_usuario
    WHERE a.id_conv_resto = p_id_conv_resto
    ORDER BY a.id_conv_resto ASC, a.pago_parcial;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: DETALLEPAGOSDIVERSOS (EXACTO del archivo original)
-- Archivo: 39_SP_CONVENIOS_DETALLEPAGOSDIVERSOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_get_resumen_totales_pagos_diversos
-- Tipo: Report
-- Descripción: Obtiene resumen de totales pagado, recargos, intereses para un id_conv_resto
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_resumen_totales_pagos_diversos(p_id_conv_resto INTEGER)
RETURNS TABLE (
    total_pagado NUMERIC(18,2),
    total_recargos NUMERIC(18,2),
    total_intereses NUMERIC(18,2)
) AS $$
DECLARE
    totpago NUMERIC(18,2) := 0;
    totbonif NUMERIC(18,2) := 0;
    totintereses NUMERIC(18,2) := 0;
BEGIN
    FOR rec IN SELECT importe_pago, importe_recargo, (SELECT COALESCE(SUM(importe),0) FROM public.ta_12_recibosdet WHERE fecha=a.fecha_pago AND id_rec=a.oficina_pago AND caja=a.caja_pago AND operacion=a.operacion_pago AND cuenta IN (46508,550200000,551100000)) AS intereses FROM public.ta_17_conv_pagos a WHERE id_conv_resto = p_id_conv_resto
    LOOP
        totpago := totpago + COALESCE(rec.importe_pago,0);
        totbonif := totbonif + COALESCE(rec.importe_recargo,0);
        totintereses := totintereses + COALESCE(rec.intereses,0);
    END LOOP;
    RETURN QUERY SELECT totpago, totbonif, totintereses;
END;
$$ LANGUAGE plpgsql;

-- ============================================

