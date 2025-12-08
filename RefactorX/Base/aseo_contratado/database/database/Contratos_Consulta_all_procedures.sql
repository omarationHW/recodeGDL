-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Contratos_Consulta
-- Base de datos: padron_licencias (aseo_contratado)
-- Actualizado: 2025-12-07
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp16_contratos_ind
-- Tipo: Report
-- Descripcion: Obtiene datos completos de un contrato individual
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
    v_control INTEGER;
BEGIN
    -- Buscar contrato
    SELECT c.control_contrato INTO v_control
    FROM ta_16_contratos c
    JOIN ta_16_tipos_aseo t ON t.tipo_aseo_id = c.tipo_aseo_id
    WHERE t.cve_tipo = UPPER(p_tipo)
      AND c.num_contrato = p_numero
    LIMIT 1;

    IF v_control IS NULL THEN
        -- Contrato no encontrado
        RETURN QUERY SELECT
            0::INTEGER, 0::INTEGER, ''::VARCHAR, ''::VARCHAR, ''::VARCHAR,
            ''::VARCHAR, ''::VARCHAR, ''::VARCHAR, ''::VARCHAR, ''::VARCHAR,
            ''::VARCHAR, ''::VARCHAR, ''::VARCHAR, 0::INTEGER, ''::VARCHAR,
            ''::VARCHAR, ''::VARCHAR, ''::VARCHAR, ''::VARCHAR, ''::VARCHAR,
            0::INTEGER, -1::INTEGER,
            ('No existe contrato ' || p_numero || ' para tipo ' || p_tipo)::VARCHAR;
        RETURN;
    END IF;

    -- Retornar datos completos
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        COALESCE(SPLIT_PART(e.domicilio, ',', 1), '')::VARCHAR as calle,
        ''::VARCHAR as numext,
        ''::VARCHAR as numint,
        COALESCE(SPLIT_PART(e.domicilio, ',', 2), '')::VARCHAR as colonia,
        ''::VARCHAR as sector,
        ''::VARCHAR as cp,
        COALESCE(e.rfc, '')::VARCHAR as rfc,
        'GUADALAJARA'::VARCHAR as municipio,
        'JALISCO'::VARCHAR as estado,
        ''::VARCHAR as curp,
        CASE c.status_vigencia
            WHEN 'V' THEN 'VIGENTE'
            WHEN 'N' THEN 'CONVENIADO'
            WHEN 'B' THEN 'BAJA'
            WHEN 'C' THEN 'CANCELADO'
            ELSE COALESCE(c.status_vigencia, '')
        END::VARCHAR as status_contrato,
        COALESCE(e.num_empresa, 0) as num_empresa,
        COALESCE(e.descripcion, '')::VARCHAR as nombre_empresa,
        COALESCE(e.representante, '')::VARCHAR as representante_empresa,
        COALESCE(t.cve_tipo, '')::VARCHAR as tipo_aseo,
        COALESCE(t.descripcion, '')::VARCHAR as tipo_aseo_descripcion,
        ''::VARCHAR as cve_recoleccion,
        ''::VARCHAR as unidad_recoleccion,
        COALESCE(c.unidades_recoleccion, 1) as cantidad_recoleccion,
        0::INTEGER as status,
        ''::VARCHAR as leyenda
    FROM ta_16_contratos c
    LEFT JOIN ta_16_empresas e ON e.ctrol_emp = c.ctrol_emp
    LEFT JOIN ta_16_tipos_aseo t ON t.tipo_aseo_id = c.tipo_aseo_id
    WHERE c.control_contrato = v_control;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp16_contratos_ind(VARCHAR, INTEGER) TO PUBLIC;


-- SP 2/5: sp16_adeudos_f02
-- Tipo: Report
-- Descripcion: Obtiene adeudos en formato F02 (desglosado)
-- ============================================
DROP FUNCTION IF EXISTS public.sp16_adeudos_f02(VARCHAR, INTEGER, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION public.sp16_adeudos_f02(
    p_tipo VARCHAR,
    p_numero INTEGER,
    p_rep VARCHAR DEFAULT 'A',
    pref VARCHAR DEFAULT ''
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
    v_control INTEGER;
BEGIN
    -- Buscar control_contrato
    SELECT c.control_contrato INTO v_control
    FROM ta_16_contratos c
    JOIN ta_16_tipos_aseo t ON t.tipo_aseo_id = c.tipo_aseo_id
    WHERE t.cve_tipo = UPPER(p_tipo)
      AND c.num_contrato = p_numero
    LIMIT 1;

    IF v_control IS NULL THEN
        RETURN;
    END IF;

    -- Retornar adeudos
    RETURN QUERY
    SELECT
        (a.ejercicio::TEXT || '/' || LPAD(EXTRACT(MONTH FROM a.fecha_vencimiento)::TEXT, 2, '0'))::VARCHAR as periodo,
        'CUOTA'::VARCHAR as concepto,
        1::INTEGER as cant_recolec,
        COALESCE(a.monto_pendiente, 0) as importe_adeudos,
        0::NUMERIC as importe_recargos,
        0::NUMERIC as importe_multa,
        0::NUMERIC as importe_gastos,
        0::NUMERIC as actualizacion
    FROM ta_16_adeudos a
    WHERE a.control_contrato = v_control
      AND a.status_pago != 'P'
      AND a.activo = true
      AND (pref = '' OR (a.ejercicio::TEXT || '/' || LPAD(EXTRACT(MONTH FROM a.fecha_vencimiento)::TEXT, 2, '0')) LIKE pref || '%')
    ORDER BY a.ejercicio, a.periodo;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp16_adeudos_f02(VARCHAR, INTEGER, VARCHAR, VARCHAR) TO PUBLIC;


-- SP 3/5: sp_aseo_convenio_contrato
-- Tipo: Report
-- Descripcion: Busca convenio asociado a un contrato
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_convenio_contrato(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_convenio_contrato(
    p_control_contrato INTEGER
)
RETURNS TABLE (
    convenio VARCHAR,
    id_conv_resto INTEGER
) AS $$
BEGIN
    -- Por ahora retorna vacio (tabla de convenios no existe aun)
    -- Se puede implementar cuando exista la tabla ta_16_convenios
    RETURN;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_convenio_contrato(INTEGER) TO PUBLIC;


-- SP 4/5: sp_aseo_licencias_contrato
-- Tipo: Report
-- Descripcion: Busca licencias asociadas a un contrato
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_licencias_contrato(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_licencias_contrato(
    p_control_contrato INTEGER
)
RETURNS TABLE (
    num_licencia INTEGER,
    actividad VARCHAR,
    propietario VARCHAR
) AS $$
BEGIN
    -- Por ahora retorna vacio (relacion con licencias no definida)
    -- Se puede implementar cuando exista la relacion
    RETURN;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_licencias_contrato(INTEGER) TO PUBLIC;


-- ============================================
-- FIN DEL ARCHIVO
-- ============================================
