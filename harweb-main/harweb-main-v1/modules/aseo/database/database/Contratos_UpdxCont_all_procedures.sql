-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Contratos_UpdxCont
-- Generado: 2025-08-27 14:22:10
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp16_buscar_contrato
-- Tipo: CRUD
-- Descripción: Busca un contrato por número y tipo de aseo, devuelve todos los datos relevantes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_buscar_contrato(p_num_contrato INTEGER, p_ctrol_aseo INTEGER)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    ctrol_recolec INTEGER,
    cantidad_recolec SMALLINT,
    domicilio VARCHAR,
    sector VARCHAR,
    ctrol_zona INTEGER,
    id_rec SMALLINT,
    fecha_hora_alta TIMESTAMP,
    status_vigencia VARCHAR,
    aso_mes_oblig DATE,
    cve VARCHAR,
    usuario INTEGER,
    fecha_hora_baja TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT control_contrato, num_contrato, ctrol_aseo, num_empresa, ctrol_emp, ctrol_recolec, cantidad_recolec, domicilio, sector, ctrol_zona, id_rec, fecha_hora_alta, status_vigencia, aso_mes_oblig, cve, usuario, fecha_hora_baja
    FROM ta_16_contratos
    WHERE num_contrato = p_num_contrato AND ctrol_aseo = p_ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp16_buscar_empresa
-- Tipo: Catalog
-- Descripción: Busca empresas por nombre (LIKE).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_buscar_empresa(p_nombre VARCHAR)
RETURNS TABLE (
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    descripcion VARCHAR,
    representante VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT num_empresa, ctrol_emp, descripcion, representante
    FROM ta_16_empresas
    WHERE UPPER(descripcion) LIKE '%' || UPPER(p_nombre) || '%'
      AND ctrol_emp = 9
    ORDER BY num_empresa;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp16_alta_empresa
-- Tipo: CRUD
-- Descripción: Da de alta una nueva empresa privada con nombre y representante igual.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_alta_empresa(p_nombre VARCHAR)
RETURNS TABLE (
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    descripcion VARCHAR,
    representante VARCHAR
) AS $$
DECLARE
    v_max INTEGER;
BEGIN
    SELECT COALESCE(MAX(num_empresa),0) INTO v_max FROM ta_16_empresas WHERE ctrol_emp = 9;
    INSERT INTO ta_16_empresas (num_empresa, ctrol_emp, descripcion, representante)
    VALUES (v_max+1, 9, p_nombre, p_nombre);
    RETURN QUERY SELECT v_max+1, 9, p_nombre, p_nombre;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp16_actualizar_contrato
-- Tipo: CRUD
-- Descripción: Actualiza los datos principales de un contrato y registra el documento probatorio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_actualizar_contrato(
    p_control_contrato INTEGER,
    p_num_empresa INTEGER,
    p_ctrol_emp INTEGER,
    p_domicilio VARCHAR,
    p_sector VARCHAR,
    p_ctrol_zona INTEGER,
    p_id_rec INTEGER,
    p_documento VARCHAR,
    p_descripcion_docto VARCHAR,
    p_usuario INTEGER
) RETURNS TABLE (updated BOOLEAN, message TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_contratos WHERE control_contrato = p_control_contrato;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'Contrato no encontrado';
        RETURN;
    END IF;
    UPDATE ta_16_contratos
    SET num_empresa = p_num_empresa,
        ctrol_emp = p_ctrol_emp,
        domicilio = p_domicilio,
        sector = p_sector,
        ctrol_zona = p_ctrol_zona,
        id_rec = p_id_rec,
        cve = 'C',
        usuario = p_usuario
    WHERE control_contrato = p_control_contrato;
    INSERT INTO ta_16_contratos_h (control, control_contrato, documento, descripcion, id_usuario, fecha_movto)
    VALUES (DEFAULT, p_control_contrato, p_documento, p_descripcion_docto, p_usuario, CURRENT_TIMESTAMP);
    RETURN QUERY SELECT TRUE, 'Contrato actualizado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

