-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSMULPAGOS (EXACTO del archivo original)
-- Archivo: 85_SP_RECAUDADORA_CONSMULPAGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_list_pagos_multas
-- Tipo: Report
-- Descripción: Lista todos los pagos de multas con datos de multa y pago.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_list_pagos_multas()
RETURNS TABLE(
    cvepago integer,
    fecha date,
    recaud integer,
    caja varchar,
    folio integer,
    importe numeric,
    cajero varchar,
    contribuyente varchar,
    domicilio varchar,
    num_acta integer,
    axo_acta integer,
    id_dependencia integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.cvepago, p.fecha, p.recaud, p.caja, p.folio, p.importe, p.cajero, m.contribuyente, m.domicilio, m.num_acta, m.axo_acta, m.id_dependencia
    FROM pagos p
    INNER JOIN multas m ON p.cvepago = m.cvepago
    WHERE p.cveconcepto = 6
    ORDER BY p.fecha DESC, p.recaud, p.caja, p.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSMULPAGOS (EXACTO del archivo original)
-- Archivo: 85_SP_RECAUDADORA_CONSMULPAGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp_detail_pago_multa
-- Tipo: Report
-- Descripción: Devuelve el detalle completo de un pago de multa.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_detail_pago_multa(p_cvepago integer)
RETURNS TABLE(
    cvepago integer,
    fecha date,
    recaud integer,
    caja varchar,
    folio integer,
    importe numeric,
    cajero varchar,
    cveconcepto integer,
    contribuyente varchar,
    domicilio varchar,
    num_acta integer,
    axo_acta integer,
    id_dependencia integer,
    multa numeric,
    calificacion numeric,
    total numeric,
    observacion text
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.cvepago, p.fecha, p.recaud, p.caja, p.folio, p.importe, p.cajero, p.cveconcepto, m.contribuyente, m.domicilio, m.num_acta, m.axo_acta, m.id_dependencia, m.multa, m.calificacion, m.total, m.observacion
    FROM pagos p
    INNER JOIN multas m ON p.cvepago = m.cvepago
    WHERE p.cvepago = p_cvepago;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSMULPAGOS (EXACTO del archivo original)
-- Archivo: 85_SP_RECAUDADORA_CONSMULPAGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

