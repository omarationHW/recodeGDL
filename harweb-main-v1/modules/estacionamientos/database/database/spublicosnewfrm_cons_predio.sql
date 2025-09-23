-- Stored Procedure: cons_predio
-- Tipo: CRUD
-- Descripción: Consulta de predio por clave predial. Retorna todos los datos relevantes.
-- Generado para formulario: spublicosnewfrm
-- Fecha: 2025-08-27 14:50:43

CREATE OR REPLACE FUNCTION cons_predio(
    opc integer,
    dato varchar
) RETURNS TABLE(
    cvecuenta integer,
    recaud integer,
    tipo varchar,
    cuenta integer,
    cvecatastral varchar,
    subpredio integer,
    contribuyente varchar,
    calle varchar,
    numext varchar,
    numint varchar,
    zona integer,
    subzona integer,
    status integer,
    mensaje varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecuenta, recaud, tipo, cuenta, cvecatastral, subpredio, contribuyente, calle, numext, numint, zona, subzona, status, mensaje
    FROM predios
    WHERE cvecatastral = dato
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;