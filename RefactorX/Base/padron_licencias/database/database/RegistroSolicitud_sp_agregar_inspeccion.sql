-- Stored Procedure: sp_agregar_inspeccion
-- Tipo: CRUD
-- Descripción: Agrega una inspección/revisión a un trámite.
-- Generado para formulario: RegistroSolicitudForm
-- Fecha: 2025-08-26 17:45:19

CREATE OR REPLACE FUNCTION sp_agregar_inspeccion(
    p_id_tramite integer,
    p_id_dependencia integer,
    p_usuario text
) RETURNS TABLE(id_revision integer, mensaje text) AS $$
DECLARE
    v_id_revision integer;
BEGIN
    INSERT INTO revisiones (id_tramite, id_dependencia, fecha_inicio, estatus, capturista)
    VALUES (p_id_tramite, p_id_dependencia, now(), 'V', p_usuario)
    RETURNING id_revision INTO v_id_revision;
    -- Insertar en seg_revision
    INSERT INTO seg_revision (id_revision, estatus, feccap)
    VALUES (v_id_revision, 'V', now());
    RETURN QUERY SELECT v_id_revision, 'Inspección agregada correctamente';
END;
$$ LANGUAGE plpgsql;