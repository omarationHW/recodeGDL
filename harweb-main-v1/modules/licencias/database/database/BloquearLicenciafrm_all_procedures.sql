-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: BloquearLicenciafrm
-- Generado: 2025-08-27 16:04:11
-- Total SPs: 2
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
        FROM licencias WHERE id_licencia = p_id_licencia;
        SELECT COUNT(*) INTO v_bloqueos FROM bloqueo WHERE id_licencia = p_id_licencia AND vigente = 'V' AND bloqueado > 0;
        IF v_bloqueos = 1 THEN
            INSERT INTO bloqueo_dom (calle, cvecalle, num_ext, let_ext, num_int, let_int, observacion, vig, fecha, capturista)
            VALUES (v_calle, v_cvecalle, v_noext, v_letext, v_noint, v_letint, p_motivo, 'V', CURRENT_DATE, p_usuario);
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_desbloquear_licencia
-- Tipo: CRUD
-- Descripción: Desbloquea una licencia para un tipo de bloqueo específico, actualiza el estado y elimina el domicilio si corresponde.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_desbloquear_licencia(
    p_id_licencia INTEGER,
    p_tipo_bloqueo INTEGER,
    p_motivo TEXT,
    p_usuario TEXT
) RETURNS VOID AS $$
DECLARE
    v_calle TEXT;
    v_noext TEXT;
    v_letext TEXT;
    v_noint TEXT;
    v_letint TEXT;
    v_cvecalle INTEGER;
    v_bloqueos INT;
    v_ultimo_bloqueo INTEGER;
BEGIN
    -- Cancela el último bloqueo vigente de ese tipo
    UPDATE bloqueo SET vigente = 'C' WHERE id_licencia = p_id_licencia AND bloqueado = p_tipo_bloqueo AND vigente = 'V';
    -- Verifica si quedan bloqueos activos
    SELECT COUNT(*) INTO v_bloqueos FROM bloqueo WHERE id_licencia = p_id_licencia AND vigente = 'V' AND bloqueado > 0;
    IF v_bloqueos = 0 THEN
        UPDATE licencias SET bloqueado = 0 WHERE id_licencia = p_id_licencia;
    ELSE
        SELECT bloqueado INTO v_ultimo_bloqueo FROM bloqueo WHERE id_licencia = p_id_licencia AND vigente = 'V' ORDER BY fecha_mov DESC LIMIT 1;
        UPDATE licencias SET bloqueado = v_ultimo_bloqueo WHERE id_licencia = p_id_licencia;
    END IF;
    -- Inserta registro de desbloqueo
    INSERT INTO bloqueo (bloqueado, id_licencia, observa, capturista, fecha_mov, vigente)
    VALUES (0, p_id_licencia, p_motivo, p_usuario, CURRENT_DATE, 'V');
    -- Si no quedan bloqueos, elimina el domicilio bloqueado y guarda histórico
    IF v_bloqueos = 0 THEN
        SELECT ubicacion, cvecalle, numext_ubic::TEXT, letraext_ubic, numint_ubic::TEXT, letraint_ubic
        INTO v_calle, v_cvecalle, v_noext, v_letext, v_noint, v_letint
        FROM licencias WHERE id_licencia = p_id_licencia;
        -- Guarda histórico
        INSERT INTO h_bloqueo_dom SELECT *, CURRENT_DATE, p_motivo, 'EL', p_usuario FROM bloqueo_dom WHERE calle = v_calle AND (num_ext = v_noext OR v_noext IS NULL) AND (let_ext = v_letext OR v_letext IS NULL) AND (num_int = v_noint OR v_noint IS NULL) AND (let_int = v_letint OR v_letint IS NULL);
        -- Elimina
        DELETE FROM bloqueo_dom WHERE calle = v_calle AND (num_ext = v_noext OR v_noext IS NULL) AND (let_ext = v_letext OR v_letext IS NULL) AND (num_int = v_noint OR v_noint IS NULL) AND (let_int = v_letint OR v_letint IS NULL);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

