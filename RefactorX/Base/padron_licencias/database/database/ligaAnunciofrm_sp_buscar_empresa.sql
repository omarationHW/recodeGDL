-- Stored Procedure: sp_buscar_empresa
-- Tipo: Catalog
-- Descripción: Busca una empresa por número.
-- Generado para formulario: ligaAnunciofrm
-- Fecha: 2025-08-26 17:10:33

CREATE OR REPLACE FUNCTION sp_buscar_empresa(p_empresa INTEGER)
RETURNS TABLE(*) AS $$
BEGIN
    RETURN QUERY SELECT * FROM licencias WHERE empresa = p_empresa;
END;
$$ LANGUAGE plpgsql;