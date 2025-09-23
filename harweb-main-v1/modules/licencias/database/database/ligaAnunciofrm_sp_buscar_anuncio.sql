-- Stored Procedure: sp_buscar_anuncio
-- Tipo: Catalog
-- Descripción: Busca un anuncio por número.
-- Generado para formulario: ligaAnunciofrm
-- Fecha: 2025-08-26 17:10:33

CREATE OR REPLACE FUNCTION sp_buscar_anuncio(p_anuncio INTEGER)
RETURNS TABLE(*) AS $$
BEGIN
    RETURN QUERY SELECT * FROM anuncios WHERE anuncio = p_anuncio;
END;
$$ LANGUAGE plpgsql;