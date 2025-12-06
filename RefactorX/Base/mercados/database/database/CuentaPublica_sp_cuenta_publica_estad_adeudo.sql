-- Stored Procedure: sp_cuenta_publica_estad_adeudo
-- Tipo: Report
-- Descripción: Obtiene el resumen de adeudos por mercado y mes para una recaudadora, año y mes dados.
-- Generado para formulario: CuentaPublica
-- Fecha: 2025-08-26 23:30:20

CREATE OR REPLACE FUNCTION sp_cuenta_publica_estad_adeudo(p_oficina integer, p_axo integer, p_periodo integer)
RETURNS TABLE (
    oficina smallint,
    num_mercado smallint,
    axo smallint,
    periodo smallint,
    total integer,
    adeudo numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.oficina, a.num_mercado, b.axo, b.periodo, COUNT(b.periodo)::integer AS total, SUM(b.importe) AS adeudo
    FROM public.ta_11_localpaso a
    JOIN public.ta_11_adeudo_local b ON a.id_local = b.id_local
    WHERE a.oficina = p_oficina
      AND b.axo = p_axo
      AND b.periodo <= p_periodo
      AND a.vigencia = 'A'
    GROUP BY a.oficina, a.num_mercado, b.axo, b.periodo
    ORDER BY a.oficina, a.num_mercado, b.axo, b.periodo;
END;
$$ LANGUAGE plpgsql;