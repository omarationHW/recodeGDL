-- Stored Procedure: sppubalta
-- Tipo: CRUD
-- Descripción: Alta de estacionamiento público. Inserta un registro en pubmain y retorna resultado, mensaje y el id nuevo.
-- Generado para formulario: spublicosnewfrm
-- Fecha: 2025-08-27 14:50:43

CREATE OR REPLACE FUNCTION sppubalta(
    pubcategoria_id integer,
    numesta integer,
    sector varchar,
    zona integer,
    subzona integer,
    numlicencia integer,
    axolicencias integer,
    cvecuenta integer,
    nombre varchar,
    calle varchar,
    numext varchar,
    telefono varchar,
    cupo integer,
    fecha_at date,
    fecha_inicial date,
    fecha_vencimiento date,
    rfc varchar,
    movtos_no integer,
    movto_cve varchar,
    movto_usr integer,
    solicitud integer,
    control integer
) RETURNS TABLE(result integer, resultstr varchar, idnvo integer) AS $$
DECLARE
    new_id integer;
BEGIN
    INSERT INTO pubmain (
        pubcategoria_id, numesta, sector, zona, subzona, numlicencia, axolicencias, cvecuenta, nombre, calle, numext, telefono, cupo, fecha_at, fecha_inicial, fecha_vencimiento, rfc, solicitud, control, movtos_no, movto_cve, movto_usr
    ) VALUES (
        pubcategoria_id, numesta, sector, zona, subzona, numlicencia, axolicencias, cvecuenta, nombre, calle, numext, telefono, cupo, fecha_at, fecha_inicial, fecha_vencimiento, rfc, solicitud, control, movtos_no, movto_cve, movto_usr
    ) RETURNING id INTO new_id;
    result := 1;
    resultstr := 'Alta exitosa';
    idnvo := new_id;
    RETURN NEXT;
EXCEPTION WHEN OTHERS THEN
    result := 0;
    resultstr := 'Error: ' || SQLERRM;
    idnvo := NULL;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;