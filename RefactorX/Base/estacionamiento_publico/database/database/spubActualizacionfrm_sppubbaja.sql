-- Stored Procedure: sppubbaja
-- Tipo: CRUD
-- Descripción: Da de baja un estacionamiento público
-- Generado para formulario: spubActualizacionfrm
-- Fecha: 2025-08-27 14:48:13

CREATE OR REPLACE FUNCTION sppubbaja(
    p_id integer,
    p_movto_cve varchar,
    p_movto_usr integer,
    p_folio integer,
    p_fecbaja date
) RETURNS TABLE(result integer, resultstr varchar) AS $$
BEGIN
    UPDATE pubmain SET
        movto_cve = p_movto_cve,
        movto_usr = p_movto_usr,
        folio_baja = p_folio,
        fecha_baja = p_fecbaja
    WHERE id = p_id;
    IF FOUND THEN
        result := 0;
        resultstr := 'Baja exitosa';
    ELSE
        result := 1;
        resultstr := 'No se encontró el registro';
    END IF;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;