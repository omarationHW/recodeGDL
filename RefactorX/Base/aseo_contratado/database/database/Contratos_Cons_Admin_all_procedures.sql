-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Contratos_Cons_Admin
-- Base de datos: padron_licencias (aseo_contratado)
-- Actualizado: 2025-12-07
-- Total SPs: 4
-- ============================================
-- Descripcion: Vista de consulta ADMIN para contratos de aseo
-- Muestra encabezados, datos varios y detalle de adeudos
-- Parametros: p_tipo (tipo de aseo A-Z), p_numero (numero contrato)
-- ============================================

-- SP 1/4: admin_encabezados_18z
-- Tipo: Report
-- Descripcion: Obtiene datos del encabezado del contrato (propietario, domicilio, etc.)
-- ============================================
DROP FUNCTION IF EXISTS public.admin_encabezados_18z(VARCHAR, INTEGER);

CREATE OR REPLACE FUNCTION public.admin_encabezados_18z(
    p_tipo VARCHAR,
    p_numero INTEGER
)
RETURNS TABLE (
    propietario VARCHAR,
    calle VARCHAR,
    numext VARCHAR,
    numint VARCHAR,
    colonia VARCHAR,
    cp VARCHAR,
    rfc VARCHAR,
    municipio VARCHAR,
    estado VARCHAR,
    curp VARCHAR,
    descripcion TEXT,
    cartera INTEGER,
    leyenda VARCHAR,
    leyendarecibo VARCHAR,
    impidecobro INTEGER
) AS $$
DECLARE
    v_control_contrato INTEGER;
BEGIN
    -- Buscar el control_contrato basado en tipo y numero
    SELECT c.control_contrato INTO v_control_contrato
    FROM ta_16_contratos c
    JOIN ta_16_tipos_aseo t ON t.tipo_aseo_id = c.tipo_aseo_id
    WHERE t.cve_tipo = UPPER(p_tipo)
      AND c.num_contrato = p_numero
    LIMIT 1;

    IF v_control_contrato IS NULL THEN
        -- Retornar registro vacio si no se encuentra
        RETURN QUERY SELECT
            ' '::VARCHAR as propietario,
            ''::VARCHAR as calle,
            ''::VARCHAR as numext,
            ''::VARCHAR as numint,
            ''::VARCHAR as colonia,
            ''::VARCHAR as cp,
            ''::VARCHAR as rfc,
            ''::VARCHAR as municipio,
            ''::VARCHAR as estado,
            ''::VARCHAR as curp,
            ''::TEXT as descripcion,
            0::INTEGER as cartera,
            ''::VARCHAR as leyenda,
            ''::VARCHAR as leyendarecibo,
            0::INTEGER as impidecobro;
        RETURN;
    END IF;

    -- Retornar datos del contrato y empresa
    RETURN QUERY
    SELECT
        COALESCE(e.representante, e.descripcion, 'Sin nombre')::VARCHAR as propietario,
        COALESCE(SPLIT_PART(e.domicilio, ',', 1), '')::VARCHAR as calle,
        ''::VARCHAR as numext,
        ''::VARCHAR as numint,
        COALESCE(SPLIT_PART(e.domicilio, ',', 2), '')::VARCHAR as colonia,
        ''::VARCHAR as cp,
        COALESCE(e.rfc, '')::VARCHAR as rfc,
        'GUADALAJARA'::VARCHAR as municipio,
        'JALISCO'::VARCHAR as estado,
        ''::VARCHAR as curp,
        COALESCE(c.observaciones, '')::TEXT as descripcion,
        0::INTEGER as cartera,
        CASE
            WHEN c.status_vigencia = 'V' THEN 'Contrato Vigente'
            WHEN c.status_vigencia = 'N' THEN 'Contrato Conveniado'
            WHEN c.status_vigencia = 'B' THEN 'Contrato dado de Baja'
            WHEN c.status_vigencia = 'C' THEN 'Contrato Cancelado'
            ELSE 'Status: ' || COALESCE(c.status_vigencia, 'Sin status')
        END::VARCHAR as leyenda,
        ''::VARCHAR as leyendarecibo,
        CASE WHEN c.status_vigencia IN ('B', 'C') THEN 1 ELSE 0 END::INTEGER as impidecobro
    FROM ta_16_contratos c
    LEFT JOIN ta_16_empresas e ON e.ctrol_emp = c.ctrol_emp
    WHERE c.control_contrato = v_control_contrato;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.admin_encabezados_18z(VARCHAR, INTEGER) TO PUBLIC;


