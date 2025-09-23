-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ConsTPat400 (Consulta Transmisiones Patrimoniales 400)
-- Generado: 2025-08-26 23:45:50
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_consultar_pagos_tpat400
-- Tipo: Report
-- Descripción: Consulta pagos de transmisiones patrimoniales en pagotransm_400 según filtros.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consultar_pagos_tpat400(
    p_fec_pag integer,
    p_rec_pag smallint DEFAULT NULL,
    p_cajpag varchar DEFAULT NULL,
    p_opc_pag smallint DEFAULT NULL
)
RETURNS TABLE (
    recaud smallint,
    mpio smallint,
    cuenta integer,
    cvecatnva varchar,
    notario varchar,
    not_mpio varchar,
    not_num smallint,
    suplente varchar,
    num_esc integer,
    fec_esc integer,
    fec_otorg integer,
    tipo_tran smallint,
    adquiriente varchar,
    sector varchar,
    valor_tran float,
    por_tran smallint,
    imp_tran float,
    tasa_tran smallint,
    rec_tran float,
    mul_tran float,
    gtos_tran float,
    fec_pag integer,
    rec_pag smallint,
    cajpag varchar,
    opc_pag smallint,
    lug_pag varchar,
    tot_pag integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.recaud, p.mpio, p.cuenta, p.cvecatnva, p.notario, p.not_mpio,
        p.not_num, p.suplente, p.num_esc, p.fec_esc, p.fec_otorg, p.tipo_tran,
        p.adquiriente, p.sector, p.valor_tran, p.por_tran, p.imp_tran, p.tasa_tran,
        p.rec_tran, p.mul_tran, p.gtos_tran, p.fec_pag, p.rec_pag, p.cajpag,
        p.opc_pag, p.lug_pag, p.tot_pag
    FROM public.pagotransm_400 p
    WHERE p.fec_pag = p_fec_pag
      AND (p_rec_pag IS NULL OR p.rec_pag = p_rec_pag)
      AND (p_cajpag IS NULL OR p.cajpag = p_cajpag)
      AND (p_opc_pag IS NULL OR p.opc_pag = p_opc_pag);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_consultar_detalle_tpat400
-- Tipo: Report
-- Descripción: Consulta detalle de transmisión patrimonial en transm_400 según filtros.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consultar_detalle_tpat400(
    p_fecha integer,
    p_recaud smallint,
    p_caja varchar,
    p_folio smallint,
    p_lug varchar
)
RETURNS TABLE (
    fecha integer,
    recaud smallint,
    caja varchar,
    folio integer,
    lug varchar,
    importe float,
    imp1 float,
    cta_apli1 integer,
    imp2 float,
    cta_apli2 integer,
    imp3 float,
    cta_apli3 integer,
    imp4 float,
    cta_apli4 integer,
    imp5 float,
    cta_apli5 integer,
    imp6 float,
    cta_apli6 integer,
    imp7 float,
    cta_apli7 integer,
    imp8 float,
    ctaapli8 integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.fecha, t.recaud, t.caja, t.folio, t.lug, t.importe,
        t.imp1, t.cta_apli1, t.imp2, t.cta_apli2, t.imp3, t.cta_apli3,
        t.imp4, t.cta_apli4, t.imp5, t.cta_apli5, t.imp6, t.cta_apli6,
        t.imp7, t.cta_apli7, t.imp8, t.ctaapli8
    FROM public.transm_400 t
    WHERE t.fecha = p_fecha
      AND t.recaud = p_recaud
      AND t.caja = p_caja
      AND t.folio = p_folio
      AND t.lug = p_lug;
END;
$$ LANGUAGE plpgsql;

-- ============================================