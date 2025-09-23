-- Stored Procedure: sp_imp_oficio_tramite_info
-- Tipo: Catalog
-- Descripción: Obtiene la información relevante de un trámite para mostrar en el formulario.
-- Generado para formulario: ImpOficiofrm
-- Fecha: 2025-08-26 17:03:12

CREATE OR REPLACE FUNCTION sp_imp_oficio_tramite_info(
    p_tramite_id INTEGER
) RETURNS TABLE(
    id INTEGER,
    propietario TEXT,
    ubicacion TEXT,
    tipo_tramite TEXT,
    estatus TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.id_tramite, t.propietario, t.ubicacion, t.tipo_tramite, t.estatus
    FROM tramites t
    WHERE t.id_tramite = p_tramite_id;
END;
$$ LANGUAGE plpgsql;
