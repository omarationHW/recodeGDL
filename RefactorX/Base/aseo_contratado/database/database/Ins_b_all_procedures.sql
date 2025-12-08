-- =============================================
-- Aseo Contratado - Ins_b Module
-- Stored Procedures for Contract Insertion (Special)
-- Database: aseo_contratado
-- Schema: public
-- =============================================

-- =============================================
-- Function: ins_b_sp_validar_contrato
-- Description: Validate contract data before insertion
-- =============================================
CREATE OR REPLACE FUNCTION public.ins_b_sp_validar_contrato(
    p_num_empresa INTEGER,
    p_ctrol_aseo INTEGER,
    p_num_contrato INTEGER
)
RETURNS TABLE (
    es_valido BOOLEAN,
    mensaje VARCHAR
) AS $$
DECLARE
    v_existe INTEGER;
BEGIN
    -- Check if contract already exists
    SELECT COUNT(*) INTO v_existe
    FROM ta_16_contratos
    WHERE num_empresa = p_num_empresa
      AND ctrol_aseo = p_ctrol_aseo
      AND num_contrato = p_num_contrato;

    IF v_existe > 0 THEN
        RETURN QUERY SELECT FALSE, 'El contrato ya existe para esta empresa'::VARCHAR;
    ELSE
        RETURN QUERY SELECT TRUE, 'Validación correcta'::VARCHAR;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- Function: ins_b_sp_insert_contrato
-- Description: Insert new contract (special insertion)
-- =============================================
CREATE OR REPLACE FUNCTION public.ins_b_sp_insert_contrato(
    p_num_empresa INTEGER,
    p_ctrol_emp INTEGER,
    p_num_contrato INTEGER,
    p_ctrol_aseo INTEGER,
    p_ctrol_recolec INTEGER,
    p_cantidad_recolec SMALLINT,
    p_domicilio VARCHAR,
    p_sector VARCHAR,
    p_ctrol_zona INTEGER,
    p_id_rec SMALLINT,
    p_aso_mes_oblig DATE,
    p_usuario INTEGER
)
RETURNS TABLE (
    control_contrato INTEGER,
    mensaje VARCHAR
) AS $$
DECLARE
    v_control INTEGER;
    v_cve VARCHAR(3);
BEGIN
    -- Generate new control
    SELECT COALESCE(MAX(control_contrato), 0) + 1 INTO v_control
    FROM ta_16_contratos;

    -- Generate cve based on tipo aseo
    SELECT SUBSTRING(tipo_aseo, 1, 1) INTO v_cve
    FROM ta_16_tipo_aseo
    WHERE ctrol_aseo = p_ctrol_aseo;

    -- Insert contract
    INSERT INTO ta_16_contratos (
        control_contrato,
        num_empresa,
        ctrol_emp,
        num_contrato,
        ctrol_aseo,
        ctrol_recolec,
        cantidad_recolec,
        domicilio,
        sector,
        ctrol_zona,
        id_rec,
        fecha_hora_alta,
        status_vigencia,
        aso_mes_oblig,
        cve,
        usuario
    ) VALUES (
        v_control,
        p_num_empresa,
        p_ctrol_emp,
        p_num_contrato,
        p_ctrol_aseo,
        p_ctrol_recolec,
        p_cantidad_recolec,
        p_domicilio,
        p_sector,
        p_ctrol_zona,
        p_id_rec,
        CURRENT_TIMESTAMP,
        'N',
        p_aso_mes_oblig,
        v_cve,
        p_usuario
    );

    RETURN QUERY SELECT v_control, 'Contrato insertado correctamente'::VARCHAR;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT 0, 'Error al insertar contrato: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- Function: ins_b_sp_get_empresas
-- Description: Get companies for contract insertion
-- =============================================
CREATE OR REPLACE FUNCTION public.ins_b_sp_get_empresas(
    p_filtro VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    descripcion VARCHAR,
    representante VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.num_empresa,
        e.ctrol_emp,
        e.descripcion,
        e.representante
    FROM ta_16_empresas e
    WHERE p_filtro IS NULL
       OR UPPER(e.descripcion) LIKE '%' || UPPER(p_filtro) || '%'
       OR UPPER(e.representante) LIKE '%' || UPPER(p_filtro) || '%'
    ORDER BY e.descripcion;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.ins_b_sp_validar_contrato(INTEGER, INTEGER, INTEGER) IS 'Validate contract before insertion - RefactorX Aseo Contratado';
COMMENT ON FUNCTION public.ins_b_sp_insert_contrato(INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, SMALLINT, VARCHAR, VARCHAR, INTEGER, SMALLINT, DATE, INTEGER) IS 'Insert new contract (special) - RefactorX Aseo Contratado';
COMMENT ON FUNCTION public.ins_b_sp_get_empresas(VARCHAR) IS 'Get companies for contract insertion - RefactorX Aseo Contratado';
