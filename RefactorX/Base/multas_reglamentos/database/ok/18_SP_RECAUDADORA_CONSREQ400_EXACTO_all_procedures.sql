-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ConsReq400 (Consulta Requerimientos 400)
-- Generado: 2025-08-26 23:40:16
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_get_consreq400
-- Tipo: Report
-- Descripción: Obtiene los requerimientos del AS-400 filtrando por recaudadora (ofnar), tpr y cuenta (ctarfc). Equivalente al query de Delphi.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_consreq400(
    p_ofnar VARCHAR,
    p_tpr VARCHAR,
    p_ctarfc VARCHAR
)
RETURNS TABLE (
    folreq VARCHAR,
    fecent1 VARCHAR,
    fecent2 VARCHAR,
    prareq VARCHAR,
    fecpra VARCHAR,
    horapra VARCHAR,
    feccita VARCHAR,
    horacit VARCHAR,
    vigreq VARCHAR,
    ejereq VARCHAR,
    dilreq VARCHAR,
    fecreq VARCHAR,
    fecpagr VARCHAR,
    ofnpagr VARCHAR,
    cajpag VARCHAR,
    opepagr VARCHAR,
    actreq VARCHAR,
    observr VARCHAR,
    axodesr VARCHAR,
    mesdesr VARCHAR,
    axohasr VARCHAR,
    meshasr VARCHAR,
    cvelet VARCHAR,
    cvenum VARCHAR,
    mesgas VARCHAR,
    zonreq VARCHAR,
    impgas VARCHAR,
    impcuo VARCHAR,
    cvesecr VARCHAR,
    cveremr VARCHAR,
    fecremr VARCHAR,
    mulreq VARCHAR,
    grabo02 VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.folreq, r.fecent1, r.fecent2, r.prareq, r.fecpra, r.horapra,
        r.feccita, r.horacit, r.vigreq, r.ejereq, r.dilreq, r.fecreq,
        r.fecpagr, r.ofnpagr, r.cajpag, r.opepagr, r.actreq, r.observr,
        r.axodesr, r.mesdesr, r.axohasr, r.meshasr, r.cvelet, r.cvenum,
        r.mesgas, r.zonreq, r.impgas, r.impcuo, r.cvesecr, r.cveremr,
        r.fecremr, r.mulreq, r.grabo02
    FROM public.req_400 r
    WHERE r.ofnar = p_ofnar
      AND r.tpr = p_tpr
      AND r.ctarfc = p_ctarfc;
END;
$$ LANGUAGE plpgsql;

-- ============================================