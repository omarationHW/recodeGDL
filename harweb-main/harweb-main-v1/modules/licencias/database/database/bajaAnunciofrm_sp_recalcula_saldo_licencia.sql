-- Stored Procedure: sp_recalcula_saldo_licencia
-- Tipo: CRUD
-- Descripción: Recalcula el saldo total de la licencia sumando derechos, anuncios, recargos, gastos, multas y formas.
-- Generado para formulario: bajaAnunciofrm
-- Fecha: 2025-08-26 14:30:28

-- sp_recalcula_saldo_licencia(id_licencia integer)
CREATE OR REPLACE FUNCTION sp_recalcula_saldo_licencia(
    p_id_licencia integer
) RETURNS void AS $$
DECLARE
    v_total numeric := 0;
    v_derechos numeric := 0;
    v_anuncios numeric := 0;
    v_recargos numeric := 0;
    v_gastos numeric := 0;
    v_multas numeric := 0;
    v_formas numeric := 0;
BEGIN
    SELECT COALESCE(SUM(derechos),0), COALESCE(SUM(anuncios),0), COALESCE(SUM(recargos),0), COALESCE(SUM(gastos),0), COALESCE(SUM(multas),0), COALESCE(SUM(formas),0)
      INTO v_derechos, v_anuncios, v_recargos, v_gastos, v_multas, v_formas
      FROM saldos_lic WHERE id_licencia = p_id_licencia;
    v_total := v_derechos + v_anuncios + v_recargos + v_gastos + v_multas + v_formas;
    UPDATE saldos_lic SET total = v_total WHERE id_licencia = p_id_licencia;
END;
$$ LANGUAGE plpgsql;