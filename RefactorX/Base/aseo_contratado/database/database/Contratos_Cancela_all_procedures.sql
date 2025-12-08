-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Contratos_Cancela (Contratos_Cancela.pas)
-- Base de datos: aseo_contratado
-- Actualizado: 2025-12-07
-- Total SPs: 4
-- ============================================
-- Descripcion: Cancelacion de contratos con detalle de adeudos
-- Flujo segun Delphi original:
--   1. Cargar combo de tipos de aseo
--   2. Buscar contrato por tipo + numero con sp16_contratos_Ind
--   3. Cargar adeudos con sp16_Adeudos_F02
--   4. Buscar convenio si existe
--   5. Buscar licencia asociada si existe
--   6. Ejecutar sp16_CancelaContrato (mismo de Contratos_Baja)
-- ============================================

-- SP 1/4: sp16_contratos_ind
-- Tipo: Select
-- Descripcion: Busca contrato con todos sus datos detallados
-- Similar a sp_aseo_buscar_contrato_baja pero con mas campos
-- ============================================
DROP FUNCTION IF EXISTS public.sp16_contratos_ind(VARCHAR, INTEGER);

CREATE OR REPLACE FUNCTION public.sp16_contratos_ind(
    p_tipo VARCHAR,
    p_numero INTEGER
)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    calle VARCHAR,
    numext VARCHAR,
    numint VARCHAR,
    colonia VARCHAR,
    sector VARCHAR,
    cp VARCHAR,
    rfc VARCHAR,
    municipio VARCHAR,
    estado VARCHAR,
    curp VARCHAR,
    status_contrato VARCHAR,
    num_empresa INTEGER,
    nombre_empresa VARCHAR,
    representante_empresa VARCHAR,
    tipo_aseo VARCHAR,
    tipo_aseo_descripcion VARCHAR,
    cve_recoleccion VARCHAR,
    unidad_recoleccion VARCHAR,
    cantidad_recoleccion INTEGER,
    status INTEGER,
    leyenda VARCHAR
) AS $$
DECLARE
    v_ctrol_aseo INTEGER;
BEGIN
    -- Obtener ctrol_aseo del tipo
    SELECT ta.ctrol_aseo INTO v_ctrol_aseo
    FROM ta_16_tipo_aseo ta
    WHERE ta.tipo_aseo = p_tipo;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            0::INTEGER, 0::INTEGER, ''::VARCHAR, ''::VARCHAR, ''::VARCHAR,
            ''::VARCHAR, ''::VARCHAR, ''::VARCHAR, ''::VARCHAR, ''::VARCHAR,
            ''::VARCHAR, ''::VARCHAR, ''::VARCHAR, 0::INTEGER, ''::VARCHAR,
            ''::VARCHAR, ''::VARCHAR, ''::VARCHAR, ''::VARCHAR, ''::VARCHAR,
            0::INTEGER, -1::INTEGER, 'Tipo de aseo no valido'::VARCHAR;
        RETURN;
    END IF;

    -- Buscar contrato
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        COALESCE(c.domicilio, '')::VARCHAR as calle,
        ''::VARCHAR as numext,
        ''::VARCHAR as numint,
        ''::VARCHAR as colonia,
        COALESCE(c.sector, '')::VARCHAR as sector,
        ''::VARCHAR as cp,
        ''::VARCHAR as rfc,
        'GUADALAJARA'::VARCHAR as municipio,
        'JALISCO'::VARCHAR as estado,
        ''::VARCHAR as curp,
        CASE c.status_vigencia
            WHEN 'V' THEN 'VIGENTE'
            WHEN 'C' THEN 'CANCELADO'
            WHEN 'N' THEN 'CONVENIADO'
            WHEN 'S' THEN 'SUSPENDIDO'
            ELSE c.status_vigencia
        END::VARCHAR as status_contrato,
        COALESCE(c.num_empresa, 0)::INTEGER,
        COALESCE(e.descripcion, '')::VARCHAR as nombre_empresa,
        COALESCE(e.representante, '')::VARCHAR as representante_empresa,
        COALESCE(ta.tipo_aseo, '')::VARCHAR,
        COALESCE(ta.descripcion, '')::VARCHAR as tipo_aseo_descripcion,
        COALESCE(u.cve_recolec, '')::VARCHAR as cve_recoleccion,
        COALESCE(u.descripcion, '')::VARCHAR as unidad_recoleccion,
        COALESCE(c.cantidad_recolec, 0)::INTEGER as cantidad_recoleccion,
        0::INTEGER as status,
        'Contrato encontrado'::VARCHAR as leyenda
    FROM ta_16_contratos c
    LEFT JOIN ta_16_tipo_aseo ta ON ta.ctrol_aseo = c.ctrol_aseo
    LEFT JOIN ta_16_empresas e ON e.ctrol_emp = c.ctrol_emp AND e.num_empresa = c.num_empresa
    LEFT JOIN ta_16_unidades u ON u.ctrol_recolec = c.ctrol_recolec
    WHERE c.num_contrato = p_numero
      AND c.ctrol_aseo = v_ctrol_aseo;

    -- Si no se encontro
    IF NOT FOUND THEN
        RETURN QUERY SELECT
            0::INTEGER, 0::INTEGER, ''::VARCHAR, ''::VARCHAR, ''::VARCHAR,
            ''::VARCHAR, ''::VARCHAR, ''::VARCHAR, ''::VARCHAR, ''::VARCHAR,
            ''::VARCHAR, ''::VARCHAR, ''::VARCHAR, 0::INTEGER, ''::VARCHAR,
            ''::VARCHAR, ''::VARCHAR, ''::VARCHAR, ''::VARCHAR, ''::VARCHAR,
            0::INTEGER, -1::INTEGER, 'No hay contrato con ese dato, intenta con otro'::VARCHAR;
    END IF;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp16_contratos_ind(VARCHAR, INTEGER) TO PUBLIC;

