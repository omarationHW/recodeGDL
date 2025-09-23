-- Stored Procedure: sp_calcular_recargos
-- Tipo: CRUD
-- Descripción: Calcula el importe de recargos según la lógica del formulario
-- Generado para formulario: CalculoRecargos
-- Fecha: 2025-08-27 13:55:28

CREATE OR REPLACE FUNCTION sp_calcular_recargos(
    p_pagos_parciales INTEGER,
    p_pagos_a_realizar INTEGER,
    p_pag_inicio NUMERIC,
    p_pag_parcial NUMERIC,
    p_fecha_vencimiento DATE,
    p_fecha_actual DATE,
    p_requerimientos JSONB,
    p_porcentaje_recargos NUMERIC
) RETURNS TABLE(
    importe_a_pagar NUMERIC,
    importerecargos NUMERIC,
    label_porc TEXT
) AS $$
DECLARE
    importe_a_pagar NUMERIC := p_pag_inicio + p_pag_parcial;
    importerecargos NUMERIC := 0;
    label_porc TEXT := '';
    tiene_requerimientos BOOLEAN := (jsonb_array_length(p_requerimientos) > 0);
BEGIN
    IF p_pagos_a_realizar > p_pagos_parciales THEN
        RAISE EXCEPTION 'Error... Los Pagos a Realizar Exceden de %', p_pagos_parciales;
    END IF;
    IF p_fecha_actual > p_fecha_vencimiento THEN
        IF NOT tiene_requerimientos THEN
            IF p_porcentaje_recargos > 100 THEN
                importerecargos := (importe_a_pagar * 100) / 100;
                label_porc := '100%';
            ELSE
                importerecargos := (importe_a_pagar * p_porcentaje_recargos) / 100;
                label_porc := p_porcentaje_recargos::TEXT || '%';
            END IF;
        ELSE
            IF p_porcentaje_recargos > 250 THEN
                importerecargos := (importe_a_pagar * 250) / 100;
                label_porc := '250%';
            ELSE
                importerecargos := (importe_a_pagar * p_porcentaje_recargos) / 100;
                label_porc := p_porcentaje_recargos::TEXT || '%';
            END IF;
        END IF;
    ELSE
        importerecargos := (importe_a_pagar * p_porcentaje_recargos) / 100;
        label_porc := p_porcentaje_recargos::TEXT || '%';
    END IF;
    IF importerecargos > 0 THEN
        importerecargos := floor(importerecargos * 100) / 100;
    END IF;
    RETURN QUERY SELECT importe_a_pagar, importerecargos, label_porc;
END;
$$ LANGUAGE plpgsql;