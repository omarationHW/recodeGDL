-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: MANTPAGOSCONTRATOS (EXACTO del archivo original)
-- Archivo: 53_SP_CONVENIOS_MANTPAGOSCONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 1/7: sp_mantpagoscontratos_buscar_pago
-- Tipo: CRUD
-- Descripción: Busca un pago de contrato por fecha, oficina, caja y operación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_mantpagoscontratos_buscar_pago(
    p_fecha_pago DATE,
    p_oficina_pago SMALLINT,
    p_caja_pago VARCHAR,
    p_operacion_pago INTEGER
) RETURNS TABLE (
    id_pago INTEGER,
    id_convenio INTEGER,
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago VARCHAR,
    operacion_pago INTEGER,
    pago_parcial SMALLINT,
    total_parciales SMALLINT,
    importe NUMERIC,
    cve_descuento SMALLINT,
    cve_bonificacion SMALLINT,
    id_usuario INTEGER,
    fecha_actual TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public.ta_17_pagos
    WHERE fecha_pago = p_fecha_pago
      AND oficina_pago = p_oficina_pago
      AND caja_pago = p_caja_pago
      AND operacion_pago = p_operacion_pago;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: MANTPAGOSCONTRATOS (EXACTO del archivo original)
-- Archivo: 53_SP_CONVENIOS_MANTPAGOSCONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 3/7: sp_mantpagoscontratos_modificar_pago
-- Tipo: CRUD
-- Descripción: Modifica un pago de contrato existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_mantpagoscontratos_modificar_pago(
    p_colonia SMALLINT,
    p_calle SMALLINT,
    p_folio INTEGER,
    p_fecha_pago DATE,
    p_oficina_pago SMALLINT,
    p_caja_pago VARCHAR,
    p_operacion_pago INTEGER,
    p_pago_parcial SMALLINT,
    p_total_parciales SMALLINT,
    p_importe NUMERIC,
    p_cve_descuento SMALLINT,
    p_cve_bonificacion SMALLINT,
    p_id_usuario INTEGER
) RETURNS TABLE(status TEXT, message TEXT) AS $$
DECLARE
    v_id_convenio INTEGER;
    v_affected INTEGER;
BEGIN
    SELECT id_convenio INTO v_id_convenio
      FROM public.ta_17_convenios
      WHERE colonia = p_colonia AND calle = p_calle AND folio = p_folio;
    IF v_id_convenio IS NULL THEN
        RETURN QUERY SELECT 'error', 'No existe el contrato especificado';
        RETURN;
    END IF;
    UPDATE public.ta_17_pagos SET
        id_convenio = v_id_convenio,
        pago_parcial = p_pago_parcial,
        total_parciales = p_total_parciales,
        importe = p_importe,
        cve_descuento = NULLIF(p_cve_descuento, 0),
        cve_bonificacion = NULLIF(p_cve_bonificacion, 0),
        id_usuario = p_id_usuario,
        fecha_actual = CURRENT_TIMESTAMP
    WHERE fecha_pago = p_fecha_pago
      AND oficina_pago = p_oficina_pago
      AND caja_pago = p_caja_pago
      AND operacion_pago = p_operacion_pago;
    GET DIAGNOSTICS v_affected = ROW_COUNT;
    IF v_affected = 0 THEN
        RETURN QUERY SELECT 'error', 'No se encontró el pago para modificar';
    ELSE
        RETURN QUERY SELECT 'success', 'Pago modificado correctamente';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: MANTPAGOSCONTRATOS (EXACTO del archivo original)
-- Archivo: 53_SP_CONVENIOS_MANTPAGOSCONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 5/7: sp_mantpagoscontratos_buscar_contrato
-- Tipo: Catalog
-- Descripción: Busca un contrato por colonia, calle y folio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_mantpagoscontratos_buscar_contrato(
    p_colonia SMALLINT,
    p_calle SMALLINT,
    p_folio INTEGER
) RETURNS TABLE (
    id_convenio INTEGER,
    colonia SMALLINT,
    calle SMALLINT,
    folio INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_convenio, colonia, calle, folio
    FROM public.ta_17_convenios
    WHERE colonia = p_colonia AND calle = p_calle AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: MANTPAGOSCONTRATOS (EXACTO del archivo original)
-- Archivo: 53_SP_CONVENIOS_MANTPAGOSCONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 7/7: sp_mantpagoscontratos_listar_cajas
-- Tipo: Catalog
-- Descripción: Lista las cajas disponibles para una public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_mantpagoscontratos_listar_cajas(
    p_oficina_pago SMALLINT
) RETURNS TABLE (caja VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT caja FROM public.ta_12_cajas WHERE id_rec = p_oficina_pago ORDER BY caja;
END;
$$ LANGUAGE plpgsql;

-- ============================================

