-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - APREMIOSSVN
-- Módulo: Consulta de Historia
-- Archivo: 22_SP_APREMIOSSVN_CONS_HIS_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 4
-- ============================================

-- SP 1/4: SP_APREMIOSSVN_GET_CONS_HIS
-- Tipo: Report
-- Descripción: Obtiene la información principal del folio de apremios (historia) con descripciones relacionadas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_GET_CONS_HIS(p_control integer)
RETURNS TABLE (
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
    hora_practicado timestamp,
    dil_descrip varchar,
    pra_descrip varchar,
    sec_descrip varchar,
    rem_descrip varchar,
    vig_descrip varchar,
    usu_descrip varchar,
    nombre_eje varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_control, a.control, a.zona, a.modulo, a.control_otr, a.folio, a.diligencia, a.importe_global, a.importe_multa, a.importe_recargo, a.importe_gastos, a.zona_apremio, a.fecha_emision, a.clave_practicado, a.fecha_practicado, a.fecha_entrega1, a.fecha_entrega2, a.fecha_citatorio, a.hora, a.ejecutor, a.clave_secuestro, a.clave_remate, a.fecha_remate, a.porcentaje_multa, a.observaciones, a.fecha_pago, a.recaudadora, a.caja, a.operacion, a.importe_pago, a.vigencia, a.fecha_actualiz, a.usuario, a.clave_mov, a.hora_practicado,
        (SELECT descrip FROM public.ta_15_claves WHERE clave=a.diligencia AND tipo_clave=4 LIMIT 1) AS dil_descrip,
        (SELECT descrip FROM public.ta_15_claves WHERE clave=a.clave_practicado AND tipo_clave=1 LIMIT 1) AS pra_descrip,
        (SELECT descrip FROM public.ta_15_claves WHERE clave=a.clave_secuestro::varchar AND tipo_clave=2 LIMIT 1) AS sec_descrip,
        (SELECT descrip FROM public.ta_15_claves WHERE clave=a.clave_remate AND tipo_clave=3 LIMIT 1) AS rem_descrip,
        (SELECT descrip FROM public.ta_15_claves WHERE clave=a.vigencia AND tipo_clave=5 LIMIT 1) AS vig_descrip,
        (SELECT nombre FROM public.ta_12_passwords WHERE id_usuario=a.usuario LIMIT 1) AS usu_descrip,
        (SELECT nombre FROM public.ta_15_ejecutores WHERE cve_eje=a.ejecutor AND id_rec=a.zona LIMIT 1) AS nombre_eje
    FROM public.ta_15_historia a
    WHERE a.control = p_control
    ORDER BY a.fecha_actualiz DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: SP_APREMIOSSVN_GET_CONS_HIS_DETAILS
-- Tipo: Report
-- Descripción: Obtiene los detalles de periodos asociados al control_otr.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_GET_CONS_HIS_DETAILS(p_control_otr integer)
RETURNS TABLE (
    id_control integer,
    control_otr integer,
    ayo smallint,
    periodo smallint,
    importe numeric,
    recargos numeric,
    cantidad numeric,
    tipo varchar,
    descripcion_periodo varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
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
                    WHEN 1 THEN 'Enero' WHEN 2 THEN 'Febrero' WHEN 3 THEN 'Marzo'
                    WHEN 4 THEN 'Abril' WHEN 5 THEN 'Mayo' WHEN 6 THEN 'Junio'
                    WHEN 7 THEN 'Julio' WHEN 8 THEN 'Agosto' WHEN 9 THEN 'Septiembre'
                    WHEN 10 THEN 'Octubre' WHEN 11 THEN 'Noviembre' WHEN 12 THEN 'Diciembre'
                    ELSE 'Periodo ' || p.periodo::text
                END || ' ' || p.ayo::text
            WHEN p.tipo = 'B' THEN 'Bimestral - Bimestre ' || p.periodo::text || ' del ' || p.ayo::text
            WHEN p.tipo = 'A' THEN 'Anual - Año ' || p.ayo::text
            ELSE 'Periodo ' || COALESCE(p.periodo::text, 'N/A') || ' del ' || p.ayo::text
        END as descripcion_periodo
    FROM public.ta_15_periodos p
    WHERE p.control_otr = p_control_otr
    ORDER BY p.ayo, p.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: SP_APREMIOSSVN_GET_ASEO_REFERENCE
-- Tipo: Catalog
-- Descripción: Obtiene la referencia de aseo para un contrato dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_GET_ASEO_REFERENCE(p_contrato integer)
RETURNS TABLE (
    control_contrato integer,
    num_contrato integer,
    ctrol_aseo integer,
    id_rec smallint,
    num_empresa integer,
    ctrol_recolec integer,
    cantidad_recolec smallint,
    fecha_hora_alta timestamp,
    status_vigencia varchar,
    aso_mes_oblig timestamp,
    cve varchar,
    usuario integer,
    fecha_hora_baja timestamp,
    ctrol_aseo_1 integer,
    tipo_aseo varchar,
    descripcion varchar,
    cta_aplicacion integer,
    num_empresa_1 integer,
    ctrol_emp integer,
    descripcion_1 varchar,
    representante varchar,
    domicilio varchar,
    sector varchar,
    ctrol_zona integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_contrato, a.num_contrato, a.ctrol_aseo, a.id_rec, a.num_empresa, a.ctrol_recolec, a.cantidad_recolec, a.fecha_hora_alta, a.status_vigencia, a.aso_mes_oblig, a.cve, a.usuario, a.fecha_hora_baja,
           c.ctrol_aseo AS ctrol_aseo_1, c.tipo_aseo, c.descripcion, c.cta_aplicacion,
           d.num_empresa AS num_empresa_1, d.ctrol_emp, d.descripcion AS descripcion_1, d.representante, d.domicilio, d.sector, d.ctrol_zona
    FROM public.ta_16_contratos a
    JOIN public.ta_16_tipo_aseo c ON a.ctrol_aseo = c.ctrol_aseo
    JOIN public.ta_16_empresas d ON a.num_empresa = d.num_empresa
    WHERE a.control_contrato = p_contrato;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: SP_APREMIOSSVN_GET_MERCADO_REFERENCE
-- Tipo: Catalog
-- Descripción: Obtiene la referencia de mercado para un local dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_GET_MERCADO_REFERENCE(p_local integer)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    local smallint,
    letra_local varchar,
    bloque varchar,
    id_contribuy_prop integer,
    id_contribuy_renta integer,
    nombre varchar,
    arrendatario varchar,
    domicilio varchar,
    sector varchar,
    zona smallint,
    descripcion_local varchar,
    superficie float,
    giro smallint,
    fecha_alta date,
    fecha_baja date,
    fecha_modificacion timestamp,
    vigencia varchar,
    id_usuario integer,
    clave_cuota smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_local, l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque, l.id_contribuy_prop, l.id_contribuy_renta, l.nombre, l.arrendatario, l.domicilio, l.sector, l.zona, l.descripcion_local, l.superficie, l.giro, l.fecha_alta, l.fecha_baja, l.fecha_modificacion, l.vigencia, l.id_usuario, l.clave_cuota
    FROM public.ta_11_locales l
    WHERE l.id_local = p_local;
END;
$$ LANGUAGE plpgsql;

-- ============================================