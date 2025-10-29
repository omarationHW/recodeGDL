-- Stored Procedure: sp_consultareg_publicos
-- Tipo: Catalog
-- Descripción: Busca un registro de estacionamiento público por número.
-- Generado para formulario: ConsultaReg
-- Fecha: 2025-08-27 13:40:42

CREATE OR REPLACE FUNCTION sp_consultareg_publicos(
    p_numesta integer
) RETURNS TABLE (
    id integer,
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
    solicitud integer,
    control integer,
    movtos_no integer,
    movto_cve varchar,
    movto_usr integer,
    folio_baja integer,
    fecha_baja date
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM pubmain WHERE numesta = p_numesta LIMIT 1;
END;
$$ LANGUAGE plpgsql;