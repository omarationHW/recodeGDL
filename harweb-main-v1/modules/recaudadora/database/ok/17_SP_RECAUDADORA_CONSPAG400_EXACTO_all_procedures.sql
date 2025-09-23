-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ConsPag400 (Consulta Pagos 400)
-- Generado: 2025-08-26 23:38:10
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_pagos_400_by_recaud_ur_cuenta
-- Tipo: Report
-- Descripción: Obtiene los registros de pagos_400 filtrando por recaud, urbrus y cuenta.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_pagos_400_by_recaud_ur_cuenta(
    p_recaud integer,
    p_ur integer,
    p_cuenta integer
)
RETURNS TABLE (
    axopag smallint,
    mespag smallint,
    diapag smallint,
    ofnpag smallint,
    cajpag varchar,
    opepag integer,
    tpopag varchar,
    secpag smallint,
    recaud smallint,
    urbrus smallint,
    cuenta integer,
    mupio smallint,
    dsdpag smallint,
    hstpag smallint,
    impto float,
    flag smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.axopag, p.mespag, p.diapag, p.ofnpag, p.cajpag, p.opepag, 
        p.tpopag, p.secpag, p.recaud, p.urbrus, p.cuenta, p.mupio, 
        p.dsdpag, p.hstpag, p.impto, p.flag
    FROM public.pagos_400 p
    WHERE p.recaud = p_recaud AND p.urbrus = p_ur AND p.cuenta = p_cuenta;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_trasp_400_by_recaud_ur_cuenta
-- Tipo: Report
-- Descripción: Obtiene los registros de trasp_400 filtrando por rect, urt y ctat.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_trasp_400_by_recaud_ur_cuenta(
    p_recaud integer,
    p_ur integer,
    p_cuenta integer
)
RETURNS TABLE (
    tafol smallint,
    tfol integer,
    rect smallint,
    urt smallint,
    ctat integer,
    tncta smallint,
    tfepag integer,
    topag smallint,
    tcpag varchar,
    toppag integer,
    tlug varchar,
    tspag smallint,
    tdsdpag smallint,
    thstpag smallint,
    timpto float,
    tflag1 smallint,
    tflag2 smallint,
    tcapto varchar,
    tfecha integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.tafol, t.tfol, t.rect, t.urt, t.ctat, t.tncta, t.tfepag, 
        t.topag, t.tcpag, t.toppag, t.tlug, t.tspag, t.tdsdpag, 
        t.thstpag, t.timpto, t.tflag1, t.tflag2, t.tcapto, t.tfecha
    FROM public.trasp_400 t
    WHERE t.rect = p_recaud AND t.urt = p_ur AND t.ctat = p_cuenta;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_pagos_400_by_anio_folio
-- Tipo: Report
-- Descripción: Obtiene los registros de pagos_400 para recaud = 0, urbrus = 9, cuenta = 0 (por comprobante, usando año y folio).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_pagos_400_by_anio_folio(
    p_anio integer,
    p_folio integer
)
RETURNS TABLE (
    axopag smallint,
    mespag smallint,
    diapag smallint,
    ofnpag smallint,
    cajpag varchar,
    opepag integer,
    tpopag varchar,
    secpag smallint,
    recaud smallint,
    urbrus smallint,
    cuenta integer,
    mupio smallint,
    dsdpag smallint,
    hstpag smallint,
    impto float,
    flag smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.axopag, p.mespag, p.diapag, p.ofnpag, p.cajpag, p.opepag, 
        p.tpopag, p.secpag, p.recaud, p.urbrus, p.cuenta, p.mupio, 
        p.dsdpag, p.hstpag, p.impto, p.flag
    FROM public.pagos_400 p
    WHERE p.recaud = 0 AND p.urbrus = 9 AND p.cuenta = 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_trasp_400_by_anio_folio
-- Tipo: Report
-- Descripción: Obtiene los registros de trasp_400 filtrando por tafol (año) y tfol (folio).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_trasp_400_by_anio_folio(
    p_anio integer,
    p_folio integer
)
RETURNS TABLE (
    tafol smallint,
    tfol integer,
    rect smallint,
    urt smallint,
    ctat integer,
    tncta smallint,
    tfepag integer,
    topag smallint,
    tcpag varchar,
    toppag integer,
    tlug varchar,
    tspag smallint,
    tdsdpag smallint,
    thstpag smallint,
    timpto float,
    tflag1 smallint,
    tflag2 smallint,
    tcapto varchar,
    tfecha integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.tafol, t.tfol, t.rect, t.urt, t.ctat, t.tncta, t.tfepag, 
        t.topag, t.tcpag, t.toppag, t.tlug, t.tspag, t.tdsdpag, 
        t.thstpag, t.timpto, t.tflag1, t.tflag2, t.tcapto, t.tfecha
    FROM public.trasp_400 t
    WHERE t.tafol = p_anio AND t.tfol = p_folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_obs_can_400_by_folio_anio
-- Tipo: Report
-- Descripción: Obtiene los registros de obs_can_400 filtrando por tofol (folio) y toafol (año).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_obs_can_400_by_folio_anio(
    p_tfol integer,
    p_tafol smallint
)
RETURNS TABLE (
    tofol integer,
    toafol smallint,
    torec smallint,
    tocta integer,
    toncta smallint,
    toimpde float,
    tobser1 varchar,
    tobser2 varchar,
    tobser3 varchar,
    tobser4 varchar,
    tcapt varchar,
    tfech integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.tofol, o.toafol, o.torec, o.tocta, o.toncta, o.toimpde,
        o.tobser1, o.tobser2, o.tobser3, o.tobser4, o.tcapt, o.tfech
    FROM public.obs_can_400 o
    WHERE o.tofol = p_tfol AND o.toafol = p_tafol;
END;
$$ LANGUAGE plpgsql;

-- ============================================