-- Stored Procedure: sp_get_predial_historico
-- Tipo: Report
-- Descripción: Obtiene el histórico de predial de la cuenta
-- Generado para formulario: Propuestatab
-- Fecha: 2025-08-26 17:34:10

CREATE OR REPLACE FUNCTION sp_get_predial_historico(p_cvecuenta INTEGER)
RETURNS TABLE(
    impuesto NUMERIC,
    recargos NUMERIC,
    multa NUMERIC,
    gasto NUMERIC,
    saldo NUMERIC,
    impuestotal NUMERIC,
    rectotal NUMERIC,
    multavir NUMERIC,
    saldototal NUMERIC,
    feccap DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT impuesto, recargos, multa, gasto, saldo, impuestotal, rectotal, multavir, saldototal, feccap
    FROM saldos
    WHERE cvecuenta = p_cvecuenta
    ORDER BY feccap DESC;
END;
$$ LANGUAGE plpgsql;