-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ConsDesgloce
-- Generado: 2025-08-27 14:10:10
-- Total SPs: 2
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
    FROM ta_17_desg_parcial a
    LEFT JOIN ta_12_ctas_odoo b ON b.axo = EXTRACT(YEAR FROM CURRENT_DATE) AND b.cta_aplic = a.cuenta_apl
    JOIN ta_17_adeudos_div d ON d.id_adeudo = a.id_adeudo
    WHERE a.id_adeudo = p_id_adeudo
    ORDER BY a.id_desgloce;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_consdesgloce_get_cuentas_aplicacion
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de cuentas de aplicación para un año dado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consdesgloce_get_cuentas_aplicacion(p_year INTEGER)
RETURNS TABLE(
    cta_aplic INTEGER,
    descripcion VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT cta_aplic, descripcion
    FROM ta_12_ctas_odoo
    WHERE axo = p_year
    ORDER BY cta_aplic;
END;
$$ LANGUAGE plpgsql;

-- ============================================

