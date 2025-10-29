-- Stored Procedure: spubreports_edocta
-- Tipo: Report
-- Descripción: Devuelve el estado de cuenta de un estacionamiento público por número de estacionamiento.
-- Generado para formulario: spubreports
-- Fecha: 2025-08-27 14:52:31

CREATE OR REPLACE FUNCTION spubreports_edocta(numesta integer)
RETURNS TABLE (
    id integer,
    pubcategoria_id integer,
    numesta integer,
    sector varchar(10),
    zona integer,
    subzona integer,
    numlicencia integer,
    axolicencias integer,
    cvecuenta integer,
    nombre varchar(100),
    calle varchar(100),
    numext varchar(10),
    telefono varchar(20),
    cupo integer,
    fecha_at date,
    fecha_inicial date,
    fecha_vencimiento date,
    rfc varchar(20),
    solicitud integer,
    control integer,
    movtos_no integer,
    movto_cve varchar(10),
    movto_usr integer,
    descripcion varchar(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id, a.pubcategoria_id, a.numesta, a.sector, a.zona, a.subzona, a.numlicencia, a.axolicencias, a.cvecuenta,
           a.nombre, a.calle, a.numext, a.telefono, a.cupo, a.fecha_at, a.fecha_inicial, a.fecha_vencimiento,
           a.rfc, a.solicitud, a.control, a.movtos_no, a.movto_cve, a.movto_usr, b.descripcion
    FROM pubmain a
    JOIN pubcategoria b ON b.id = a.pubcategoria_id
    WHERE a.numesta = numesta AND a.movto_cve <> 'C';
END;
$$ LANGUAGE plpgsql;