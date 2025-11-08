-- Stored Procedure: sp_licencia_search
-- Tipo: Catalog
-- Descripción: Busca una licencia por número.
-- Generado para formulario: Responsivafrm
-- Fecha: 2025-08-26 18:03:33

CREATE OR REPLACE FUNCTION sp_licencia_search(licencia_in TEXT)
RETURNS TABLE(id_licencia INTEGER, licencia TEXT, propietario TEXT, actividad TEXT, ubicacion TEXT, recaud INTEGER, descripcion TEXT, propietarionvo TEXT) AS $$
BEGIN
    RETURN QUERY SELECT l.id_licencia, l.licencia, l.propietario, l.actividad, l.ubicacion, l.recaud, g.descripcion, trim(trim(coalesce(l.primer_ap,''))||' '||trim(coalesce(l.segundo_ap,''))||' '||trim(l.propietario)) as propietarionvo
    FROM licencias l LEFT JOIN c_giros g ON g.id_giro = l.id_giro
    WHERE l.licencia = licencia_in;
END;
$$ LANGUAGE plpgsql;