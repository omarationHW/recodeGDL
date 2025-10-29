-- Stored Procedure: sp_get_aseo_reference
-- Tipo: Catalog
-- Descripción: Obtiene la referencia de aseo para un contrato dado.
-- Generado para formulario: Cons_his
-- Fecha: 2025-08-27 13:42:45

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