-- Stored Procedure: sp_get_public_parking_list
-- Tipo: Catalog
-- Descripción: Obtiene la lista de estacionamientos públicos con sus datos principales.
-- Generado para formulario: sfrm_consultapublicos
-- Fecha: 2025-08-27 16:04:06

CREATE OR REPLACE FUNCTION sp_get_public_parking_list()
RETURNS TABLE (
    id integer,
    pubcategoria_id integer,
    categoria varchar(2),
    descripcion varchar,
    numesta integer,
    sector varchar(1),
    nomsector varchar(8),
    zona integer,
    subzona integer,
    numlicencia integer,
    axolicencias integer,
    cvecuenta integer,
    nombre varchar(100),
    calle varchar(100),
    numext varchar(6),
    telefono varchar(15),
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
    ORDER BY b.categoria, a.numesta;
END;
$$ LANGUAGE plpgsql;