-- Stored Procedure: sp_tipos_create
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro en el catálogo de tipos.
-- Generado para formulario: TiposMntto
-- Fecha: 2025-08-27 16:03:12

CREATE OR REPLACE FUNCTION sp_tipos_create(p_tipo integer, p_descripcion varchar)
RETURNS TABLE(tipo integer, descripcion varchar) AS $$
BEGIN
    INSERT INTO ta_17_tipos (tipo, descripcion) VALUES (p_tipo, p_descripcion);
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos WHERE tipo = p_tipo;
END;
$$ LANGUAGE plpgsql;