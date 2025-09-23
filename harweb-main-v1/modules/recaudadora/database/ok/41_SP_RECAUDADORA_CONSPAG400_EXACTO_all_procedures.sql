-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSPAG400 (EXACTO del archivo original)
-- Archivo: 41_SP_RECAUDADORA_CONSPAG400_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
    SELECT * FROM pagos_400
    WHERE recaud = p_recaud AND urbrus = p_ur AND cuenta = p_cuenta;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSPAG400 (EXACTO del archivo original)
-- Archivo: 41_SP_RECAUDADORA_CONSPAG400_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
    SELECT * FROM pagos_400
    WHERE recaud = 0 AND urbrus = 9 AND cuenta = 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSPAG400 (EXACTO del archivo original)
-- Archivo: 41_SP_RECAUDADORA_CONSPAG400_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
    SELECT * FROM obs_can_400
    WHERE tofol = p_tfol AND toafol = p_tafol;
END;
$$ LANGUAGE plpgsql;

-- ============================================

