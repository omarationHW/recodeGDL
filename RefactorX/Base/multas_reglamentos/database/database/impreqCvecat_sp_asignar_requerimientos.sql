-- Stored Procedure: sp_asignar_requerimientos
-- Tipo: CRUD
-- Descripción: Asigna requerimientos a un ejecutor en un rango de folios
-- Generado para formulario: impreqCvecat
-- Fecha: 2025-08-27 21:20:48

CREATE OR REPLACE FUNCTION sp_asignar_requerimientos(
    p_recaud INTEGER, p_folioini INTEGER, p_foliofin INTEGER, p_ejecutor INTEGER, p_fecha DATE
) RETURNS TABLE(folio INTEGER, status TEXT) AS $$
BEGIN
    UPDATE reqpredial
    SET cveejecut = p_ejecutor, fecejec = p_fecha
    WHERE recaud = p_recaud AND folioreq BETWEEN p_folioini AND p_foliofin AND vigencia = 'V';
    RETURN QUERY SELECT folioreq, 'asignado' FROM reqpredial WHERE recaud = p_recaud AND folioreq BETWEEN p_folioini AND p_foliofin;
END;
$$ LANGUAGE plpgsql;