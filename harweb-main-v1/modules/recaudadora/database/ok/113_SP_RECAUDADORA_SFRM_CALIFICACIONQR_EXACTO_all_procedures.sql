-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: SFRM_CALIFICACIONQR (EXACTO del archivo original)
-- Archivo: 113_SP_RECAUDADORA_SFRM_CALIFICACIONQR_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_get_calificacion_qr
-- Tipo: Report
-- Descripción: Obtiene los datos principales de la multa para impresión QR
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_calificacion_qr(p_id_multa integer)
RETURNS TABLE (
    id_multa integer,
    id_dependencia smallint,
    axo_acta smallint,
    num_acta integer,
    fecha_acta date,
    fecha_cancelacion date,
    contribuyente varchar,
    domicilio varchar,
    recaud smallint,
    num_licencia integer,
    giro varchar,
    calificacion numeric,
    multa numeric,
    gastos numeric,
    total numeric,
    cvepago integer,
    capturista varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_multa, id_dependencia, axo_acta, num_acta, fecha_acta, fecha_cancelacion, contribuyente, domicilio, recaud, num_licencia, giro, calificacion, multa, gastos, total, cvepago, capturista
    FROM multas
    WHERE id_multa = p_id_multa;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: SFRM_CALIFICACIONQR (EXACTO del archivo original)
-- Archivo: 113_SP_RECAUDADORA_SFRM_CALIFICACIONQR_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

