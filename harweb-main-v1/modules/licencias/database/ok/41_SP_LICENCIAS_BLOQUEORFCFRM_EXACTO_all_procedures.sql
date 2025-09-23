-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: BLOQUEORFCFRM (EXACTO del archivo original)
-- Archivo: 41_SP_LICENCIAS_BLOQUEORFCFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: BLOQUEORFCFRM (EXACTO del archivo original)
-- Archivo: 41_SP_LICENCIAS_BLOQUEORFCFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: BLOQUEORFCFRM (EXACTO del archivo original)
-- Archivo: 41_SP_LICENCIAS_BLOQUEORFCFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: BLOQUEORFCFRM (EXACTO del archivo original)
-- Archivo: 41_SP_LICENCIAS_BLOQUEORFCFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

