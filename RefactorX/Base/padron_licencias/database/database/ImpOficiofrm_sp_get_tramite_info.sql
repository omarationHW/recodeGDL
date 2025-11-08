-- Stored Procedure: sp_get_tramite_info
-- Tipo: Catalog
-- Descripción: Obtiene la información básica de un trámite por su ID.
-- Generado para formulario: ImpOficiofrm
-- Fecha: 2025-08-27 18:30:26

CREATE OR REPLACE FUNCTION sp_get_tramite_info(p_tramite_id INTEGER)
RETURNS TABLE(
    id_tramite INTEGER,
    propietario TEXT,
    ubicacion TEXT,
    estatus TEXT,
    tipo_tramite TEXT,
    fecha TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.id_tramite, t.propietario, t.ubicacion, t.estatus, t.tipo_tramite, t.feccap
    FROM tramites t
    WHERE t.id_tramite = p_tramite_id;
END;
$$ LANGUAGE plpgsql;