-- Stored Procedure: buscar_licencia_responsiva
-- Tipo: Catalog
-- Descripción: Busca una licencia por número y retorna datos relevantes para la responsiva.
-- Generado para formulario: Responsivafrm
-- Fecha: 2025-08-27 19:29:54

CREATE OR REPLACE FUNCTION buscar_licencia_responsiva(p_licencia INTEGER)
RETURNS TABLE (
    id_licencia INTEGER,
    licencia INTEGER,
    recaud INTEGER,
    descripcion TEXT,
    actividad TEXT,
    propietarionvo TEXT,
    ubicacion TEXT,
    numext_ubic TEXT,
    letraext_ubic TEXT,
    numint_ubic TEXT,
    letraint_ubic TEXT,
    colonia_ubic TEXT,
    cp TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_licencia, l.licencia, l.recaud, g.descripcion, l.actividad,
           trim(coalesce(l.primer_ap,'') || ' ' || coalesce(l.segundo_ap,'') || ' ' || coalesce(l.propietario,'')) as propietarionvo,
           l.ubicacion, l.numext_ubic, l.letraext_ubic, l.numint_ubic, l.letraint_ubic, l.colonia_ubic, l.cp
    FROM licencias l
    LEFT JOIN c_giros g ON g.id_giro = l.id_giro
    WHERE l.licencia = p_licencia;
END;
$$ LANGUAGE plpgsql;