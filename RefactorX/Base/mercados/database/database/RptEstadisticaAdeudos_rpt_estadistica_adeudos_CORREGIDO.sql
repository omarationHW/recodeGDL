-- ============================================
-- STORED PROCEDURE CORREGIDO
-- Formulario: RptEstadisticaAdeudos
-- SP: rpt_estadistica_adeudos
-- Base: mercados.public
-- Fecha: 2025-12-03
-- ============================================

DROP FUNCTION IF EXISTS rpt_estadistica_adeudos(INTEGER, INTEGER, NUMERIC, INTEGER);

CREATE OR REPLACE FUNCTION rpt_estadistica_adeudos(
    p_axo INTEGER,
    p_periodo INTEGER,
    p_importe NUMERIC DEFAULT 0,
    p_opc INTEGER DEFAULT 1
)
RETURNS TABLE (
    oficina SMALLINT,
    num_mercado SMALLINT,
    local INTEGER,
    descripcion VARCHAR,
    adeudo NUMERIC
) AS $$
BEGIN
    IF p_opc = 1 THEN
        RETURN QUERY
        SELECT a.oficina, a.num_mercado, a.id_local AS local, b.descripcion, SUM(c.importe) AS adeudo
        FROM padron_licencias.comun.ta_11_locales a
        JOIN padron_licencias.comun.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
        JOIN padron_licencias.comun.ta_11_adeudo_local c ON a.id_local = c.id_local
        WHERE ((c.axo = p_axo AND c.periodo <= p_periodo) OR (c.axo < p_axo))
        GROUP BY a.oficina, a.num_mercado, a.id_local, b.descripcion
        ORDER BY a.oficina, a.num_mercado, a.id_local, b.descripcion;
    ELSE
        RETURN QUERY
        SELECT a.oficina, a.num_mercado, a.id_local AS local, b.descripcion, SUM(c.importe) AS adeudo
        FROM padron_licencias.comun.ta_11_locales a
        JOIN padron_licencias.comun.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
        JOIN padron_licencias.comun.ta_11_adeudo_local c ON a.id_local = c.id_local
        WHERE ((c.axo = p_axo AND c.periodo <= p_periodo) OR (c.axo < p_axo))
        GROUP BY a.oficina, a.num_mercado, a.id_local, b.descripcion
        HAVING SUM(c.importe) >= p_importe
        ORDER BY a.oficina, a.num_mercado, a.id_local, b.descripcion;
    END IF;
END;
$$ LANGUAGE plpgsql;
