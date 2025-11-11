-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RprtListaxRegAseo
-- Generado: 2025-08-27 14:41:01
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_rprt_listax_reg_aseo
-- Tipo: Report
-- Descripción: Obtiene el listado de registros de aseo con requerimientos, filtrando por oficina, tipo de aseo, clave practicado y vigencia.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rprt_listax_reg_aseo(
    p_id_rec integer,
    p_tipo_aseo text,
    p_clave_practicado text DEFAULT 'todas',
    p_vigencia text DEFAULT 'todas'
)
RETURNS TABLE (
    control_contrato integer,
    num_contrato integer,
    ctrol_aseo integer,
    num_empresa integer,
    ctrol_emp integer,
    ctrol_recolec integer,
    cantidad_recolec smallint,
    domicilio text,
    sector text,
    ctrol_zona integer,
    id_rec smallint,
    fecha_hora_alta timestamp,
    status_vigencia text,
    aso_mes_oblig date,
    cve text,
    usuario integer,
    fecha_hora_baja timestamp,
    id_control integer,
    zona smallint,
    modulo smallint,
    control_otr integer,
    folio integer,
    diligencia text,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_gastos numeric,
    zona_apremio smallint,
    fecha_emision date,
    clave_practicado text,
    fecha_practicado date,
    fecha_entrega1 date,
    fecha_entrega2 date,
    fecha_citatorio date,
    hora timestamp,
    ejecutor smallint,
    clave_secuestro smallint,
    clave_remate text,
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones text,
    fecha_pago date,
    recaudadora smallint,
    caja text,
    operacion integer,
    importe_pago numeric,
    vigencia text,
    fecha_actualiz date,
    usuario_1 integer,
    clave_mov text,
    hora_practicado timestamp,
    id_ejecutor integer,
    cve_eje integer,
    ini_rfc text,
    fec_rfc date,
    hom_rfc text,
    nombre text,
    id_rec_1 smallint,
    categoria text,
    observacion text,
    ctrol_aseo_1 integer,
    tipo_aseo text,
    descripcion text,
    cta_aplicacion integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_contrato, a.num_contrato, a.ctrol_aseo, a.num_empresa, a.ctrol_emp, a.ctrol_recolec, a.cantidad_recolec, a.domicilio, a.sector, a.ctrol_zona, a.id_rec, a.fecha_hora_alta, a.status_vigencia, a.aso_mes_oblig, a.cve, a.usuario, a.fecha_hora_baja,
           b.id_control, b.zona, b.modulo, b.control_otr, b.folio, b.diligencia, b.importe_global, b.importe_multa, b.importe_recargo, b.importe_gastos, b.zona_apremio, b.fecha_emision, b.clave_practicado, b.fecha_practicado, b.fecha_entrega1, b.fecha_entrega2, b.fecha_citatorio, b.hora, b.ejecutor, b.clave_secuestro, b.clave_remate, b.fecha_remate, b.porcentaje_multa, b.observaciones, b.fecha_pago, b.recaudadora, b.caja, b.operacion, b.importe_pago, b.vigencia, b.fecha_actualiz, b.usuario as usuario_1, b.clave_mov, b.hora_practicado,
           c.id_ejecutor, c.cve_eje, c.ini_rfc, c.fec_rfc, c.hom_rfc, c.nombre, c.id_rec as id_rec_1, c.categoria, c.observacion,
           d.ctrol_aseo as ctrol_aseo_1, d.tipo_aseo, d.descripcion, d.cta_aplicacion
    FROM ta_16_contratos a
    JOIN ta_15_apremios b ON b.control_otr = a.control_contrato AND b.modulo = 16
    LEFT JOIN ta_15_ejecutores c ON b.ejecutor = c.cve_eje AND b.zona = c.id_rec
    JOIN ta_16_tipo_aseo d ON a.ctrol_aseo = d.ctrol_aseo
    WHERE a.id_rec = p_id_rec
      AND d.tipo_aseo = p_tipo_aseo
      AND (
        p_clave_practicado = 'todas' OR b.clave_practicado = p_clave_practicado
      )
      AND (
        p_vigencia = 'todas' OR
        (p_vigencia = '2' AND (b.vigencia = '2' OR b.vigencia = 'P')) OR
        (p_vigencia <> '2' AND b.vigencia = p_vigencia)
      );
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_get_recaudadora_zona
-- Tipo: Catalog
-- Descripción: Obtiene los datos de la recaudadora y zona para una oficina (id_rec).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_recaudadora_zona(
    p_id_rec integer
)
RETURNS TABLE (
    id_rec smallint,
    id_zona integer,
    recaudadora text,
    domicilio text,
    tel text,
    recaudador text,
    sector text,
    zona text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_rec, a.id_zona, a.recaudadora, a.domicilio, a.tel, a.recaudador, a.sector, b.zona
    FROM padron_licencias.comun.ta_12_recaudadoras a
    JOIN padron_licencias.comun.ta_12_zonas b ON a.id_zona = b.id_zona
    WHERE a.id_rec = p_id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

