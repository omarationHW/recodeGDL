-- Stored Procedure: sp_calc_recargos_adeudo
-- Tipo: CRUD
-- Descripción: Calcula el recargo para un adeudo de predio/convenio
-- Generado para formulario: IndividualPredios
-- Fecha: 2025-08-27 14:45:56

CREATE OR REPLACE FUNCTION sp_calc_recargos_adeudo(
    p_id_conv_resto INTEGER,
    p_importe NUMERIC,
    p_fecha_venc DATE,
    p_fecha_actual DATE
) RETURNS NUMERIC AS $$
DECLARE
    alov INTEGER;
    mesv INTEGER;
    diav INTEGER;
    alo INTEGER;
    mes INTEGER;
    dia INTEGER;
    dvenc INTEGER;
    porc FLOAT;
    recargo NUMERIC := 0;
    v_porcentaje FLOAT;
BEGIN
    SELECT EXTRACT(YEAR FROM p_fecha_venc), EXTRACT(MONTH FROM p_fecha_venc), EXTRACT(DAY FROM p_fecha_venc)
      INTO alov, mesv, diav;
    SELECT EXTRACT(YEAR FROM p_fecha_actual), EXTRACT(MONTH FROM p_fecha_actual), EXTRACT(DAY FROM p_fecha_actual)
      INTO alo, mes, dia;
    -- Buscar día de vencimiento
    SELECT COALESCE(day(fecha_venc), diav) INTO dvenc
      FROM ta_17_adeudos_div
      WHERE id_conv_resto = p_id_conv_resto
        AND EXTRACT(YEAR FROM fecha_venc) = alo
        AND EXTRACT(MONTH FROM fecha_venc) = mes
      LIMIT 1;
    -- Calcular porcentaje
    SELECT COALESCE(SUM(porcentaje_parcial), 0) INTO v_porcentaje
      FROM ta_13_recargosrcm
      WHERE (axo = alov AND mes >= mesv)
        OR (axo = alo AND mes <= CASE WHEN dia <= dvenc THEN mes-1 ELSE mes END)
        OR (axo > alov AND axo < alo);
    recargo := (p_importe * v_porcentaje) / 100.0;
    IF recargo > 0 THEN
        recargo := trunc(recargo * 100) / 100.0;
    END IF;
    RETURN recargo;
END;
$$ LANGUAGE plpgsql;