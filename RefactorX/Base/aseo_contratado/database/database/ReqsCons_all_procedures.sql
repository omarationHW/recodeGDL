-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ReqsCons
-- Generado: 2025-08-27 20:45:14
-- Total SPs: 7
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
    UPDATE ta_15_apremios
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

-- SP 2/7: sp_get_tipo_aseo
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de tipos de aseo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tipo_aseo()
RETURNS TABLE(ctrol_aseo INTEGER, tipo_aseo VARCHAR, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion FROM ta_16_tipo_aseo ORDER BY ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/7: sp_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de recaudadoras.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE(id_rec INTEGER, recaudadora VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/7: sp_buscar_contrato
-- Tipo: CRUD
-- Descripción: Busca un contrato por número y tipo de aseo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_contrato(p_num_contrato INTEGER, p_ctrol_aseo INTEGER)
RETURNS TABLE(control_contrato INTEGER, status_vigencia VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT control_contrato, status_vigencia FROM ta_16_contratos WHERE num_contrato = p_num_contrato AND ctrol_aseo = p_ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/7: sp_buscar_apremios
-- Tipo: CRUD
-- Descripción: Busca los apremios de un contrato.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_apremios(p_control_contrato INTEGER)
RETURNS TABLE(id_control INTEGER, folio INTEGER, importe_multa NUMERIC, importe_recargo NUMERIC, importe_gastos NUMERIC, fecha_emision DATE, fecha_practicado DATE, vigencia VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT id_control, folio, importe_multa, importe_recargo, importe_gastos, fecha_emision, fecha_practicado, vigencia FROM ta_15_apremios WHERE modulo = 16 AND control_otr = p_control_contrato AND vigencia = '1' AND clave_practicado = 'P' ORDER BY folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/7: sp_buscar_periodos_apremio
-- Tipo: CRUD
-- Descripción: Busca los periodos de un apremio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_periodos_apremio(p_id_apremio INTEGER)
RETURNS TABLE(id_control INTEGER, control_otr INTEGER, ayo SMALLINT, periodo SMALLINT, importe NUMERIC, recargos NUMERIC, cantidad NUMERIC, tipo INTEGER) AS $$
BEGIN
    RETURN QUERY SELECT id_control, control_otr, ayo, periodo, importe, recargos, cantidad, tipo FROM ta_15_periodos WHERE control_otr = p_id_apremio ORDER BY ayo, periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/7: sp_buscar_convenio
-- Tipo: CRUD
-- Descripción: Busca el convenio relacionado a un contrato.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_convenio(p_idlc INTEGER)
RETURNS TABLE(convenio VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT (trim(d.letras_exp)||'/'||d.numero_exp||'/'||d.axo_exp) convenio FROM ta_17_referencia a, ta_17_conv_d_resto b, ta_17_conv_diverso d WHERE a.id_referencia = p_idlc AND a.modulo = 16 AND b.id_conv_resto = a.id_conv_resto AND b.vigencia = 'A' AND d.tipo = b.tipo AND d.id_conv_diver = b.id_conv_diver;
END;
$$ LANGUAGE plpgsql;

-- ============================================

