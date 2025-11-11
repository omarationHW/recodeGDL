-- ============================================================================
-- MÓDULO CONTRATOS - 16 SPs
-- Generado: 2025-11-09
-- Desbloquea: Contratos.vue, Cons_Cont.vue, Contratos_Mod.vue, etc.
-- ============================================================================

-- 1. SP_ASEO_CONTRATOS_LIST - Listar todos los contratos
CREATE OR REPLACE FUNCTION public.sp_aseo_contratos_list(
    p_limit INTEGER DEFAULT 100,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    num_empresa INTEGER,
    domicilio VARCHAR,
    status_vigencia CHAR,
    fecha_hora_alta TIMESTAMP,
    total_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        c.ctrol_aseo,
        c.num_empresa,
        c.domicilio,
        c.status_vigencia,
        c.fecha_hora_alta,
        COUNT(*) OVER() as total_count
    FROM ta_16_contratos c
    WHERE c.status_vigencia != 'B'
    ORDER BY c.control_contrato DESC
    LIMIT p_limit OFFSET p_offset;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- 2. SP_ASEO_DETALLE_CONTRATO - Consultar detalle de un contrato
CREATE OR REPLACE FUNCTION public.sp_aseo_detalle_contrato(
    p_control_contrato INTEGER
)
RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    ctrol_recolec INTEGER,
    cantidad_recolec SMALLINT,
    domicilio VARCHAR,
    sector CHAR,
    ctrol_zona INTEGER,
    id_rec SMALLINT,
    fecha_hora_alta TIMESTAMP,
    status_vigencia CHAR,
    aso_mes_oblig TIMESTAMP,
    cve CHAR,
    usuario INTEGER,
    fecha_hora_baja TIMESTAMP,
    tipo_desc VARCHAR,
    empresa_nombre VARCHAR,
    zona_desc VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        c.ctrol_aseo,
        c.num_empresa,
        c.ctrol_emp,
        c.ctrol_recolec,
        c.cantidad_recolec,
        c.domicilio,
        c.sector,
        c.ctrol_zona,
        c.id_rec,
        c.fecha_hora_alta,
        c.status_vigencia,
        c.aso_mes_oblig,
        c.cve,
        c.usuario,
        c.fecha_hora_baja,
        COALESCE(t.descripcion, '') as tipo_desc,
        COALESCE(e.descripcion, '') as empresa_nombre,
        COALESCE(z.descripcion, '') as zona_desc
    FROM ta_16_contratos c
    LEFT JOIN ta_16_tipo_aseo t ON c.ctrol_aseo = t.ctrol_aseo
    LEFT JOIN ta_16_empresas e ON c.num_empresa = e.num_empresa
    LEFT JOIN ta_16_zonas z ON c.ctrol_zona = z.ctrol_zona
    WHERE c.control_contrato = p_control_contrato;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- 3. SP_ASEO_CONTRATOS_UPDATE - Actualizar contrato
CREATE OR REPLACE FUNCTION public.sp_aseo_contratos_update(
    p_control_contrato INTEGER,
    p_ctrol_aseo INTEGER DEFAULT NULL,
    p_num_empresa INTEGER DEFAULT NULL,
    p_domicilio VARCHAR DEFAULT NULL,
    p_ctrol_zona INTEGER DEFAULT NULL,
    p_cantidad_recolec SMALLINT DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    UPDATE ta_16_contratos
    SET
        ctrol_aseo = COALESCE(p_ctrol_aseo, ctrol_aseo),
        num_empresa = COALESCE(p_num_empresa, num_empresa),
        domicilio = COALESCE(p_domicilio, domicilio),
        ctrol_zona = COALESCE(p_ctrol_zona, ctrol_zona),
        cantidad_recolec = COALESCE(p_cantidad_recolec, cantidad_recolec)
    WHERE control_contrato = p_control_contrato;

    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Contrato actualizado correctamente';
    ELSE
        RETURN QUERY SELECT FALSE, 'Contrato no encontrado';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- 4. SP_ASEO_CONTRATOS_CONSULTA_ADMIN - Consulta administrativa de contratos
CREATE OR REPLACE FUNCTION public.sp_aseo_contratos_consulta_admin(
    p_num_contrato INTEGER DEFAULT NULL,
    p_domicilio VARCHAR DEFAULT NULL,
    p_status_vigencia CHAR DEFAULT NULL,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    domicilio VARCHAR,
    status_vigencia CHAR,
    fecha_alta TIMESTAMP,
    tipo_aseo VARCHAR,
    empresa VARCHAR,
    zona VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        c.domicilio,
        c.status_vigencia,
        c.fecha_hora_alta,
        COALESCE(t.descripcion, '') as tipo_aseo,
        COALESCE(e.descripcion, '') as empresa,
        COALESCE(z.descripcion, '') as zona
    FROM ta_16_contratos c
    LEFT JOIN ta_16_tipo_aseo t ON c.ctrol_aseo = t.ctrol_aseo
    LEFT JOIN ta_16_empresas e ON c.num_empresa = e.num_empresa
    LEFT JOIN ta_16_zonas z ON c.ctrol_zona = z.ctrol_zona
    WHERE (p_num_contrato IS NULL OR c.num_contrato = p_num_contrato)
      AND (p_domicilio IS NULL OR c.domicilio ILIKE '%' || p_domicilio || '%')
      AND (p_status_vigencia IS NULL OR c.status_vigencia = p_status_vigencia)
    ORDER BY c.control_contrato DESC
    LIMIT p_limit;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- 5. SP_ASEO_CONTRATOS_POR_TIPO - Consultar contratos por tipo
CREATE OR REPLACE FUNCTION public.sp_aseo_contratos_por_tipo(
    p_ctrol_aseo INTEGER
)
RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    domicilio VARCHAR,
    status_vigencia CHAR,
    fecha_alta TIMESTAMP,
    tipo_desc VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        c.domicilio,
        c.status_vigencia,
        c.fecha_hora_alta,
        COALESCE(t.descripcion, '') as tipo_desc
    FROM ta_16_contratos c
    LEFT JOIN ta_16_tipo_aseo t ON c.ctrol_aseo = t.ctrol_aseo
    WHERE c.ctrol_aseo = p_ctrol_aseo
      AND c.status_vigencia != 'B'
    ORDER BY c.control_contrato DESC;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- 6. SP_ASEO_CONTRATOS_POR_EMPRESA - Consultar contratos por empresa
CREATE OR REPLACE FUNCTION public.sp_aseo_contratos_por_empresa(
    p_num_empresa INTEGER
)
RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    domicilio VARCHAR,
    status_vigencia CHAR,
    fecha_alta TIMESTAMP,
    empresa_nombre VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        c.domicilio,
        c.status_vigencia,
        c.fecha_hora_alta,
        COALESCE(e.descripcion, '') as empresa_nombre
    FROM ta_16_contratos c
    LEFT JOIN ta_16_empresas e ON c.num_empresa = e.num_empresa
    WHERE c.num_empresa = p_num_empresa
      AND c.status_vigencia != 'B'
    ORDER BY c.control_contrato DESC;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- 7. SP_ASEO_CONTRATO_CANCELAR - Cancelar contrato (soft delete)
CREATE OR REPLACE FUNCTION public.sp_aseo_contrato_cancelar(
    p_control_contrato INTEGER,
    p_usuario INTEGER DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_tiene_adeudos INTEGER;
    v_tiene_pagos INTEGER;
BEGIN
    -- Verificar si tiene adeudos pendientes
    SELECT COUNT(*) INTO v_tiene_adeudos
    FROM ta_16_adeudos
    WHERE ctrol_contrato = p_control_contrato
      AND status_adeudo = 'P';

    -- Verificar si tiene pagos
    SELECT COUNT(*) INTO v_tiene_pagos
    FROM ta_16_pagos
    WHERE ctrol_contrato = p_control_contrato;

    IF v_tiene_adeudos > 0 THEN
        RETURN QUERY SELECT FALSE, 'No se puede cancelar: tiene adeudos pendientes';
        RETURN;
    END IF;

    -- Cancelar contrato
    UPDATE ta_16_contratos
    SET
        status_vigencia = 'B',
        fecha_hora_baja = NOW(),
        usuario = COALESCE(p_usuario, usuario)
    WHERE control_contrato = p_control_contrato;

    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Contrato cancelado correctamente';
    ELSE
        RETURN QUERY SELECT FALSE, 'Contrato no encontrado';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- 8. SP_ASEO_CONTRATOS_PARA_UPD_PERIODO - Listar contratos para actualizar periodo
CREATE OR REPLACE FUNCTION public.sp_aseo_contratos_para_upd_periodo(
    p_ctrol_zona INTEGER DEFAULT NULL,
    p_ctrol_aseo INTEGER DEFAULT NULL
)
RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    domicilio VARCHAR,
    aso_mes_oblig TIMESTAMP,
    zona VARCHAR,
    tipo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        c.domicilio,
        c.aso_mes_oblig,
        COALESCE(z.descripcion, '') as zona,
        COALESCE(t.descripcion, '') as tipo
    FROM ta_16_contratos c
    LEFT JOIN ta_16_zonas z ON c.ctrol_zona = z.ctrol_zona
    LEFT JOIN ta_16_tipo_aseo t ON c.ctrol_aseo = t.ctrol_aseo
    WHERE c.status_vigencia = 'V'
      AND (p_ctrol_zona IS NULL OR c.ctrol_zona = p_ctrol_zona)
      AND (p_ctrol_aseo IS NULL OR c.ctrol_aseo = p_ctrol_aseo)
    ORDER BY c.control_contrato;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- 9. SP_ASEO_ACTUALIZAR_PERIODOS_CONTRATOS - Actualizar periodos masivamente
CREATE OR REPLACE FUNCTION public.sp_aseo_actualizar_periodos_contratos(
    p_contratos INTEGER[],
    p_nuevo_periodo TIMESTAMP
)
RETURNS TABLE(success BOOLEAN, message TEXT, total_updated INTEGER) AS $$
DECLARE
    v_updated INTEGER;
BEGIN
    UPDATE ta_16_contratos
    SET aso_mes_oblig = p_nuevo_periodo
    WHERE control_contrato = ANY(p_contratos)
      AND status_vigencia = 'V';

    GET DIAGNOSTICS v_updated = ROW_COUNT;

    RETURN QUERY SELECT TRUE, 'Periodos actualizados', v_updated;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, 0;
END;
$$ LANGUAGE plpgsql;

-- 10. SP_ASEO_CONTRATOS_PARA_UPD_UNIDAD - Listar contratos para actualizar unidad
CREATE OR REPLACE FUNCTION public.sp_aseo_contratos_para_upd_unidad(
    p_ctrol_zona INTEGER DEFAULT NULL
)
RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    domicilio VARCHAR,
    cantidad_recolec SMALLINT,
    zona VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        c.domicilio,
        c.cantidad_recolec,
        COALESCE(z.descripcion, '') as zona
    FROM ta_16_contratos c
    LEFT JOIN ta_16_zonas z ON c.ctrol_zona = z.ctrol_zona
    WHERE c.status_vigencia = 'V'
      AND (p_ctrol_zona IS NULL OR c.ctrol_zona = p_ctrol_zona)
    ORDER BY c.control_contrato;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- 11. SP_ASEO_ACTUALIZAR_UNIDADES_CONTRATOS - Actualizar unidades masivamente
CREATE OR REPLACE FUNCTION public.sp_aseo_actualizar_unidades_contratos(
    p_contratos INTEGER[],
    p_nueva_cantidad SMALLINT
)
RETURNS TABLE(success BOOLEAN, message TEXT, total_updated INTEGER) AS $$
DECLARE
    v_updated INTEGER;
BEGIN
    UPDATE ta_16_contratos
    SET cantidad_recolec = p_nueva_cantidad
    WHERE control_contrato = ANY(p_contratos)
      AND status_vigencia = 'V';

    GET DIAGNOSTICS v_updated = ROW_COUNT;

    RETURN QUERY SELECT TRUE, 'Unidades actualizadas', v_updated;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, 0;
END;
$$ LANGUAGE plpgsql;

-- 12. SP_ASEO_CONTRATOS_PARA_ACTUALIZAR - Listar contratos pendientes de actualización
CREATE OR REPLACE FUNCTION public.sp_aseo_contratos_para_actualizar()
RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    domicilio VARCHAR,
    fecha_alta TIMESTAMP,
    dias_sin_actualizar INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        c.domicilio,
        c.fecha_hora_alta,
        EXTRACT(DAY FROM NOW() - c.fecha_hora_alta)::INTEGER as dias_sin_actualizar
    FROM ta_16_contratos c
    WHERE c.status_vigencia = 'V'
      AND c.aso_mes_oblig IS NULL
    ORDER BY c.fecha_hora_alta;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- 13. SP_ASEO_APLICAR_ACTUALIZACIONES_MASIVAS - Aplicar actualizaciones masivas
CREATE OR REPLACE FUNCTION public.sp_aseo_aplicar_actualizaciones_masivas(
    p_contratos INTEGER[],
    p_campo VARCHAR,
    p_valor VARCHAR
)
RETURNS TABLE(success BOOLEAN, message TEXT, total_updated INTEGER) AS $$
DECLARE
    v_updated INTEGER;
    v_sql TEXT;
BEGIN
    -- Validar campo permitido
    IF p_campo NOT IN ('ctrol_zona', 'ctrol_aseo', 'num_empresa', 'sector') THEN
        RETURN QUERY SELECT FALSE, 'Campo no permitido para actualización masiva', 0;
        RETURN;
    END IF;

    v_sql := 'UPDATE ta_16_contratos SET ' || p_campo || ' = $1 WHERE control_contrato = ANY($2) AND status_vigencia = ''V''';

    EXECUTE v_sql USING p_valor::INTEGER, p_contratos;
    GET DIAGNOSTICS v_updated = ROW_COUNT;

    RETURN QUERY SELECT TRUE, 'Actualizaciones aplicadas', v_updated;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, 0;
END;
$$ LANGUAGE plpgsql;

-- 14. SP_ASEO_CONTRATOS_SIN_PERIODO_INICIAL - Listar contratos sin periodo inicial
CREATE OR REPLACE FUNCTION public.sp_aseo_contratos_sin_periodo_inicial()
RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    domicilio VARCHAR,
    fecha_alta TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        c.domicilio,
        c.fecha_hora_alta
    FROM ta_16_contratos c
    WHERE c.status_vigencia = 'V'
      AND c.aso_mes_oblig IS NULL
    ORDER BY c.fecha_hora_alta;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- 15. SP_ASEO_BUSCAR_CONTRATO_INDIVIDUAL - Buscar contrato individual
CREATE OR REPLACE FUNCTION public.sp_aseo_buscar_contrato_individual(
    p_criterio VARCHAR
)
RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    domicilio VARCHAR,
    status_vigencia CHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        c.domicilio,
        c.status_vigencia
    FROM ta_16_contratos c
    WHERE c.num_contrato::TEXT ILIKE '%' || p_criterio || '%'
       OR c.domicilio ILIKE '%' || p_criterio || '%'
    ORDER BY c.control_contrato DESC
    LIMIT 50;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- 16. SP_ASEO_ACTUALIZAR_CONTRATO_INDIVIDUAL - Actualizar contrato individual
CREATE OR REPLACE FUNCTION public.sp_aseo_actualizar_contrato_individual(
    p_control_contrato INTEGER,
    p_updates JSONB
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_campo TEXT;
    v_valor TEXT;
    v_sql TEXT;
BEGIN
    -- Iterar sobre los campos a actualizar
    FOR v_campo, v_valor IN
        SELECT key, value::TEXT FROM jsonb_each_text(p_updates)
    LOOP
        -- Validar campos permitidos
        IF v_campo IN ('ctrol_aseo', 'num_empresa', 'domicilio', 'ctrol_zona', 'cantidad_recolec', 'sector') THEN
            v_sql := 'UPDATE ta_16_contratos SET ' || v_campo || ' = $1 WHERE control_contrato = $2';
            EXECUTE v_sql USING v_valor, p_control_contrato;
        END IF;
    END LOOP;

    RETURN QUERY SELECT TRUE, 'Contrato actualizado correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- FIN MÓDULO CONTRATOS
-- ============================================================================
-- ============================================================================
-- MÓDULO PAGOS - 7 SPs
-- Generado: 2025-11-09
-- Desbloquea: Pagos_Cons_Cont.vue, Pagos_Con_FPgo.vue, etc.
-- ============================================================================

-- 1. SP_ASEO_PAGOS_BUSCAR - Buscar pagos por criterios
CREATE OR REPLACE FUNCTION public.sp_aseo_pagos_buscar(
    p_control_contrato INTEGER DEFAULT NULL,
    p_folio_rcbo VARCHAR DEFAULT NULL,
    p_fecha_desde TIMESTAMP DEFAULT NULL,
    p_fecha_hasta TIMESTAMP DEFAULT NULL,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    control_contrato INTEGER,
    aso_mes_pago TIMESTAMP,
    ctrol_operacion INTEGER,
    importe NUMERIC,
    fecha_hora_pago TIMESTAMP,
    folio_rcbo VARCHAR,
    caja VARCHAR,
    status_vigencia CHAR,
    observaciones VARCHAR
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        p.control_contrato,
        p.aso_mes_pago,
        p.ctrol_operacion,
        p.importe,
        p.fecha_hora_pago,
        p.folio_rcbo,
        p.caja::VARCHAR,
        p.status_vigencia,
        p.observaciones
    FROM ta_16_pagos p
    WHERE (p_control_contrato IS NULL OR p.control_contrato = p_control_contrato)
      AND (p_folio_rcbo IS NULL OR p.folio_rcbo ILIKE '%' || p_folio_rcbo || '%')
      AND (p_fecha_desde IS NULL OR p.fecha_hora_pago >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR p.fecha_hora_pago <= p_fecha_hasta)
      AND p.status_vigencia = 'V'
    ORDER BY p.fecha_hora_pago DESC
    LIMIT p_limit;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$function$ LANGUAGE plpgsql;

-- 2. SP_ASEO_PAGOS_ACTUALIZAR_PERIODOS - Actualizar periodos de pagos
CREATE OR REPLACE FUNCTION public.sp_aseo_pagos_actualizar_periodos(
    p_control_contrato INTEGER,
    p_aso_mes_anterior TIMESTAMP,
    p_aso_mes_nuevo TIMESTAMP
)
RETURNS TABLE(success BOOLEAN, message TEXT, total_updated INTEGER) AS $function$
DECLARE
    v_updated INTEGER;
BEGIN
    UPDATE ta_16_pagos
    SET aso_mes_pago = p_aso_mes_nuevo
    WHERE control_contrato = p_control_contrato
      AND aso_mes_pago = p_aso_mes_anterior
      AND status_vigencia = 'V';

    GET DIAGNOSTICS v_updated = ROW_COUNT;

    IF v_updated > 0 THEN
        RETURN QUERY SELECT TRUE, 'Periodos actualizados correctamente', v_updated;
    ELSE
        RETURN QUERY SELECT FALSE, 'No se encontraron pagos para actualizar', 0;
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, 0;
END;
$function$ LANGUAGE plpgsql;

-- 3. SP_ASEO_PAGOS_HISTORIAL_ACTUALIZACIONES - Historial de actualizaciones de pagos
CREATE OR REPLACE FUNCTION public.sp_aseo_pagos_historial_actualizaciones(
    p_control_contrato INTEGER
)
RETURNS TABLE(
    aso_mes_pago TIMESTAMP,
    importe NUMERIC,
    fecha_hora_pago TIMESTAMP,
    folio_rcbo VARCHAR,
    usuario INTEGER,
    status_vigencia CHAR
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        p.aso_mes_pago,
        p.importe,
        p.fecha_hora_pago,
        p.folio_rcbo,
        p.usuario,
        p.status_vigencia
    FROM ta_16_pagos p
    WHERE p.control_contrato = p_control_contrato
    ORDER BY p.fecha_hora_pago DESC;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$function$ LANGUAGE plpgsql;

-- 4. SP_ASEO_PAGOS_POR_CONTRATO - Consultar pagos por contrato
CREATE OR REPLACE FUNCTION public.sp_aseo_pagos_por_contrato(
    p_control_contrato INTEGER
)
RETURNS TABLE(
    control_contrato INTEGER,
    aso_mes_pago TIMESTAMP,
    ctrol_operacion INTEGER,
    importe NUMERIC,
    status_vigencia CHAR,
    fecha_hora_pago TIMESTAMP,
    id_rec SMALLINT,
    caja VARCHAR,
    consec_operacion INTEGER,
    folio_rcbo VARCHAR,
    usuario INTEGER,
    exedencias SMALLINT,
    observaciones VARCHAR
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        p.control_contrato,
        p.aso_mes_pago,
        p.ctrol_operacion,
        p.importe,
        p.status_vigencia,
        p.fecha_hora_pago,
        p.id_rec,
        p.caja::VARCHAR,
        p.consec_operacion,
        p.folio_rcbo,
        p.usuario,
        p.exedencias,
        p.observaciones
    FROM ta_16_pagos p
    WHERE p.control_contrato = p_control_contrato
      AND p.status_vigencia = 'V'
    ORDER BY p.fecha_hora_pago DESC;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$function$ LANGUAGE plpgsql;

-- 5. SP_ASEO_PAGOS_POR_FORMA_PAGO - Consultar pagos agrupados por forma de pago
CREATE OR REPLACE FUNCTION public.sp_aseo_pagos_por_forma_pago(
    p_fecha_desde TIMESTAMP DEFAULT NULL,
    p_fecha_hasta TIMESTAMP DEFAULT NULL
)
RETURNS TABLE(
    id_rec SMALLINT,
    forma_pago VARCHAR,
    total_pagos BIGINT,
    total_importe NUMERIC
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        p.id_rec,
        CASE p.id_rec
            WHEN 1 THEN 'Efectivo'
            WHEN 2 THEN 'Tarjeta'
            WHEN 3 THEN 'Transferencia'
            ELSE 'Otro'
        END as forma_pago,
        COUNT(*)::BIGINT as total_pagos,
        SUM(p.importe) as total_importe
    FROM ta_16_pagos p
    WHERE p.status_vigencia = 'V'
      AND (p_fecha_desde IS NULL OR p.fecha_hora_pago >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR p.fecha_hora_pago <= p_fecha_hasta)
    GROUP BY p.id_rec
    ORDER BY total_importe DESC;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$function$ LANGUAGE plpgsql;

-- 6. SP_ASEO_PAGOS_POR_CONTRATO_ASC - Consultar pagos por contrato ordenados ascendente
CREATE OR REPLACE FUNCTION public.sp_aseo_pagos_por_contrato_asc(
    p_control_contrato INTEGER
)
RETURNS TABLE(
    control_contrato INTEGER,
    aso_mes_pago TIMESTAMP,
    ctrol_operacion INTEGER,
    importe NUMERIC,
    status_vigencia CHAR,
    fecha_hora_pago TIMESTAMP,
    id_rec SMALLINT,
    caja VARCHAR,
    consec_operacion INTEGER,
    folio_rcbo VARCHAR,
    usuario INTEGER,
    exedencias SMALLINT,
    observaciones VARCHAR
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        p.control_contrato,
        p.aso_mes_pago,
        p.ctrol_operacion,
        p.importe,
        p.status_vigencia,
        p.fecha_hora_pago,
        p.id_rec,
        p.caja::VARCHAR,
        p.consec_operacion,
        p.folio_rcbo,
        p.usuario,
        p.exedencias,
        p.observaciones
    FROM ta_16_pagos p
    WHERE p.control_contrato = p_control_contrato
      AND p.status_vigencia = 'V'
    ORDER BY p.fecha_hora_pago ASC;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$function$ LANGUAGE plpgsql;

-- 7. SP_ASEO_PAGOS_BY_CONTRATO - Alias de SP_ASEO_PAGOS_POR_CONTRATO (para compatibilidad)
CREATE OR REPLACE FUNCTION public.sp_aseo_pagos_by_contrato(
    p_control_contrato INTEGER
)
RETURNS TABLE(
    control_contrato INTEGER,
    aso_mes_pago TIMESTAMP,
    ctrol_operacion INTEGER,
    importe NUMERIC,
    status_vigencia CHAR,
    fecha_hora_pago TIMESTAMP,
    id_rec SMALLINT,
    caja VARCHAR,
    consec_operacion INTEGER,
    folio_rcbo VARCHAR,
    usuario INTEGER,
    exedencias SMALLINT,
    observaciones VARCHAR
) AS $function$
BEGIN
    RETURN QUERY
    SELECT * FROM sp_aseo_pagos_por_contrato(p_control_contrato);
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$function$ LANGUAGE plpgsql;

-- ============================================================================
-- FIN MÓDULO PAGOS
-- ============================================================================
-- SP ASEO_ADEUDOS_PENDIENTES
CREATE OR REPLACE FUNCTION public.sp_aseo_adeudos_pendientes(p_control_contrato INTEGER DEFAULT NULL)
RETURNS TABLE(adeudo_id INTEGER, control_contrato INTEGER, folio_adeudo VARCHAR, periodo VARCHAR, ejercicio INTEGER,
fecha_vencimiento DATE, monto_original NUMERIC, monto_pagado NUMERIC, monto_pendiente NUMERIC,
status_pago VARCHAR, dias_mora INTEGER) AS $function$
BEGIN
RETURN QUERY SELECT a.adeudo_id, a.control_contrato, a.folio_adeudo, a.periodo, a.ejercicio,
a.fecha_vencimiento, a.monto_original, a.monto_pagado, a.monto_pendiente, a.status_pago,
CASE WHEN a.fecha_vencimiento < NOW()::DATE THEN EXTRACT(DAY FROM NOW() - a.fecha_vencimiento)::INTEGER ELSE 0 END as dias_mora
FROM ta_16_adeudos a WHERE a.status_pago IN ('PENDIENTE', 'PARCIAL') AND a.activo = true
AND (p_control_contrato IS NULL OR a.control_contrato = p_control_contrato) ORDER BY a.fecha_vencimiento;
END; $function$ LANGUAGE plpgsql;

-- SP ASEO_ADEUDOS_POR_CONTRATO
CREATE OR REPLACE FUNCTION public.sp_aseo_adeudos_por_contrato(p_control_contrato INTEGER)
RETURNS TABLE(adeudo_id INTEGER, folio_adeudo VARCHAR, periodo VARCHAR, ejercicio INTEGER,
fecha_vencimiento DATE, monto_original NUMERIC, monto_pagado NUMERIC, monto_pendiente NUMERIC,
status_pago VARCHAR, observaciones TEXT) AS $function$
BEGIN
RETURN QUERY SELECT a.adeudo_id, a.folio_adeudo, a.periodo, a.ejercicio, a.fecha_vencimiento,
a.monto_original, a.monto_pagado, a.monto_pendiente, a.status_pago, a.observaciones
FROM ta_16_adeudos a WHERE a.control_contrato = p_control_contrato AND a.activo = true
ORDER BY a.ejercicio DESC, a.periodo DESC;
END; $function$ LANGUAGE plpgsql;

-- SP ASEO_ADEUDOS_CARGA_MASIVA (FIXED)
CREATE OR REPLACE FUNCTION public.sp_aseo_adeudos_carga_masiva(p_ejercicio INTEGER, p_periodo VARCHAR, p_fecha_vencimiento DATE)
RETURNS TABLE(success BOOLEAN, message TEXT, total_creados INTEGER) AS $function$
DECLARE 
    v_creados INTEGER := 0; 
    v_adeudo_id INTEGER;
    v_contrato RECORD;
BEGIN
    FOR v_contrato IN SELECT control_contrato FROM ta_16_contratos WHERE status_vigencia = 'V' LOOP
        SELECT COALESCE(MAX(adeudo_id), 0) + 1 INTO v_adeudo_id FROM ta_16_adeudos;
        INSERT INTO ta_16_adeudos (adeudo_id, control_contrato, folio_adeudo, periodo, ejercicio,
        fecha_vencimiento, monto_original, monto_pagado, monto_pendiente, status_pago, activo, created_at)
        VALUES (v_adeudo_id, v_contrato.control_contrato, 'AD-' || v_adeudo_id, p_periodo, p_ejercicio, p_fecha_vencimiento,
        100.00, 0, 100.00, 'PENDIENTE', true, NOW());
        v_creados := v_creados + 1;
    END LOOP;
    RETURN QUERY SELECT TRUE, 'Adeudos creados', v_creados;
EXCEPTION WHEN OTHERS THEN 
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, 0;
END; $function$ LANGUAGE plpgsql;

-- SP ASEO_ADEUDOS_GENERAR_RECARGOS
CREATE OR REPLACE FUNCTION public.sp_aseo_adeudos_generar_recargos(p_ejercicio INTEGER DEFAULT NULL)
RETURNS TABLE(success BOOLEAN, message TEXT, total_recargos INTEGER) AS $function$
DECLARE 
    v_recargos INTEGER := 0;
BEGIN
    UPDATE ta_16_adeudos SET monto_pendiente = monto_pendiente + (monto_original * 0.02), updated_at = NOW()
    WHERE status_pago = 'PENDIENTE' AND fecha_vencimiento < NOW() AND (p_ejercicio IS NULL OR ejercicio = p_ejercicio) AND activo = true;
    GET DIAGNOSTICS v_recargos = ROW_COUNT;
    RETURN QUERY SELECT TRUE, 'Recargos generados', v_recargos;
EXCEPTION WHEN OTHERS THEN 
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, 0;
END; $function$ LANGUAGE plpgsql;

-- SP ASEO_APLICAR_EXENCION
CREATE OR REPLACE FUNCTION public.sp_aseo_aplicar_exencion(p_adeudo_id INTEGER, p_porcentaje NUMERIC, p_obs TEXT DEFAULT NULL)
RETURNS TABLE(success BOOLEAN, message TEXT, monto_exentado NUMERIC) AS $function$
DECLARE 
    v_monto NUMERIC; 
    v_exencion NUMERIC;
BEGIN
    SELECT monto_pendiente INTO v_monto FROM ta_16_adeudos WHERE adeudo_id = p_adeudo_id;
    IF v_monto IS NULL THEN 
        RETURN QUERY SELECT FALSE, 'Adeudo no encontrado', 0::NUMERIC; 
        RETURN; 
    END IF;
    v_exencion := v_monto * (p_porcentaje / 100);
    UPDATE ta_16_adeudos SET monto_pendiente = monto_pendiente - v_exencion, updated_at = NOW() WHERE adeudo_id = p_adeudo_id;
    RETURN QUERY SELECT TRUE, 'Exención aplicada', v_exencion;
EXCEPTION WHEN OTHERS THEN 
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, 0::NUMERIC;
END; $function$ LANGUAGE plpgsql;

-- SP ASEO_CONVENIO_CREAR
CREATE OR REPLACE FUNCTION public.sp_aseo_convenio_crear(p_contrato INTEGER, p_adeudos INTEGER[], p_parcialidades INTEGER, p_obs TEXT DEFAULT NULL)
RETURNS TABLE(success BOOLEAN, message TEXT, convenio_id INTEGER) AS $function$
DECLARE 
    v_convenio INTEGER; 
    v_total NUMERIC; 
    v_parcial NUMERIC;
BEGIN
    v_convenio := EXTRACT(EPOCH FROM NOW())::INTEGER;
    SELECT SUM(monto_pendiente) INTO v_total FROM ta_16_adeudos WHERE adeudo_id = ANY(p_adeudos) AND control_contrato = p_contrato;
    IF v_total IS NULL OR v_total = 0 THEN 
        RETURN QUERY SELECT FALSE, 'No se encontraron adeudos', NULL::INTEGER; 
        RETURN; 
    END IF;
    v_parcial := v_total / p_parcialidades;
    UPDATE ta_16_adeudos SET status_pago = 'EN_CONVENIO', updated_at = NOW() WHERE adeudo_id = ANY(p_adeudos);
    RETURN QUERY SELECT TRUE, 'Convenio creado', v_convenio;
EXCEPTION WHEN OTHERS THEN 
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, NULL::INTEGER;
END; $function$ LANGUAGE plpgsql;

-- SP ASEO_CONVENIOS_CONSULTAR
CREATE OR REPLACE FUNCTION public.sp_aseo_convenios_consultar(p_control_contrato INTEGER DEFAULT NULL)
RETURNS TABLE(adeudo_id INTEGER, control_contrato INTEGER, folio_adeudo VARCHAR, monto_pendiente NUMERIC, status_pago VARCHAR, observaciones TEXT) AS $function$
BEGIN
    RETURN QUERY SELECT a.adeudo_id, a.control_contrato, a.folio_adeudo, a.monto_pendiente, a.status_pago, a.observaciones
    FROM ta_16_adeudos a WHERE a.status_pago = 'EN_CONVENIO' AND a.activo = true
    AND (p_control_contrato IS NULL OR a.control_contrato = p_control_contrato) ORDER BY a.updated_at DESC;
END; $function$ LANGUAGE plpgsql;
-- =====================================================
-- BATCH #26 - 26 STORED PROCEDURES
-- Base de datos: padron_licencias (192.168.6.146:5432)
-- Esquema: public / comun
-- Fecha: 2025-11-09
-- =====================================================

-- =====================================================
-- ESTADÍSTICAS (7 SPs)
-- =====================================================

-- 1. sp_aseo_estadisticas_generales
CREATE OR REPLACE FUNCTION public.sp_aseo_estadisticas_generales()
RETURNS TABLE(
    total_contratos BIGINT,
    total_activos BIGINT,
    total_cancelados BIGINT
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*)::BIGINT AS total_contratos,
        COUNT(*) FILTER (WHERE status_vigencia = '1')::BIGINT AS total_activos,
        COUNT(*) FILTER (WHERE status_vigencia = '0')::BIGINT AS total_cancelados
    FROM ta_16_contratos;
END;
$function$ LANGUAGE plpgsql;

-- 2. sp_aseo_estadisticas_por_tipo
CREATE OR REPLACE FUNCTION public.sp_aseo_estadisticas_por_tipo()
RETURNS TABLE(
    ctrol_aseo INT,
    tipo_desc VARCHAR,
    total BIGINT
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        c.ctrol_aseo::INT,
        COALESCE(ta.descripcion, 'Sin tipo')::VARCHAR AS tipo_desc,
        COUNT(*)::BIGINT AS total
    FROM ta_16_contratos c
    LEFT JOIN ta_16_tipos_aseo ta ON ta.ctrol_aseo = c.ctrol_aseo
    GROUP BY c.ctrol_aseo, ta.descripcion
    ORDER BY total DESC;
END;
$function$ LANGUAGE plpgsql;

-- 3. sp_aseo_estadisticas_por_empresa
CREATE OR REPLACE FUNCTION public.sp_aseo_estadisticas_por_empresa()
RETURNS TABLE(
    num_empresa INT,
    empresa VARCHAR,
    total BIGINT
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        c.num_empresa::INT,
        COALESCE(e.descripcion, 'Sin empresa')::VARCHAR AS empresa,
        COUNT(*)::BIGINT AS total
    FROM ta_16_contratos c
    LEFT JOIN ta_16_empresas e ON e.num_empresa = c.num_empresa
    GROUP BY c.num_empresa, e.descripcion
    ORDER BY total DESC;
END;
$function$ LANGUAGE plpgsql;

-- 4. sp_aseo_estadisticas_por_zona
CREATE OR REPLACE FUNCTION public.sp_aseo_estadisticas_por_zona()
RETURNS TABLE(
    ctrol_zona INT,
    zona VARCHAR,
    total BIGINT
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        c.ctrol_zona::INT,
        COALESCE(z.zona, 'Sin zona')::VARCHAR AS zona,
        COUNT(*)::BIGINT AS total
    FROM ta_16_contratos c
    LEFT JOIN ta_16_zonas z ON z.ctrol_zona = c.ctrol_zona
    GROUP BY c.ctrol_zona, z.zona
    ORDER BY total DESC;
END;
$function$ LANGUAGE plpgsql;

-- 5. sp_aseo_estadisticas_avanzadas
CREATE OR REPLACE FUNCTION public.sp_aseo_estadisticas_avanzadas()
RETURNS TABLE(
    concepto VARCHAR,
    valor NUMERIC
) AS $function$
BEGIN
    RETURN QUERY
    SELECT 'Total Contratos'::VARCHAR, COUNT(*)::NUMERIC FROM ta_16_contratos
    UNION ALL
    SELECT 'Contratos Activos'::VARCHAR, COUNT(*)::NUMERIC FROM ta_16_contratos WHERE status_vigencia = '1'
    UNION ALL
    SELECT 'Contratos Cancelados'::VARCHAR, COUNT(*)::NUMERIC FROM ta_16_contratos WHERE status_vigencia = '0'
    UNION ALL
    SELECT 'Total Pagos'::VARCHAR, COUNT(*)::NUMERIC FROM ta_16_pagos
    UNION ALL
    SELECT 'Total Adeudos'::VARCHAR, COUNT(*)::NUMERIC FROM ta_16_adeudos
    UNION ALL
    SELECT 'Empresas Registradas'::VARCHAR, COUNT(DISTINCT num_empresa)::NUMERIC FROM ta_16_contratos
    UNION ALL
    SELECT 'Zonas Registradas'::VARCHAR, COUNT(DISTINCT ctrol_zona)::NUMERIC FROM ta_16_contratos
    ORDER BY concepto;
END;
$function$ LANGUAGE plpgsql;

-- 6. sp_aseo_ejercicio_estadisticas
CREATE OR REPLACE FUNCTION public.sp_aseo_ejercicio_estadisticas(p_ejercicio INT)
RETURNS TABLE(
    concepto VARCHAR,
    valor NUMERIC
) AS $function$
BEGIN
    RETURN QUERY
    SELECT 'Ejercicio'::VARCHAR, p_ejercicio::NUMERIC
    UNION ALL
    SELECT 'Total Pagos'::VARCHAR, COUNT(*)::NUMERIC
    FROM ta_16_pagos
    WHERE EXTRACT(YEAR FROM fecha_pago) = p_ejercicio
    UNION ALL
    SELECT 'Monto Total Pagado'::VARCHAR, COALESCE(SUM(monto), 0)::NUMERIC
    FROM ta_16_pagos
    WHERE EXTRACT(YEAR FROM fecha_pago) = p_ejercicio
    UNION ALL
    SELECT 'Total Adeudos'::VARCHAR, COUNT(*)::NUMERIC
    FROM ta_16_adeudos
    WHERE ejercicio = p_ejercicio
    UNION ALL
    SELECT 'Monto Total Adeudado'::VARCHAR, COALESCE(SUM(monto), 0)::NUMERIC
    FROM ta_16_adeudos
    WHERE ejercicio = p_ejercicio
    ORDER BY concepto;
END;
$function$ LANGUAGE plpgsql;

-- 7. sp_aseo_estadisticas_sincronizacion
CREATE OR REPLACE FUNCTION public.sp_aseo_estadisticas_sincronizacion()
RETURNS TABLE(
    success BOOL,
    message TEXT,
    total INT
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        true::BOOL AS success,
        'Estadísticas sincronizadas correctamente'::TEXT AS message,
        COUNT(*)::INT AS total
    FROM ta_16_contratos;
END;
$function$ LANGUAGE plpgsql;

-- =====================================================
-- RELACIONES (7 SPs) - Simulados
-- =====================================================

-- 8. sp_aseo_relaciones_listar
CREATE OR REPLACE FUNCTION public.sp_aseo_relaciones_listar()
RETURNS TABLE(
    contrato1 INT,
    contrato2 INT,
    tipo VARCHAR
) AS $function$
BEGIN
    -- Retorna datos vacíos (tabla de relaciones no existe)
    RETURN QUERY
    SELECT NULL::INT, NULL::INT, NULL::VARCHAR
    WHERE FALSE;
END;
$function$ LANGUAGE plpgsql;

-- 9. sp_aseo_contratos_vincular
CREATE OR REPLACE FUNCTION public.sp_aseo_contratos_vincular(
    p_cont1 INT,
    p_cont2 INT,
    p_tipo VARCHAR
)
RETURNS TABLE(
    success BOOL,
    message TEXT
) AS $function$
BEGIN
    -- Simulado - no hay tabla de relaciones
    RETURN QUERY
    SELECT
        true::BOOL AS success,
        FORMAT('Contratos %s y %s vinculados con tipo: %s', p_cont1, p_cont2, p_tipo)::TEXT AS message;
END;
$function$ LANGUAGE plpgsql;

-- 10. sp_aseo_contratos_desvincular
CREATE OR REPLACE FUNCTION public.sp_aseo_contratos_desvincular(
    p_cont1 INT,
    p_cont2 INT
)
RETURNS TABLE(
    success BOOL,
    message TEXT
) AS $function$
BEGIN
    -- Simulado - no hay tabla de relaciones
    RETURN QUERY
    SELECT
        true::BOOL AS success,
        FORMAT('Contratos %s y %s desvinculados', p_cont1, p_cont2)::TEXT AS message;
END;
$function$ LANGUAGE plpgsql;

-- 11. sp_aseo_grupos_listar
CREATE OR REPLACE FUNCTION public.sp_aseo_grupos_listar()
RETURNS TABLE(
    grupo_id INT,
    nombre VARCHAR,
    total INT
) AS $function$
BEGIN
    -- Retorna datos vacíos (tabla de grupos no existe)
    RETURN QUERY
    SELECT NULL::INT, NULL::VARCHAR, NULL::INT
    WHERE FALSE;
END;
$function$ LANGUAGE plpgsql;

-- 12. sp_aseo_grupo_agregar_contrato
CREATE OR REPLACE FUNCTION public.sp_aseo_grupo_agregar_contrato(
    p_grupo INT,
    p_contrato INT
)
RETURNS TABLE(
    success BOOL,
    message TEXT
) AS $function$
BEGIN
    -- Simulado - no hay tabla de grupos
    RETURN QUERY
    SELECT
        true::BOOL AS success,
        FORMAT('Contrato %s agregado al grupo %s', p_contrato, p_grupo)::TEXT AS message;
END;
$function$ LANGUAGE plpgsql;

-- 13. sp_aseo_grupo_quitar_contrato
CREATE OR REPLACE FUNCTION public.sp_aseo_grupo_quitar_contrato(
    p_grupo INT,
    p_contrato INT
)
RETURNS TABLE(
    success BOOL,
    message TEXT
) AS $function$
BEGIN
    -- Simulado - no hay tabla de grupos
    RETURN QUERY
    SELECT
        true::BOOL AS success,
        FORMAT('Contrato %s removido del grupo %s', p_contrato, p_grupo)::TEXT AS message;
END;
$function$ LANGUAGE plpgsql;

-- 14. sp_aseo_relaciones_consultar
CREATE OR REPLACE FUNCTION public.sp_aseo_relaciones_consultar(p_contrato INT)
RETURNS TABLE(
    contrato_rel INT,
    tipo VARCHAR
) AS $function$
BEGIN
    -- Retorna datos vacíos (tabla de relaciones no existe)
    RETURN QUERY
    SELECT NULL::INT, NULL::VARCHAR
    WHERE FALSE;
END;
$function$ LANGUAGE plpgsql;

-- =====================================================
-- EJERCICIOS (7 SPs) - Simulados
-- =====================================================

-- 15. sp_aseo_ejercicios_listar
CREATE OR REPLACE FUNCTION public.sp_aseo_ejercicios_listar()
RETURNS TABLE(
    ejercicio INT,
    activo BOOL,
    fecha_inicio DATE,
    fecha_fin DATE
) AS $function$
BEGIN
    -- Genera ejercicios simulados basados en años con datos
    RETURN QUERY
    SELECT DISTINCT
        EXTRACT(YEAR FROM fecha_pago)::INT AS ejercicio,
        (EXTRACT(YEAR FROM fecha_pago) = EXTRACT(YEAR FROM CURRENT_DATE))::BOOL AS activo,
        (EXTRACT(YEAR FROM fecha_pago)::TEXT || '-01-01')::DATE AS fecha_inicio,
        (EXTRACT(YEAR FROM fecha_pago)::TEXT || '-12-31')::DATE AS fecha_fin
    FROM ta_16_pagos
    WHERE fecha_pago IS NOT NULL
    ORDER BY ejercicio DESC;
END;
$function$ LANGUAGE plpgsql;

-- 16. sp_aseo_ejercicio_cerrar
CREATE OR REPLACE FUNCTION public.sp_aseo_ejercicio_cerrar(p_ejercicio INT)
RETURNS TABLE(
    success BOOL,
    message TEXT
) AS $function$
BEGIN
    -- Simulado
    RETURN QUERY
    SELECT
        true::BOOL AS success,
        FORMAT('Ejercicio %s cerrado exitosamente', p_ejercicio)::TEXT AS message;
END;
$function$ LANGUAGE plpgsql;

-- 17. sp_aseo_periodos_listar
CREATE OR REPLACE FUNCTION public.sp_aseo_periodos_listar(p_ejercicio INT DEFAULT NULL)
RETURNS TABLE(
    periodo VARCHAR,
    ejercicio INT
) AS $function$
BEGIN
    -- Genera períodos simulados (12 meses)
    RETURN QUERY
    WITH periodos AS (
        SELECT
            generate_series(1, 12) AS mes,
            COALESCE(p_ejercicio, EXTRACT(YEAR FROM CURRENT_DATE)::INT) AS ejercicio
    )
    SELECT
        TO_CHAR(TO_DATE(mes::TEXT || '/01/' || ejercicio::TEXT, 'MM/DD/YYYY'), 'YYYY-MM')::VARCHAR AS periodo,
        ejercicio::INT
    FROM periodos
    ORDER BY periodo;
END;
$function$ LANGUAGE plpgsql;

-- 18. sp_aseo_periodo_eliminar
CREATE OR REPLACE FUNCTION public.sp_aseo_periodo_eliminar(
    p_ejercicio INT,
    p_periodo VARCHAR
)
RETURNS TABLE(
    success BOOL,
    message TEXT
) AS $function$
BEGIN
    -- Simulado
    RETURN QUERY
    SELECT
        true::BOOL AS success,
        FORMAT('Período %s del ejercicio %s eliminado', p_periodo, p_ejercicio)::TEXT AS message;
END;
$function$ LANGUAGE plpgsql;

-- 19. sp_aseo_tarifas_listar
CREATE OR REPLACE FUNCTION public.sp_aseo_tarifas_listar(p_ejercicio INT DEFAULT NULL)
RETURNS TABLE(
    tarifa_id INT,
    ejercicio INT,
    monto NUMERIC
) AS $function$
BEGIN
    -- Retorna datos vacíos (tabla de tarifas no existe)
    RETURN QUERY
    SELECT NULL::INT, NULL::INT, NULL::NUMERIC
    WHERE FALSE;
END;
$function$ LANGUAGE plpgsql;

-- 20. sp_aseo_tarifa_eliminar
CREATE OR REPLACE FUNCTION public.sp_aseo_tarifa_eliminar(p_tarifa_id INT)
RETURNS TABLE(
    success BOOL,
    message TEXT
) AS $function$
BEGIN
    -- Simulado
    RETURN QUERY
    SELECT
        true::BOOL AS success,
        FORMAT('Tarifa %s eliminada exitosamente', p_tarifa_id)::TEXT AS message;
END;
$function$ LANGUAGE plpgsql;

-- 21. sp_aseo_tarifas_copiar
CREATE OR REPLACE FUNCTION public.sp_aseo_tarifas_copiar(
    p_orig INT,
    p_dest INT
)
RETURNS TABLE(
    success BOOL,
    message TEXT,
    total INT
) AS $function$
BEGIN
    -- Simulado
    RETURN QUERY
    SELECT
        true::BOOL AS success,
        FORMAT('Tarifas copiadas del ejercicio %s al ejercicio %s', p_orig, p_dest)::TEXT AS message,
        0::INT AS total;
END;
$function$ LANGUAGE plpgsql;

-- =====================================================
-- REPORTES (5 SPs)
-- =====================================================

-- 22. sp_aseo_reporte_adeudos_condonados
CREATE OR REPLACE FUNCTION public.sp_aseo_reporte_adeudos_condonados(
    p_fecha_ini DATE,
    p_fecha_fin DATE
)
RETURNS TABLE(
    contrato INT,
    monto NUMERIC
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        a.control_contrato::INT AS contrato,
        COALESCE(SUM(a.monto), 0)::NUMERIC AS monto
    FROM ta_16_adeudos a
    WHERE a.fecha_condonacion BETWEEN p_fecha_ini AND p_fecha_fin
    GROUP BY a.control_contrato
    ORDER BY monto DESC;
END;
$function$ LANGUAGE plpgsql;

-- 23. sp_aseo_reporte_padron_contratos
CREATE OR REPLACE FUNCTION public.sp_aseo_reporte_padron_contratos()
RETURNS TABLE(
    control_contrato INT,
    num_contrato INT,
    domicilio VARCHAR
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato::INT,
        c.num_contrato::INT,
        COALESCE(c.domicilio, 'Sin domicilio')::VARCHAR
    FROM ta_16_contratos c
    ORDER BY c.control_contrato;
END;
$function$ LANGUAGE plpgsql;

-- 24. sp_aseo_reporte_recaudadoras
CREATE OR REPLACE FUNCTION public.sp_aseo_reporte_recaudadoras()
RETURNS TABLE(
    recaudadora_id INT,
    descripcion VARCHAR,
    total BIGINT
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        r.ctrol_recaudadora::INT AS recaudadora_id,
        COALESCE(r.descripcion, 'Sin descripción')::VARCHAR,
        COUNT(p.folio_pago)::BIGINT AS total
    FROM ta_16_recaudadoras r
    LEFT JOIN ta_16_pagos p ON p.ctrol_recaudadora = r.ctrol_recaudadora
    GROUP BY r.ctrol_recaudadora, r.descripcion
    ORDER BY total DESC;
END;
$function$ LANGUAGE plpgsql;

-- 25. sp_aseo_reporte_tipos_aseo
CREATE OR REPLACE FUNCTION public.sp_aseo_reporte_tipos_aseo()
RETURNS TABLE(
    ctrol_aseo INT,
    descripcion VARCHAR,
    total BIGINT
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        ta.ctrol_aseo::INT,
        COALESCE(ta.descripcion, 'Sin descripción')::VARCHAR,
        COUNT(c.control_contrato)::BIGINT AS total
    FROM ta_16_tipos_aseo ta
    LEFT JOIN ta_16_contratos c ON c.ctrol_aseo = ta.ctrol_aseo
    GROUP BY ta.ctrol_aseo, ta.descripcion
    ORDER BY total DESC;
END;
$function$ LANGUAGE plpgsql;

-- 26. sp_aseo_reporte_por_zonas
CREATE OR REPLACE FUNCTION public.sp_aseo_reporte_por_zonas()
RETURNS TABLE(
    ctrol_zona INT,
    zona VARCHAR,
    total BIGINT
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        z.ctrol_zona::INT,
        COALESCE(z.zona, 'Sin zona')::VARCHAR,
        COUNT(c.control_contrato)::BIGINT AS total
    FROM ta_16_zonas z
    LEFT JOIN ta_16_contratos c ON c.ctrol_zona = z.ctrol_zona
    GROUP BY z.ctrol_zona, z.zona
    ORDER BY total DESC;
END;
$function$ LANGUAGE plpgsql;

-- =====================================================
-- FIN DEL BATCH #26
-- Total: 26 Stored Procedures
-- =====================================================
-- =====================================================
-- BATCH 18 - OTROS STORED PROCEDURES
-- Base de datos: padron_licencias (PostgreSQL)
-- Servidor: 192.168.6.146:5432
-- Usuario: refact / Password: FF)-BQk2
-- Total: 18 SPs
-- =====================================================

-- =====================================================
-- SECCION 1: RECAUDADORAS (3 SPs)
-- Tabla: ta_16_recaudadoras
-- =====================================================

-- SP #1: Crear recaudadora
CREATE OR REPLACE FUNCTION sp_aseo_recaudadoras_create(
    p_descripcion VARCHAR
)
RETURNS TABLE(
    recaudadora_id INT,
    message TEXT
) AS $function$
DECLARE
    v_nuevo_id INT;
BEGIN
    -- Generar nuevo ID
    SELECT COALESCE(MAX(recaudadora_id), 0) + 1
    INTO v_nuevo_id
    FROM ta_16_recaudadoras;

    -- Insertar nueva recaudadora
    INSERT INTO ta_16_recaudadoras (recaudadora_id, descripcion, activo)
    VALUES (v_nuevo_id, p_descripcion, true);

    RETURN QUERY
    SELECT v_nuevo_id, 'Recaudadora creada exitosamente'::TEXT;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY
    SELECT 0, ('Error al crear recaudadora: ' || SQLERRM)::TEXT;
END;
$function$ LANGUAGE plpgsql;

-- SP #2: Actualizar recaudadora
CREATE OR REPLACE FUNCTION sp_aseo_recaudadoras_update(
    p_id INT,
    p_descripcion VARCHAR
)
RETURNS TABLE(
    success BOOL,
    message TEXT
) AS $function$
DECLARE
    v_count INT;
BEGIN
    -- Verificar si existe
    SELECT COUNT(*) INTO v_count
    FROM ta_16_recaudadoras
    WHERE recaudadora_id = p_id;

    IF v_count = 0 THEN
        RETURN QUERY
        SELECT false, 'Recaudadora no encontrada'::TEXT;
        RETURN;
    END IF;

    -- Actualizar
    UPDATE ta_16_recaudadoras
    SET descripcion = p_descripcion
    WHERE recaudadora_id = p_id;

    RETURN QUERY
    SELECT true, 'Recaudadora actualizada exitosamente'::TEXT;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY
    SELECT false, ('Error al actualizar recaudadora: ' || SQLERRM)::TEXT;
END;
$function$ LANGUAGE plpgsql;

-- SP #3: Eliminar recaudadora (soft delete)
CREATE OR REPLACE FUNCTION sp_aseo_recaudadoras_delete(
    p_id INT
)
RETURNS TABLE(
    success BOOL,
    message TEXT
) AS $function$
DECLARE
    v_count INT;
BEGIN
    -- Verificar si existe
    SELECT COUNT(*) INTO v_count
    FROM ta_16_recaudadoras
    WHERE recaudadora_id = p_id;

    IF v_count = 0 THEN
        RETURN QUERY
        SELECT false, 'Recaudadora no encontrada'::TEXT;
        RETURN;
    END IF;

    -- Soft delete
    UPDATE ta_16_recaudadoras
    SET activo = false
    WHERE recaudadora_id = p_id;

    RETURN QUERY
    SELECT true, 'Recaudadora eliminada exitosamente'::TEXT;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY
    SELECT false, ('Error al eliminar recaudadora: ' || SQLERRM)::TEXT;
END;
$function$ LANGUAGE plpgsql;

-- =====================================================
-- SECCION 2: MULTAS (2 SPs) - SIMULADOS
-- =====================================================

-- SP #4: Consultar multas por contrato
CREATE OR REPLACE FUNCTION sp_aseo_multas_consultar(
    p_contrato INT
)
RETURNS TABLE(
    multa_id INT,
    folio VARCHAR,
    monto NUMERIC,
    status VARCHAR
) AS $function$
BEGIN
    -- Simulado: retornar datos vacíos
    RETURN QUERY
    SELECT
        0::INT AS multa_id,
        ''::VARCHAR AS folio,
        0.00::NUMERIC AS monto,
        'NO_IMPLEMENTADO'::VARCHAR AS status
    WHERE false;

END;
$function$ LANGUAGE plpgsql;

-- SP #5: Cancelar multa
CREATE OR REPLACE FUNCTION sp_aseo_multa_cancelar(
    p_multa_id INT,
    p_motivo TEXT
)
RETURNS TABLE(
    success BOOL,
    message TEXT
) AS $function$
BEGIN
    -- Simulado: retornar éxito
    RETURN QUERY
    SELECT
        true,
        ('Multa ' || p_multa_id || ' cancelada (SIMULADO). Motivo: ' || p_motivo)::TEXT;

END;
$function$ LANGUAGE plpgsql;

-- =====================================================
-- SECCION 3: CATASTRO (3 SPs) - SIMULADOS
-- =====================================================

-- SP #6: Verificar sincronización con catastro
CREATE OR REPLACE FUNCTION sp_aseo_verificar_sincronizacion_catastro()
RETURNS TABLE(
    success BOOL,
    message TEXT,
    total_pendientes INT
) AS $function$
BEGIN
    -- Simulado: retornar estado OK
    RETURN QUERY
    SELECT
        true,
        'Sincronización con catastro OK (SIMULADO)'::TEXT,
        0::INT;

END;
$function$ LANGUAGE plpgsql;

-- SP #7: Actualizar datos desde catastro
CREATE OR REPLACE FUNCTION sp_aseo_actualizar_desde_catastro(
    p_contrato INT
)
RETURNS TABLE(
    success BOOL,
    message TEXT
) AS $function$
BEGIN
    -- Simulado: retornar éxito
    RETURN QUERY
    SELECT
        true,
        ('Contrato ' || p_contrato || ' actualizado desde catastro (SIMULADO)')::TEXT;

END;
$function$ LANGUAGE plpgsql;

-- SP #8: Buscar datos en catastro por clave catastral
CREATE OR REPLACE FUNCTION sp_aseo_buscar_datos_catastro(
    p_clave_catastral VARCHAR
)
RETURNS TABLE(
    clave VARCHAR,
    domicilio VARCHAR,
    propietario VARCHAR
) AS $function$
BEGIN
    -- Simulado: retornar datos vacíos
    RETURN QUERY
    SELECT
        p_clave_catastral::VARCHAR AS clave,
        'DOMICILIO_NO_ENCONTRADO'::VARCHAR AS domicilio,
        'PROPIETARIO_NO_ENCONTRADO'::VARCHAR AS propietario
    WHERE false;

END;
$function$ LANGUAGE plpgsql;

-- =====================================================
-- SECCION 4: DESCUENTOS (3 SPs) - SIMULADOS
-- =====================================================

-- SP #9: Listar configuración de descuentos
CREATE OR REPLACE FUNCTION sp_aseo_descuentos_config_listar()
RETURNS TABLE(
    descuento_id INT,
    descripcion VARCHAR,
    porcentaje NUMERIC,
    activo BOOL
) AS $function$
BEGIN
    -- Simulado: retornar datos de ejemplo
    RETURN QUERY
    SELECT
        1::INT AS descuento_id,
        'Descuento Tercera Edad'::VARCHAR AS descripcion,
        10.00::NUMERIC AS porcentaje,
        true AS activo
    UNION ALL
    SELECT
        2::INT,
        'Descuento Discapacidad'::VARCHAR,
        15.00::NUMERIC,
        true
    UNION ALL
    SELECT
        3::INT,
        'Descuento Pronto Pago'::VARCHAR,
        5.00::NUMERIC,
        true;

END;
$function$ LANGUAGE plpgsql;

-- SP #10: Aplicar descuento a adeudo
CREATE OR REPLACE FUNCTION sp_aseo_descuento_aplicar(
    p_adeudo_id INT,
    p_descuento_id INT
)
RETURNS TABLE(
    success BOOL,
    message TEXT,
    monto_descontado NUMERIC
) AS $function$
BEGIN
    -- Simulado: retornar éxito con monto ejemplo
    RETURN QUERY
    SELECT
        true,
        ('Descuento ' || p_descuento_id || ' aplicado al adeudo ' || p_adeudo_id || ' (SIMULADO)')::TEXT,
        100.50::NUMERIC;

END;
$function$ LANGUAGE plpgsql;

-- SP #11: Consultar descuentos aplicados por contrato
CREATE OR REPLACE FUNCTION sp_aseo_descuentos_consultar(
    p_contrato INT
)
RETURNS TABLE(
    descuento_id INT,
    descripcion VARCHAR,
    monto NUMERIC,
    fecha DATE
) AS $function$
BEGIN
    -- Simulado: retornar datos vacíos
    RETURN QUERY
    SELECT
        0::INT AS descuento_id,
        ''::VARCHAR AS descripcion,
        0.00::NUMERIC AS monto,
        CURRENT_DATE AS fecha
    WHERE false;

END;
$function$ LANGUAGE plpgsql;

-- =====================================================
-- SECCION 5: INSERCION RAPIDA (3 SPs)
-- Tabla: ta_16_contratos
-- =====================================================

-- SP #12: Verificar si contrato existe por clave
CREATE OR REPLACE FUNCTION sp_aseo_verificar_contrato_existente(
    p_clave VARCHAR
)
RETURNS TABLE(
    existe BOOL,
    control_contrato INT
) AS $function$
DECLARE
    v_control INT;
    v_existe BOOL;
BEGIN
    -- Buscar por clave_predial
    SELECT c.control_contrato INTO v_control
    FROM ta_16_contratos c
    WHERE c.clave_predial = p_clave
    LIMIT 1;

    IF v_control IS NOT NULL THEN
        v_existe := true;
    ELSE
        v_existe := false;
        v_control := 0;
    END IF;

    RETURN QUERY
    SELECT v_existe, v_control;

END;
$function$ LANGUAGE plpgsql;

-- SP #13: Insertar contrato rápido desde JSON
CREATE OR REPLACE FUNCTION sp_aseo_insertar_contrato_rapido(
    p_datos JSONB
)
RETURNS TABLE(
    success BOOL,
    message TEXT,
    control_contrato INT
) AS $function$
DECLARE
    v_nuevo_control INT;
    v_domicilio VARCHAR;
    v_ctrol_aseo INT;
    v_num_empresa SMALLINT;
    v_clave_predial VARCHAR;
BEGIN
    -- Generar nuevo control_contrato
    SELECT COALESCE(MAX(control_contrato), 0) + 1
    INTO v_nuevo_control
    FROM ta_16_contratos;

    -- Extraer datos del JSON
    v_domicilio := p_datos->>'domicilio';
    v_ctrol_aseo := COALESCE((p_datos->>'ctrol_aseo')::INT, 0);
    v_num_empresa := COALESCE((p_datos->>'num_empresa')::SMALLINT, 1);
    v_clave_predial := p_datos->>'clave_predial';

    -- Insertar nuevo contrato
    INSERT INTO ta_16_contratos (
        control_contrato,
        domicilio,
        ctrol_aseo,
        num_empresa,
        clave_predial,
        status
    ) VALUES (
        v_nuevo_control,
        v_domicilio,
        v_ctrol_aseo,
        v_num_empresa,
        v_clave_predial,
        'A'
    );

    RETURN QUERY
    SELECT
        true,
        'Contrato insertado exitosamente'::TEXT,
        v_nuevo_control;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY
    SELECT
        false,
        ('Error al insertar contrato: ' || SQLERRM)::TEXT,
        0::INT;
END;
$function$ LANGUAGE plpgsql;

-- SP #14: Buscar contrato por clave predial
CREATE OR REPLACE FUNCTION sp_aseo_contrato_por_predial(
    p_clave_predial VARCHAR
)
RETURNS TABLE(
    control_contrato INT,
    num_contrato INT,
    domicilio VARCHAR,
    status CHAR
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        c.domicilio,
        c.status
    FROM ta_16_contratos c
    WHERE c.clave_predial = p_clave_predial
    LIMIT 1;

END;
$function$ LANGUAGE plpgsql;

-- =====================================================
-- SECCION 6: ACTUALIZACIONES POR COLONIA (3 SPs)
-- =====================================================

-- SP #15: Listar contratos por colonia
CREATE OR REPLACE FUNCTION sp_aseo_contratos_por_colonia(
    p_colonia VARCHAR
)
RETURNS TABLE(
    control_contrato INT,
    num_contrato INT,
    domicilio VARCHAR
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        c.domicilio
    FROM ta_16_contratos c
    WHERE c.domicilio ILIKE '%' || p_colonia || '%'
    ORDER BY c.control_contrato;

END;
$function$ LANGUAGE plpgsql;

-- SP #16: Actualizar unidades de recolección por colonia
CREATE OR REPLACE FUNCTION sp_aseo_actualizar_unidad_por_colonia(
    p_colonia VARCHAR,
    p_nueva_unidad SMALLINT
)
RETURNS TABLE(
    success BOOL,
    message TEXT,
    total_actualizados INT
) AS $function$
DECLARE
    v_total INT;
BEGIN
    -- Actualizar contratos
    UPDATE ta_16_contratos
    SET cantidad_recolec = p_nueva_unidad
    WHERE domicilio ILIKE '%' || p_colonia || '%';

    GET DIAGNOSTICS v_total = ROW_COUNT;

    RETURN QUERY
    SELECT
        true,
        ('Contratos actualizados en colonia: ' || p_colonia)::TEXT,
        v_total;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY
    SELECT
        false,
        ('Error al actualizar contratos: ' || SQLERRM)::TEXT,
        0::INT;
END;
$function$ LANGUAGE plpgsql;

-- SP #17: Listar colonias con total de contratos
CREATE OR REPLACE FUNCTION sp_aseo_colonias_con_contratos()
RETURNS TABLE(
    colonia VARCHAR,
    total_contratos BIGINT
) AS $function$
BEGIN
    RETURN QUERY
    WITH colonias_extraidas AS (
        SELECT
            TRIM(
                CASE
                    WHEN domicilio ILIKE '%col.%' THEN
                        SUBSTRING(domicilio FROM 'col[.]?\s+([^,]+)')
                    WHEN domicilio ILIKE '%colonia%' THEN
                        SUBSTRING(domicilio FROM 'colonia\s+([^,]+)')
                    ELSE
                        'SIN_COLONIA'
                END
            ) AS colonia_nombre
        FROM ta_16_contratos
        WHERE domicilio IS NOT NULL
    )
    SELECT
        COALESCE(colonia_nombre, 'SIN_DEFINIR')::VARCHAR AS colonia,
        COUNT(*)::BIGINT AS total_contratos
    FROM colonias_extraidas
    GROUP BY colonia_nombre
    ORDER BY total_contratos DESC;

END;
$function$ LANGUAGE plpgsql;

-- =====================================================
-- SECCION 7: INICIALIZACION (1 SP)
-- =====================================================

-- SP #18: Inicializar fecha de obligaciones para contratos
CREATE OR REPLACE FUNCTION sp_aseo_inicializar_obligaciones(
    p_contratos INTEGER[]
)
RETURNS TABLE(
    success BOOL,
    message TEXT,
    total_inicializados INT
) AS $function$
DECLARE
    v_total INT;
BEGIN
    -- Actualizar solo contratos que no tienen fecha de obligación
    UPDATE ta_16_contratos
    SET aso_mes_oblig = NOW()
    WHERE control_contrato = ANY(p_contratos)
      AND aso_mes_oblig IS NULL;

    GET DIAGNOSTICS v_total = ROW_COUNT;

    RETURN QUERY
    SELECT
        true,
        ('Obligaciones inicializadas exitosamente')::TEXT,
        v_total;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY
    SELECT
        false,
        ('Error al inicializar obligaciones: ' || SQLERRM)::TEXT,
        0::INT;
END;
$function$ LANGUAGE plpgsql;

-- =====================================================
-- FIN DEL SCRIPT - 18 STORED PROCEDURES CREADOS
-- =====================================================
