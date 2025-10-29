-- Stored Procedure: sp_tipos_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un tipo existente.
-- Generado para formulario: TiposMntto
-- Fecha: 2025-08-27 16:03:12

CREATE OR REPLACE FUNCTION sp_tipos_update(p_tipo integer, p_descripcion varchar)
RETURNS TABLE(tipo integer, descripcion varchar) AS $$
BEGIN
    UPDATE ta_17_tipos SET descripcion = p_descripcion WHERE tipo = p_tipo;
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos WHERE tipo = p_tipo;
END;
$$ LANGUAGE plpgsql;