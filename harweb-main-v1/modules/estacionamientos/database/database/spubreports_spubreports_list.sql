-- Stored Procedure: spubreports_list
-- Tipo: Report
-- Descripción: Devuelve la lista de estacionamientos públicos según el tipo de ordenamiento (por categoría, sector, número, nombre, calle, zona/subzona).
-- Generado para formulario: spubreports
-- Fecha: 2025-08-27 14:52:31

CREATE OR REPLACE FUNCTION spubreports_list(opc integer)
RETURNS TABLE (
    id integer,
    pubcategoria_id integer,
    categoria varchar(10),
    descripcion varchar(100),
    numesta integer,
    sector varchar(10),
    nomsector varchar(20),
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
    fecha_vencimiento date
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id, a.pubcategoria_id, b.categoria, b.descripcion, a.numesta,
        a.sector,
        CASE a.sector
            WHEN 'J' THEN 'JUAREZ'
            WHEN 'H' THEN 'HIDALGO'
            WHEN 'L' THEN 'LIBERTAD'
            WHEN 'R' THEN 'REFORMA'
            ELSE 'S/N'
        END AS nomsector,
        a.zona, a.subzona, a.numlicencia, a.axolicencias, a.cvecuenta,
        a.nombre, a.calle, a.numext, a.telefono, a.cupo, a.fecha_at, a.fecha_inicial, a.fecha_vencimiento
    FROM pubmain a
    JOIN pubcategoria b ON b.id = a.pubcategoria_id
    WHERE a.movto_cve <> 'C'
    ORDER BY
        CASE WHEN opc = 1 THEN b.categoria END,
        CASE WHEN opc = 2 THEN a.sector END,
        CASE WHEN opc = 3 THEN a.numesta END,
        CASE WHEN opc = 4 THEN a.nombre END,
        CASE WHEN opc = 5 THEN a.calle END,
        CASE WHEN opc = 7 THEN a.zona END,
        CASE WHEN opc = 7 THEN a.subzona END,
        a.numesta;
END;
$$ LANGUAGE plpgsql;