-- SP 2/4: admin_datos_varios_18
-- Tipo: Report
-- Descripcion: Obtiene datos varios del contrato en formato lista
-- ============================================
DROP FUNCTION IF EXISTS public.admin_datos_varios_18(VARCHAR, INTEGER);

CREATE OR REPLACE FUNCTION public.admin_datos_varios_18(
    p_tipo VARCHAR,
    p_numero INTEGER
)
RETURNS TABLE (
    datovario VARCHAR
) AS $$
DECLARE
    v_control_contrato INTEGER;
    rec RECORD;
BEGIN
    -- Buscar el control_contrato basado en tipo y numero
    SELECT c.control_contrato INTO v_control_contrato
    FROM ta_16_contratos c
    JOIN ta_16_tipos_aseo t ON t.tipo_aseo_id = c.tipo_aseo_id
    WHERE t.cve_tipo = UPPER(p_tipo)
      AND c.num_contrato = p_numero
    LIMIT 1;

    IF v_control_contrato IS NULL THEN
        RETURN;
    END IF;

    -- Obtener datos del contrato
    SELECT * INTO rec
    FROM ta_16_contratos c
    LEFT JOIN ta_16_tipos_aseo t ON t.tipo_aseo_id = c.tipo_aseo_id
    LEFT JOIN ta_16_empresas e ON e.ctrol_emp = c.ctrol_emp
    LEFT JOIN ta_16_zonas z ON z.zona_id = c.zona_id
    WHERE c.control_contrato = v_control_contrato;

    -- Retornar datos en formato lista
    RETURN QUERY SELECT ('Control Contrato: ' || COALESCE(rec.control_contrato::TEXT, ''))::VARCHAR;
    RETURN QUERY SELECT ('Numero Contrato: ' || COALESCE(rec.num_contrato::TEXT, ''))::VARCHAR;
    RETURN QUERY SELECT ('Tipo Aseo: ' || COALESCE(rec.cve_tipo, '') || ' - ' || COALESCE(rec.descripcion, ''))::VARCHAR;
    RETURN QUERY SELECT ('Folio: ' || COALESCE(rec.folio, ''))::VARCHAR;
    RETURN QUERY SELECT ('Cuenta Predial: ' || COALESCE(rec.cuenta_predial, ''))::VARCHAR;
    RETURN QUERY SELECT ('Empresa: ' || COALESCE(rec.num_empresa::TEXT, '') || ' - ' || COALESCE((SELECT descripcion FROM ta_16_empresas WHERE ctrol_emp = rec.ctrol_emp), ''))::VARCHAR;
    RETURN QUERY SELECT ('Fecha Inicio: ' || COALESCE(TO_CHAR(rec.fecha_inicio, 'DD/MM/YYYY'), ''))::VARCHAR;
    RETURN QUERY SELECT ('Fecha Fin: ' || COALESCE(TO_CHAR(rec.fecha_fin, 'DD/MM/YYYY'), ''))::VARCHAR;
    RETURN QUERY SELECT ('Status Vigencia: ' || COALESCE(rec.status_vigencia, ''))::VARCHAR;
    RETURN QUERY SELECT ('Monto Mensual: $' || COALESCE(TO_CHAR(rec.monto_mensual, 'FM999,999,990.00'), '0.00'))::VARCHAR;
    RETURN QUERY SELECT ('Unidades Recoleccion: ' || COALESCE(rec.unidades_recoleccion::TEXT, '0'))::VARCHAR;
    RETURN QUERY SELECT ('Zona: ' || COALESCE((SELECT descripcion FROM ta_16_zonas WHERE zona_id = rec.zona_id), ''))::VARCHAR;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.admin_datos_varios_18(VARCHAR, INTEGER) TO PUBLIC;


-- SP 3/4: admin_adeudos_detalle_18
-- Tipo: Report
-- Descripcion: Obtiene detalle de adeudos del contrato
-- ============================================
DROP FUNCTION IF EXISTS public.admin_adeudos_detalle_18(VARCHAR, INTEGER, VARCHAR);

CREATE OR REPLACE FUNCTION public.admin_adeudos_detalle_18(
    p_tipo VARCHAR,
    p_numero INTEGER,
    pref VARCHAR DEFAULT ''
)
RETURNS TABLE (
    rubro INTEGER,
    concepto INTEGER,
    cuenta_aplicacion INTEGER,
    referencia VARCHAR,
    descripcion VARCHAR,
    monto NUMERIC,
    acumulado NUMERIC
) AS $$
DECLARE
    v_control_contrato INTEGER;
    v_acumulado NUMERIC := 0;
