-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: CALCULORECARGOS (EXACTO del archivo original)
-- Archivo: 31_SP_CONVENIOS_CALCULORECARGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_get_contrato
-- Tipo: Catalog
-- Descripción: Obtiene los datos principales del contrato/convenio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_contrato(p_id_convenio INTEGER)
RETURNS TABLE(
    id_convenio INTEGER,
    pago_inicial NUMERIC,
    pago_quincenal NUMERIC,
    pagos_parciales INTEGER,
    fecha_vencimiento DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_convenio, pago_inicial, pago_quincenal, pagos_parciales, fecha_vencimiento
    FROM public.ta_17_convenios
    WHERE id_convenio = p_id_convenio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: CALCULORECARGOS (EXACTO del archivo original)
-- Archivo: 31_SP_CONVENIOS_CALCULORECARGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp_get_recargos
-- Tipo: CRUD
-- Descripción: Obtiene el porcentaje de recargos acumulado para el periodo dado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_recargos(
    p_alov INTEGER, p_mesv INTEGER, p_alo INTEGER, p_mes INTEGER, p_dia INTEGER, p_diav INTEGER
) RETURNS NUMERIC AS $$
DECLARE
    mes_limit INTEGER;
    porcentaje NUMERIC;
BEGIN
    IF p_dia <= p_diav THEN
        mes_limit := p_mes - 1;
    ELSE
        mes_limit := p_mes;
    END IF;
    SELECT SUM(porcentaje_parcial) INTO porcentaje
    FROM public.ta_13_recargosrcm
    WHERE (axo = p_alov AND mes >= p_mesv)
      OR (axo = p_alo AND mes <= mes_limit)
      OR (axo > p_alov AND axo < p_alo);
    RETURN COALESCE(porcentaje, 0);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: CALCULORECARGOS (EXACTO del archivo original)
-- Archivo: 31_SP_CONVENIOS_CALCULORECARGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

