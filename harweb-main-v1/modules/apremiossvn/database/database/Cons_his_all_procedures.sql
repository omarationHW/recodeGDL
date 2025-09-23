-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Cons_his
-- Generado: 2025-08-27 13:42:45
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_get_cons_his
-- Tipo: Report
-- Descripción: Obtiene la información principal del folio de apremios (historia) con descripciones relacionadas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cons_his(p_control integer)
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
        (SELECT descrip FROM ta_15_claves WHERE clave=a.diligencia AND tipo_clave=4 LIMIT 1) AS dil_descrip,
        (SELECT descrip FROM ta_15_claves WHERE clave=a.clave_practicado AND tipo_clave=1 LIMIT 1) AS pra_descrip,
        (SELECT descrip FROM ta_15_claves WHERE clave=a.clave_secuestro::varchar AND tipo_clave=2 LIMIT 1) AS sec_descrip,
        (SELECT descrip FROM ta_15_claves WHERE clave=a.clave_remate AND tipo_clave=3 LIMIT 1) AS rem_descrip,
        (SELECT descrip FROM ta_15_claves WHERE clave=a.clave_mov AND tipo_clave=5 LIMIT 1) AS vig_descrip,
        (SELECT nombre FROM ta_12_passwords WHERE id_usuario=a.usuario LIMIT 1) AS usu_descrip,
        (SELECT nombre FROM ta_15_ejecutores WHERE cve_eje=a.ejecutor AND id_rec=a.zona LIMIT 1) AS nombre_eje
    FROM ta_15_historia a
    WHERE a.id_control = p_control
    ORDER BY a.control DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_get_cons_his_details
-- Tipo: Report
-- Descripción: Obtiene los detalles de periodos asociados al control_otr.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cons_his_details(p_control_otr integer)
RETURNS TABLE (
    id_control integer,
    control_otr integer,
    ayo smallint,
    periodo smallint,
    importe numeric,
    recargos numeric,
    cantidad numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_control, control_otr, ayo, periodo, importe, recargos, cantidad
    FROM ta_15_periodos
    WHERE control_otr = p_control_otr;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_get_aseo_reference
-- Tipo: Catalog
-- Descripción: Obtiene la referencia de aseo para un contrato dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_aseo_reference(p_contrato integer)
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
    FROM ta_16_contratos a
    JOIN ta_16_tipo_aseo c ON a.ctrol_aseo = c.ctrol_aseo
    JOIN ta_16_empresas d ON a.num_empresa = d.num_empresa
    WHERE a.control_contrato = p_contrato;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_get_mercado_reference
-- Tipo: Catalog
-- Descripción: Obtiene la referencia de mercado para un local dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_mercado_reference(p_local integer)
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
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, id_contribuy_prop, id_contribuy_renta, nombre, arrendatario, domicilio, sector, zona, descripcion_local, superficie, giro, fecha_alta, fecha_baja, fecha_modificacion, vigencia, id_usuario, clave_cuota
    FROM ta_11_locales
    WHERE id_local = p_local;
END;
$$ LANGUAGE plpgsql;

-- ============================================

