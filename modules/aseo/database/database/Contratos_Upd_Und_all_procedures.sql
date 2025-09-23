-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Contratos_Upd_Und
-- Generado: 2025-08-27 14:29:48
-- Total SPs: 4
-- ============================================

-- SP 1/4: buscar_contrato_upd_und
-- Tipo: CRUD
-- Descripción: Devuelve los datos completos de un contrato vigente por número y tipo de aseo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION buscar_contrato_upd_und(p_num_contrato INTEGER, p_ctrol_aseo INTEGER)
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
    JOIN ta_16_tipo_aseo d ON c.ctrol_aseo = d.ctrol_aseo
    JOIN ta_16_unidades e ON c.ctrol_recolec = e.ctrol_recolec
    JOIN ta_16_zonas f ON c.ctrol_zona = f.ctrol_zona
    JOIN ta_12_recaudadoras g ON c.id_rec = g.id_rec
    WHERE c.num_contrato = p_num_contrato
      AND c.ctrol_aseo = p_ctrol_aseo
      AND c.status_vigencia = 'V'
    ORDER BY c.num_contrato
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: catalogo_tipo_aseo
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de tipos de aseo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION catalogo_tipo_aseo()
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

-- SP 3/4: catalogo_unidades
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de unidades de recolección para un ejercicio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION catalogo_unidades(p_ejercicio INTEGER)
RETURNS TABLE (
    ctrol_recolec INTEGER,
    ejercicio_recolec SMALLINT,
    cve_recolec VARCHAR,
    descripcion VARCHAR,
    costo_unidad NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_recolec, ejercicio_recolec, cve_recolec, descripcion, costo_unidad
    FROM ta_16_unidades
    WHERE ejercicio_recolec = p_ejercicio
    ORDER BY ctrol_recolec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: actualizar_unidades_contrato
-- Tipo: CRUD
-- Descripción: Actualiza las unidades de recolección de un contrato, ajusta pagos y guarda histórico.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION actualizar_unidades_contrato(
    p_control_contrato INTEGER,
    p_ctrol_recolec INTEGER,
    p_cantidad SMALLINT,
    p_ejercicio INTEGER,
    p_mes INTEGER,
    p_documento VARCHAR,
    p_descripcion VARCHAR,
    p_user_id INTEGER
) RETURNS TABLE(status INTEGER, leyenda TEXT) AS $$
DECLARE
    v_importe NUMERIC;
    v_importe_sig NUMERIC;
    v_ejer_sig INTEGER;
    v_dia INTEGER := 1;
    v_unidades SMALLINT;
    v_costo NUMERIC;
    v_costo_sig NUMERIC;
BEGIN
    -- Validaciones básicas
    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        RETURN QUERY SELECT 1, 'Cantidad inválida.';
        RETURN;
    END IF;
    IF p_documento IS NULL OR length(p_documento) < 3 THEN
        RETURN QUERY SELECT 2, 'Documento requerido.';
        RETURN;
    END IF;
    v_ejer_sig := p_ejercicio + 1;
    -- Obtener costo unidad actual y siguiente
    SELECT costo_unidad INTO v_costo FROM ta_16_unidades WHERE ejercicio_recolec = p_ejercicio AND ctrol_recolec = p_ctrol_recolec LIMIT 1;
    SELECT costo_unidad INTO v_costo_sig FROM ta_16_unidades WHERE ejercicio_recolec = v_ejer_sig AND ctrol_recolec = p_ctrol_recolec LIMIT 1;
    IF v_costo IS NULL THEN
        RETURN QUERY SELECT 3, 'No existe costo de unidad para el ejercicio actual.';
        RETURN;
    END IF;
    -- Actualizar contrato
    UPDATE ta_16_contratos
    SET ctrol_recolec = p_ctrol_recolec,
        cantidad_recolec = p_cantidad,
        usuario = p_user_id
    WHERE control_contrato = p_control_contrato;
    -- Actualizar pagos del ejercicio actual
    v_importe := p_cantidad * v_costo;
    UPDATE ta_16_pagos
    SET importe = v_importe
    WHERE control_contrato = p_control_contrato
      AND aso_mes_pago >= make_date(p_ejercicio, p_mes, v_dia)
      AND status_vigencia = 'V';
    -- Actualizar pagos del ejercicio siguiente
    IF v_costo_sig IS NOT NULL THEN
        v_importe_sig := p_cantidad * v_costo_sig;
        UPDATE ta_16_pagos
        SET importe = v_importe_sig
        WHERE control_contrato = p_control_contrato
          AND aso_mes_pago >= make_date(v_ejer_sig, 1, v_dia)
          AND status_vigencia = 'V';
    END IF;
    -- Insertar histórico
    INSERT INTO ta_16_contratos_h (control, control_contrato, documento, descripcion, id_usuario, fecha_movto)
    VALUES (DEFAULT, p_control_contrato, p_documento, p_descripcion, p_user_id, now());
    RETURN QUERY SELECT 0, 'Actualización exitosa.';
END;
$$ LANGUAGE plpgsql;

-- ============================================

