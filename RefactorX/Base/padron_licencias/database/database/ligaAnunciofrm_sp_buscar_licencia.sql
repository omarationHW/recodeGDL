-- Stored Procedure: sp_buscar_licencia
-- Tipo: Catalog
-- Descripción: Busca una licencia por número.
-- Generado para formulario: ligaAnunciofrm
-- Fecha: 2025-08-26 17:10:33

CREATE OR REPLACE FUNCTION sp_buscar_licencia(p_licencia INTEGER)
RETURNS TABLE(*) AS $$
BEGIN
    RETURN QUERY SELECT * FROM licencias WHERE licencia = p_licencia;
END;
$$ LANGUAGE plpgsql;