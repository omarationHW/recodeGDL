-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Contratos_Alta (Contratos_Ins.pas)
-- Base de datos: aseo_contratado
-- Actualizado: 2025-12-07
-- Total SPs: 8
-- ============================================
-- Descripcion: Alta de nuevos contratos de aseo contratado
-- Flujo segun Delphi original:
--   1. Cargar combos (tipos aseo, zonas, recaudadoras, unidades)
--   2. Buscar empresa por nombre
--   3. Verificar que empresa existe y contrato no existe
--   4. Crear contrato con SpdGenContrato
--   5. Generar pagos desde mes inicio hasta dic del ejercicio
--   6. Si hay costos del anio siguiente, generar ene-dic siguiente
-- ============================================

-- SP 1/8: sp_aseo_tipos_aseo_combo
-- Tipo: Catalog
-- Descripcion: Lista tipos de aseo para combo
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_tipos_aseo_combo();

CREATE OR REPLACE FUNCTION public.sp_aseo_tipos_aseo_combo()
RETURNS TABLE (
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR,
    display_text VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ta.ctrol_aseo,
        ta.tipo_aseo::VARCHAR,
        ta.descripcion::VARCHAR,
        (ta.ctrol_aseo::VARCHAR || ' - ' || ta.tipo_aseo || ' - ' || COALESCE(ta.descripcion, ''))::VARCHAR as display_text
    FROM ta_16_tipo_aseo ta
    ORDER BY ta.ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_tipos_aseo_combo() TO PUBLIC;

-- SP 2/8: sp_aseo_zonas_combo
-- Tipo: Catalog
-- Descripcion: Lista zonas para combo
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_zonas_combo();

CREATE OR REPLACE FUNCTION public.sp_aseo_zonas_combo()
RETURNS TABLE (
    ctrol_zona INTEGER,
    zona SMALLINT,
    sub_zona SMALLINT,
    descripcion VARCHAR,
    display_text VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        z.ctrol_zona,
        z.zona,
        z.sub_zona,
        z.descripcion::VARCHAR,
        (LPAD(z.ctrol_zona::VARCHAR, 6, '0') || ' - ' || z.zona::VARCHAR || ' - ' || z.sub_zona::VARCHAR || ' - ' || COALESCE(z.descripcion, ''))::VARCHAR as display_text
    FROM ta_16_zonas z
    ORDER BY z.ctrol_zona;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_zonas_combo() TO PUBLIC;

-- SP 3/8: sp_aseo_recaudadoras_combo
-- Tipo: Catalog
-- Descripcion: Lista recaudadoras para combo
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_recaudadoras_combo();

CREATE OR REPLACE FUNCTION public.sp_aseo_recaudadoras_combo()
RETURNS TABLE (
    id_rec SMALLINT,
    recaudadora VARCHAR,
    display_text VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id_rec,
        r.recaudadora::VARCHAR,
        (LPAD(r.id_rec::VARCHAR, 2, '0') || ' - ' || COALESCE(r.recaudadora, ''))::VARCHAR as display_text
    FROM ta_16_recaudadoras r
    ORDER BY r.id_rec;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_recaudadoras_combo() TO PUBLIC;

-- SP 4/8: sp_aseo_unidades_combo
-- Tipo: Catalog
-- Descripcion: Lista unidades de recoleccion por ejercicio
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_unidades_combo(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_unidades_combo(
    p_ejercicio INTEGER
)
RETURNS TABLE (
    ctrol_recolec INTEGER,
    ejercicio_recolec SMALLINT,
    cve_recolec VARCHAR,
    descripcion VARCHAR,
    costo_unidad NUMERIC,
    costo_exed NUMERIC,
    display_text VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.ctrol_recolec,
        u.ejercicio_recolec,
        u.cve_recolec::VARCHAR,
        u.descripcion::VARCHAR,
        COALESCE(u.costo_unidad, 0)::NUMERIC,
        COALESCE(u.costo_exed, 0)::NUMERIC,
        (LPAD(u.ctrol_recolec::VARCHAR, 4, '0') || ' - ' || u.cve_recolec || ' - ' || COALESCE(u.descripcion, ''))::VARCHAR as display_text
    FROM ta_16_unidades u
    WHERE u.ejercicio_recolec = p_ejercicio
    ORDER BY u.ctrol_recolec;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_unidades_combo(INTEGER) TO PUBLIC;

-- SP 5/8: sp_aseo_buscar_empresas_nombre
-- Tipo: Search
-- Descripcion: Busca empresas por nombre (ctrol_emp = 9 = privadas)
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_buscar_empresas_nombre(VARCHAR);

CREATE OR REPLACE FUNCTION public.sp_aseo_buscar_empresas_nombre(
    p_nombre VARCHAR
)
RETURNS TABLE (
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    descripcion VARCHAR,
    representante VARCHAR,
    tipo_empresa VARCHAR,
    tipo_descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.num_empresa,
        e.ctrol_emp,
        e.descripcion::VARCHAR,
        e.representante::VARCHAR,
        te.tipo_empresa::VARCHAR,
        te.descripcion::VARCHAR as tipo_descripcion
    FROM ta_16_empresas e
    LEFT JOIN ta_16_tipos_emp te ON te.ctrol_emp = e.ctrol_emp
    WHERE e.descripcion ILIKE '%' || p_nombre || '%'
      AND e.ctrol_emp = 9  -- Empresas privadas
    ORDER BY e.num_empresa;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_buscar_empresas_nombre(VARCHAR) TO PUBLIC;

-- SP 6/8: sp_aseo_verificar_contrato_empresa
-- Tipo: Validation
-- Descripcion: Verifica que empresa exista y contrato no exista
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_verificar_contrato_empresa(INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_verificar_contrato_empresa(
    p_num_contrato INTEGER,
    p_num_empresa INTEGER,
    p_ctrol_aseo INTEGER
)
RETURNS TABLE (
    empresa_existe BOOLEAN,
    contrato_existe BOOLEAN,
    mensaje VARCHAR,
    valido BOOLEAN,
    nombre_empresa VARCHAR,
    representante VARCHAR
) AS $$
DECLARE
    v_empresa_existe BOOLEAN := FALSE;
    v_contrato_existe BOOLEAN := FALSE;
    v_nombre_empresa VARCHAR := '';
    v_representante VARCHAR := '';
    v_mensaje VARCHAR := '';
BEGIN
    -- Verificar si la empresa existe (ctrol_emp = 9)
    SELECT TRUE, e.descripcion, e.representante
    INTO v_empresa_existe, v_nombre_empresa, v_representante
    FROM ta_16_empresas e
    WHERE e.num_empresa = p_num_empresa
      AND e.ctrol_emp = 9;

    IF NOT FOUND THEN
        v_empresa_existe := FALSE;
        v_nombre_empresa := '';
        v_representante := '';
    END IF;

    -- Verificar si el contrato ya existe
    SELECT TRUE INTO v_contrato_existe
    FROM ta_16_contratos c
    WHERE c.num_contrato = p_num_contrato
      AND c.ctrol_aseo = p_ctrol_aseo;

    IF NOT FOUND THEN
        v_contrato_existe := FALSE;
    END IF;

    -- Construir mensaje
    IF NOT v_empresa_existe THEN
        v_mensaje := 'El dato de la empresa no existe';
    ELSIF v_contrato_existe THEN
        v_mensaje := 'El Contrato ya existe, intenta con otro';
    ELSE
        v_mensaje := 'OK';
    END IF;

    RETURN QUERY SELECT
        v_empresa_existe,
        v_contrato_existe,
        v_mensaje,
        (v_empresa_existe AND NOT v_contrato_existe)::BOOLEAN as valido,
        COALESCE(v_nombre_empresa, '')::VARCHAR,
        COALESCE(v_representante, '')::VARCHAR;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_verificar_contrato_empresa(INTEGER, INTEGER, INTEGER) TO PUBLIC;

-- SP 7/8: sp_aseo_crear_contrato
-- Tipo: Insert
-- Descripcion: Crea el contrato (equivalente a SpdGenContrato)
-- Retorna el control_contrato generado
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_crear_contrato(INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, SMALLINT, VARCHAR, VARCHAR, INTEGER, SMALLINT, DATE, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_crear_contrato(
    p_num_contrato INTEGER,
    p_ctrol_aseo INTEGER,
    p_num_empresa INTEGER,
    p_ctrol_emp INTEGER,           -- Siempre 9 (privadas)
    p_ctrol_recolec INTEGER,
    p_cantidad_recolec SMALLINT,
    p_domicilio VARCHAR,
    p_sector VARCHAR,
    p_ctrol_zona INTEGER,
    p_id_rec SMALLINT,
    p_fecha_oblig DATE,
    p_usuario INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    control_contrato INTEGER,
    mensaje VARCHAR
) AS $$
DECLARE
    v_control_contrato INTEGER;
BEGIN
    -- Obtener siguiente control_contrato
    SELECT COALESCE(MAX(control_contrato), 0) + 1
    INTO v_control_contrato
    FROM ta_16_contratos;

    -- Insertar contrato
    INSERT INTO ta_16_contratos (
        control_contrato,
        num_contrato,
        ctrol_aseo,
        num_empresa,
        ctrol_emp,
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
        v_control_contrato,
        p_num_contrato,
        p_ctrol_aseo,
        p_num_empresa,
        p_ctrol_emp,
        p_ctrol_recolec,
        p_cantidad_recolec,
        p_domicilio,
        p_sector,
        p_ctrol_zona,
        p_id_rec,
        NOW(),
        'V',          -- Vigente
        p_fecha_oblig,
        'A',          -- Alta
        p_usuario
    );

    RETURN QUERY SELECT
        TRUE::BOOLEAN,
        v_control_contrato,
        'Contrato creado exitosamente'::VARCHAR;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT
        FALSE::BOOLEAN,
        0::INTEGER,
        ('Error al crear contrato: ' || SQLERRM)::VARCHAR;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_crear_contrato(INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, SMALLINT, VARCHAR, VARCHAR, INTEGER, SMALLINT, DATE, INTEGER) TO PUBLIC;

-- SP 8/8: sp_aseo_generar_pagos_contrato
-- Tipo: Insert
-- Descripcion: Genera los pagos (adeudos) del contrato
-- Desde mes inicio hasta diciembre, y si hay costos del siguiente anio, ene-dic
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_generar_pagos_contrato(INTEGER, INTEGER, VARCHAR, SMALLINT, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_generar_pagos_contrato(
    p_control_contrato INTEGER,
    p_ejercicio INTEGER,
    p_cve_recolec VARCHAR,
    p_cantidad SMALLINT,
    p_mes_inicio INTEGER,
    p_usuario INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    pagos_generados INTEGER,
    mensaje VARCHAR
) AS $$
DECLARE
    v_costo_unidad_ejer NUMERIC := 0;
    v_costo_unidad_sig NUMERIC := 0;
    v_ejercicio_sig INTEGER;
    v_mes INTEGER;
    v_importe NUMERIC;
    v_pagos_count INTEGER := 0;
    v_tiene_sig BOOLEAN := FALSE;
BEGIN
    v_ejercicio_sig := p_ejercicio + 1;

    -- Obtener costo unidad del ejercicio actual
    SELECT COALESCE(u.costo_unidad, 0)
    INTO v_costo_unidad_ejer
    FROM ta_16_unidades u
    WHERE u.ejercicio_recolec = p_ejercicio
      AND u.cve_recolec = p_cve_recolec;

    IF NOT FOUND THEN
        v_costo_unidad_ejer := 0;
    END IF;

    -- Obtener costo unidad del ejercicio siguiente (si existe)
    SELECT COALESCE(u.costo_unidad, 0)
    INTO v_costo_unidad_sig
    FROM ta_16_unidades u
    WHERE u.ejercicio_recolec = v_ejercicio_sig
      AND u.cve_recolec = p_cve_recolec;

    IF FOUND AND v_costo_unidad_sig > 0 THEN
        v_tiene_sig := TRUE;
    END IF;

    -- Generar pagos del ejercicio actual (mes inicio a diciembre)
    FOR v_mes IN p_mes_inicio..12 LOOP
        v_importe := p_cantidad * v_costo_unidad_ejer;

        INSERT INTO ta_16_pagos (
            control_contrato,
            aso_mes_pago,
            ctrol_operacion,
            importe,
            status_vigencia,
            usuario,
            exed
        ) VALUES (
            p_control_contrato,
            MAKE_DATE(p_ejercicio, v_mes, 1),
            6,  -- Cuota normal
            v_importe,
            'V',  -- Vigente
            p_usuario,
            p_cantidad
        );

        v_pagos_count := v_pagos_count + 1;
    END LOOP;

    -- Si hay costos del ejercicio siguiente, generar ene-dic
    IF v_tiene_sig THEN
        FOR v_mes IN 1..12 LOOP
            v_importe := p_cantidad * v_costo_unidad_sig;

            INSERT INTO ta_16_pagos (
                control_contrato,
                aso_mes_pago,
                ctrol_operacion,
                importe,
                status_vigencia,
                usuario,
                exed
            ) VALUES (
                p_control_contrato,
                MAKE_DATE(v_ejercicio_sig, v_mes, 1),
                6,  -- Cuota normal
                v_importe,
                'V',  -- Vigente
                p_usuario,
                p_cantidad
            );

            v_pagos_count := v_pagos_count + 1;
        END LOOP;
    END IF;

    RETURN QUERY SELECT
        TRUE::BOOLEAN,
        v_pagos_count,
        ('Se generaron ' || v_pagos_count || ' pagos')::VARCHAR;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT
        FALSE::BOOLEAN,
        0::INTEGER,
        ('Error al generar pagos: ' || SQLERRM)::VARCHAR;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_generar_pagos_contrato(INTEGER, INTEGER, VARCHAR, SMALLINT, INTEGER, INTEGER) TO PUBLIC;

-- SP Auxiliar: sp_aseo_crear_empresa_nueva
-- Tipo: Insert
-- Descripcion: Crea una empresa nueva (si no existe al buscar)
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_crear_empresa_nueva(VARCHAR);

CREATE OR REPLACE FUNCTION public.sp_aseo_crear_empresa_nueva(
    p_nombre VARCHAR
)
RETURNS TABLE (
    success BOOLEAN,
    num_empresa INTEGER,
    mensaje VARCHAR
) AS $$
DECLARE
    v_max_num INTEGER;
    v_nuevo_num INTEGER;
BEGIN
    -- Obtener max num_empresa para ctrol_emp = 9
    SELECT COALESCE(MAX(num_empresa), 0) + 1
    INTO v_nuevo_num
    FROM ta_16_empresas
    WHERE ctrol_emp = 9;

    -- Insertar nueva empresa
    INSERT INTO ta_16_empresas (
        num_empresa,
        ctrol_emp,
        descripcion,
        representante
    ) VALUES (
        v_nuevo_num,
        9,  -- Empresas privadas
        p_nombre,
        p_nombre  -- El representante es igual al nombre inicialmente
    );

    RETURN QUERY SELECT
        TRUE::BOOLEAN,
        v_nuevo_num,
        ('Empresa creada con numero: ' || v_nuevo_num)::VARCHAR;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT
        FALSE::BOOLEAN,
        0::INTEGER,
        ('Error al crear empresa: ' || SQLERRM)::VARCHAR;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_crear_empresa_nueva(VARCHAR) TO PUBLIC;

-- ============================================
-- FIN DEL ARCHIVO
-- ============================================
