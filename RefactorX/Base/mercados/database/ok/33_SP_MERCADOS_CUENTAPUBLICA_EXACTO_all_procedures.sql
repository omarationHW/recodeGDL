-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CuentaPublica
-- Generado: 2025-08-26 23:30:20
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_cuenta_publica_estad_adeudo
-- Tipo: Report
-- Descripción: Obtiene el resumen de adeudos por mercado y mes para una recaudadora, año y mes dados.
-- --------------------------------------------

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
    SELECT a.oficina, a.num_mercado, b.axo, b.periodo, COUNT(b.periodo) AS total, SUM(b.importe) AS adeudo
    FROM public.ta_11_locales a
    JOIN public.ta_11_adeudo_local b ON a.id_local = b.id_local
    WHERE a.oficina = p_oficina
      AND b.axo = p_axo
      AND b.periodo <= p_periodo
      AND a.vigencia = 'A'
    GROUP BY a.oficina, a.num_mercado, b.axo, b.periodo
    ORDER BY a.oficina, a.num_mercado, b.axo, b.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_cuenta_publica_total_adeudo
-- Tipo: Report
-- Descripción: Obtiene el total de adeudos por recaudadora y mes para un año y mes dados.
-- --------------------------------------------

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
    FROM public.ta_11_locales a
    JOIN public.ta_11_adeudo_local b ON a.id_local = b.id_local
    WHERE a.oficina = p_oficina
      AND b.axo = p_axo
      AND b.periodo <= p_periodo
      AND a.vigencia = 'A'
    GROUP BY a.oficina, b.axo, b.periodo
    ORDER BY a.oficina, b.axo, b.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_cuenta_publica_reporte
-- Tipo: Report
-- Descripción: Genera el reporte de cuenta pública para impresión/exportación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cuenta_publica_reporte(p_axo integer, p_oficina integer)
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
    SELECT a.oficina, a.num_mercado, b.axo, b.periodo, COUNT(b.periodo) AS total, SUM(b.importe) AS adeudo
    FROM public.ta_11_locales a
    JOIN public.ta_11_adeudo_local b ON a.id_local = b.id_local
    WHERE a.oficina = p_oficina
      AND b.axo = p_axo
      AND a.vigencia = 'A'
    GROUP BY a.oficina, a.num_mercado, b.axo, b.periodo
    ORDER BY a.oficina, a.num_mercado, b.axo, b.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

