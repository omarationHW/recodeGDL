-- Stored Procedure: sp_categoria_insert
-- Tipo: CRUD
-- Descripción: Inserta una nueva categoría en ta_11_categoria
-- Generado para formulario: CategoriaMntto
-- Fecha: 2025-08-26 19:16:59

CREATE OR REPLACE PROCEDURE sp_categoria_insert(
    p_categoria SMALLINT,
    p_descripcion VARCHAR(30)
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_descripcion IS NULL OR trim(p_descripcion) = '' THEN
        RAISE EXCEPTION 'La Descripcion no puede ser Nula';
    END IF;
    INSERT INTO ta_11_categoria (categoria, descripcion)
    VALUES (p_categoria, upper(p_descripcion));
END;
$$;