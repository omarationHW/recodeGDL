-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: entregafrm
-- Generado: 2025-08-27 11:57:32
-- Total SPs: 4
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

-- SP 2/4: sp_quitar_requerimiento
-- Tipo: CRUD
-- Descripción: Quita la asignación de un requerimiento a un ejecutor y actualiza los contadores.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_quitar_requerimiento(
    p_folio INTEGER,
    p_recaud INTEGER,
    p_cveejecutor INTEGER,
    p_usuario VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE reqpredial
    SET cveejecut = NULL,
        fecejec = NULL,
        capturista = p_usuario,
        feccap = NOW()
    WHERE folioreq = p_folio AND recaud = p_recaud AND cveejecut = p_cveejecutor;
    -- Actualiza detalle ejecutor
    UPDATE detejecutor
    SET asignados = GREATEST(asignados - 1, 0),
        pendientes = GREATEST(pendientes - 1, 0)
    WHERE cveejecutor = p_cveejecutor AND recaud = p_recaud;
END;
$$;

-- ============================================

-- SP 3/4: sp_listar_requerimientos_ejecutor
-- Tipo: Report
-- Descripción: Lista los requerimientos asignados a un ejecutor en una fecha y recaudadora.
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

-- SP 4/4: sp_buscar_ejecutor
-- Tipo: Catalog
-- Descripción: Busca ejecutores por número o nombre.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_ejecutor(
    p_criterio TEXT,
    p_tipo TEXT
) RETURNS TABLE (
    cveejecutor INTEGER,
    paterno TEXT,
    materno TEXT,
    nombres TEXT,
    recaud INTEGER,
    ncompleto TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    IF p_tipo = 'numero' THEN
        RETURN QUERY SELECT cveejecutor, paterno, materno, nombres, recaud, TRIM(paterno)||' '||TRIM(materno)||' '||TRIM(nombres) as ncompleto
        FROM ejecutor WHERE cveejecutor = p_criterio::INTEGER;
    ELSE
        RETURN QUERY SELECT cveejecutor, paterno, materno, nombres, recaud, TRIM(paterno)||' '||TRIM(materno)||' '||TRIM(nombres) as ncompleto
        FROM ejecutor WHERE (TRIM(paterno)||' '||TRIM(materno)||' '||TRIM(nombres)) ILIKE '%'||p_criterio||'%';
    END IF;
END;
$$;

-- ============================================

