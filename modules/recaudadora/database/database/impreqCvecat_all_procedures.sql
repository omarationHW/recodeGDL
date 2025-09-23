-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: impreqCvecat
-- Generado: 2025-08-27 21:20:48
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_asignar_requerimientos
-- Tipo: CRUD
-- Descripción: Asigna requerimientos a un ejecutor en un rango de folios
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_asignar_requerimientos(
    p_recaud INTEGER, p_folioini INTEGER, p_foliofin INTEGER, p_ejecutor INTEGER, p_fecha DATE
) RETURNS TABLE(folio INTEGER, status TEXT) AS $$
BEGIN
    UPDATE reqpredial
    SET cveejecut = p_ejecutor, fecejec = p_fecha
    WHERE recaud = p_recaud AND folioreq BETWEEN p_folioini AND p_foliofin AND vigencia = 'V';
    RETURN QUERY SELECT folioreq, 'asignado' FROM reqpredial WHERE recaud = p_recaud AND folioreq BETWEEN p_folioini AND p_foliofin;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_marcar_impresos
-- Tipo: CRUD
-- Descripción: Marca como impresos los requerimientos seleccionados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_marcar_impresos(
    p_recaud INTEGER, p_folioini INTEGER, p_foliofin INTEGER, p_usuario TEXT
) RETURNS TABLE(folio INTEGER, status TEXT) AS $$
BEGIN
    UPDATE reqpredial
    SET impreso = 'S', feccap = NOW(), capturista = p_usuario
    WHERE recaud = p_recaud AND folioreq BETWEEN p_folioini AND p_foliofin AND vigencia = 'V';
    RETURN QUERY SELECT folioreq, 'impreso' FROM reqpredial WHERE recaud = p_recaud AND folioreq BETWEEN p_folioini AND p_foliofin;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_lista_ejecutores
-- Tipo: Catalog
-- Descripción: Lista ejecutores disponibles para una recaudadora y fecha
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_lista_ejecutores(
    p_recaud INTEGER, p_fecha DATE
) RETURNS TABLE(cveejecutor INTEGER, ncompleto TEXT, asignar INTEGER, ultfec_entrega DATE) AS $$
BEGIN
    RETURN QUERY SELECT cveejecutor, ncompleto, asignados, ultfec_entrega FROM ejecutores WHERE recaud = p_recaud AND (vigencia = 'V' OR (ultfec_entrega = p_fecha));
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_max_impresiones
-- Tipo: CRUD
-- Descripción: Calcula el máximo de impresiones posibles para una recaudadora
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_max_impresiones(
    p_recaud INTEGER
) RETURNS TABLE(max INTEGER) AS $$
DECLARE
    tEjec INTEGER;
    tReq INTEGER;
    sZona INTEGER;
    maxImp INTEGER;
BEGIN
    SELECT COUNT(*) INTO tEjec FROM ejecutores WHERE recaud = p_recaud AND vigencia = 'V';
    SELECT COUNT(*) INTO tReq FROM reqpredial WHERE recaud = p_recaud AND vigencia = 'V';
    SELECT COUNT(*) INTO sZona FROM reqpredial WHERE recaud = p_recaud AND (zona_subzona = '0' OR zona_subzona IS NULL) AND vigencia = 'V';
    maxImp := tReq - sZona;
    IF tEjec > 0 THEN
        maxImp := LEAST(maxImp, tEjec);
    END IF;
    RETURN QUERY SELECT maxImp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

