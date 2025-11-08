-- Stored Procedure: sp_get_importe_recargo
-- Tipo: CRUD
-- Descripción: Calcula el importe de recargo para un adeudo vencido, según la lógica del formulario.
-- Generado para formulario: sQRptAdeudosVenc
-- Fecha: 2025-08-27 15:24:46

CREATE OR REPLACE FUNCTION sp_get_importe_recargo(
    p_importe numeric,
    p_ctrol_operacion integer,
    p_aso_mes_pago date,
    p_aso_hoy smallint,
    p_mes_hoy smallint
)
RETURNS TABLE(importe_recargo numeric) AS $$
DECLARE
    year_pago integer;
    mes_pago integer;
    year_ade integer;
    mes_ade integer;
    aso_ade integer;
    mes_ade_final integer;
    aso_hoy integer := p_aso_hoy;
    mes_hoy integer := p_mes_hoy;
    sum_recargo numeric := 0;
    fecha_pago text;
    fecha_hoy text;
BEGIN
    year_pago := EXTRACT(YEAR FROM p_aso_mes_pago);
    mes_pago := EXTRACT(MONTH FROM p_aso_mes_pago);
    aso_ade := year_pago;
    mes_ade_final := mes_pago;
    IF p_ctrol_operacion <> 6 THEN
        IF mes_ade_final = 11 THEN
            aso_ade := aso_ade + 1;
            mes_ade_final := 1;
        ELSIF mes_ade_final = 12 THEN
            aso_ade := aso_ade + 1;
            mes_ade_final := 2;
        ELSIF mes_ade_final >= 1 AND mes_ade_final <= 10 THEN
            mes_ade_final := mes_ade_final + 2;
        END IF;
    END IF;
    fecha_pago := aso_ade::text || '-' || LPAD(mes_ade_final::text,2,'0');
    fecha_hoy := aso_hoy::text || '-' || LPAD(mes_hoy::text,2,'0');
    SELECT COALESCE(SUM(porc_recargo),0) INTO sum_recargo
    FROM ta_16_recargos
    WHERE aso_mes_recargo BETWEEN fecha_pago AND fecha_hoy;
    RETURN QUERY SELECT ROUND((p_importe * sum_recargo) / 100, 2);
END;
$$ LANGUAGE plpgsql;