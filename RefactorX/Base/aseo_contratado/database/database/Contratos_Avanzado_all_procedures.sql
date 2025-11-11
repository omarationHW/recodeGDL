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
