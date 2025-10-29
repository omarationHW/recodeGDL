-- Stored Procedure: sp_pub_movtos
-- Tipo: CRUD
-- Descripción: Registra incrementos/decrementos de cajones o cambio de categoría
-- Generado para formulario: spubActualizacionfrm
-- Fecha: 2025-08-27 14:48:13

CREATE OR REPLACE FUNCTION sp_pub_movtos(
    p_opc integer,
    p_pubmain_id integer,
    p_fecha date,
    p_cajones integer,
    p_categoria integer,
    p_oficio varchar,
    p_usuario integer
) RETURNS TABLE(resultado integer) AS $$
BEGIN
    IF p_opc = 1 THEN
        UPDATE pubmain SET cupo = cupo + p_cajones WHERE id = p_pubmain_id;
        resultado := 0;
    ELSIF p_opc = 2 THEN
        UPDATE pubmain SET pubcategoria_id = p_categoria WHERE id = p_pubmain_id;
        resultado := 0;
    ELSE
        resultado := 1;
    END IF;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;