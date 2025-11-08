-- Stored Procedure: sp_modificar_bloqueo_rfc
-- Tipo: CRUD
-- Descripción: Modifica el motivo de un bloqueo vigente.
-- Generado para formulario: bloqueoRFCfrm
-- Fecha: 2025-08-26 14:47:37

CREATE OR REPLACE FUNCTION sp_modificar_bloqueo_rfc(
    p_rfc TEXT,
    p_id_tramite INTEGER,
    p_observacion TEXT,
    p_capturista TEXT
) RETURNS TEXT AS $$
BEGIN
    UPDATE bloqueo_rfc_lic
    SET observacion = p_observacion, capturista = p_capturista
    WHERE rfc = p_rfc AND id_tramite = p_id_tramite AND vig = 'V';
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;