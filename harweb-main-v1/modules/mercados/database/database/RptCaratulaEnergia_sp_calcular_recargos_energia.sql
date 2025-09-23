-- Stored Procedure: sp_calcular_recargos_energia
-- Tipo: CRUD
-- Descripción: Calcula los recargos de energía para un adeudo específico
-- Generado para formulario: RptCaratulaEnergia
-- Fecha: 2025-08-27 00:46:24

CREATE OR REPLACE FUNCTION sp_calcular_recargos_energia(p_id_adeudo INTEGER)
RETURNS NUMERIC AS $$
DECLARE
    v_axo SMALLINT;
    v_periodo SMALLINT;
    v_importe NUMERIC;
    v_recargos NUMERIC := 0;
    v_mes_actual SMALLINT;
    v_alo SMALLINT;
    v_dia_actual SMALLINT;
    v_dia_venc SMALLINT;
    v_porcentaje NUMERIC;
    v_mes_calc SMALLINT;
    v_meses INTEGER := 1;
    v_impmescalc NUMERIC;
    v_cont INTEGER;
    v_id_energia INTEGER;
    v_id_local INTEGER;
    v_mercado SMALLINT;
    v_req_count INTEGER;
BEGIN
    SELECT a.axo, a.periodo, a.importe, a.id_energia INTO v_axo, v_periodo, v_importe, v_id_energia
    FROM ta_11_adeudo_energ a WHERE a.id_adeudo_energia = p_id_adeudo;
    SELECT e.id_local INTO v_id_local FROM ta_11_energia e WHERE e.id_energia = v_id_energia;
    SELECT l.num_mercado INTO v_mercado FROM ta_11_locales l WHERE l.id_local = v_id_local;
    SELECT EXTRACT(MONTH FROM CURRENT_DATE)::SMALLINT, EXTRACT(YEAR FROM CURRENT_DATE)::SMALLINT, EXTRACT(DAY FROM CURRENT_DATE)::SMALLINT INTO v_mes_actual, v_alo, v_dia_actual;
    SELECT dia INTO v_dia_venc FROM sp_get_dia_vencimiento(v_mes_actual);
    IF v_mercado = 1 THEN
        RETURN 0;
    END IF;
    IF v_axo <= 2002 THEN
        v_meses := 2;
        v_impmescalc := v_importe / 2;
        IF v_periodo = 1 THEN v_mes_calc := 1;
        ELSIF v_periodo = 2 THEN v_mes_calc := 3;
        ELSIF v_periodo = 3 THEN v_mes_calc := 5;
        ELSIF v_periodo = 4 THEN v_mes_calc := 7;
        ELSIF v_periodo = 5 THEN v_mes_calc := 9;
        ELSE v_mes_calc := 11;
        END IF;
    ELSE
        v_meses := 1;
        v_impmescalc := v_importe;
        v_mes_calc := v_periodo;
    END IF;
    FOR v_cont IN 1..v_meses LOOP
        SELECT COALESCE(SUM(porcentaje_mes),0) INTO v_porcentaje
        FROM ta_12_recargos
        WHERE (axo = v_axo AND mes >= v_mes_calc)
           OR (axo = v_alo AND mes <= (CASE WHEN v_dia_actual < v_dia_venc THEN v_mes_actual-1 ELSE v_mes_actual END))
           OR (axo > v_axo AND axo < v_alo);
        SELECT COUNT(*) INTO v_req_count FROM ta_15_apremios WHERE modulo=33 AND control_otr=v_id_local;
        IF v_axo = v_alo THEN
            IF v_periodo = v_mes_actual THEN
                IF v_dia_actual > v_dia_venc THEN
                    IF v_req_count = 0 THEN
                        IF v_porcentaje > 100 THEN
                            v_recargos := v_recargos + (v_impmescalc * 100) / 100;
                        ELSE
                            v_recargos := v_recargos + (v_impmescalc * v_porcentaje) / 100;
                        END IF;
                    ELSE
                        IF v_porcentaje > 250 THEN
                            v_recargos := v_recargos + (v_impmescalc * 250) / 100;
                        ELSE
                            v_recargos := v_recargos + (v_impmescalc * v_porcentaje) / 100;
                        END IF;
                    END IF;
                END IF;
            ELSE
                IF v_req_count = 0 THEN
                    IF v_porcentaje > 100 THEN
                        v_recargos := v_recargos + (v_impmescalc * 100) / 100;
                    ELSE
                        v_recargos := v_recargos + (v_impmescalc * v_porcentaje) / 100;
                    END IF;
                ELSE
                    IF v_porcentaje > 250 THEN
                        v_recargos := v_recargos + (v_impmescalc * 250) / 100;
                    ELSE
                        v_recargos := v_recargos + (v_impmescalc * v_porcentaje) / 100;
                    END IF;
                END IF;
            END IF;
        ELSE
            IF v_req_count = 0 THEN
                IF v_porcentaje > 100 THEN
                    v_recargos := v_recargos + (v_impmescalc * 100) / 100;
                ELSE
                    v_recargos := v_recargos + (v_impmescalc * v_porcentaje) / 100;
                END IF;
            ELSE
                IF v_porcentaje > 250 THEN
                    v_recargos := v_recargos + (v_impmescalc * 250) / 100;
                ELSE
                    v_recargos := v_recargos + (v_impmescalc * v_porcentaje) / 100;
                END IF;
            END IF;
        END IF;
        v_mes_calc := v_mes_calc + 1;
    END LOOP;
    RETURN v_recargos;
END;
$$ LANGUAGE plpgsql;