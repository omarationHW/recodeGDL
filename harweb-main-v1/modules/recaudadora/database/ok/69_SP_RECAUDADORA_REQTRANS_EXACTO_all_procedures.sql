-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: REQTRANS (EXACTO del archivo original)
-- Archivo: 69_SP_RECAUDADORA_REQTRANS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: sp_reqtransm_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de requerimiento de transmisión patrimonial
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_reqtransm_create(
    p_folioreq integer,
    p_tipo varchar,
    p_cvecta integer,
    p_cveejec integer,
    p_fecemi date,
    p_importe numeric,
    p_recargos numeric,
    p_multas_ex numeric,
    p_multas_otr numeric,
    p_gastos numeric,
    p_gastos_req numeric,
    p_total numeric,
    p_observ text,
    p_usu_act varchar
) RETURNS integer AS $$
DECLARE
    v_id integer;
BEGIN
    INSERT INTO reqtransm (
        folioreq, tipo, cvecta, cveejec, fecemi, importe, recargos, multas_ex, multas_otr, gastos, gastos_req, total, observ, fecha_actual, usu_act, vigencia
    ) VALUES (
        p_folioreq, p_tipo, p_cvecta, p_cveejec, p_fecemi, p_importe, p_recargos, p_multas_ex, p_multas_otr, p_gastos, p_gastos_req, p_total, p_observ, now(), p_usu_act, 'V'
    ) RETURNING id INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: REQTRANS (EXACTO del archivo original)
-- Archivo: 69_SP_RECAUDADORA_REQTRANS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 3/5: sp_reqtransm_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de requerimiento de transmisión patrimonial
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_reqtransm_delete(p_id integer) RETURNS boolean AS $$
BEGIN
    DELETE FROM reqtransm WHERE id = p_id;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: REQTRANS (EXACTO del archivo original)
-- Archivo: 69_SP_RECAUDADORA_REQTRANS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 5/5: sp_reqtransm_folio_data
-- Tipo: CRUD
-- Descripción: Devuelve los datos generales de un folio de transmisión patrimonial
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_reqtransm_folio_data(p_foliotrans integer) RETURNS TABLE(
    *
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM datos_gral WHERE cvecuenta = (SELECT cvecuenta FROM actostransm WHERE folio = p_foliotrans);
END;
$$ LANGUAGE plpgsql;

-- ============================================

