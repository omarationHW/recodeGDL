-- Stored Procedure: sp_update_tipo
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un tipo existente
-- Generado para formulario: ModuloBD
-- Fecha: 2025-08-27 20:53:53

CREATE OR REPLACE FUNCTION sp_update_tipo(p_tipo INTEGER, p_descripcion VARCHAR)
RETURNS TABLE(tipo INTEGER, descripcion VARCHAR) AS $$
BEGIN
    UPDATE ta_17_tipos SET descripcion = p_descripcion WHERE tipo = p_tipo;
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos WHERE tipo = p_tipo;
END;
$$ LANGUAGE plpgsql;