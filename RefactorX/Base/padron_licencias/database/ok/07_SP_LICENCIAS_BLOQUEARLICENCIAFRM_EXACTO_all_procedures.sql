-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: BLOQUEARLICENCIAFRM (EXACTO del archivo original)
-- Archivo: 07_SP_LICENCIAS_BLOQUEARLICENCIAFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_bloquear_licencia
-- Tipo: CRUD
-- Descripción: Bloquea una licencia, registra el movimiento y actualiza el estado de la licencia y domicilio si aplica.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_bloquear_licencia(
    p_id_licencia INTEGER,
    p_tipo_bloqueo INTEGER,
    p_motivo TEXT,
    p_usuario TEXT
) RETURNS VOID AS $$
DECLARE
    v_calle TEXT;
    v_cvecalle INTEGER;
    v_noext TEXT;
    v_noint TEXT;
    v_letext TEXT;
    v_letint TEXT;
    v_bloqueos INT;
BEGIN
    -- Actualiza la licencia
    UPDATE licencias SET bloqueado = p_tipo_bloqueo WHERE id_licencia = p_id_licencia;
    -- Cancela bloqueos vigentes del mismo tipo
    UPDATE bloqueo SET vigente = 'C' WHERE id_licencia = p_id_licencia AND vigente = 'V' AND bloqueado = p_tipo_bloqueo;
    -- Inserta el nuevo bloqueo
    INSERT INTO bloqueo (bloqueado, id_licencia, observa, capturista, fecha_mov, vigente)
    VALUES (p_tipo_bloqueo, p_id_licencia, p_motivo, p_usuario, CURRENT_DATE, 'V');
    -- Si el tipo de bloqueo no es 'responsiva', bloquea domicilio si no hay otro bloqueo activo
    IF p_tipo_bloqueo <> 5 THEN
        SELECT ubicacion, cvecalle, numext_ubic::TEXT, numint_ubic::TEXT, letraext_ubic, letraint_ubic
        INTO v_calle, v_cvecalle, v_noext, v_noint, v_letext, v_letint
        FROM public WHERE id_licencia = p_id_licencia;
        SELECT COUNT(*) INTO v_bloqueos FROM bloqueo WHERE id_licencia = p_id_licencia AND vigente = 'V' AND bloqueado > 0;
        IF v_bloqueos = 1 THEN
            INSERT INTO bloqueo_dom (calle, cvecalle, num_ext, let_ext, num_int, let_int, observacion, vig, fecha, capturista)
            VALUES (v_calle, v_cvecalle, v_noext, v_letext, v_noint, v_letint, p_motivo, 'V', CURRENT_DATE, p_usuario);
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: BLOQUEARLICENCIAFRM (EXACTO del archivo original)
-- Archivo: 07_SP_LICENCIAS_BLOQUEARLICENCIAFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

