-- Stored Procedure: sp_delete_tipo
-- Tipo: CRUD
-- Descripción: Elimina un tipo del catálogo
-- Generado para formulario: ModuloBD
-- Fecha: 2025-08-27 20:53:53

CREATE OR REPLACE FUNCTION sp_delete_tipo(p_tipo INTEGER)
RETURNS TABLE(tipo INTEGER, descripcion VARCHAR) AS $$
DECLARE
    old_tipo INTEGER;
    old_desc VARCHAR;
BEGIN
    SELECT tipo, descripcion INTO old_tipo, old_desc FROM ta_17_tipos WHERE tipo = p_tipo;
    DELETE FROM ta_17_tipos WHERE tipo = p_tipo;
    RETURN QUERY SELECT old_tipo, old_desc;
END;
$$ LANGUAGE plpgsql;