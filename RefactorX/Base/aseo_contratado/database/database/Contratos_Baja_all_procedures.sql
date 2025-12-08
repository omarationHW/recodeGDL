-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Contratos_Baja (Contratos_Del.pas)
-- Base de datos: aseo_contratado
-- Actualizado: 2025-12-07
-- Total SPs: 4
-- ============================================
-- Descripcion: Baja de contratos de aseo contratado
-- Flujo segun Delphi original:
--   1. Buscar contrato por num_contrato + ctrol_aseo
--   2. Verificar si tiene adeudos vencidos (sp16_Ade_x_Contrato)
--   3. Verificar status: solo V permite baja, N muestra convenio
--   4. Ingresar: anio, mes, fecha_baja, documento, descripcion
--   5. Ejecutar sp16_CancelaContrato
-- ============================================

-- SP 1/4: sp_aseo_buscar_contrato_baja
-- Tipo: Select
-- Descripcion: Busca contrato para dar de baja con todos sus datos
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_buscar_contrato_baja(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_buscar_contrato_baja(
    p_num_contrato INTEGER,
    p_ctrol_aseo INTEGER
)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion_aseo VARCHAR,
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR,
    descripcion_tipo_emp VARCHAR,
    nombre_empresa VARCHAR,
    representante VARCHAR,
    cantidad_recolec SMALLINT,
    ctrol_recolec INTEGER,
    cve_recolec VARCHAR,
    descripcion_recolec VARCHAR,
    domicilio VARCHAR,
    sector VARCHAR,
    ctrol_zona INTEGER,
    zona SMALLINT,
    sub_zona SMALLINT,
    descripcion_zona VARCHAR,
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
        a.control_contrato,
        a.num_contrato,
        a.ctrol_aseo,
        b.tipo_aseo::VARCHAR,
        b.descripcion::VARCHAR as descripcion_aseo,
        a.num_empresa,
        a.ctrol_emp,
        c.tipo_empresa::VARCHAR,
        c.descripcion::VARCHAR as descripcion_tipo_emp,
        d.descripcion::VARCHAR as nombre_empresa,
        d.representante::VARCHAR,
        a.cantidad_recolec,
        a.ctrol_recolec,
        e.cve_recolec::VARCHAR,
        e.descripcion::VARCHAR as descripcion_recolec,
        a.domicilio::VARCHAR,
        a.sector::VARCHAR,
        a.ctrol_zona,
        f.zona,
        f.sub_zona,
        f.descripcion::VARCHAR as descripcion_zona,
        a.id_rec,
        g.recaudadora::VARCHAR,
        a.fecha_hora_alta,
        a.status_vigencia::VARCHAR,
        a.aso_mes_oblig,
        a.cve::VARCHAR,
        a.usuario,
        a.fecha_hora_baja
    FROM ta_16_contratos a
    INNER JOIN ta_16_tipo_aseo b ON b.ctrol_aseo = a.ctrol_aseo
    INNER JOIN ta_16_tipos_emp c ON c.ctrol_emp = a.ctrol_emp
    INNER JOIN ta_16_empresas d ON d.ctrol_emp = a.ctrol_emp AND d.num_empresa = a.num_empresa
    INNER JOIN ta_16_unidades e ON e.ctrol_recolec = a.ctrol_recolec
    INNER JOIN ta_16_zonas f ON f.ctrol_zona = a.ctrol_zona
    INNER JOIN ta_16_recaudadoras g ON g.id_rec = a.id_rec
    WHERE a.num_contrato = p_num_contrato
      AND a.ctrol_aseo = p_ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_buscar_contrato_baja(INTEGER, INTEGER) TO PUBLIC;

-- SP 2/4: sp16_ade_x_contrato
-- Tipo: Select
-- Descripcion: Verifica si el contrato tiene adeudos vencidos
-- Retorna status=1 si tiene adeudos, con leyenda del ultimo periodo vencido
-- ============================================
DROP FUNCTION IF EXISTS public.sp16_ade_x_contrato(INTEGER);

CREATE OR REPLACE FUNCTION public.sp16_ade_x_contrato(
    p_control_contrato INTEGER
)
RETURNS TABLE (
    status INTEGER,
    leyenda VARCHAR
) AS $$
DECLARE
    v_count INTEGER;
    v_ultimo_periodo VARCHAR;
BEGIN
    -- Contar adeudos vencidos (status_vigencia = 'V' y fecha anterior a hoy)
    SELECT COUNT(*), MAX(TO_CHAR(aso_mes_pago, 'YYYY-MM'))
    INTO v_count, v_ultimo_periodo
    FROM ta_16_pagos
    WHERE control_contrato = p_control_contrato
      AND status_vigencia = 'V'
      AND aso_mes_pago < CURRENT_DATE;

    IF v_count > 0 THEN
        RETURN QUERY SELECT
            1::INTEGER,
            ('TIENE ' || v_count || ' ADEUDOS HASTA ' || COALESCE(v_ultimo_periodo, ''))::VARCHAR;
    ELSE
        RETURN QUERY SELECT
            0::INTEGER,
            'SIN ADEUDOS VENCIDOS'::VARCHAR;
    END IF;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp16_ade_x_contrato(INTEGER) TO PUBLIC;

-- SP 3/4: sp_aseo_buscar_convenio_contrato
-- Tipo: Select
-- Descripcion: Busca si el contrato tiene convenio (para status='N')
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_buscar_convenio_contrato(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_buscar_convenio_contrato(
    p_control_contrato INTEGER
)
RETURNS TABLE (
    convenio VARCHAR,
    id_conv_resto INTEGER
) AS $$
BEGIN
    -- Buscar en tabla de convenios si existe
    -- Nota: Ajustar segun estructura real de la tabla de convenios
    RETURN QUERY
    SELECT
        COALESCE(c.num_convenio, '')::VARCHAR as convenio,
        COALESCE(c.id_conv_resto, 0)::INTEGER
    FROM ta_convenios_aseo c
    WHERE c.control_contrato = p_control_contrato
    LIMIT 1;

    -- Si no existe tabla o no hay resultados, retornar vacio
    IF NOT FOUND THEN
        RETURN;
    END IF;

EXCEPTION WHEN undefined_table THEN
    -- Si la tabla no existe, no retornar nada
    RETURN;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_buscar_convenio_contrato(INTEGER) TO PUBLIC;

-- SP 4/4: sp16_cancela_contrato
-- Tipo: Update
-- Descripcion: Cancela/da de baja el contrato
-- Parametros segun Delphi:
--   parControl_Contrato, parFechaCanc, parPeriodo (YYYY-MM), parDocto, parDescrip
-- ============================================
DROP FUNCTION IF EXISTS public.sp16_cancela_contrato(INTEGER, DATE, VARCHAR, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION public.sp16_cancela_contrato(
    p_control_contrato INTEGER,
    p_fecha_canc DATE,
    p_periodo VARCHAR,        -- Formato YYYY-MM
    p_docto VARCHAR,
    p_descrip VARCHAR
)
RETURNS TABLE (
    status INTEGER,
    leyenda VARCHAR
) AS $$
DECLARE
    v_anio_periodo INTEGER;
    v_mes_periodo INTEGER;
    v_aso_mes_oblig DATE;
    v_anio_oblig INTEGER;
BEGIN
    -- Obtener fecha de inicio de obligacion
    SELECT aso_mes_oblig INTO v_aso_mes_oblig
    FROM ta_16_contratos
    WHERE control_contrato = p_control_contrato;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            1::INTEGER,
            'Contrato no encontrado'::VARCHAR;
        RETURN;
    END IF;

    -- Extraer anio del periodo
    v_anio_periodo := CAST(SUBSTRING(p_periodo, 1, 4) AS INTEGER);
    v_mes_periodo := CAST(SUBSTRING(p_periodo, 6, 2) AS INTEGER);
    v_anio_oblig := EXTRACT(YEAR FROM v_aso_mes_oblig);

    -- Validar que el anio no sea menor al inicio de obligacion
    IF v_anio_periodo < v_anio_oblig THEN
        RETURN QUERY SELECT
            1::INTEGER,
            'El Anio de Cancelacion no puede ser MENOR al Inicio de Obligacion'::VARCHAR;
        RETURN;
    END IF;

    -- Actualizar contrato a status 'C' (Cancelado/Baja)
    UPDATE ta_16_contratos SET
        status_vigencia = 'C',
        fecha_hora_baja = p_fecha_canc,
        cve = 'B'  -- Baja
    WHERE control_contrato = p_control_contrato;

    -- Cancelar adeudos desde el periodo indicado en adelante
    UPDATE ta_16_pagos SET
        status_vigencia = 'C'
    WHERE control_contrato = p_control_contrato
      AND status_vigencia = 'V'
      AND aso_mes_pago >= TO_DATE(p_periodo || '-01', 'YYYY-MM-DD');

    -- Insertar registro en historial
    INSERT INTO ta_16_historial_contratos (
        control_contrato,
        fecha_movimiento,
        tipo_movimiento,
        documento,
        descripcion,
        usuario
    ) VALUES (
        p_control_contrato,
        NOW(),
        'BAJA',
        p_docto,
        p_descrip,
        1  -- TODO: parametro de usuario
    );

    RETURN QUERY SELECT
        0::INTEGER,
        'Contrato dado de BAJA exitosamente'::VARCHAR;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT
        1::INTEGER,
        ('Error al cancelar contrato: ' || SQLERRM)::VARCHAR;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp16_cancela_contrato(INTEGER, DATE, VARCHAR, VARCHAR, VARCHAR) TO PUBLIC;

-- ============================================
-- DDL: Crear tabla historial si no existe
-- ============================================
-- CREATE TABLE IF NOT EXISTS ta_16_historial_contratos (
--     id SERIAL PRIMARY KEY,
--     control_contrato INTEGER,
--     fecha_movimiento TIMESTAMP DEFAULT NOW(),
--     tipo_movimiento VARCHAR(20),
--     documento VARCHAR(100),
--     descripcion TEXT,
--     usuario INTEGER
-- );

-- ============================================
-- FIN DEL ARCHIVO
-- ============================================
