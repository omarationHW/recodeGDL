-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: RPTPARCVENCIDASPREDIOS (EXACTO del archivo original)
-- Archivo: 86_SP_CONVENIOS_RPTPARCVENCIDASPREDIOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_parcialidades_vencidas_predios
-- Tipo: Report
-- Descripción: Obtiene el reporte de parcialidades vencidas de predios por subtipo, fecha de corte y estado.
-- --------------------------------------------

-- PostgreSQL stored procedure for Parcialidades Vencidas Predios
CREATE OR REPLACE FUNCTION sp_parcialidades_vencidas_predios(
    p_subtipo integer,
    p_fechahst date,
    p_est varchar
)
RETURNS TABLE(
    id_conv_predio integer,
    tipo smallint,
    subtipo smallint,
    manzana varchar,
    lote integer,
    letra varchar,
    nombre varchar,
    calle varchar,
    num_exterior smallint,
    num_interior smallint,
    inciso varchar,
    costo numeric,
    parcpag numeric,
    pagos numeric,
    recargos numeric,
    venc integer,
    parcade numeric,
    adeudos numeric,
    desc_subtipo varchar,
    letracomp varchar
) AS $$
BEGIN
    RETURN QUERY
    -- Pagos corrientes y vencidos
    SELECT a.id_conv_predio, a.tipo, a.subtipo, a.manzana, a.lote, a.letra,
           b.nombre, b.calle, b.num_exterior, b.num_interior, b.inciso,
           b.cantidad_total as costo,
           COUNT(c.id_conv_resto) as parcpag,
           COALESCE(SUM(c.importe_pago), 0) as pagos,
           COALESCE(SUM(c.importe_recargo), 0) as recargos,
           c.cve_venc as venc,
           0 as parcade,
           0 as adeudos,
           d.desc_subtipo,
           CASE WHEN a.letra = 'B' THEN 'BIS' WHEN a.letra = 'S' THEN 'SUB' ELSE ' ' END as letracomp
    FROM public.ta_17_con_reg_pred a
    JOIN public.ta_17_conv_d_resto b ON a.tipo = b.tipo AND a.id_conv_predio = b.id_conv_diver
    LEFT JOIN public.ta_17_conv_pagos c ON b.id_conv_resto = c.id_conv_resto AND c.fecha_pago <= p_fechahst
    JOIN public.ta_17_subtipo_conv d ON a.tipo = d.tipo AND a.subtipo = d.subtipo
    WHERE a.tipo = 14
      AND a.subtipo = p_subtipo
      AND b.vigencia = p_est
    GROUP BY a.id_conv_predio, a.tipo, a.subtipo, a.manzana, a.lote, a.letra,
             b.nombre, b.calle, b.num_exterior, b.num_interior, b.inciso,
             b.cantidad_total, c.cve_venc, d.desc_subtipo
    UNION
    -- Adeudos vencidos
    SELECT e.id_conv_predio, e.tipo, e.subtipo, e.manzana, e.lote, e.letra,
           f.nombre, f.calle, f.num_exterior, f.num_interior, f.inciso,
           0 as costo,
           0 as parcpag,
           0 as pagos,
           0 as recargos,
           3 as venc,
           COUNT(h.id_conv_resto) as parcade,
           COALESCE(SUM(h.importe), 0) as adeudos,
           g.desc_subtipo,
           CASE WHEN e.letra = 'B' THEN 'BIS' WHEN e.letra = 'S' THEN 'SUB' ELSE ' ' END as letracomp
    FROM public.ta_17_con_reg_pred e
    JOIN public.ta_17_conv_d_resto f ON e.tipo = f.tipo AND e.id_conv_predio = f.id_conv_diver
    LEFT JOIN public.ta_17_adeudos_div h ON f.id_conv_resto = h.id_conv_resto AND h.fecha_venc < p_fechahst AND h.clave_pago IS NULL
    JOIN public.ta_17_subtipo_conv g ON e.tipo = g.tipo AND e.subtipo = g.subtipo
    WHERE e.tipo = 14
      AND e.subtipo = p_subtipo
      AND f.vigencia = p_est
    GROUP BY e.id_conv_predio, e.tipo, e.subtipo, e.manzana, e.lote, e.letra,
             f.nombre, f.calle, f.num_exterior, f.num_interior, f.inciso,
             g.desc_subtipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

