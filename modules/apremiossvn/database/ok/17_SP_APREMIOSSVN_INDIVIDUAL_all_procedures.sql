-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - APREMIOSSVN
-- Módulo: Consulta Individual de Folios
-- Archivo: 17_SP_APREMIOSSVN_INDIVIDUAL_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 4
-- ============================================

-- SP 1/4: SP_APREMIOSSVN_GET_INDIVIDUAL_FOLIO
-- Tipo: Report
-- Descripción: Obtiene los datos principales de un folio individual por id (folio)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_GET_INDIVIDUAL_FOLIO(folio_param integer)
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
    dil_descrip varchar,
    pra_descrip varchar,
    sec_descrip varchar,
    rem_descrip varchar,
    usu_descrip varchar,
    clave_mov varchar,
    vig_descrip varchar,
    nombre_eje varchar,
    hora_practicado timestamp,
    mod_desc varchar,
    datos varchar,
    importe_actualizacion numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_control, a.zona, a.modulo, a.control_otr, a.folio, a.diligencia, a.importe_global, 
           a.importe_multa, a.importe_recargo, a.importe_gastos, a.zona_apremio, a.fecha_emision, 
           a.clave_practicado, a.fecha_practicado, a.fecha_entrega1, a.fecha_entrega2, a.fecha_citatorio, 
           a.hora, a.ejecutor, a.clave_secuestro, a.clave_remate, a.fecha_remate, a.porcentaje_multa, 
           a.observaciones, a.fecha_pago, a.recaudadora, a.caja, a.operacion, a.importe_pago, 
           a.vigencia, a.fecha_actualiz, a.usuario,
        (SELECT descrip FROM public.ta_15_claves WHERE clave=a.diligencia AND tipo_clave=4) AS dil_descrip,
        (SELECT descrip FROM public.ta_15_claves WHERE clave=a.clave_practicado AND tipo_clave=1) AS pra_descrip,
        (SELECT descrip FROM public.ta_15_claves WHERE clave=a.clave_secuestro::text AND tipo_clave=2) AS sec_descrip,
        (SELECT descrip FROM public.ta_15_claves WHERE clave=a.clave_remate AND tipo_clave=3) AS rem_descrip,
        (SELECT nombre FROM public.ta_12_passwords WHERE id_usuario=a.usuario) AS usu_descrip,
        a.clave_mov,
        (SELECT descrip FROM public.ta_15_claves WHERE clave=a.vigencia AND tipo_clave=5) AS vig_descrip,
        (SELECT nombre FROM public.ta_15_ejecutores WHERE cve_eje=a.ejecutor AND id_rec=a.zona) AS nombre_eje,
        a.hora_practicado,
        CASE a.modulo
            WHEN 16 THEN 'Aseo'
            WHEN 11 THEN 'Mercado'
            WHEN 24 THEN 'Estacionamientos Publicos'
            WHEN 28 THEN 'Estacionamientos Exclusivos'
            WHEN 14 THEN 'Estacionometros'
            WHEN 13 THEN 'Cementerios'
            ELSE 'Otro'
        END AS mod_desc,
        CASE 
            WHEN a.modulo = 16 THEN 'Contrato: ' || COALESCE((SELECT num_contrato::text FROM public.ta_16_contratos WHERE control_contrato = a.control_otr), 'N/A')
            WHEN a.modulo = 11 THEN 'Local: ' || COALESCE((SELECT local::text FROM public.ta_11_locales WHERE id_local = a.control_otr), 'N/A')
            WHEN a.modulo = 13 THEN 'Control: ' || COALESCE((SELECT control_rcm::text FROM public.ta_13_datosrcm WHERE control_rcm = a.control_otr), 'N/A')
            ELSE 'Control: ' || COALESCE(a.control_otr::text, 'N/A')
        END AS datos,
        a.importe_actualizacion
    FROM public.ta_15_apremios a
    WHERE a.folio = folio_param;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: SP_APREMIOSSVN_GET_INDIVIDUAL_FOLIO_HISTORY
