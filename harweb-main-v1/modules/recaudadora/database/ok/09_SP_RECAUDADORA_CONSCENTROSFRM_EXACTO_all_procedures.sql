-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: conscentrosfrm
-- Generado: 2025-08-27 11:54:28
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_get_centros_list
-- Tipo: Report
-- Descripción: Obtiene el listado general de pagos en centros de recaudación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_centros_list()
RETURNS TABLE (
    fecha DATE,
    abrevia VARCHAR,
    axo_acta INTEGER,
    num_acta INTEGER,
    num_recibo INTEGER,
    importe_pago NUMERIC(12,2),
    contribuyente VARCHAR,
    domicilio VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT fecha, abrevia, axo_acta, num_acta, num_recibo, importe_pago, contribuyente, domicilio
    FROM public.centros_recaudacion_view
    ORDER BY fecha DESC, num_recibo DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_get_centros_by_fecha
-- Tipo: Report
-- Descripción: Obtiene pagos en centros de recaudación filtrados por fecha.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_centros_by_fecha(p_fecha DATE)
RETURNS TABLE (
    fecha DATE,
    abrevia VARCHAR,
    axo_acta INTEGER,
    num_acta INTEGER,
    num_recibo INTEGER,
    importe_pago NUMERIC(12,2),
    contribuyente VARCHAR,
    domicilio VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT fecha, abrevia, axo_acta, num_acta, num_recibo, importe_pago, contribuyente, domicilio
    FROM public.centros_recaudacion_view
    WHERE fecha = p_fecha
    ORDER BY num_recibo DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_get_centros_by_dependencia
-- Tipo: Report
-- Descripción: Obtiene pagos en centros de recaudación filtrados por dependencia.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_centros_by_dependencia(p_id_dependencia INTEGER)
RETURNS TABLE (
    fecha DATE,
    abrevia VARCHAR,
    axo_acta INTEGER,
    num_acta INTEGER,
    num_recibo INTEGER,
    importe_pago NUMERIC(12,2),
    contribuyente VARCHAR,
    domicilio VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT fecha, abrevia, axo_acta, num_acta, num_recibo, importe_pago, contribuyente, domicilio
    FROM public.centros_recaudacion_view
    WHERE id_dependencia = p_id_dependencia
    ORDER BY fecha DESC, num_recibo DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_get_centros_by_acta
-- Tipo: Report
-- Descripción: Obtiene pagos en centros de recaudación filtrados por año y número de acta.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_centros_by_acta(p_axo_acta INTEGER, p_num_acta INTEGER)
RETURNS TABLE (
    fecha DATE,
    abrevia VARCHAR,
    axo_acta INTEGER,
    num_acta INTEGER,
    num_recibo INTEGER,
    importe_pago NUMERIC(12,2),
    contribuyente VARCHAR,
    domicilio VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT fecha, abrevia, axo_acta, num_acta, num_recibo, importe_pago, contribuyente, domicilio
    FROM public.centros_recaudacion_view
    WHERE axo_acta = p_axo_acta AND num_acta = p_num_acta
    ORDER BY fecha DESC, num_recibo DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================