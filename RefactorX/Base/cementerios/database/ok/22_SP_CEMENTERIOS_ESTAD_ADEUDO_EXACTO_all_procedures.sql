-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: ESTAD_ADEUDO (EXACTO del archivo original)
-- Archivo: 22_SP_CEMENTERIOS_ESTAD_ADEUDO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_estad_adeudo_resumen
-- Tipo: Report
-- Descripción: Devuelve el resumen de adeudos por cementerio y año (UAP, cuenta).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_estad_adeudo_resumen()
RETURNS TABLE(
    cementerio VARCHAR,
    uap INTEGER,
    cuenta INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT cementerio, (axo_pagado-5) AS uap, COUNT(*) AS cuenta
    FROM public.ta_13_datosrcm
    GROUP BY cementerio, (axo_pagado-5)
    ORDER BY cementerio, uap;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: ESTAD_ADEUDO (EXACTO del archivo original)
-- Archivo: 22_SP_CEMENTERIOS_ESTAD_ADEUDO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