-- Tipo: Report
-- Descripción: Obtiene el historial de movimientos de un folio individual
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_GET_INDIVIDUAL_FOLIO_HISTORY(id_control_param integer)
RETURNS TABLE (
    id_historia integer,
    id_control integer,
    control integer,
    zona smallint,
    modulo smallint,
    control_otr integer,
    folio integer,
    diligencia varchar,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
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
    SELECT h.id_historia, h.id_control, h.control, h.zona, h.modulo, h.control_otr, h.folio, h.diligencia, 
           h.importe_global, h.importe_multa, h.importe_recargo, h.importe_gastos, h.zona_apremio, 
           h.fecha_emision, h.clave_practicado, h.fecha_practicado, h.fecha_entrega1, h.fecha_entrega2, 
           h.fecha_citatorio, h.hora, h.ejecutor, h.clave_secuestro, h.clave_remate, h.fecha_remate, 
           h.porcentaje_multa, h.observaciones, h.fecha_pago, h.recaudadora, h.caja, h.operacion, 
           h.importe_pago, h.vigencia, h.fecha_actualiz, h.usuario, h.clave_mov, h.hora_practicado
    FROM public.ta_15_historia h 
    WHERE h.control = id_control_param
    ORDER BY h.fecha_actualiz DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: SP_APREMIOSSVN_GET_INDIVIDUAL_FOLIO_PERIODS
-- Tipo: Report
-- Descripción: Obtiene los periodos asociados a un folio individual
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_GET_INDIVIDUAL_FOLIO_PERIODS(id_control_param integer)
RETURNS TABLE (
    id_periodo integer,
    id_control integer,
    control_otr integer,
    ayo smallint,
    periodo integer,
    importe numeric,
    recargos numeric,
    cantidad numeric,
    tipo varchar,
    descripcion_periodo varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id_periodo,
        p.id_control,
        p.control_otr, 
        p.ayo, 
        p.periodo, 
        p.importe, 
        p.recargos, 
        p.cantidad,
        p.tipo,
        CASE 
            WHEN p.tipo = 'M' THEN 'Mensual - ' || 
                CASE p.periodo
                    WHEN 1 THEN 'Enero'
                    WHEN 2 THEN 'Febrero' 
                    WHEN 3 THEN 'Marzo'
                    WHEN 4 THEN 'Abril'
                    WHEN 5 THEN 'Mayo'
                    WHEN 6 THEN 'Junio'
                    WHEN 7 THEN 'Julio'
                    WHEN 8 THEN 'Agosto'
                    WHEN 9 THEN 'Septiembre'
                    WHEN 10 THEN 'Octubre'
                    WHEN 11 THEN 'Noviembre'
                    WHEN 12 THEN 'Diciembre'
                    ELSE 'Periodo ' || p.periodo::text
                END || ' ' || p.ayo::text
            WHEN p.tipo = 'B' THEN 'Bimestral - Bimestre ' || p.periodo::text || ' del ' || p.ayo::text
            WHEN p.tipo = 'A' THEN 'Anual - Año ' || p.ayo::text
            ELSE 'Periodo ' || COALESCE(p.periodo::text, 'N/A') || ' del ' || p.ayo::text
        END as descripcion_periodo
    FROM public.ta_15_periodos p 
    WHERE p.control_otr = id_control_param
    ORDER BY p.ayo, p.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: SP_APREMIOSSVN_GET_MODULE_DETAILS
-- Tipo: Catalog
-- Descripción: Obtiene el detalle de la aplicación asociada al folio según el módulo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_GET_MODULE_DETAILS(modulo_param integer, control_otr_param integer)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    IF modulo_param = 16 THEN
        SELECT row_to_json(t)::jsonb INTO result FROM (
            SELECT * FROM public.ta_16_contratos WHERE control_contrato = control_otr_param
        ) t;
    ELSIF modulo_param = 11 THEN
        SELECT row_to_json(t)::jsonb INTO result FROM (
            SELECT * FROM public.ta_11_locales WHERE id_local = control_otr_param
        ) t;
    ELSIF modulo_param = 24 THEN
        SELECT row_to_json(t)::jsonb INTO result FROM (
            SELECT * FROM public.pubmain WHERE id = control_otr_param
        ) t;
    ELSIF modulo_param = 28 THEN
        SELECT row_to_json(t)::jsonb INTO result FROM (
            SELECT * FROM public.ex_contrato WHERE id = control_otr_param
        ) t;
    ELSIF modulo_param = 14 THEN
        SELECT row_to_json(t)::jsonb INTO result FROM (
            SELECT * FROM public.ta_padron WHERE id = control_otr_param
        ) t;
    ELSIF modulo_param = 13 THEN
        SELECT row_to_json(t)::jsonb INTO result FROM (
            SELECT * FROM public.ta_13_datosrcm WHERE control_rcm = control_otr_param
        ) t;
    ELSE
        result := jsonb_build_object('error', 'Módulo no soportado', 'modulo', modulo_param);
    END IF;
    
    IF result IS NULL THEN
        result := jsonb_build_object('error', 'No se encontraron datos', 'modulo', modulo_param, 'control_otr', control_otr_param);
    END IF;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- ============================================