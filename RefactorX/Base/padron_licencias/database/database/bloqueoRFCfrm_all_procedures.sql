-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: bloqueoRFCfrm
-- Generado: 2025-08-27 16:24:36
-- Total SPs: 6
-- ============================================

-- SP 1/6: sp_get_bloqueos_rfc
-- Tipo: Catalog
-- Descripción: Obtiene todos los RFC bloqueados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_bloqueos_rfc()
RETURNS TABLE(
    rfc VARCHAR(13),
    id_tramite INTEGER,
    licencia INTEGER,
    hora TIMESTAMP,
    vig CHAR(1),
    observacion VARCHAR(255),
    capturista VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY SELECT rfc, id_tramite, licencia, hora, vig, observacion, capturista FROM bloqueo_rfc_lic ORDER BY rfc;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/6: sp_search_bloqueos_rfc
-- Tipo: Catalog
-- Descripción: Busca RFC bloqueados por coincidencia parcial
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_search_bloqueos_rfc(p_rfc VARCHAR)
RETURNS TABLE(
    rfc VARCHAR(13),
    id_tramite INTEGER,
    licencia INTEGER,
    hora TIMESTAMP,
    vig CHAR(1),
    observacion VARCHAR(255),
    capturista VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY SELECT rfc, id_tramite, licencia, hora, vig, observacion, capturista FROM bloqueo_rfc_lic WHERE rfc ILIKE '%' || p_rfc || '%' ORDER BY rfc;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/6: sp_get_tramite_info
-- Tipo: Catalog
-- Descripción: Obtiene información de trámite y RFC para bloqueo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tramite_info(p_id_tramite INTEGER)
RETURNS TABLE(
    id_tramite INTEGER,
    id_licencia INTEGER,
    rfc VARCHAR(13),
    actividad VARCHAR(130),
    propietarionvo VARCHAR(242)
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.id_tramite, t.id_licencia, t.rfc, t.actividad,
      trim(trim(coalesce(t.primer_ap, '')) || ' ' || trim(coalesce(t.segundo_ap, '')) || ' ' || trim(t.propietario)) as propietarionvo
    FROM lic_autoev a
    JOIN tramites t ON t.id_tramite = a.id_tramite
    WHERE a.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/6: sp_add_bloqueo_rfc
-- Tipo: CRUD
-- Descripción: Agrega un nuevo bloqueo de RFC
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_add_bloqueo_rfc(
    p_rfc VARCHAR(13),
    p_id_tramite INTEGER,
    p_licencia INTEGER,
    p_observacion VARCHAR(255),
    p_capturista VARCHAR(10)
) RETURNS VOID AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT 1 INTO v_exists FROM bloqueo_rfc_lic WHERE rfc = p_rfc AND vig = 'V' LIMIT 1;
    IF v_exists IS NOT NULL THEN
        RAISE EXCEPTION 'Ya existe un bloqueo vigente para este RFC';
    END IF;
    INSERT INTO bloqueo_rfc_lic (rfc, id_tramite, licencia, hora, vig, observacion, capturista)
    VALUES (p_rfc, p_id_tramite, p_licencia, now(), 'V', p_observacion, p_capturista);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/6: sp_edit_bloqueo_rfc
-- Tipo: CRUD
-- Descripción: Edita el motivo de un bloqueo vigente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_edit_bloqueo_rfc(
    p_rfc VARCHAR(13),
    p_observacion VARCHAR(255),
    p_capturista VARCHAR(10)
) RETURNS INTEGER AS $$
DECLARE
    v_updated INTEGER;
BEGIN
    UPDATE bloqueo_rfc_lic SET observacion = p_observacion, hora = now(), capturista = p_capturista
    WHERE rfc = p_rfc AND vig = 'V';
    GET DIAGNOSTICS v_updated = ROW_COUNT;
    RETURN v_updated;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/6: sp_desbloquear_rfc
-- Tipo: CRUD
-- Descripción: Desbloquea un RFC (cambia vig a 'C')
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_desbloquear_rfc(
    p_rfc VARCHAR(13),
    p_observacion VARCHAR(255),
    p_capturista VARCHAR(10)
) RETURNS INTEGER AS $$
DECLARE
    v_updated INTEGER;
BEGIN
    UPDATE bloqueo_rfc_lic SET observacion = p_observacion, vig = 'C', hora = now(), capturista = p_capturista
    WHERE rfc = p_rfc AND vig = 'V';
    GET DIAGNOSTICS v_updated = ROW_COUNT;
    RETURN v_updated;
END;
$$ LANGUAGE plpgsql;

-- ============================================

