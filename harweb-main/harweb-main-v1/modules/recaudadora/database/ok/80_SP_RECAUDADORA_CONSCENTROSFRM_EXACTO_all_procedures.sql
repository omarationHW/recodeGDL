-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSCENTROSFRM (EXACTO del archivo original)
-- Archivo: 80_SP_RECAUDADORA_CONSCENTROSFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
    FROM centros_recaudacion_view
    ORDER BY fecha DESC, num_recibo DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSCENTROSFRM (EXACTO del archivo original)
-- Archivo: 80_SP_RECAUDADORA_CONSCENTROSFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
    FROM centros_recaudacion_view
    WHERE id_dependencia = p_id_dependencia
    ORDER BY fecha DESC, num_recibo DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSCENTROSFRM (EXACTO del archivo original)
-- Archivo: 80_SP_RECAUDADORA_CONSCENTROSFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

