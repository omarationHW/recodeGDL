-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Contratos_Upd_UndC
-- Generado: 2025-08-27 14:31:21
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_contratos_upd_undc_buscar
-- Tipo: CRUD
-- Descripción: Busca un contrato vigente por número y tipo de aseo, retorna todos los datos relevantes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_contratos_upd_undc_buscar(p_num_contrato INTEGER, p_ctrol_aseo INTEGER)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion_2 VARCHAR,
    ctrol_recolec INTEGER,
    cve_recolec VARCHAR,
    descripcion_3 VARCHAR,
    cantidad_recolec SMALLINT,
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
    fecha_hora_baja TIMESTAMP,
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    descripcion_1 VARCHAR,
    representante VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.control_contrato, c.num_contrato, c.ctrol_aseo, d.tipo_aseo, d.descripcion,
        c.ctrol_recolec, e.cve_recolec, e.descripcion, c.cantidad_recolec,
        c.domicilio, c.sector, c.ctrol_zona, f.zona, f.sub_zona, f.descripcion,
        c.id_rec, g.recaudadora, c.fecha_hora_alta, c.status_vigencia, c.aso_mes_oblig, c.cve, c.usuario, c.fecha_hora_baja,
        a.num_empresa, a.ctrol_emp, a.descripcion, a.representante
    FROM ta_16_contratos c
    JOIN ta_16_empresas a ON a.num_empresa = c.num_empresa AND a.ctrol_emp = c.ctrol_emp
    JOIN ta_16_tipos_emp b ON a.ctrol_emp = b.ctrol_emp
    JOIN ta_16_tipo_aseo d ON d.ctrol_aseo = c.ctrol_aseo
    JOIN ta_16_unidades e ON e.ctrol_recolec = c.ctrol_recolec
    JOIN ta_16_zonas f ON f.ctrol_zona = c.ctrol_zona
    JOIN ta_12_recaudadoras g ON g.id_rec = c.id_rec
    WHERE c.num_contrato = p_num_contrato
      AND c.ctrol_aseo = p_ctrol_aseo
      AND c.status_vigencia = 'V'
    ORDER BY c.num_contrato
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_contratos_upd_undc_listar_tipos_aseo
-- Tipo: Catalog
-- Descripción: Lista todos los tipos de aseo disponibles.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_contratos_upd_undc_listar_tipos_aseo()
RETURNS TABLE (
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR,
    cta_aplicacion INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion
    FROM ta_16_tipo_aseo
    ORDER BY ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_contratos_upd_undc_actualizar_unidades
-- Tipo: CRUD
-- Descripción: Actualiza la cantidad de unidades de recolección en un contrato, recalcula importes de pagos, y registra el documento probatorio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_contratos_upd_undc_actualizar_unidades(
    p_control_contrato INTEGER,
    p_nueva_cantidad SMALLINT,
    p_ejercicio SMALLINT,
    p_mes SMALLINT,
    p_documento VARCHAR,
    p_descripcion_docto VARCHAR,
    p_usuario INTEGER
) RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_contrato RECORD;
    v_unidad RECORD;
    v_unidad_sig RECORD;
    v_importe NUMERIC;
    v_importe_sig NUMERIC;
    v_ejercicio_sig SMALLINT;
    v_dia SMALLINT := 1;
BEGIN
    -- Validaciones
    SELECT * INTO v_contrato FROM ta_16_contratos WHERE control_contrato = p_control_contrato AND status_vigencia = 'V';
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Contrato no encontrado o no vigente.';
        RETURN;
    END IF;
    IF p_nueva_cantidad IS NULL OR p_nueva_cantidad = 0 THEN
        RETURN QUERY SELECT FALSE, 'La cantidad debe ser mayor a cero.';
        RETURN;
    END IF;
    IF p_documento IS NULL OR length(trim(p_documento)) = 0 THEN
        RETURN QUERY SELECT FALSE, 'Debe proporcionar un documento probatorio.';
        RETURN;
    END IF;
    v_ejercicio_sig := p_ejercicio + 1;
    -- Buscar unidad actual
    SELECT * INTO v_unidad FROM ta_16_unidades WHERE ejercicio_recolec = p_ejercicio AND cve_recolec = v_contrato.cve_recolec LIMIT 1;
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'No existe tarifa de unidad para el ejercicio actual.';
        RETURN;
    END IF;
    -- Buscar unidad siguiente
    SELECT * INTO v_unidad_sig FROM ta_16_unidades WHERE ejercicio_recolec = v_ejercicio_sig AND cve_recolec = v_contrato.cve_recolec LIMIT 1;
    -- Actualizar contrato
    UPDATE ta_16_contratos SET cantidad_recolec = p_nueva_cantidad, usuario = p_usuario WHERE control_contrato = p_control_contrato;
    -- Actualizar pagos del ejercicio actual
    v_importe := p_nueva_cantidad * v_unidad.costo_unidad;
    UPDATE ta_16_pagos SET exedencias = p_nueva_cantidad, importe = v_importe
      WHERE control_contrato = p_control_contrato
        AND aso_mes_pago >= make_date(p_ejercicio, p_mes, v_dia)
        AND status_vigencia = 'V';
    -- Actualizar pagos del ejercicio siguiente si existe tarifa
    IF FOUND AND v_unidad_sig IS NOT NULL THEN
        v_importe_sig := p_nueva_cantidad * v_unidad_sig.costo_unidad;
        UPDATE ta_16_pagos SET importe = v_importe_sig
          WHERE control_contrato = p_control_contrato
            AND aso_mes_pago >= make_date(v_ejercicio_sig, 1, v_dia)
            AND status_vigencia = 'V';
    END IF;
    -- Insertar en historial de contratos
    INSERT INTO ta_16_contratos_h (control, control_contrato, documento, descripcion, id_usuario, fecha_movto)
    VALUES (DEFAULT, p_control_contrato, p_documento, p_descripcion_docto, p_usuario, now());
    RETURN QUERY SELECT TRUE, 'Unidades actualizadas correctamente.';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error al actualizar unidades: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

