-- Stored Procedure: sp_contratos_buscar
-- Tipo: Catalog
-- Descripción: Busca un contrato por número y tipo de aseo, devolviendo todos los datos relevantes.
-- Generado para formulario: Contratos_Upd_Periodo
-- Fecha: 2025-08-27 14:27:57

CREATE OR REPLACE FUNCTION sp_contratos_buscar(p_num_contrato INTEGER, p_ctrol_aseo INTEGER)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion_2 VARCHAR,
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    descripcion_1 VARCHAR,
    representante VARCHAR,
    cantidad_recolec SMALLINT,
    ctrol_recolec INTEGER,
    cve_recolec VARCHAR,
    descripcion_3 VARCHAR,
    domicilio VARCHAR,
    sector VARCHAR,
    ctrol_zona INTEGER,
    zona SMALLINT,
    sub_zona SMALLINT,
    descripcion_4 VARCHAR,
    id_rec SMALLINT,
    recaudadora VARCHAR,
    fecha_hora_alta TIMESTAMP,
    status_vigencia VARCHAR,
    aso_mes_oblig DATE,
    cve VARCHAR,
    usuario INTEGER,
    fecha_hora_baja TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        c.ctrol_aseo,
        d.tipo_aseo,
        d.descripcion,
        a.num_empresa,
        a.ctrol_emp,
        a.descripcion,
        a.representante,
        c.cantidad_recolec,
        c.ctrol_recolec,
        e.cve_recolec,
        e.descripcion,
        c.domicilio,
        c.sector,
        c.ctrol_zona,
        f.zona,
        f.sub_zona,
        f.descripcion,
        c.id_rec,
        g.recaudadora,
        c.fecha_hora_alta,
        c.status_vigencia,
        c.aso_mes_oblig,
        c.cve,
        c.usuario,
        c.fecha_hora_baja
    FROM ta_16_contratos c
    JOIN ta_16_empresas a ON a.num_empresa = c.num_empresa AND a.ctrol_emp = c.ctrol_emp
    JOIN ta_16_tipos_emp b ON a.ctrol_emp = b.ctrol_emp
    JOIN ta_16_tipo_aseo d ON c.ctrol_aseo = d.ctrol_aseo
    JOIN ta_16_unidades e ON c.ctrol_recolec = e.ctrol_recolec
    JOIN ta_16_zonas f ON c.ctrol_zona = f.ctrol_zona
    JOIN ta_12_recaudadoras g ON c.id_rec = g.id_rec
    WHERE c.num_contrato = p_num_contrato AND c.ctrol_aseo = p_ctrol_aseo
    ORDER BY c.num_contrato;
END;
$$ LANGUAGE plpgsql;