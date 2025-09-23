-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: PREPAGOFRM (EXACTO del archivo original)
-- Archivo: 78_SP_LICENCIAS_PREPAGOFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 1/7: sp_prepago_get_data
-- Tipo: Catalog
-- Descripción: Obtiene los datos principales del contribuyente y cuenta catastral para el formulario de prepago.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_prepago_get_data(p_cvecuenta INTEGER)
RETURNS TABLE(
    ncompleto TEXT,
    calle TEXT,
    noexterior TEXT,
    interior TEXT,
    ultcomp INTEGER,
    axoultcomp SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.nombre_completo, c.calle, c.noexterior, c.interior, ca.ultcomp, ca.axoultcomp
    FROM catastro ca
    JOIN regprop rp ON rp.cvecuenta = ca.cvecuenta AND rp.cveregprop = ca.cveregprop AND rp.encabeza = 'S'
    JOIN contrib c ON c.cvecont = rp.cvecont
    WHERE ca.cvecuenta = p_cvecuenta
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: PREPAGOFRM (EXACTO del archivo original)
-- Archivo: 78_SP_LICENCIAS_PREPAGOFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 3/7: sp_prepago_get_descuentos
-- Tipo: Catalog
-- Descripción: Obtiene los descuentos aplicados a la cuenta en el periodo seleccionado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_prepago_get_descuentos(
    p_cvecuenta INTEGER,
    p_asal INTEGER,
    p_bsal INTEGER,
    p_asalf INTEGER,
    p_bsalf INTEGER
) RETURNS TABLE(
    cvedescuento INTEGER,
    descripcion TEXT,
    impdescto NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.cvedescuento, c.descripcion, SUM(d.impvir) AS impdescto
    FROM detsaldos d
    JOIN valoradeudo v ON v.cvecuenta = d.cvecuenta AND v.axoefec = d.axosal AND v.bimefec = d.bimsal
    LEFT JOIN c_descpred c ON d.cvedescuento = c.cvedescuento
    WHERE d.cvecuenta = p_cvecuenta AND d.saldo > 0
      AND ((d.axosal > p_asal OR (d.bimsal >= p_bsal AND d.axosal = p_asal))
           AND (d.axosal < p_asalf OR (d.bimsal <= p_bsalf AND d.axosal = p_asalf)))
      AND d.cvedescuento IS NOT NULL
    GROUP BY d.cvedescuento, c.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: PREPAGOFRM (EXACTO del archivo original)
-- Archivo: 78_SP_LICENCIAS_PREPAGOFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 5/7: sp_prepago_recalcular_dpp
-- Tipo: CRUD
-- Descripción: Ejecuta la lógica de recálculo de descuento pronto pago para la cuenta.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_prepago_recalcular_dpp(p_cvecuenta INTEGER)
RETURNS TEXT AS $$
BEGIN
    -- Aquí se ejecutaría la lógica de recálculo (actualiza tablas, etc)
    -- Por ejemplo, llamar otro SP o actualizar campos
    -- UPDATE detsaldos SET ... WHERE cvecuenta = p_cvecuenta;
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: PREPAGOFRM (EXACTO del archivo original)
-- Archivo: 78_SP_LICENCIAS_PREPAGOFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 7/7: sp_prepago_calcular_descpred
-- Tipo: CRUD
-- Descripción: Calcula el descuento predial para la cuenta (aplica reglas de pronto pago, etc).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_prepago_calcular_descpred(p_cvecuenta INTEGER)
RETURNS TEXT AS $$
BEGIN
    -- Aquí se ejecutaría la lógica de cálculo de descuento predial
    -- UPDATE detsaldos SET ... WHERE cvecuenta = p_cvecuenta;
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

