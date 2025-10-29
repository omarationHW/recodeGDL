-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptRecup_Aseo
-- Generado: 2025-08-27 15:00:57
-- Total SPs: 3
-- ============================================

-- SP 1/3: rptrecup_aseo_report
-- Tipo: Report
-- Descripción: Obtiene el reporte de adeudos de aseo contratado para un rango de folios y oficina.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rptrecup_aseo_report(
    p_ofna integer,
    p_folio1 integer,
    p_folio2 integer
)
RETURNS TABLE (
    control_contrato integer,
    num_contrato integer,
    ctrol_aseo integer,
    num_empresa integer,
    ctrol_emp integer,
    ctrol_recolec integer,
    cantidad_recolec smallint,
    domicilio varchar,
    sector varchar,
    ctrol_zona integer,
    id_rec smallint,
    fecha_hora_alta timestamp,
    status_vigencia varchar,
    aso_mes_oblig timestamp,
    cve varchar,
    usuario integer,
    fecha_hora_baja timestamp,
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
    usuario_1 integer,
    clave_mov varchar,
    hora_practicado timestamp,
    id_control_1 integer,
    control_otr_1 integer,
    ayo smallint,
    periodo smallint,
    importe numeric,
    recargos numeric,
    cantidad numeric,
    ctrol_aseo_1 integer,
    tipo_aseo varchar,
    descripcion varchar,
    cta_aplicacion integer,
    num_empresa_1 integer,
    ctrol_emp_1 integer,
    descripcion_1 varchar,
    representante varchar,
    ctrol_zona_1 integer,
    zona_1 smallint,
    sub_zona smallint,
    descripcion_2 varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_contrato, a.num_contrato, a.ctrol_aseo, a.num_empresa, a.ctrol_emp, a.ctrol_recolec, a.cantidad_recolec, a.domicilio, a.sector, a.ctrol_zona, a.id_rec, a.fecha_hora_alta, a.status_vigencia, a.aso_mes_oblig, a.cve, a.usuario, a.fecha_hora_baja,
           b.id_control, b.zona, b.modulo, b.control_otr, b.folio, b.diligencia, b.importe_global, b.importe_multa, b.importe_recargo, b.importe_gastos, b.zona_apremio, b.fecha_emision, b.clave_practicado, b.fecha_practicado, b.fecha_entrega1, b.fecha_entrega2, b.fecha_citatorio, b.hora, b.ejecutor, b.clave_secuestro, b.clave_remate, b.fecha_remate, b.porcentaje_multa, b.observaciones, b.fecha_pago, b.recaudadora, b.caja, b.operacion, b.importe_pago, b.vigencia, b.fecha_actualiz, b.usuario as usuario_1, b.clave_mov, b.hora_practicado,
           g.id_control as id_control_1, g.control_otr as control_otr_1, g.ayo, g.periodo, g.importe, g.recargos, g.cantidad,
           c.ctrol_aseo as ctrol_aseo_1, c.tipo_aseo, c.descripcion, c.cta_aplicacion,
           d.num_empresa as num_empresa_1, d.ctrol_emp as ctrol_emp_1, d.descripcion as descripcion_1, d.representante,
           f.ctrol_zona as ctrol_zona_1, f.zona as zona_1, f.sub_zona, f.descripcion as descripcion_2
    FROM ta_16_contratos a
    JOIN ta_15_apremios b ON a.control_contrato = b.control_otr
    JOIN ta_15_periodos g ON b.id_control = g.control_otr
    JOIN ta_16_tipo_aseo c ON a.ctrol_aseo = c.ctrol_aseo
    JOIN ta_16_empresas d ON a.num_empresa = d.num_empresa
    JOIN ta_16_zonas f ON a.ctrol_zona = f.ctrol_zona
    WHERE b.zona = p_ofna
      AND b.modulo = 16
      AND b.folio >= p_folio1 AND b.folio <= p_folio2
      AND b.vigencia = '1'
    ORDER BY b.folio, g.id_control;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: rptrecup_aseo_recaudadora
-- Tipo: Catalog
-- Descripción: Obtiene los datos de la recaudadora para la oficina/ofna dada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rptrecup_aseo_recaudadora(
    p_ofna integer
)
RETURNS TABLE (
    id_rec smallint,
    id_zona integer,
    recaudadora varchar,
    domicilio varchar,
    tel varchar,
    recaudador varchar,
    sector varchar,
    recing smallint,
    nomre varchar,
    id_zona_1 integer,
    zona varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_rec, a.id_zona, a.recaudadora, a.domicilio, a.tel, a.recaudador, a.sector, b.recing, b.nomre, c.id_zona as id_zona_1, c.zona
    FROM ta_12_recaudadoras a
    JOIN ta_12_nombrerec b ON a.id_rec = b.recing
    JOIN ta_12_zonas c ON a.id_zona = c.id_zona
    WHERE a.id_rec = p_ofna;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: fecha_a_letras
-- Tipo: CRUD
-- Descripción: Convierte una fecha a formato 'día de Mes de Año' en español.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION fecha_a_letras(p_fecha date)
RETURNS text AS $$
DECLARE
    meses text[] := ARRAY['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
    d integer;
    m integer;
    y integer;
BEGIN
    d := EXTRACT(DAY FROM p_fecha);
    m := EXTRACT(MONTH FROM p_fecha);
    y := EXTRACT(YEAR FROM p_fecha);
    RETURN d::text || ' de ' || meses[m] || ' de ' || y::text;
END;
$$ LANGUAGE plpgsql;

-- ============================================

