-- ============================================================================
-- ADEUDOS - ALL PROCEDURES
-- Aseo Contratado Module
-- Schema: public
-- Generated: 2025-12-07
-- ============================================================================

-- ============================================================================
-- 1. SP_ASEO_TIPOS_ASEO_LISTAR
-- List all types of aseo service
-- ============================================================================
CREATE OR REPLACE FUNCTION public.sp_aseo_tipos_aseo_listar()
RETURNS TABLE (
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR,
    cta_aplicacion INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ta.ctrol_aseo,
        ta.tipo_aseo,
        ta.descripcion,
        ta.cta_aplicacion
    FROM public.ta_16_tipo_aseo ta
    ORDER BY ta.ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 2. SP_ASEO_CONTRATO_BUSCAR
-- Search contract by number and type
-- ============================================================================
CREATE OR REPLACE FUNCTION public.sp_aseo_contrato_buscar(
    p_num_contrato INTEGER,
    p_ctrol_aseo INTEGER
)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    desc_tipo_aseo VARCHAR,
    ctrol_recolec INTEGER,
    cve_recolec VARCHAR,
    des_recoleccion VARCHAR,
    cantidad_recolec SMALLINT,
    domicilio VARCHAR,
    sector VARCHAR,
    ctrol_zona INTEGER,
    zona SMALLINT,
    sub_zona SMALLINT,
    des_zona VARCHAR,
    id_rec SMALLINT,
    recaudadora VARCHAR,
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    des_empresa VARCHAR,
    fecha_hora_alta TIMESTAMP,
    status_vigencia VARCHAR,
    aso_mes_oblig TIMESTAMP,
    cve VARCHAR,
    usuario INTEGER,
    fecha_hora_baja TIMESTAMP,
    costo_exed NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        c.ctrol_aseo,
        d.tipo_aseo,
        d.descripcion AS desc_tipo_aseo,
        c.ctrol_recolec,
        e.cve_recolec,
        e.descripcion AS des_recoleccion,
        c.cantidad_recolec,
        c.domicilio,
        c.sector,
        c.ctrol_zona,
        f.zona,
        f.sub_zona,
        f.descripcion AS des_zona,
        c.id_rec,
        g.recaudadora,
        c.num_empresa,
        h.ctrol_emp,
        h.descripcion AS des_empresa,
        c.fecha_hora_alta,
        c.status_vigencia,
        c.aso_mes_oblig,
        c.cve,
        c.usuario,
        c.fecha_hora_baja,
        COALESCE(c.costo_exed, 0) AS costo_exed
    FROM public.ta_16_contratos c
    INNER JOIN public.ta_16_tipo_aseo d ON d.ctrol_aseo = c.ctrol_aseo
    INNER JOIN public.ta_16_unidades e ON e.ctrol_recolec = c.ctrol_recolec
    INNER JOIN public.ta_16_zonas f ON f.ctrol_zona = c.ctrol_zona
    INNER JOIN public.ta_12_recaudadoras g ON g.id_rec = c.id_rec
    INNER JOIN public.ta_16_empresas h ON h.num_empresa = c.num_empresa AND h.ctrol_emp = c.ctrol_emp
    WHERE c.num_contrato = p_num_contrato
      AND c.ctrol_aseo = p_ctrol_aseo
      AND c.status_vigencia = 'V'
    ORDER BY c.ctrol_aseo, c.num_contrato;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 3. SP_ASEO_CREA_DET_PAGOS
-- Create temporary table for payment details
-- ============================================================================
CREATE OR REPLACE FUNCTION public.sp_aseo_crea_det_pagos()
RETURNS VOID AS $$
BEGIN
    DROP TABLE IF EXISTS temp_det_pagos;

    CREATE TEMP TABLE temp_det_pagos (
        control_contrato INTEGER,
        ejercicio INTEGER,
        detalle VARCHAR(100),
        importe_adeudos NUMERIC(12,2) DEFAULT 0,
        importe_recargos NUMERIC(12,2) DEFAULT 0,
        importe_multas NUMERIC(12,2) DEFAULT 0,
        importe_gastos NUMERIC(12,2) DEFAULT 0
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 4. SP_ASEO_CREA_DET_APREMIOS
-- Create temporary table for apremios
-- ============================================================================
CREATE OR REPLACE FUNCTION public.sp_aseo_crea_det_apremios()
RETURNS VOID AS $$
BEGIN
    DROP TABLE IF EXISTS temp_det_apremios;

    CREATE TEMP TABLE temp_det_apremios (
        control_contrato INTEGER,
        ejercicio INTEGER,
        gastos_apremio NUMERIC(12,2) DEFAULT 0
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 5. SP_ASEO_DET_APREMIOS
-- Calculate apremios details
-- ============================================================================
CREATE OR REPLACE FUNCTION public.sp_aseo_det_apremios(
    p_control_contrato INTEGER
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO temp_det_apremios (control_contrato, ejercicio, gastos_apremio)
    SELECT
        control_contrato,
        EXTRACT(YEAR FROM aso_mes_pago)::INTEGER AS ejercicio,
        SUM(COALESCE(importe_gastos, 0)) AS gastos_apremio
    FROM public.ta_16_pagos
    WHERE control_contrato = p_control_contrato
      AND importe_gastos > 0
      AND status_vigencia IN ('V', 'P')
    GROUP BY control_contrato, EXTRACT(YEAR FROM aso_mes_pago);
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 6. SP_ASEO_DET_PAGOS
-- Calculate payment details by period
-- ============================================================================
CREATE OR REPLACE FUNCTION public.sp_aseo_det_pagos(
    p_control INTEGER,
    p_ejercicio INTEGER,
    p_per1 VARCHAR,
    p_per2 VARCHAR,
    p_per3 VARCHAR,
    p_status VARCHAR
)
RETURNS VOID AS $$
DECLARE
    v_aso_ini INTEGER;
    v_mes_ini INTEGER;
    v_aso_fin INTEGER;
    v_mes_fin INTEGER;
BEGIN
    -- Parsear periodo inicial
    v_aso_ini := SPLIT_PART(p_per1, '-', 1)::INTEGER;
    v_mes_ini := SPLIT_PART(p_per1, '-', 2)::INTEGER;

    -- Parsear periodo final
    v_aso_fin := SPLIT_PART(p_per2, '-', 1)::INTEGER;
    v_mes_fin := SPLIT_PART(p_per2, '-', 2)::INTEGER;

    -- Insertar detalle de adeudos por ejercicio
    INSERT INTO temp_det_pagos (control_contrato, ejercicio, detalle,
                                 importe_adeudos, importe_recargos,
                                 importe_multas, importe_gastos)
    SELECT
        p_control,
        EXTRACT(YEAR FROM aso_mes_pago)::INTEGER,
        'Adeudos ' || EXTRACT(YEAR FROM aso_mes_pago)::VARCHAR,
        SUM(CASE WHEN ctrol_operacion = 1 THEN COALESCE(importe, 0) ELSE 0 END),
        SUM(CASE WHEN ctrol_operacion = 2 THEN COALESCE(importe, 0) ELSE 0 END),
        SUM(CASE WHEN ctrol_operacion = 3 THEN COALESCE(importe, 0) ELSE 0 END),
        COALESCE(
            (SELECT gastos_apremio
             FROM temp_det_apremios
             WHERE control_contrato = p_control
               AND ejercicio = EXTRACT(YEAR FROM aso_mes_pago)::INTEGER
             LIMIT 1), 0
        )
    FROM public.ta_16_pagos
    WHERE control_contrato = p_control
      AND status_vigencia IN ('V', 'P')
      AND aso_mes_pago >= (v_aso_ini || '-' || LPAD(v_mes_ini::TEXT, 2, '0') || '-01')::DATE
      AND aso_mes_pago <= (v_aso_fin || '-' || LPAD(v_mes_fin::TEXT, 2, '0') || '-01')::DATE
    GROUP BY EXTRACT(YEAR FROM aso_mes_pago)
    ORDER BY EXTRACT(YEAR FROM aso_mes_pago);
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 7. SP_ASEO_EDO_CUENTA_DETALLE
-- Get account statement detail
-- ============================================================================
CREATE OR REPLACE FUNCTION public.sp_aseo_edo_cuenta_detalle(
    p_control_contrato INTEGER
)
RETURNS TABLE (
    control_contrato INTEGER,
    ejercicio INTEGER,
    detalle VARCHAR,
    importe_adeudos NUMERIC,
    importe_recargos NUMERIC,
    importe_multas NUMERIC,
    importe_gastos NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        dp.control_contrato,
        dp.ejercicio,
        dp.detalle,
        dp.importe_adeudos,
        dp.importe_recargos,
        dp.importe_multas,
        dp.importe_gastos
    FROM temp_det_pagos dp
    WHERE dp.control_contrato = p_control_contrato
    ORDER BY dp.ejercicio;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 8. SP_ASEO_TIPOS_OPERACION_LISTAR
-- List operation types
-- ============================================================================
CREATE OR REPLACE FUNCTION public.sp_aseo_tipos_operacion_listar()
RETURNS TABLE (
    ctrol_operacion INTEGER,
    cve_operacion VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        to2.ctrol_operacion,
        to2.cve_operacion,
        to2.descripcion
    FROM public.ta_14_cve_operacion to2
    ORDER BY to2.ctrol_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 9. SP_ASEO_ADEUDO_INSERTAR
-- Insert new debt
-- ============================================================================
CREATE OR REPLACE FUNCTION public.sp_aseo_adeudo_insertar(
    p_control_contrato INTEGER,
    p_aso_mes_pago DATE,
    p_ctrol_operacion INTEGER,
    p_importe NUMERIC,
    p_status_vigencia VARCHAR,
    p_folio_rcbo VARCHAR,
    p_usuario INTEGER,
    p_exedencias SMALLINT DEFAULT 0
)
RETURNS TABLE (
    success BOOLEAN,
    mensaje VARCHAR
) AS $$
DECLARE
    v_existe INTEGER;
BEGIN
    -- Verificar si ya existe el adeudo
    SELECT COUNT(*) INTO v_existe
    FROM public.ta_16_pagos
    WHERE control_contrato = p_control_contrato
      AND aso_mes_pago = p_aso_mes_pago
      AND ctrol_operacion = p_ctrol_operacion
      AND status_vigencia IN ('V', 'P');

    IF v_existe > 0 THEN
        RETURN QUERY SELECT FALSE, 'El adeudo ya existe para este periodo y operación';
        RETURN;
    END IF;

    -- Insertar nuevo adeudo
    INSERT INTO public.ta_16_pagos (
        control_contrato,
        aso_mes_pago,
        ctrol_operacion,
        importe,
        status_vigencia,
        folio_rcbo,
        usuario,
        cantidad_exedencias,
        fecha_hora
    ) VALUES (
        p_control_contrato,
        p_aso_mes_pago,
        p_ctrol_operacion,
        p_importe,
        p_status_vigencia,
        p_folio_rcbo,
        p_usuario,
        p_exedencias,
        NOW()
    );

    RETURN QUERY SELECT TRUE, 'Adeudo insertado exitosamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 10. SP_ASEO_ADEUDO_ELIMINAR
-- Delete debt (with validation)
-- ============================================================================
CREATE OR REPLACE FUNCTION public.sp_aseo_adeudo_eliminar(
    p_control_contrato INTEGER,
    p_aso_mes_pago DATE,
    p_ctrol_operacion INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    mensaje VARCHAR
) AS $$
DECLARE
    v_existe INTEGER;
    v_tiene_pago INTEGER;
BEGIN
    -- Verificar si existe el adeudo
    SELECT COUNT(*) INTO v_existe
    FROM public.ta_16_pagos
    WHERE control_contrato = p_control_contrato
      AND aso_mes_pago = p_aso_mes_pago
      AND ctrol_operacion = p_ctrol_operacion;

    IF v_existe = 0 THEN
        RETURN QUERY SELECT FALSE, 'El adeudo no existe';
        RETURN;
    END IF;

    -- Verificar si tiene pagos aplicados
    SELECT COUNT(*) INTO v_tiene_pago
    FROM public.ta_16_pagos
    WHERE control_contrato = p_control_contrato
      AND aso_mes_pago = p_aso_mes_pago
      AND ctrol_operacion = p_ctrol_operacion
      AND status_vigencia = 'P';

    IF v_tiene_pago > 0 THEN
        RETURN QUERY SELECT FALSE, 'No se puede eliminar un adeudo con pagos aplicados';
        RETURN;
    END IF;

    -- Eliminar adeudo
    DELETE FROM public.ta_16_pagos
    WHERE control_contrato = p_control_contrato
      AND aso_mes_pago = p_aso_mes_pago
      AND ctrol_operacion = p_ctrol_operacion;

    RETURN QUERY SELECT TRUE, 'Adeudo eliminado exitosamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 11. SP_ASEO_ADEUDOS_VENCIDOS
-- Get overdue debts
-- ============================================================================
CREATE OR REPLACE FUNCTION public.sp_aseo_adeudos_vencidos(
    p_fecha_corte DATE DEFAULT NULL
)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    nom_empresa VARCHAR,
    aso_mes_pago DATE,
    periodo VARCHAR,
    concepto VARCHAR,
    importe NUMERIC,
    dias_vencidos INTEGER,
    recargo_aplicable NUMERIC
) AS $$
DECLARE
    v_fecha_corte DATE;
BEGIN
    v_fecha_corte := COALESCE(p_fecha_corte, CURRENT_DATE);

    RETURN QUERY
    SELECT
        p.control_contrato,
        c.num_contrato,
        e.descripcion AS nom_empresa,
        p.aso_mes_pago,
        TO_CHAR(p.aso_mes_pago, 'YYYY-MM') AS periodo,
        o.descripcion AS concepto,
        p.importe,
        (v_fecha_corte - p.aso_mes_pago)::INTEGER AS dias_vencidos,
        (p.importe * 0.02 * FLOOR((v_fecha_corte - p.aso_mes_pago) / 30.0)) AS recargo_aplicable
    FROM public.ta_16_pagos p
    INNER JOIN public.ta_16_contratos c ON c.control_contrato = p.control_contrato
    INNER JOIN public.ta_16_empresas e ON e.num_empresa = c.num_empresa AND e.ctrol_emp = c.ctrol_emp
    INNER JOIN public.ta_14_cve_operacion o ON o.ctrol_operacion = p.ctrol_operacion
    WHERE p.status_vigencia = 'V'
      AND p.aso_mes_pago < v_fecha_corte
      AND p.importe > 0
    ORDER BY dias_vencidos DESC, p.importe DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 12. SP_ASEO_ADEUDOS_ESTADISTICAS
-- Get debt statistics
-- ============================================================================
CREATE OR REPLACE FUNCTION public.sp_aseo_adeudos_estadisticas(
    p_ejercicio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    ejercicio INTEGER,
    total_contratos INTEGER,
    contratos_con_adeudo INTEGER,
    contratos_al_corriente INTEGER,
    total_adeudos NUMERIC,
    total_recargos NUMERIC,
    total_multas NUMERIC,
    total_gastos NUMERIC,
    promedio_adeudo NUMERIC
) AS $$
DECLARE
    v_ejercicio INTEGER;
BEGIN
    v_ejercicio := COALESCE(p_ejercicio, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER);

    RETURN QUERY
    SELECT
        v_ejercicio,
        COUNT(DISTINCT c.control_contrato)::INTEGER AS total_contratos,
        COUNT(DISTINCT CASE WHEN p.control_contrato IS NOT NULL THEN c.control_contrato END)::INTEGER AS contratos_con_adeudo,
        COUNT(DISTINCT CASE WHEN p.control_contrato IS NULL THEN c.control_contrato END)::INTEGER AS contratos_al_corriente,
        COALESCE(SUM(CASE WHEN o.ctrol_operacion = 1 THEN p.importe ELSE 0 END), 0) AS total_adeudos,
        COALESCE(SUM(CASE WHEN o.ctrol_operacion = 2 THEN p.importe ELSE 0 END), 0) AS total_recargos,
        COALESCE(SUM(CASE WHEN o.ctrol_operacion = 3 THEN p.importe ELSE 0 END), 0) AS total_multas,
        COALESCE(SUM(p.importe_gastos), 0) AS total_gastos,
        COALESCE(AVG(p.importe), 0) AS promedio_adeudo
    FROM public.ta_16_contratos c
    LEFT JOIN public.ta_16_pagos p ON p.control_contrato = c.control_contrato
        AND p.status_vigencia = 'V'
        AND EXTRACT(YEAR FROM p.aso_mes_pago) = v_ejercicio
    LEFT JOIN public.ta_14_cve_operacion o ON o.ctrol_operacion = p.ctrol_operacion
    WHERE c.status_vigencia = 'V';
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 13. SP_ASEO_ADEUDO_ACTUALIZAR_EXCEDENTE
-- Update exceeded quantities
-- ============================================================================
CREATE OR REPLACE FUNCTION public.sp_aseo_adeudo_actualizar_excedente(
    p_control_contrato INTEGER,
    p_aso_mes_pago DATE,
    p_ctrol_operacion INTEGER,
    p_nueva_cantidad SMALLINT,
    p_nuevo_importe NUMERIC
)
RETURNS TABLE (
    success BOOLEAN,
    mensaje VARCHAR
) AS $$
BEGIN
    UPDATE public.ta_16_pagos
    SET cantidad_exedencias = p_nueva_cantidad,
        importe = p_nuevo_importe,
        fecha_hora = NOW()
    WHERE control_contrato = p_control_contrato
      AND aso_mes_pago = p_aso_mes_pago
      AND ctrol_operacion = p_ctrol_operacion;

    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Excedente actualizado exitosamente';
    ELSE
        RETURN QUERY SELECT FALSE, 'No se encontró el adeudo a actualizar';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 14. SP_ASEO_ADEUDOS_CONDONAR
-- Forgive/condone debts
-- ============================================================================
CREATE OR REPLACE FUNCTION public.sp_aseo_adeudos_condonar(
    p_control_contrato INTEGER,
    p_ejercicio INTEGER,
    p_tipo_condonacion VARCHAR, -- 'R' = Recargos, 'M' = Multas, 'T' = Total
    p_porcentaje NUMERIC DEFAULT 100,
    p_usuario INTEGER DEFAULT 1
)
RETURNS TABLE (
    success BOOLEAN,
    mensaje VARCHAR,
    adeudos_afectados INTEGER,
    monto_condonado NUMERIC
) AS $$
DECLARE
    v_count INTEGER := 0;
    v_monto NUMERIC := 0;
BEGIN
    -- Aplicar condonación según el tipo
    IF p_tipo_condonacion = 'R' THEN
        -- Condonar recargos
        WITH updated AS (
            UPDATE public.ta_16_pagos
            SET importe = importe * (1 - (p_porcentaje / 100.0)),
                status_vigencia = 'C'
            WHERE control_contrato = p_control_contrato
              AND EXTRACT(YEAR FROM aso_mes_pago) = p_ejercicio
              AND ctrol_operacion = 2 -- Recargos
              AND status_vigencia = 'V'
            RETURNING importe
        )
        SELECT COUNT(*), SUM(importe) INTO v_count, v_monto FROM updated;

    ELSIF p_tipo_condonacion = 'M' THEN
        -- Condonar multas
        WITH updated AS (
            UPDATE public.ta_16_pagos
            SET importe = importe * (1 - (p_porcentaje / 100.0)),
                status_vigencia = 'C'
            WHERE control_contrato = p_control_contrato
              AND EXTRACT(YEAR FROM aso_mes_pago) = p_ejercicio
              AND ctrol_operacion = 3 -- Multas
              AND status_vigencia = 'V'
            RETURNING importe
        )
        SELECT COUNT(*), SUM(importe) INTO v_count, v_monto FROM updated;

    ELSIF p_tipo_condonacion = 'T' THEN
        -- Condonar todo
        WITH updated AS (
            UPDATE public.ta_16_pagos
            SET importe = importe * (1 - (p_porcentaje / 100.0)),
                status_vigencia = 'C'
            WHERE control_contrato = p_control_contrato
              AND EXTRACT(YEAR FROM aso_mes_pago) = p_ejercicio
              AND status_vigencia = 'V'
            RETURNING importe
        )
        SELECT COUNT(*), SUM(importe) INTO v_count, v_monto FROM updated;
    END IF;

    RETURN QUERY SELECT
        TRUE,
        'Condonación aplicada exitosamente',
        v_count,
        COALESCE(v_monto, 0);
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- END OF FILE
-- ============================================================================
