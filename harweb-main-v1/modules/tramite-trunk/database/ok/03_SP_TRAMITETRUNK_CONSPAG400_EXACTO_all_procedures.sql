-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - TRAMITE-TRUNK
-- Formulario: conspag400 (EXACTO del archivo original)
-- Archivo: 03_SP_TRAMITETRUNK_CONSPAG400_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_conspag400
-- Tipo: Report
-- Descripción: Consulta pagos del AS400 filtrando por recaud, urbrus y cuenta.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_conspag400(
    p_recaud integer,
    p_urbrus integer,
    p_cuenta integer
)
RETURNS TABLE (
    axopag smallint,
    mespag smallint,
    diapag smallint,
    ofnpag smallint,
    cajpag varchar(1),
    opepag integer,
    tpopag varchar(1),
    secpag smallint,
    recaud smallint,
    urbrus smallint,
    cuenta integer,
    mupio smallint,
    dsdpag smallint,
    hstpag smallint,
    impto double precision,
    flag smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        axopag, mespag, diapag, ofnpag, cajpag, opepag, tpopag, secpag, recaud, urbrus, cuenta, mupio, dsdpag, hstpag, impto, flag
    FROM tramitetrunk.pagos_400
    WHERE recaud = p_recaud AND urbrus = p_urbrus AND cuenta = p_cuenta;
END;
$$ LANGUAGE plpgsql;


-- ============================================