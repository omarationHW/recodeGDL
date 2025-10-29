-- Stored Procedure: sp_consultar_sanandres
-- Tipo: Catalog
-- Descripción: Devuelve todos los registros de la tabla 'datos' del cementerio San Andrés.
-- Generado para formulario: ConsultaSAndres
-- Fecha: 2025-08-27 14:24:28

CREATE OR REPLACE FUNCTION sp_consultar_sanandres()
RETURNS TABLE (
    id integer,
    clase text,
    seccion text,
    linea text,
    fosa text,
    ppago text,
    nombre text,
    fcompra timestamp,
    otros text,
    clave smallint,
    medida float,
    calle text,
    colonia text
) AS $$
BEGIN
    RETURN QUERY SELECT id, clase, seccion, linea, fosa, ppago, nombre, fcompra, otros, clave, medida, calle, colonia FROM datos;
END;
$$ LANGUAGE plpgsql;