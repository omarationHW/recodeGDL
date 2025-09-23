-- Stored Procedure: sp_add_tipo
-- Tipo: CRUD
-- Descripción: Agrega un nuevo tipo al catálogo
-- Generado para formulario: ModuloBD
-- Fecha: 2025-08-27 20:53:53

CREATE OR REPLACE FUNCTION sp_add_tipo(p_descripcion VARCHAR)
RETURNS TABLE(tipo INTEGER, descripcion VARCHAR) AS $$
DECLARE
    new_tipo INTEGER;
BEGIN
    SELECT COALESCE(MAX(tipo), 0) + 1 INTO new_tipo FROM ta_17_tipos;
    INSERT INTO ta_17_tipos (tipo, descripcion) VALUES (new_tipo, p_descripcion);
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos WHERE tipo = new_tipo;
END;
$$ LANGUAGE plpgsql;