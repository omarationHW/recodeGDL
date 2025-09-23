-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - APREMIOSSVN
-- Módulo: Consulta Múltiple por Emisión
-- Archivo: 16_SP_APREMIOSSVN_CONSULTA_MULT_EMISION_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 2
-- ============================================

-- SP 1/2: SP_APREMIOSSVN_CMULTEMISION_SEARCH
-- Tipo: Report
-- Descripción: Busca folios por módulo, zona y fecha de emisión.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_CMULTEMISION_SEARCH(p_modulo integer, p_zona integer, p_fecha date)
RETURNS TABLE (
    id_control integer,
    zona smallint,
    modulo smallint,
    control_otr integer,
    folio integer,
    diligencia varchar,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_actualizacion numeric,
    importe_gastos numeric,
    zona_apremio smallint,
    fecha_emision date,
    clave_practicado varchar,
    fecha_practicado date,
    fecha_entrega1 date,
    fecha_entrega2 date,
    fecha_citatorio date,
    hora timestamp,
    ejecutor smallint,
    ejecutor_nombre text,
    clave_secuestro smallint,
    clave_remate varchar,
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar,
    fecha_pago date,
    recaudadora smallint,
    caja varchar,
    operacion integer,
    importe_pago numeric,
    vigencia varchar,
    fecha_actualiz date,
    usuario integer,
    clave_mov varchar,
    hora_practicado timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_control, a.zona, a.modulo, a.control_otr, a.folio, a.diligencia, a.importe_global, 
        a.importe_multa, a.importe_recargo, a.importe_actualizacion, a.importe_gastos, 
        a.zona_apremio, a.fecha_emision, a.clave_practicado, a.fecha_practicado, 
        a.fecha_entrega1, a.fecha_entrega2, a.fecha_citatorio, a.hora, a.ejecutor,
        COALESCE(e.nombre, 'Sin asignar') as ejecutor_nombre,
        a.clave_secuestro, a.clave_remate, a.fecha_remate, a.porcentaje_multa, 
        a.observaciones, a.fecha_pago, a.recaudadora, a.caja, a.operacion, 
        a.importe_pago, a.vigencia, a.fecha_actualiz, a.usuario, a.clave_mov, a.hora_practicado
    FROM public.ta_15_apremios a
    LEFT JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    WHERE a.modulo = p_modulo AND a.zona = p_zona AND a.fecha_emision = p_fecha
    ORDER BY a.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: SP_APREMIOSSVN_CMULTEMISION_FOLIO_DETAIL
-- Tipo: Report
-- Descripción: Obtiene el detalle completo de un folio por id_control.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_CMULTEMISION_FOLIO_DETAIL(p_id_control integer)
RETURNS TABLE (
    id_control integer,
    zona smallint,
    modulo smallint,
    control_otr integer,
    folio integer,
    diligencia varchar,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_actualizacion numeric,
    importe_gastos numeric,
    zona_apremio smallint,
    fecha_emision date,
    clave_practicado varchar,
    fecha_practicado date,
    fecha_entrega1 date,
    fecha_entrega2 date,
    fecha_citatorio date,
    hora timestamp,
    ejecutor smallint,
    ejecutor_nombre text,
    clave_secuestro smallint,
    clave_remate varchar,
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar,
    fecha_pago date,
    recaudadora smallint,
    caja varchar,
    operacion integer,
    importe_pago numeric,
    vigencia varchar,
    fecha_actualiz date,
    usuario integer,
    clave_mov varchar,
    hora_practicado timestamp,
    modulo_descripcion text,
    datos_contribuyente text
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_control, a.zona, a.modulo, a.control_otr, a.folio, a.diligencia, a.importe_global, 
        a.importe_multa, a.importe_recargo, a.importe_actualizacion, a.importe_gastos, 
        a.zona_apremio, a.fecha_emision, a.clave_practicado, a.fecha_practicado, 
        a.fecha_entrega1, a.fecha_entrega2, a.fecha_citatorio, a.hora, a.ejecutor,
        COALESCE(e.nombre, 'Sin asignar') as ejecutor_nombre,
        a.clave_secuestro, a.clave_remate, a.fecha_remate, a.porcentaje_multa, 
        a.observaciones, a.fecha_pago, a.recaudadora, a.caja, a.operacion, 
        a.importe_pago, a.vigencia, a.fecha_actualiz, a.usuario, a.clave_mov, a.hora_practicado,
        CASE a.modulo
            WHEN 16 THEN 'Aseo'
            WHEN 11 THEN 'Mercados'
            WHEN 24 THEN 'Estacionamientos Públicos'
            WHEN 28 THEN 'Estacionamientos Exclusivos'
            WHEN 14 THEN 'Estacionómetros'
            WHEN 13 THEN 'Cementerios'
            ELSE 'Otro Módulo'
        END as modulo_descripcion,
        CASE 
            WHEN a.modulo = 16 THEN 'Aseo - Contrato: ' || COALESCE(ta_16_contratos.num_contrato::text,'N/A')
            WHEN a.modulo = 11 THEN 'Mercados - Local: ' || COALESCE(ta_11_locales.local::text,'N/A')
            WHEN a.modulo = 13 THEN 'Cementerios - Control: ' || COALESCE(ta_13_datosrcm.control_rcm::text,'N/A')
            ELSE 'Módulo: ' || a.modulo::text || ' - Control: ' || COALESCE(a.control_otr::text,'N/A')
        END as datos_contribuyente
    FROM public.ta_15_apremios a
    LEFT JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    LEFT JOIN public.ta_16_contratos ON a.modulo = 16 AND a.control_otr = ta_16_contratos.control_contrato
    LEFT JOIN public.ta_11_locales ON a.modulo = 11 AND a.control_otr = ta_11_locales.id_local
    LEFT JOIN public.ta_13_datosrcm ON a.modulo = 13 AND a.control_otr = ta_13_datosrcm.control_rcm
    WHERE a.id_control = p_id_control;
END;
$$ LANGUAGE plpgsql;

-- ============================================