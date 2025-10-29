-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Rep_AdeudCond
-- Generado: 2025-08-27 15:05:40
-- Total SPs: 4
-- ============================================

-- SP 1/4: get_tipo_aseo_catalog
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de tipos de aseo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_tipo_aseo_catalog()
RETURNS TABLE (
    ctrol_aseo integer,
    tipo_aseo varchar(1),
    descripcion varchar(80),
    cta_aplicacion integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion
    FROM ta_16_tipo_aseo
    ORDER BY ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: get_contrato_by_numero_tipoaseo
-- Tipo: CRUD
-- Descripción: Obtiene el contrato por número y tipo de aseo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_contrato_by_numero_tipoaseo(
    p_num_contrato integer,
    p_ctrol_aseo integer
)
RETURNS TABLE (
    control_contrato integer,
    num_contrato integer,
    ctrol_aseo integer,
    ctrol_recolec integer,
    costo_unidad numeric,
    aso_mes_oblig date
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_contrato, a.num_contrato, a.ctrol_aseo, a.ctrol_recolec, b.costo_unidad, a.aso_mes_oblig
    FROM ta_16_contratos a
    JOIN ta_16_unidades b ON b.ctrol_recolec = a.ctrol_recolec
    WHERE a.num_contrato = p_num_contrato
      AND a.ctrol_aseo = p_ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: get_adeudos_condonados_by_contrato
-- Tipo: Report
-- Descripción: Devuelve los adeudos condonados (status 'S') para un contrato.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_adeudos_condonados_by_contrato(
    p_control_contrato integer
)
RETURNS SETOF ta_16_pagos AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta_16_pagos
    WHERE control_contrato = p_control_contrato
      AND status_vigencia = 'S';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: get_reporte_adeudos_condonados
-- Tipo: Report
-- Descripción: Devuelve el reporte de adeudos condonados para un contrato, ordenado por periodo de pago u operación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_reporte_adeudos_condonados(
    p_control_contrato integer,
    p_opcion smallint
)
RETURNS TABLE (
    control_contrato integer,
    num_contrato integer,
    ctrol_aseo integer,
    tipo_aseo varchar(1),
    descripcion varchar(80),
    ctrol_recolec integer,
    cve_recolec varchar(20),
    descripcion_1 varchar(80),
    cantidad_recolec smallint,
    domicilio varchar(255),
    sector varchar(50),
    ctrol_zona integer,
    zona smallint,
    sub_zona smallint,
    descripcion_2 varchar(80),
    id_rec smallint,
    recaudadora varchar(80),
    fecha_hora_alta timestamp,
    status_vigencia varchar(1),
    aso_mes_oblig date,
    cve varchar(20),
    usuario integer,
    fecha_hora_baja timestamp,
    control_contrato_1 integer,
    aso_mes_pago date,
    ctrol_operacion integer,
    cve_operacion varchar(20),
    descripcion_3 varchar(80),
    importe numeric,
    status_vigencia_1 varchar(1),
    fecha_hora_pago timestamp,
    folio_rcbo varchar(50),
    exedencias smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT C.control_contrato, C.num_contrato, C.ctrol_aseo, D.tipo_aseo, D.descripcion,
           C.ctrol_recolec, E.cve_recolec, E.descripcion, C.cantidad_recolec,
           C.domicilio, C.sector, C.ctrol_zona, F.zona, F.sub_zona, F.descripcion,
           C.id_rec, G.recaudadora, C.fecha_hora_alta, C.status_vigencia, C.aso_mes_oblig,
           C.cve, C.usuario, C.fecha_hora_baja,
           H.control_contrato, H.aso_mes_pago, H.ctrol_operacion, I.cve_operacion, I.descripcion,
           H.importe, H.status_vigencia, H.fecha_hora_pago, H.folio_rcbo, H.exedencias
    FROM ta_16_pagos H
    JOIN ta_16_contratos C ON C.control_contrato = H.control_contrato
    JOIN ta_16_tipo_aseo D ON D.ctrol_aseo = C.ctrol_aseo
    JOIN ta_16_unidades E ON E.ctrol_recolec = C.ctrol_recolec
    JOIN ta_16_zonas F ON F.ctrol_zona = C.ctrol_zona
    JOIN ta_12_recaudadoras G ON G.id_rec = C.id_rec
    JOIN ta_16_operacion I ON I.ctrol_operacion = H.ctrol_operacion
    WHERE H.control_contrato = p_control_contrato
      AND H.status_vigencia = 'S'
    ORDER BY
      CASE WHEN p_opcion = 1 THEN H.aso_mes_pago END,
      CASE WHEN p_opcion = 1 THEN I.cve_operacion END,
      CASE WHEN p_opcion = 2 THEN I.cve_operacion END,
      CASE WHEN p_opcion = 2 THEN H.aso_mes_pago END;
END;
$$ LANGUAGE plpgsql;

-- ============================================

