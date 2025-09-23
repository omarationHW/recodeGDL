-- Stored Procedure: sppubmodi
-- Tipo: CRUD
-- Descripción: Actualiza los datos de un estacionamiento público
-- Generado para formulario: spubActualizacionfrm
-- Fecha: 2025-08-27 14:48:13

CREATE OR REPLACE FUNCTION sppubmodi(
    p_id integer,
    p_sector varchar,
    p_zona integer,
    p_subzona integer,
    p_numlicencia integer,
    p_cvecuenta integer,
    p_calle varchar,
    p_numext varchar,
    p_telefono varchar,
    p_fecha_at date,
    p_fecha_inicial date,
    p_fecha_vencimiento date,
    p_movto_cve varchar,
    p_movto_usr integer,
    p_solicitud integer,
    p_control integer
) RETURNS TABLE(result integer, resultstr varchar) AS $$
BEGIN
    UPDATE pubmain SET
        sector = p_sector,
        zona = p_zona,
        subzona = p_subzona,
        numlicencia = p_numlicencia,
        cvecuenta = p_cvecuenta,
        calle = p_calle,
        numext = p_numext,
        telefono = p_telefono,
        fecha_at = p_fecha_at,
        fecha_inicial = p_fecha_inicial,
        fecha_vencimiento = p_fecha_vencimiento,
        movto_cve = p_movto_cve,
        movto_usr = p_movto_usr,
        solicitud = p_solicitud,
        control = p_control
    WHERE id = p_id;
    IF FOUND THEN
        result := 0;
        resultstr := 'Actualización exitosa';
    ELSE
        result := 1;
        resultstr := 'No se encontró el registro';
    END IF;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;