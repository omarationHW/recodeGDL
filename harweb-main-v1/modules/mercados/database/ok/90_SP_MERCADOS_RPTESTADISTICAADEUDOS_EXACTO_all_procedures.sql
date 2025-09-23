-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptEstadisticaAdeudos
-- Generado: 2025-08-27 01:01:49
-- Total SPs: 1
-- ============================================

-- SP 1/1: rpt_estadistica_adeudos
-- Tipo: Report
-- Descripción: Reporte de estadística global de adeudos vencidos al periodo y opcionalmente filtrando por importe mínimo.
-- --------------------------------------------

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
        FROM public.ta_11_locales a
        JOIN public.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
        JOIN public.ta_11_adeudo_local c ON a.id_local = c.id_local
        WHERE ((c.axo = p_axo AND c.periodo <= p_periodo) OR (c.axo < p_axo))
        GROUP BY a.oficina, a.num_mercado, a.id_local, b.descripcion
        ORDER BY a.oficina, a.num_mercado, a.id_local, b.descripcion;
    ELSE
        RETURN QUERY
        SELECT a.oficina, a.num_mercado, a.id_local AS local, b.descripcion, SUM(c.importe) AS adeudo
        FROM public.ta_11_locales a
        JOIN public.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
        JOIN public.ta_11_adeudo_local c ON a.id_local = c.id_local
        WHERE ((c.axo = p_axo AND c.periodo <= p_periodo) OR (c.axo < p_axo))
        GROUP BY a.oficina, a.num_mercado, a.id_local, b.descripcion
        HAVING SUM(c.importe) >= p_importe
        ORDER BY a.oficina, a.num_mercado, a.id_local, b.descripcion;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

