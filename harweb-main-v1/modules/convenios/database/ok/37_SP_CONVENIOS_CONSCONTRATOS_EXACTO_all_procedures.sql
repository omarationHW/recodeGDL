-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: CONSCONTRATOS (EXACTO del archivo original)
-- Archivo: 37_SP_CONVENIOS_CONSCONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_cons_contratos_search_by_contrato
-- Tipo: Report
-- Descripción: Busca contratos por Colonia, Calle y Folio (mínimo)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cons_contratos_search_by_contrato(p_colonia integer, p_calle integer, p_folio integer)
RETURNS TABLE(
    id_convenio integer,
    colonia smallint,
    calle smallint,
    folio integer,
    nombre varchar,
    desc_calle varchar,
    numero varchar,
    tipo_casa varchar,
    mtrs_frente float,
    mtrs_ancho float,
    metros2 float,
    entre_calle_1 varchar,
    entre_calle_2 varchar,
    pago_total numeric,
    pago_inicial numeric,
    pago_quincenal numeric,
    pagos_parciales smallint,
    fecha_firma date,
    fecha_vencimiento date,
    escritura varchar,
    propiedad varchar,
    compro_dom varchar,
    otros varchar,
    observacion varchar,
    fecha_impresion date,
    fecha_rev date,
    fecha_cancelado date,
    vigencia varchar,
    id_usuario integer,
    fecha_actual timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public.ta_17_convenios
    WHERE colonia = COALESCE(NULLIF(p_colonia, 0), colonia)
      AND calle = COALESCE(NULLIF(p_calle, 0), calle)
      AND folio >= COALESCE(NULLIF(p_folio, 0), folio)
    ORDER BY colonia ASC, calle ASC, folio ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: CONSCONTRATOS (EXACTO del archivo original)
-- Archivo: 37_SP_CONVENIOS_CONSCONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp_cons_contratos_search_by_domicilio
-- Tipo: Report
-- Descripción: Busca contratos por descripción de calle y número (LIKE)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cons_contratos_search_by_domicilio(p_desc_calle varchar, p_numero varchar)
RETURNS TABLE(
    id_convenio integer,
    colonia smallint,
    calle smallint,
    folio integer,
    nombre varchar,
    desc_calle varchar,
    numero varchar,
    tipo_casa varchar,
    mtrs_frente float,
    mtrs_ancho float,
    metros2 float,
    entre_calle_1 varchar,
    entre_calle_2 varchar,
    pago_total numeric,
    pago_inicial numeric,
    pago_quincenal numeric,
    pagos_parciales smallint,
    fecha_firma date,
    fecha_vencimiento date,
    escritura varchar,
    propiedad varchar,
    compro_dom varchar,
    otros varchar,
    observacion varchar,
    fecha_impresion date,
    fecha_rev date,
    fecha_cancelado date,
    vigencia varchar,
    id_usuario integer,
    fecha_actual timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public.ta_17_convenios
    WHERE desc_calle ILIKE '%' || p_desc_calle || '%'
      AND numero ILIKE '%' || p_numero || '%'
    ORDER BY desc_calle ASC, numero ASC, colonia ASC, calle ASC, folio ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: CONSCONTRATOS (EXACTO del archivo original)
-- Archivo: 37_SP_CONVENIOS_CONSCONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

