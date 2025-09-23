-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: RPTADEUDOCORTEMANZANA (EXACTO del archivo original)
-- Archivo: 67_SP_CONVENIOS_RPTADEUDOCORTEMANZANA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_adeudo_corte_manzana
-- Tipo: Report
-- Descripción: Reporte de corte de adeudos por manzana, agrupando por manzana y subtipo, con totales de costo, pagos, recargos y saldo.
-- --------------------------------------------

-- PostgreSQL stored procedure for Adeudo Corte Manzana
CREATE OR REPLACE FUNCTION sp_adeudo_corte_manzana(
    p_subtipo integer,
    p_fechadsd date,
    p_fechahst date,
    p_rep integer,
    p_est varchar
)
RETURNS TABLE (
    id_conv_predio integer,
    tipo smallint,
    subtipo smallint,
    manzana varchar,
    lote integer,
    letra varchar,
    letracomp varchar,
    nombre varchar,
    calle varchar,
    num_exterior smallint,
    num_interior smallint,
    inciso varchar,
    cantidad_total numeric,
    parcpag numeric,
    pagos numeric,
    desc_subtipo varchar,
    recargos numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_conv_predio,
        a.tipo,
        a.subtipo,
        a.manzana,
        a.lote,
        a.letra,
        CASE WHEN a.letra = 'B' THEN 'BIS' WHEN a.letra = 'S' THEN 'SUB' ELSE ' ' END AS letracomp,
        b.nombre,
        b.calle,
        b.num_exterior,
        b.num_interior,
        b.inciso,
        b.cantidad_total,
        COUNT(c.id_conv_resto) AS parcpag,
        COALESCE(SUM(c.importe_pago),0) AS pagos,
        d.desc_subtipo,
        COALESCE(SUM(c.importe_recargo),0) AS recargos
    FROM public.ta_17_con_reg_pred a
    JOIN public.ta_17_conv_d_resto b ON a.tipo = b.tipo AND a.id_conv_predio = b.id_conv_diver
    LEFT JOIN public.ta_17_conv_pagos c ON b.id_conv_resto = c.id_conv_resto AND (c.fecha_pago <= p_fechahst)
    JOIN public.ta_17_subtipo_conv d ON a.tipo = d.tipo AND a.subtipo = d.subtipo
    WHERE a.tipo = 14
      AND a.subtipo = p_subtipo
      AND b.vigencia = p_est
    GROUP BY a.id_conv_predio, a.tipo, a.subtipo, a.manzana, a.lote, a.letra, b.nombre, b.calle, b.num_exterior, b.num_interior, b.inciso, b.cantidad_total, d.desc_subtipo
    ORDER BY a.id_conv_predio, a.tipo, a.subtipo, a.manzana, a.lote, a.letra;
END;
$$ LANGUAGE plpgsql;

-- ============================================

