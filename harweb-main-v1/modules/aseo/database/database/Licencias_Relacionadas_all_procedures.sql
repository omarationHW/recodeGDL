-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Licencias_Relacionadas
-- Generado: 2025-08-27 14:41:43
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp16_licenciagiro_abc
-- Tipo: CRUD
-- Descripción: Alta, baja (desligar), o actualización de relación entre licencia y contrato
-- --------------------------------------------

-- PostgreSQL version of sp16_LicenciaGiro_ABC
CREATE OR REPLACE FUNCTION sp16_licenciagiro_abc(
    par_opc VARCHAR,
    par_licenciagiro INTEGER,
    par_control_contrato INTEGER,
    par_usuario INTEGER DEFAULT 0
) RETURNS TABLE(status INTEGER, leyenda VARCHAR) AS $$
DECLARE
BEGIN
    IF par_opc = 'D' THEN
        DELETE FROM ta_16_rel_licgiro
        WHERE num_licencia = par_licenciagiro AND control_contrato = par_control_contrato;
        RETURN QUERY SELECT 0 AS status, 'Licencia desligada correctamente' AS leyenda;
    ELSIF par_opc = 'A' THEN
        INSERT INTO ta_16_rel_licgiro (num_licencia, control_contrato, vigencia, usuario)
        VALUES (par_licenciagiro, par_control_contrato, 'V', par_usuario)
        ON CONFLICT (num_licencia, control_contrato) DO UPDATE SET vigencia = 'V', usuario = par_usuario;
        RETURN QUERY SELECT 0 AS status, 'Licencia ligada correctamente' AS leyenda;
    ELSE
        RETURN QUERY SELECT 1 AS status, 'Operación no soportada' AS leyenda;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp16_licencias_relacionadas
-- Tipo: Report
-- Descripción: Consulta de licencias relacionadas a contratos según opción
-- --------------------------------------------

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

-- ============================================

-- SP 3/3: sp16_tipos_aseo
-- Tipo: Catalog
-- Descripción: Catálogo de tipos de aseo
-- --------------------------------------------

-- PostgreSQL version for catálogo de tipos de aseo
CREATE OR REPLACE FUNCTION sp16_tipos_aseo() RETURNS TABLE(
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

