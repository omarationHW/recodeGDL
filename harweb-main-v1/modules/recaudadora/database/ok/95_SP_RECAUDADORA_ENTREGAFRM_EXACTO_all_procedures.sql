-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: ENTREGAFRM (EXACTO del archivo original)
-- Archivo: 95_SP_RECAUDADORA_ENTREGAFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_asignar_requerimiento
-- Tipo: CRUD
-- Descripción: Asigna un requerimiento a un ejecutor y actualiza los contadores de asignados/pendientes.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_asignar_requerimiento(
    p_folio INTEGER,
    p_recaud INTEGER,
    p_cveejecutor INTEGER,
    p_fecha DATE,
    p_usuario VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE reqpredial
    SET cveejecut = p_cveejecutor,
        fecejec = p_fecha,
        capturista = p_usuario,
        feccap = NOW()
    WHERE folioreq = p_folio AND recaud = p_recaud;
    -- Actualiza detalle ejecutor
    UPDATE detejecutor
    SET asignados = asignados + 1,
        pendientes = pendientes + 1,
        ultfec_entrega = NOW()
    WHERE cveejecutor = p_cveejecutor AND recaud = p_recaud;
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: ENTREGAFRM (EXACTO del archivo original)
-- Archivo: 95_SP_RECAUDADORA_ENTREGAFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp_listar_requerimientos_ejecutor
-- Tipo: Report
-- Descripción: Lista los requerimientos asignados a un ejecutor en una fecha y public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_listar_requerimientos_ejecutor(
    p_cveejecutor INTEGER,
    p_recaud INTEGER,
    p_fecha DATE
) RETURNS TABLE (
    folioreq INTEGER,
    cvecuenta INTEGER,
    impuesto NUMERIC,
    recargos NUMERIC,
    gastos NUMERIC,
    multas NUMERIC,
    total NUMERIC
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT folioreq, cvecuenta, impuesto, recargos, gastos, multas, total
    FROM reqpredial
    WHERE cveejecut = p_cveejecutor AND recaud = p_recaud AND fecejec = p_fecha;
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: ENTREGAFRM (EXACTO del archivo original)
-- Archivo: 95_SP_RECAUDADORA_ENTREGAFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