BEGIN
    -- Buscar el control_contrato basado en tipo y numero
    SELECT c.control_contrato INTO v_control_contrato
    FROM ta_16_contratos c
    JOIN ta_16_tipos_aseo t ON t.tipo_aseo_id = c.tipo_aseo_id
    WHERE t.cve_tipo = UPPER(p_tipo)
      AND c.num_contrato = p_numero
    LIMIT 1;

    IF v_control_contrato IS NULL THEN
        RETURN;
    END IF;

    -- Obtener adeudos pendientes
    RETURN QUERY
    SELECT
        a.ejercicio as rubro,
        EXTRACT(MONTH FROM a.fecha_vencimiento)::INTEGER as concepto,
        (SELECT tipo_aseo_id FROM ta_16_contratos WHERE control_contrato = v_control_contrato)::INTEGER as cuenta_aplicacion,
        (a.ejercicio::TEXT || '-' || LPAD(EXTRACT(MONTH FROM a.fecha_vencimiento)::TEXT, 2, '0'))::VARCHAR as referencia,
        ('Adeudo ' || a.periodo || ' ' || a.ejercicio || ' - ' || COALESCE(a.observaciones, 'Cuota'))::VARCHAR as descripcion,
        a.monto_pendiente as monto,
        SUM(a.monto_pendiente) OVER (ORDER BY a.ejercicio, a.periodo) as acumulado
    FROM ta_16_adeudos a
    WHERE a.control_contrato = v_control_contrato
      AND a.status_pago != 'P' -- No pagados
      AND a.activo = true
      AND (pref = '' OR (a.ejercicio::TEXT || '-' || LPAD(EXTRACT(MONTH FROM a.fecha_vencimiento)::TEXT, 2, '0')) = pref)
    ORDER BY a.ejercicio, a.periodo;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.admin_adeudos_detalle_18(VARCHAR, INTEGER, VARCHAR) TO PUBLIC;


-- SP 4/4: admin_adeudos_detalle_18_tot
-- Tipo: Report
-- Descripcion: Obtiene totales de adeudos agrupados por cuenta de aplicacion
-- ============================================
DROP FUNCTION IF EXISTS public.admin_adeudos_detalle_18_tot(VARCHAR, INTEGER, VARCHAR);

CREATE OR REPLACE FUNCTION public.admin_adeudos_detalle_18_tot(
    p_tipo VARCHAR,
    p_numero INTEGER,
    pref VARCHAR DEFAULT ''
)
RETURNS TABLE (
    cuenta_aplicacion INTEGER,
    referencia VARCHAR,
    monto NUMERIC
) AS $$
DECLARE
    v_control_contrato INTEGER;
BEGIN
    -- Buscar el control_contrato basado en tipo y numero
    SELECT c.control_contrato INTO v_control_contrato
    FROM ta_16_contratos c
    JOIN ta_16_tipos_aseo t ON t.tipo_aseo_id = c.tipo_aseo_id
    WHERE t.cve_tipo = UPPER(p_tipo)
      AND c.num_contrato = p_numero
    LIMIT 1;

    IF v_control_contrato IS NULL THEN
        RETURN;
    END IF;

    -- Obtener totales por cuenta de aplicacion
    RETURN QUERY
    SELECT
        t.tipo_aseo_id as cuenta_aplicacion,
        ('Total ' || COALESCE(t.descripcion, 'Aseo'))::VARCHAR as referencia,
        SUM(a.monto_pendiente) as monto
    FROM ta_16_adeudos a
    JOIN ta_16_contratos c ON c.control_contrato = a.control_contrato
    JOIN ta_16_tipos_aseo t ON t.tipo_aseo_id = c.tipo_aseo_id
    WHERE a.control_contrato = v_control_contrato
      AND a.status_pago != 'P' -- No pagados
      AND a.activo = true
      AND (pref = '' OR (a.ejercicio::TEXT || '-' || LPAD(EXTRACT(MONTH FROM a.fecha_vencimiento)::TEXT, 2, '0')) = pref)
    GROUP BY t.tipo_aseo_id, t.descripcion
    ORDER BY t.tipo_aseo_id;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.admin_adeudos_detalle_18_tot(VARCHAR, INTEGER, VARCHAR) TO PUBLIC;


-- ============================================
-- FIN DEL ARCHIVO
-- ============================================
