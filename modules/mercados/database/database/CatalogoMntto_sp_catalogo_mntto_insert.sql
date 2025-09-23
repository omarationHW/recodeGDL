-- Stored Procedure: sp_catalogo_mntto_insert
-- Tipo: CRUD
-- Descripción: Inserta un nuevo mercado en el catálogo
-- Generado para formulario: CatalogoMntto
-- Fecha: 2025-08-26 23:06:58

CREATE OR REPLACE FUNCTION sp_catalogo_mntto_insert(
    p_oficina INTEGER,
    p_num_mercado_nvo INTEGER,
    p_categoria INTEGER,
    p_descripcion VARCHAR,
    p_cuenta_ingreso INTEGER,
    p_pregunta VARCHAR,
    p_cuenta_energia INTEGER,
    p_zona INTEGER,
    p_emision VARCHAR
) RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_tipo_emision CHAR(1);
BEGIN
    IF p_emision = 'MASIVA' THEN
        v_tipo_emision := 'M';
    ELSIF p_emision = 'DISKETTE' THEN
        v_tipo_emision := 'D';
    ELSIF p_emision = 'BAJA' THEN
        v_tipo_emision := 'B';
    ELSE
        v_tipo_emision := 'M';
    END IF;
    IF EXISTS (SELECT 1 FROM ta_11_mercados WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado_nvo) THEN
        RETURN QUERY SELECT FALSE, 'Ya existe un mercado con esa clave';
        RETURN;
    END IF;
    INSERT INTO ta_11_mercados (
        oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision
    ) VALUES (
        p_oficina, p_num_mercado_nvo, p_categoria, UPPER(p_descripcion), p_cuenta_ingreso,
        CASE WHEN p_pregunta = 'S' THEN p_cuenta_energia ELSE NULL END,
        p_zona, v_tipo_emision
    );
    RETURN QUERY SELECT TRUE, 'Mercado insertado correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error al insertar: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;