-- SP 2/4: sp16_adeudos_f02
-- Tipo: Select
-- Descripcion: Obtiene los adeudos detallados de un contrato
-- ============================================
DROP FUNCTION IF EXISTS public.sp16_adeudos_f02(VARCHAR, INTEGER, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION public.sp16_adeudos_f02(
    p_tipo VARCHAR,
    p_numero INTEGER,
    p_rep VARCHAR,
    pref VARCHAR
)
RETURNS TABLE (
    periodo VARCHAR,
    concepto VARCHAR,
    cant_recolec INTEGER,
    importe_adeudos NUMERIC,
    importe_recargos NUMERIC,
    importe_multa NUMERIC,
    importe_gastos NUMERIC,
    actualizacion NUMERIC
) AS $$
DECLARE
    v_control_contrato INTEGER;
    v_ctrol_aseo INTEGER;
BEGIN
    -- Obtener ctrol_aseo del tipo
    SELECT ta.ctrol_aseo INTO v_ctrol_aseo
    FROM ta_16_tipo_aseo ta
    WHERE ta.tipo_aseo = p_tipo;

    IF NOT FOUND THEN
        RETURN;
    END IF;

    -- Obtener control_contrato
    SELECT c.control_contrato INTO v_control_contrato
    FROM ta_16_contratos c
    WHERE c.num_contrato = p_numero
      AND c.ctrol_aseo = v_ctrol_aseo;

    IF NOT FOUND THEN
        RETURN;
    END IF;

    -- Obtener adeudos pendientes
    RETURN QUERY
    SELECT
        TO_CHAR(p.aso_mes_pago, 'YYYY-MM')::VARCHAR as periodo,
        COALESCE(o.descripcion, 'CUOTA')::VARCHAR as concepto,
        COALESCE(p.exed, 1)::INTEGER as cant_recolec,
        COALESCE(p.importe, 0)::NUMERIC as importe_adeudos,
        COALESCE(p.recargos, 0)::NUMERIC as importe_recargos,
        COALESCE(p.multa, 0)::NUMERIC as importe_multa,
        COALESCE(p.gastos, 0)::NUMERIC as importe_gastos,
        COALESCE(p.actualizacion, 0)::NUMERIC as actualizacion
    FROM ta_16_pagos p
    LEFT JOIN ta_16_cves_operacion o ON o.ctrol_operacion = p.ctrol_operacion
    WHERE p.control_contrato = v_control_contrato
      AND p.status_vigencia = 'V'
      AND p.aso_mes_pago < CURRENT_DATE
    ORDER BY p.aso_mes_pago;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp16_adeudos_f02(VARCHAR, INTEGER, VARCHAR, VARCHAR) TO PUBLIC;

-- SP 3/4: sp_aseo_buscar_licencia_contrato
-- Tipo: Select
-- Descripcion: Busca la licencia asociada a un contrato
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_buscar_licencia_contrato(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_buscar_licencia_contrato(
    p_control_contrato INTEGER
)
RETURNS TABLE (
    num_licencia INTEGER,
    actividad VARCHAR,
    propietario VARCHAR
) AS $$
BEGIN
    -- Buscar licencia relacionada al contrato
    -- Nota: Esta relacion puede variar segun la estructura real
    RETURN QUERY
    SELECT
        COALESCE(l.num_licencia, 0)::INTEGER,
        COALESCE(l.actividad, '')::VARCHAR,
        COALESCE(l.propietario, '')::VARCHAR
    FROM ta_licencias_aseo l
    WHERE l.control_contrato = p_control_contrato
    LIMIT 1;

EXCEPTION WHEN undefined_table THEN
    -- Si la tabla no existe, no retornar nada
    RETURN;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_buscar_licencia_contrato(INTEGER) TO PUBLIC;

-- SP 4/4: sp16_cancela_contrato (ya existe en Contratos_Baja_all_procedures.sql)
-- Este SP es compartido entre Contratos_Baja y Contratos_Cancela
-- No se duplica aqui para evitar conflictos

-- ============================================
-- DDL: Crear tablas auxiliares si no existen
-- ============================================
-- CREATE TABLE IF NOT EXISTS ta_16_cves_operacion (
--     ctrol_operacion INTEGER PRIMARY KEY,
--     descripcion VARCHAR(100)
-- );

-- CREATE TABLE IF NOT EXISTS ta_licencias_aseo (
--     id SERIAL PRIMARY KEY,
--     control_contrato INTEGER,
--     num_licencia INTEGER,
--     actividad VARCHAR(200),
--     propietario VARCHAR(200)
-- );

-- ============================================
-- FIN DEL ARCHIVO
-- ============================================
