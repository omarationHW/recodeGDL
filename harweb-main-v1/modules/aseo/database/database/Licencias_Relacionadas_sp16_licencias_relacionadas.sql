-- Stored Procedure: sp16_licencias_relacionadas
-- Tipo: Report
-- Descripción: Consulta de licencias relacionadas a contratos según opción
-- Generado para formulario: Licencias_Relacionadas
-- Fecha: 2025-08-27 14:41:43

-- PostgreSQL version for consulta de licencias relacionadas
CREATE OR REPLACE FUNCTION sp16_licencias_relacionadas(
    opcion INTEGER,
    num_licencia INTEGER DEFAULT NULL,
    control_contrato INTEGER DEFAULT NULL
) RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    domicilio_recoleccion_contrato VARCHAR,
    empresa_contrato VARCHAR,
    representante_contrato VARCHAR,
    num_licencia INTEGER,
    actividad_licencia VARCHAR,
    propietario_licencia VARCHAR,
    domicilio_licencia VARCHAR,
    numext_prop INTEGER,
    ubicacion_licencia VARCHAR,
    numext_ubic INTEGER,
    vigencia_rel VARCHAR,
    tipo_aseo VARCHAR
) AS $$
BEGIN
    IF opcion = 0 THEN
        RETURN QUERY
        SELECT c.control_contrato, c.num_contrato, c.domicilio, d.descripcion, d.representante, a.num_licencia, b.actividad, b.propietario, b.domicilio, b.numext_prop, b.ubicacion, b.numext_ubic, a.vigencia, e.tipo_aseo
        FROM ta_16_rel_licgiro a
        JOIN ta_16_contratos c ON c.control_contrato = a.control_contrato
        JOIN ta_16_empresas d ON d.num_empresa = c.num_empresa AND d.ctrol_emp = c.ctrol_emp
        JOIN ta_16_tipo_aseo e ON e.ctrol_aseo = c.ctrol_aseo
        LEFT JOIN licencias b ON b.licencia = a.num_licencia AND b.vigente = 'V'
        WHERE a.control_contrato > 0
        ORDER BY c.num_contrato, a.num_licencia;
    ELSIF opcion = 1 THEN
        RETURN QUERY
        SELECT c.control_contrato, c.num_contrato, c.domicilio, d.descripcion, d.representante, a.num_licencia, b.actividad, b.propietario, b.domicilio, b.numext_prop, b.ubicacion, b.numext_ubic, a.vigencia, e.tipo_aseo
        FROM ta_16_rel_licgiro a
        JOIN ta_16_contratos c ON c.control_contrato = a.control_contrato
        JOIN ta_16_empresas d ON d.num_empresa = c.num_empresa AND d.ctrol_emp = c.ctrol_emp
        JOIN ta_16_tipo_aseo e ON e.ctrol_aseo = c.ctrol_aseo
        LEFT JOIN licencias b ON b.licencia = a.num_licencia AND b.vigente = 'V'
        WHERE a.num_licencia = num_licencia
        ORDER BY c.num_contrato, a.num_licencia;
    ELSIF opcion = 2 THEN
        RETURN QUERY
        SELECT c.control_contrato, c.num_contrato, c.domicilio, d.descripcion, d.representante, a.num_licencia, b.actividad, b.propietario, b.domicilio, b.numext_prop, b.ubicacion, b.numext_ubic, a.vigencia, e.tipo_aseo
        FROM ta_16_rel_licgiro a
        JOIN ta_16_contratos c ON c.control_contrato = a.control_contrato
        JOIN ta_16_empresas d ON d.num_empresa = c.num_empresa AND d.ctrol_emp = c.ctrol_emp
        JOIN ta_16_tipo_aseo e ON e.ctrol_aseo = c.ctrol_aseo
        LEFT JOIN licencias b ON b.licencia = a.num_licencia AND b.vigente = 'V'
        WHERE a.control_contrato = control_contrato
        ORDER BY c.num_contrato, a.num_licencia;
    END IF;
END;
$$ LANGUAGE plpgsql;