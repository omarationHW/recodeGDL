-- Stored Procedure: sp_catalogo_mntto_update
-- Tipo: CRUD
-- Descripción: Actualiza un mercado existente en el catálogo
-- Generado para formulario: CatalogoMntto
-- Fecha: 2025-08-26 23:06:58

CREATE OR REPLACE FUNCTION sp_catalogo_mntto_update(
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
    UPDATE ta_11_mercados SET
        categoria = p_categoria,
        descripcion = UPPER(p_descripcion),
        cuenta_ingreso = p_cuenta_ingreso,
        cuenta_energia = CASE WHEN p_pregunta = 'S' THEN p_cuenta_energia ELSE NULL END,
        id_zona = p_zona,
        tipo_emision = v_tipo_emision
    WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado_nvo;
    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Mercado actualizado correctamente';
    ELSE
        RETURN QUERY SELECT FALSE, 'No se encontró el mercado para actualizar';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error al actualizar: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;