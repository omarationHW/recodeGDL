-- Stored Procedure: sp_recargos_acumulado
-- Tipo: CRUD
-- Descripción: Recalcula el porcentaje_global acumulado para todos los años y meses posteriores al registro modificado.
-- Generado para formulario: ABCRecargos
-- Fecha: 2025-08-28 17:38:53

CREATE OR REPLACE FUNCTION sp_recargos_acumulado(p_axo integer, p_mes integer)
RETURNS TABLE(result text) AS $$
DECLARE
    v_year integer;
    v_month integer;
    v_now_year integer;
    v_now_month integer;
    v_global float;
    v_axo integer;
    v_axo2 integer;
    vmes integer;
    vmes2 integer;
BEGIN
    SELECT EXTRACT(YEAR FROM CURRENT_DATE)::integer INTO v_now_year;
    SELECT EXTRACT(MONTH FROM CURRENT_DATE)::integer INTO v_now_month;
    v_axo := 1994;
    v_axo2 := p_axo;
    IF p_axo < v_now_year THEN
        v_axo2 := p_axo;
    ELSE
        v_axo2 := v_now_year;
    END IF;
    vmes := p_mes;
    vmes2 := 12;
    -- Recalcular para cada año desde 1994 hasta v_axo2
    FOR v_year IN v_axo..v_axo2 LOOP
        IF v_year < v_axo2 THEN
            SELECT SUM(porcentaje_parcial) INTO v_global
            FROM ta_13_recargosrcm
            WHERE (axo = v_year AND mes >= 3) OR (axo > v_year AND axo < v_axo2) OR (axo = v_axo2 AND mes <= p_mes);
        ELSE
            SELECT SUM(porcentaje_parcial) INTO v_global
            FROM ta_13_recargosrcm
            WHERE axo = v_year AND mes <= p_mes;
        END IF;
        IF v_global > 100 THEN
            v_global := 100;
        END IF;
        UPDATE ta_13_recargosrcm
        SET porcentaje_global = v_global
        WHERE axo = v_year AND mes = p_mes;
    END LOOP;
    -- Si es el año actual y mes actual, actualizar meses siguientes
    IF (p_axo = v_now_year) AND (p_mes = v_now_month) THEN
        FOR v_month IN p_mes+1..vmes2 LOOP
            SELECT SUM(porcentaje_parcial) INTO v_global
            FROM ta_13_recargosrcm
            WHERE axo = v_now_year AND mes <= v_month;
            UPDATE ta_13_recargosrcm
            SET porcentaje_global = v_global
            WHERE axo = v_now_year AND mes = v_month;
        END LOOP;
    END IF;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;