-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ConsReq400
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
        folreq,
        fecent1,
        fecent2,
        prareq,
        fecpra,
        horapra,
        feccita,
        horacit,
        vigreq,
        ejereq,
        dilreq,
        fecreq,
        fecpagr,
        ofnpagr,
        cajpag,
        opepagr,
        actreq,
        observr,
        axodesr,
        mesdesr,
        axohasr,
        meshasr,
        cvelet,
        cvenum,
        mesgas,
        zonreq,
        impgas,
        impcuo,
        cvesecr,
        cveremr,
        fecremr,
        mulreq,
        grabo02
    FROM req_400
    WHERE ofnar = p_ofnar
      AND tpr = p_tpr
      AND ctarfc = p_ctarfc;
END;
$$ LANGUAGE plpgsql;

-- ============================================

