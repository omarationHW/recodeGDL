-- Stored Procedure: sp_carga_adeudos_contratos_vigentes
-- Tipo: CRUD
-- Descripción: Carga masiva de adeudos para todos los contratos vigentes y no vigentes del ejercicio especificado. Inserta registros en ta_16_pagos para cada mes del año.
-- Generado para formulario: Adeudos_Carga
-- Fecha: 2025-08-27 13:40:10

-- PostgreSQL stored procedure for Adeudos_Carga
CREATE OR REPLACE PROCEDURE sp_carga_adeudos_contratos_vigentes(
    IN p_ejercicio INTEGER,
    IN p_usuario_id INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    mes INTEGER;
    dia INTEGER := 1;
    unidades INTEGER;
    cantidad NUMERIC;
    v_ctrol_operacion INTEGER;
BEGIN
    -- Obtener la clave de operacion para cuota normal (C)
    SELECT ctrol_operacion INTO v_ctrol_operacion FROM ta_16_operacion WHERE cve_operacion = 'C' LIMIT 1;
    IF v_ctrol_operacion IS NULL THEN
        RAISE EXCEPTION 'No existe clave de operacion C en ta_16_operacion';
    END IF;

    FOR rec IN
        SELECT a.control_contrato, a.num_contrato, a.ctrol_aseo, a.ctrol_recolec,
               a.cantidad_recolec, c.costo_unidad, a.aso_mes_oblig
        FROM ta_16_contratos a
        JOIN ta_16_unidades b ON b.ctrol_recolec = a.ctrol_recolec
        JOIN ta_16_unidades c ON c.cve_recolec = b.cve_recolec AND c.ejercicio_recolec = p_ejercicio
        WHERE a.status_vigencia IN ('V','N')
        ORDER BY a.ctrol_aseo, a.num_contrato
    LOOP
        unidades := rec.cantidad_recolec;
        cantidad := unidades * rec.costo_unidad;
        FOR mes IN 1..12 LOOP
            BEGIN
                INSERT INTO ta_16_pagos (
                    control_contrato, aso_mes_pago, ctrol_operacion, importe, status_vigencia, fecha_hora_pago, id_rec, caja, consec_operacion, folio_rcbo, usuario, exedencias
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
            EXCEPTION WHEN unique_violation THEN
                -- Si ya existe el pago para ese periodo, lo ignora
                CONTINUE;
            END;
        END LOOP;
    END LOOP;
END;
$$;