-- Stored Procedure: sp_buscar_anuncio
-- Tipo: Catalog
-- Descripción: Busca un anuncio por su número y retorna todos los campos relevantes.
-- Generado para formulario: BloquearAnunciorm
-- Fecha: 2025-08-26 14:36:16

CREATE OR REPLACE FUNCTION sp_buscar_anuncio(p_numero_anuncio INTEGER)
RETURNS TABLE (
    id_anuncio INTEGER,
    id_licencia INTEGER,
    fecha_otorgamiento DATE,
    medidas1 VARCHAR,
    medidas2 VARCHAR,
    area_anuncio NUMERIC,
    ubicacion VARCHAR,
    numext_ubic VARCHAR,
    letraext_ubic VARCHAR,
    numint_ubic VARCHAR,
    letraint_ubic VARCHAR,
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
    WHERE anuncio = p_numero_anuncio;
END;
$$ LANGUAGE plpgsql;