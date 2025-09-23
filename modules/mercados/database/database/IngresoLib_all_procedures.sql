-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: IngresoLib
-- Generado: 2025-08-27 00:06:35
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_get_mercados
-- Tipo: Catalog
-- Descripción: Obtiene la lista de mercados con tipo_emision = 'D' (Mercado Libertad).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_mercados()
RETURNS TABLE (
    oficina smallint,
    num_mercado_nvo smallint,
    descripcion varchar,
    cuenta_ingreso integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT oficina, num_mercado_nvo, descripcion, cuenta_ingreso
    FROM ta_11_mercados
    WHERE tipo_emision = 'D'
    ORDER BY num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_get_ingresos_libertad
-- Tipo: Report
-- Descripción: Obtiene los ingresos por fecha y caja para el Mercado Libertad en un mes/año.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_ingresos_libertad(p_mes integer, p_anio integer, p_mercado integer)
RETURNS TABLE (
    fecha_pago date,
    caja_pago varchar,
    pagos integer,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.fecha_pago, b.caja_pago, COUNT(*) AS pagos, SUM(b.importe_pago) AS importe
    FROM ta_11_locales a
    JOIN ta_11_pagos_local b ON a.id_local = b.id_local
    WHERE a.num_mercado = p_mercado
      AND EXTRACT(MONTH FROM b.fecha_pago) = p_mes
      AND EXTRACT(YEAR FROM b.fecha_pago) = p_anio
    GROUP BY b.fecha_pago, b.caja_pago
    ORDER BY b.fecha_pago, b.caja_pago;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_get_cajas_libertad
-- Tipo: Report
-- Descripción: Obtiene los totales por caja para el Mercado Libertad en un mes/año.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cajas_libertad(p_mes integer, p_anio integer, p_mercado integer)
RETURNS TABLE (
    caja_pago varchar,
    pagos integer,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.caja_pago, COUNT(*) AS pagos, SUM(b.importe_pago) AS importe
    FROM ta_11_locales a
    JOIN ta_11_pagos_local b ON a.id_local = b.id_local
    WHERE a.num_mercado = p_mercado
      AND EXTRACT(MONTH FROM b.fecha_pago) = p_mes
      AND EXTRACT(YEAR FROM b.fecha_pago) = p_anio
    GROUP BY b.caja_pago
    ORDER BY b.caja_pago;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_get_totals_libertad
-- Tipo: Report
-- Descripción: Obtiene los totales globales de pagos y renta pagada para el Mercado Libertad en un mes/año.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_totals_libertad(p_mes integer, p_anio integer, p_mercado integer)
RETURNS TABLE (
    total_pagos integer,
    total_importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(*) AS total_pagos, COALESCE(SUM(b.importe_pago),0) AS total_importe
    FROM ta_11_locales a
    JOIN ta_11_pagos_local b ON a.id_local = b.id_local
    WHERE a.num_mercado = p_mercado
      AND EXTRACT(MONTH FROM b.fecha_pago) = p_mes
      AND EXTRACT(YEAR FROM b.fecha_pago) = p_anio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

