-- Stored Procedure: sp_agregar_bloqueo_rfc
-- Tipo: CRUD
-- Descripción: Agrega un nuevo bloqueo de RFC si no existe uno vigente.
-- Generado para formulario: bloqueoRFCfrm
-- Fecha: 2025-08-26 14:47:37

CREATE OR REPLACE FUNCTION sp_agregar_bloqueo_rfc(
    p_rfc TEXT,
    p_id_tramite INTEGER,
    p_licencia INTEGER,
    p_observacion TEXT,
    p_capturista TEXT
) RETURNS TEXT AS $$
DECLARE
    existe INTEGER;
BEGIN
    SELECT 1 INTO existe FROM bloqueo_rfc_lic WHERE rfc = p_rfc AND vig = 'V' LIMIT 1;
    IF existe IS NOT NULL THEN
        RETURN 'El RFC ya está bloqueado';
    END IF;
    INSERT INTO bloqueo_rfc_lic (rfc, id_tramite, licencia, hora, vig, observacion, capturista)
    VALUES (p_rfc, p_id_tramite, p_licencia, NOW(), 'V', p_observacion, p_capturista);
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;