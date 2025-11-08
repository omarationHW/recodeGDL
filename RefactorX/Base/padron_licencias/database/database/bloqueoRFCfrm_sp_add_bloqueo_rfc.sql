-- Stored Procedure: sp_add_bloqueo_rfc
-- Tipo: CRUD
-- Descripción: Agrega un nuevo bloqueo de RFC
-- Generado para formulario: bloqueoRFCfrm
-- Fecha: 2025-08-27 16:24:36

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