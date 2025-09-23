-- Stored Procedure: sp_eliminar_documento
-- Tipo: CRUD
-- Descripción: Elimina un documento de un trámite.
-- Generado para formulario: RegistroSolicitudForm
-- Fecha: 2025-08-26 17:45:19

CREATE OR REPLACE FUNCTION sp_eliminar_documento(
    p_id_tramite integer,
    p_id_documento integer,
    p_usuario text
) RETURNS TABLE(mensaje text) AS $$
BEGIN
    DELETE FROM tramitedocs WHERE id_tramite = p_id_tramite AND id_documento = p_id_documento;
    RETURN QUERY SELECT 'Documento eliminado correctamente';
END;
$$ LANGUAGE plpgsql;