-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Contratos_Upd_Periodo
-- Generado: 2025-08-27 14:27:57
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_contratos_buscar
-- Tipo: Catalog
-- Descripción: Busca un contrato por número y tipo de aseo, devolviendo todos los datos relevantes.
-- --------------------------------------------

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

-- ============================================

-- SP 2/2: sp_contratos_actualizar_periodo_obligacion
-- Tipo: CRUD
-- Descripción: Actualiza el periodo de inicio de obligación de un contrato, registra el documento y descripción en el histórico.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_contratos_actualizar_periodo_obligacion(
    p_control_contrato INTEGER,
    p_anio INTEGER,
    p_mes INTEGER,
    p_documento VARCHAR,
    p_descripcion VARCHAR,
    p_usuario INTEGER
) RETURNS TABLE(status INTEGER, leyenda VARCHAR) AS $$
DECLARE
    v_fecha DATE;
    v_old_fecha DATE;
    v_count INTEGER;
BEGIN
    -- Validaciones
    IF p_documento IS NULL OR length(trim(p_documento)) = 0 THEN
        RETURN QUERY SELECT 1, 'Falta documento que avale el cambio';
        RETURN;
    END IF;
    v_fecha := make_date(p_anio, p_mes, 1);
    SELECT aso_mes_oblig INTO v_old_fecha FROM ta_16_contratos WHERE control_contrato = p_control_contrato;
    IF v_old_fecha IS NULL THEN
        RETURN QUERY SELECT 2, 'Contrato no encontrado';
        RETURN;
    END IF;
    IF v_fecha = v_old_fecha THEN
        RETURN QUERY SELECT 3, 'El periodo es igual al actual, no hay cambios';
        RETURN;
    END IF;
    -- Actualización
    UPDATE ta_16_contratos
    SET aso_mes_oblig = v_fecha,
        cve = 'C',
        usuario = p_usuario
    WHERE control_contrato = p_control_contrato;
    -- Insertar en histórico
    INSERT INTO ta_16_contratos_h (control, control_contrato, documento, descripcion, id_usuario, fecha_movto)
    VALUES (DEFAULT, p_control_contrato, p_documento, p_descripcion, p_usuario, now());
    RETURN QUERY SELECT 0, 'Periodo de inicio de obligación actualizado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

