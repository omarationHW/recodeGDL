-- Stored Procedure: buscar_anuncio
-- Tipo: Catalog
-- Descripción: Busca un anuncio por su número y devuelve todos sus datos.
-- Generado para formulario: BloquearAnunciorm
-- Fecha: 2025-08-27 16:01:27

CREATE OR REPLACE FUNCTION buscar_anuncio(numero_anuncio TEXT)
RETURNS TABLE (
    id_anuncio INTEGER,
    id_licencia INTEGER,
    fecha_otorgamiento DATE,
    medidas1 TEXT,
    medidas2 TEXT,
    area_anuncio NUMERIC,
    ubicacion TEXT,
    numext_ubic TEXT,
    letraext_ubic TEXT,
    numint_ubic TEXT,
    letraint_ubic TEXT,
    bloqueado INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        id_anuncio,
        id_licencia,
        fecha_otorgamiento,
        medidas1,
        medidas2,
        area_anuncio,
        ubicacion,
        numext_ubic,
        letraext_ubic,
        numint_ubic,
        letraint_ubic,
        bloqueado
    FROM anuncios
    WHERE anuncio = numero_anuncio::INTEGER;
END;
$$ LANGUAGE plpgsql;