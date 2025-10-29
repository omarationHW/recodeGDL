-- Stored Procedure: sp_agregar_documento
-- Tipo: CRUD
-- Descripción: Agrega un documento a un trámite.
-- Generado para formulario: RegistroSolicitudForm
-- Fecha: 2025-08-26 17:45:19

CREATE OR REPLACE FUNCTION sp_agregar_documento(
    p_id_tramite integer,
    p_nombre text,
    p_ruta text,
    p_usuario text
) RETURNS TABLE(id_documento integer, mensaje text) AS $$
DECLARE
    v_id_documento integer;
BEGIN
    INSERT INTO tramitedocs (id_tramite, nombre, ruta, feccap, capturista)
    VALUES (p_id_tramite, p_nombre, p_ruta, now(), p_usuario)
    RETURNING id_documento INTO v_id_documento;
    RETURN QUERY SELECT v_id_documento, 'Documento agregado correctamente';
END;
$$ LANGUAGE plpgsql;