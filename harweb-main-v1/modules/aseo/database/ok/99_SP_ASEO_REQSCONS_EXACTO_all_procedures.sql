-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: REQSCONS (EXACTO del archivo original)
-- Archivo: 99_SP_ASEO_REQSCONS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 1/7: sp_pagar_apremio
-- Tipo: CRUD
-- Descripción: Marca un apremio como pagado, actualizando los campos de pago.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_pagar_apremio(
    p_fecha DATE,
    p_id_rec INTEGER,
    p_caja VARCHAR,
    p_operacion INTEGER,
    p_importe_gastos NUMERIC,
    p_id_control INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public.ta_15_apremios
    SET fecha_pago = p_fecha,
        recaudadora = p_id_rec,
        caja = p_caja,
        operacion = p_operacion,
        vigencia = '2',
        clave_mov = 'P',
        importe_pago = p_importe_gastos
    WHERE id_control = p_id_control;
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: REQSCONS (EXACTO del archivo original)
-- Archivo: 99_SP_ASEO_REQSCONS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 3/7: sp_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de recaudadoras.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE(id_rec INTEGER, recaudadora VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT id_rec, recaudadora FROM public.ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: REQSCONS (EXACTO del archivo original)
-- Archivo: 99_SP_ASEO_REQSCONS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 5/7: sp_buscar_apremios
-- Tipo: CRUD
-- Descripción: Busca los apremios de un contrato.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_apremios(p_control_contrato INTEGER)
RETURNS TABLE(id_control INTEGER, folio INTEGER, importe_multa NUMERIC, importe_recargo NUMERIC, importe_gastos NUMERIC, fecha_emision DATE, fecha_practicado DATE, vigencia VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT id_control, folio, importe_multa, importe_recargo, importe_gastos, fecha_emision, fecha_practicado, vigencia FROM public.ta_15_apremios WHERE modulo = 16 AND control_otr = p_control_contrato AND vigencia = '1' AND clave_practicado = 'P' ORDER BY folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: REQSCONS (EXACTO del archivo original)
-- Archivo: 99_SP_ASEO_REQSCONS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 7/7: sp_buscar_convenio
-- Tipo: CRUD
-- Descripción: Busca el convenio relacionado a un contrato.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_convenio(p_idlc INTEGER)
RETURNS TABLE(convenio VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT (trim(d.letras_exp)||'/'||d.numero_exp||'/'||d.axo_exp) convenio FROM public.ta_17_referencia a, ta_17_conv_d_resto b, ta_17_conv_diverso d WHERE a.id_referencia = p_idlc AND a.modulo = 16 AND b.id_conv_resto = a.id_conv_resto AND b.vigencia = 'A' AND d.tipo = b.tipo AND d.id_conv_diver = b.id_conv_diver;
END;
$$ LANGUAGE plpgsql;

-- ============================================

