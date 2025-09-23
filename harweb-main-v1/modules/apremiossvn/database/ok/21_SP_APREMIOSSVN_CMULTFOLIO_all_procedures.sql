-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - APREMIOSSVN
-- Módulo: Consulta Múltiple por Folio
-- Archivo: 21_SP_APREMIOSSVN_CMULTFOLIO_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 3
-- ============================================

-- SP 1/3: SP_APREMIOSSVN_CMULTFOLIO_SEARCH
-- Tipo: Report
-- Descripción: Busca folios en ta_15_apremios por módulo, zona y folio inicial (devuelve hasta 100 consecutivos)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_CMULTFOLIO_SEARCH(p_modulo integer, p_zona integer, p_folio integer)
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
    ejecutor_nombre varchar,
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
    SELECT a.id_control, a.zona, a.modulo, a.control_otr, a.folio, a.diligencia, a.importe_global, a.importe_multa, a.importe_recargo, a.importe_actualizacion, a.importe_gastos, a.zona_apremio, a.fecha_emision, a.clave_practicado, a.fecha_practicado, a.fecha_entrega1, a.fecha_entrega2, a.fecha_citatorio, a.hora, a.ejecutor, 
    COALESCE(e.nombre, 'Sin asignar') as ejecutor_nombre,
    a.clave_secuestro, a.clave_remate, a.fecha_remate, a.porcentaje_multa, a.observaciones, a.fecha_pago, a.recaudadora, a.caja, a.operacion, a.importe_pago, a.vigencia, a.fecha_actualiz, a.usuario, a.clave_mov, a.hora_practicado
    FROM public.ta_15_apremios a
    LEFT JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    WHERE a.modulo = p_modulo
      AND a.zona = p_zona
      AND a.folio BETWEEN p_folio AND (p_folio + 100)
    ORDER BY a.folio ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: SP_APREMIOSSVN_CMULTFOLIO_DETAIL
-- Tipo: Report
-- Descripción: Devuelve el detalle de un folio por id_control
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_CMULTFOLIO_DETAIL(p_id_control integer)
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
    ejecutor_nombre varchar,
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
    SELECT a.id_control, a.zona, a.modulo, a.control_otr, a.folio, a.diligencia, a.importe_global, a.importe_multa, a.importe_recargo, a.importe_actualizacion, a.importe_gastos, a.zona_apremio, a.fecha_emision, a.clave_practicado, a.fecha_practicado, a.fecha_entrega1, a.fecha_entrega2, a.fecha_citatorio, a.hora, a.ejecutor,
    COALESCE(e.nombre, 'Sin asignar') as ejecutor_nombre,
    a.clave_secuestro, a.clave_remate, a.fecha_remate, a.porcentaje_multa, a.observaciones, a.fecha_pago, a.recaudadora, a.caja, a.operacion, a.importe_pago, a.vigencia, a.fecha_actualiz, a.usuario, a.clave_mov, a.hora_practicado
    FROM public.ta_15_apremios a
    LEFT JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    WHERE a.id_control = p_id_control;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: SP_APREMIOSSVN_CMULTFOLIO_INDIVIDUAL
-- Tipo: Report
-- Descripción: Devuelve el detalle individual extendido de un folio (para vista individual)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_CMULTFOLIO_INDIVIDUAL(p_id_control integer)
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
    ejecutor_nombre varchar,
    clave_secuestro smallint,
    clave_remate varchar,
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar,
    fecha_pago date,
    recaudadora smallint,
    recaudadora_nombre varchar,
    caja varchar,
    operacion integer,
    importe_pago numeric,
    vigencia varchar,
    fecha_actualiz date,
    usuario integer,
    usuario_nombre varchar,
    clave_mov varchar,
    hora_practicado timestamp,
    modulo_descripcion varchar,
    datos_contribuyente varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_control, a.zona, a.modulo, a.control_otr, a.folio, a.diligencia, a.importe_global, a.importe_multa, a.importe_recargo, a.importe_actualizacion, a.importe_gastos, a.zona_apremio, a.fecha_emision, a.clave_practicado, a.fecha_practicado, a.fecha_entrega1, a.fecha_entrega2, a.fecha_citatorio, a.hora, a.ejecutor,
    COALESCE(e.nombre, 'Sin asignar') as ejecutor_nombre,
    a.clave_secuestro, a.clave_remate, a.fecha_remate, a.porcentaje_multa, a.observaciones, a.fecha_pago, a.recaudadora,
    COALESCE(r.recaudadora, 'No especificada') as recaudadora_nombre,
    a.caja, a.operacion, a.importe_pago, a.vigencia, a.fecha_actualiz, a.usuario,
    COALESCE(u.nombre, 'Usuario no encontrado') as usuario_nombre,
    a.clave_mov, a.hora_practicado,
    CASE a.modulo
        WHEN 16 THEN 'Aseo'
        WHEN 11 THEN 'Mercados'
        WHEN 24 THEN 'Estacionamientos Públicos'
        WHEN 28 THEN 'Estacionamientos Exclusivos'
        WHEN 14 THEN 'Estacionómetros'
        WHEN 13 THEN 'Cementerios'
        ELSE 'Módulo ' || a.modulo::text
    END as modulo_descripcion,
    CASE 
        WHEN a.modulo = 16 THEN 'Aseo - Contrato: ' || COALESCE((SELECT num_contrato::text FROM public.ta_16_contratos WHERE control_contrato = a.control_otr), 'N/A')
        WHEN a.modulo = 11 THEN 'Mercados - Local: ' || COALESCE((SELECT local::text FROM public.ta_11_locales WHERE id_local = a.control_otr), 'N/A')
        WHEN a.modulo = 13 THEN 'Cementerios - Control: ' || COALESCE((SELECT control_rcm::text FROM public.ta_13_datosrcm WHERE control_rcm = a.control_otr), 'N/A')
        ELSE 'Control: ' || COALESCE(a.control_otr::text, 'N/A')
    END as datos_contribuyente
    FROM public.ta_15_apremios a
    LEFT JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    LEFT JOIN public.ta_12_recaudadoras r ON a.recaudadora = r.id_rec
    LEFT JOIN public.ta_12_passwords u ON a.usuario = u.id_usuario
    WHERE a.id_control = p_id_control;
END;
$$ LANGUAGE plpgsql;

-- ============================================