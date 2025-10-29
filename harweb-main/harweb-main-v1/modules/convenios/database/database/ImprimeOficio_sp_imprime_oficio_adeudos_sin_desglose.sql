-- Stored Procedure: sp_imprime_oficio_adeudos_sin_desglose
-- Tipo: CRUD
-- Descripción: Devuelve parcialidades sin desglose de cuentas para un convenio.
-- Generado para formulario: ImprimeOficio
-- Fecha: 2025-08-27 14:41:11

CREATE OR REPLACE FUNCTION sp_imprime_oficio_adeudos_sin_desglose(
    p_id_conv_resto INTEGER
) RETURNS TABLE (
    id_adeudo INTEGER,
    id_conv_resto INTEGER,
    pago_parcial INTEGER,
    importe NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_adeudo, a.id_conv_resto, a.pago_parcial, a.importe
    FROM ta_17_adeudos_div a
    WHERE a.id_conv_resto=p_id_conv_resto
      AND a.id_adeudo NOT IN (
        SELECT id_adeudo FROM ta_17_desg_parcial WHERE id_adeudo=a.id_adeudo
      )
    ORDER BY a.pago_parcial;
END;
$$ LANGUAGE plpgsql;