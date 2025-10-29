-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: FrmEje
-- Generado: 2025-08-27 21:17:33
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_eje_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo ejecutor
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_eje_create(
    p_paterno TEXT,
    p_materno TEXT,
    p_nombres TEXT,
    p_rfc TEXT,
    p_recaud INTEGER,
    p_oficio TEXT,
    p_fecing DATE,
    p_fecinic DATE,
    p_fecterm DATE,
    p_capturista TEXT
) RETURNS TABLE(cveejecutor INTEGER) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO ejecutores (paterno, materno, nombres, rfc, recaud, oficio, fecing, fecinic, fecterm, capturista, vigente, feccap)
    VALUES (p_paterno, p_materno, p_nombres, p_rfc, p_recaud, p_oficio, p_fecing, p_fecinic, p_fecterm, p_capturista, 'V', NOW())
    RETURNING cveejecutor INTO new_id;
    RETURN QUERY SELECT new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_eje_update
-- Tipo: CRUD
-- Descripción: Actualiza un ejecutor existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_eje_update(
    p_id INTEGER,
    p_paterno TEXT,
    p_materno TEXT,
    p_nombres TEXT,
    p_rfc TEXT,
    p_recaud INTEGER,
    p_oficio TEXT,
    p_fecing DATE,
    p_fecinic DATE,
    p_fecterm DATE,
    p_capturista TEXT
) RETURNS TABLE(updated BOOLEAN) AS $$
BEGIN
    UPDATE ejecutores SET
        paterno = p_paterno,
        materno = p_materno,
        nombres = p_nombres,
        rfc = p_rfc,
        recaud = p_recaud,
        oficio = p_oficio,
        fecing = p_fecing,
        fecinic = p_fecinic,
        fecterm = p_fecterm,
        capturista = p_capturista,
        feccap = NOW()
    WHERE cveejecutor = p_id;
    RETURN QUERY SELECT FOUND();
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_eje_delete
-- Tipo: CRUD
-- Descripción: Elimina un ejecutor (baja lógica)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_eje_delete(p_id INTEGER) RETURNS TABLE(deleted BOOLEAN) AS $$
BEGIN
    UPDATE ejecutores SET vigente = 'C', fecbaj = NOW() WHERE cveejecutor = p_id;
    RETURN QUERY SELECT FOUND();
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_eje_report
-- Tipo: Report
-- Descripción: Reporte de ejecutores por rango de fechas y recaudadora
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_eje_report(
    p_fecha_inicio DATE,
    p_fecha_fin DATE,
    p_recaud INTEGER
) RETURNS TABLE(
    cveejecutor INTEGER,
    paterno TEXT,
    materno TEXT,
    nombres TEXT,
    rfc TEXT,
    recaud INTEGER,
    oficio TEXT,
    fecing DATE,
    fecinic DATE,
    fecterm DATE,
    vigente TEXT,
    feccap DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT cveejecutor, paterno, materno, nombres, rfc, recaud, oficio, fecing, fecinic, fecterm, vigente, feccap
    FROM ejecutores
    WHERE (p_fecha_inicio IS NULL OR fecing >= p_fecha_inicio)
      AND (p_fecha_fin IS NULL OR fecing <= p_fecha_fin)
      AND (p_recaud IS NULL OR recaud = p_recaud)
    ORDER BY cveejecutor;
END;
$$ LANGUAGE plpgsql;

-- ============================================

