-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: CONSDESGLOCE (EXACTO del archivo original)
-- Archivo: 38_SP_CONVENIOS_CONSDESGLOCE_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_consdesgloce_get_desgloce
-- Tipo: Report
-- Descripción: Obtiene el desgloce de cuentas de aplicación para un id_adeudo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consdesgloce_get_desgloce(p_id_adeudo INTEGER)
RETURNS TABLE(
    pago_parcial SMALLINT,
    importe NUMERIC(18,2),
    cuenta_apl INTEGER,
    descripcion VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.pago_parcial,
        a.importe,
        a.cuenta_apl,
        COALESCE(b.descripcion, '') AS descripcion
    FROM public.ta_17_desg_parcial a
    LEFT JOIN public.ta_12_ctas_odoo b ON b.axo = EXTRACT(YEAR FROM CURRENT_DATE) AND b.cta_aplic = a.cuenta_apl
    JOIN public.ta_17_adeudos_div d ON d.id_adeudo = a.id_adeudo
    WHERE a.id_adeudo = p_id_adeudo
    ORDER BY a.id_desgloce;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: CONSDESGLOCE (EXACTO del archivo original)
-- Archivo: 38_SP_CONVENIOS_CONSDESGLOCE_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

