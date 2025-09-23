-- Stored Procedure: sp_cuenta_publica_total_adeudo
-- Tipo: Report
-- Descripción: Obtiene el total de adeudos por recaudadora y mes para un año y mes dados.
-- Generado para formulario: CuentaPublica
-- Fecha: 2025-08-26 23:30:20

CREATE OR REPLACE FUNCTION sp_cuenta_publica_total_adeudo(p_oficina integer, p_axo integer, p_periodo integer)
RETURNS TABLE (
    oficina smallint,
    axo smallint,
    periodo smallint,
    total integer,
    adeudo numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.oficina, b.axo, b.periodo, COUNT(b.periodo) AS total, SUM(b.importe) AS adeudo
    FROM ta_11_locales a
    JOIN ta_11_adeudo_local b ON a.id_local = b.id_local
    WHERE a.oficina = p_oficina
      AND b.axo = p_axo
      AND b.periodo <= p_periodo
      AND a.vigencia = 'A'
    GROUP BY a.oficina, b.axo, b.periodo
    ORDER BY a.oficina, b.axo, b.periodo;
END;
$$ LANGUAGE plpgsql;