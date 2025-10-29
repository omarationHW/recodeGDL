-- ============================================
-- MIGRACIÓN DE STORED PROCEDURES - BLOQUEARLICENCIAFRM
-- Base de datos: padron_licencias
-- Esquema: informix
-- Generado: 2025-09-22
-- ============================================

\c padron_licencias;
SET search_path TO informix;

-- ============================================
-- SP 1/1: sp_bloquear_licencia
-- Descripción: Bloquea una licencia, registra el movimiento y actualiza el estado de la licencia y domicilio si aplica
-- ============================================

CREATE OR REPLACE FUNCTION informix.sp_bloquear_licencia(
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
    UPDATE informix.licencias SET bloqueado = p_tipo_bloqueo WHERE id_licencia = p_id_licencia;

    -- Cancela bloqueos vigentes del mismo tipo
    UPDATE informix.bloqueo SET vigente = 'C'
    WHERE id_licencia = p_id_licencia AND vigente = 'V' AND bloqueado = p_tipo_bloqueo;

    -- Inserta el nuevo bloqueo
    INSERT INTO informix.bloqueo (bloqueado, id_licencia, observa, capturista, fecha_mov, vigente)
    VALUES (p_tipo_bloqueo, p_id_licencia, p_motivo, p_usuario, CURRENT_DATE, 'V');

    -- Si el tipo de bloqueo no es 'responsiva' (5), bloquea domicilio si no hay otro bloqueo activo
    IF p_tipo_bloqueo <> 5 THEN
        SELECT ubicacion, cvecalle, numext_ubic::TEXT, numint_ubic::TEXT, letraext_ubic, letraint_ubic
        INTO v_calle, v_cvecalle, v_noext, v_noint, v_letext, v_letint
        FROM informix.licencias WHERE id_licencia = p_id_licencia;

        SELECT COUNT(*) INTO v_bloqueos
        FROM informix.bloqueo
        WHERE id_licencia = p_id_licencia AND vigente = 'V' AND bloqueado > 0;

        IF v_bloqueos = 1 THEN
            INSERT INTO informix.bloqueo_dom (calle, cvecalle, num_ext, let_ext, num_int, let_int, observacion, vig, fecha, capturista)
            VALUES (v_calle, v_cvecalle, v_noext, v_letext, v_noint, v_letint, p_motivo, 'V', CURRENT_DATE, p_usuario);
        END IF;
    END IF;

EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Error al bloquear licencia: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMENTARIOS DE USO
-- ============================================
-- 1. Bloquear licencia: SELECT informix.sp_bloquear_licencia(12345, 1, 'Motivo del bloqueo', 'usuario_sistema');
-- Tipos de bloqueo comunes:
-- 1 = Bloqueo administrativo
-- 2 = Bloqueo técnico
-- 3 = Bloqueo legal
-- 4 = Bloqueo temporal
-- 5 = Responsiva (no bloquea domicilio)