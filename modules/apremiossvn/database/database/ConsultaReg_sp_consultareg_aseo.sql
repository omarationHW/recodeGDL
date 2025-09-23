-- Stored Procedure: sp_consultareg_aseo
-- Tipo: Catalog
-- Descripción: Busca un registro de aseo por número de contrato y tipo.
-- Generado para formulario: ConsultaReg
-- Fecha: 2025-08-27 13:40:42

CREATE OR REPLACE FUNCTION sp_consultareg_aseo(
    p_contrato integer,
    p_tipo varchar
) RETURNS TABLE (
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
    SELECT a.*, c.*, d.*
    FROM ta_16_contratos a
    JOIN ta_16_tipo_aseo c ON a.ctrol_aseo = c.ctrol_aseo
    JOIN ta_16_empresas d ON a.num_empresa = d.num_empresa
    WHERE a.num_contrato = p_contrato AND c.tipo_aseo = p_tipo
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;