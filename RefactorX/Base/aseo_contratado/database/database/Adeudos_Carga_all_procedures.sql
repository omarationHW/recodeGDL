-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Adeudos_Carga
-- Base de datos: aseo_contratado
-- Actualizado: 2025-12-07
-- Total SPs: 1
-- ============================================
-- Descripcion: Carga masiva de adeudos para todos los contratos
-- vigentes del ejercicio especificado.
-- Flujo segun Delphi original:
--   1. Buscar contratos con status V o N
--   2. Para cada contrato, generar 12 registros (ene-dic)
--   3. Importe = cantidad_recolec * costo_unidad del ejercicio
--   4. Ignorar duplicados
-- ============================================

-- SP 1/1: sp_carga_adeudos_contratos_vigentes
-- Tipo: Process
-- Descripcion: Carga masiva de adeudos para contratos vigentes
-- ============================================
DROP FUNCTION IF EXISTS public.sp_carga_adeudos_contratos_vigentes(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_carga_adeudos_contratos_vigentes(
    p_ejercicio INTEGER,
    p_usuario_id INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    mensaje VARCHAR,
    contratos_procesados INTEGER,
    adeudos_generados INTEGER
) AS $$
DECLARE
    rec RECORD;
    mes INTEGER;
    dia INTEGER := 1;
    unidades INTEGER;
    cantidad NUMERIC;
    v_ctrol_operacion INTEGER;
    v_contratos_procesados INTEGER := 0;
    v_adeudos_generados INTEGER := 0;
    v_adeudos_omitidos INTEGER := 0;
BEGIN
    -- Obtener la clave de operacion para cuota normal (C o 6)
    SELECT o.ctrol_operacion INTO v_ctrol_operacion
    FROM ta_16_operacion o
    WHERE o.cve_operacion = 'C' OR o.ctrol_operacion = 6
    LIMIT 1;

    IF v_ctrol_operacion IS NULL THEN
        -- Intentar con valor por defecto
        v_ctrol_operacion := 6;
    END IF;

    -- Procesar cada contrato vigente
    FOR rec IN
        SELECT a.control_contrato, a.num_contrato, a.ctrol_aseo, a.ctrol_recolec,
               a.cantidad_recolec,
               COALESCE(c.costo_unidad, 0) as costo_unidad,
               a.aso_mes_oblig
        FROM ta_16_contratos a
        LEFT JOIN ta_16_unidades b ON b.ctrol_recolec = a.ctrol_recolec
        LEFT JOIN ta_16_unidades c ON c.cve_recolec = b.cve_recolec
                                   AND c.ejercicio_recolec = p_ejercicio
        WHERE a.status_vigencia IN ('V','N')
        ORDER BY a.ctrol_aseo, a.num_contrato
    LOOP
        v_contratos_procesados := v_contratos_procesados + 1;
        unidades := COALESCE(rec.cantidad_recolec, 1);
        cantidad := unidades * COALESCE(rec.costo_unidad, 0);

        -- Generar 12 meses
        FOR mes IN 1..12 LOOP
            BEGIN
                INSERT INTO ta_16_pagos (
                    control_contrato,
                    aso_mes_pago,
                    ctrol_operacion,
                    importe,
                    status_vigencia,
                    fecha_hora_pago,
                    id_rec,
                    caja,
                    consec_operacion,
                    folio_rcbo,
                    usuario,
                    exedencias
                ) VALUES (
                    rec.control_contrato,
                    make_date(p_ejercicio, mes, dia),
                    v_ctrol_operacion,
                    cantidad,
                    'V',
                    NULL,
                    0,
                    '',
                    0,
                    '',
                    p_usuario_id,
                    unidades
                );
                v_adeudos_generados := v_adeudos_generados + 1;
            EXCEPTION WHEN unique_violation THEN
                -- Si ya existe el pago para ese periodo, lo ignora
                v_adeudos_omitidos := v_adeudos_omitidos + 1;
            END;
        END LOOP;
    END LOOP;

    -- Retornar resultado
    RETURN QUERY SELECT
        TRUE::BOOLEAN as success,
        ('Proceso completado. Contratos: ' || v_contratos_procesados ||
         ', Adeudos generados: ' || v_adeudos_generados ||
         ', Omitidos (ya existian): ' || v_adeudos_omitidos)::VARCHAR as mensaje,
        v_contratos_procesados,
        v_adeudos_generados;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT
        FALSE::BOOLEAN as success,
        ('Error: ' || SQLERRM)::VARCHAR as mensaje,
        0::INTEGER,
        0::INTEGER;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_carga_adeudos_contratos_vigentes(INTEGER, INTEGER) TO PUBLIC;

-- ============================================
-- FIN DEL ARCHIVO
-- ============================================
