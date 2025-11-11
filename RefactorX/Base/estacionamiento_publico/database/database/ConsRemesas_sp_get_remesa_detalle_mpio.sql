-- Stored Procedure: sp_get_remesa_detalle_mpio
-- Tipo: Report
-- Descripción: Obtiene el detalle de una remesa municipal (tabla ta14_datos_mpio) por nombre de remesa.
-- Generado para formulario: ConsRemesas
-- Fecha: 2025-08-27 13:30:41

CREATE OR REPLACE FUNCTION sp_get_remesa_detalle_mpio(remesa_param character varying)
RETURNS TABLE(
    idrmunicipio integer,
    tipoact varchar,
    folio bigint,
    fechagenreq date,
    placa varchar,
    folionot varchar,
    fechanot date,
    fechapago date,
    fechacancelado date,
    importe numeric,
    clave varchar,
    fechaalta date,
    fechavenc date,
    folioec varchar,
    folioecmpio varchar,
    gastos numeric,
    remesa varchar,
    fecharemesa date
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.idrmunicipio, t.tipoact, t.folio, t.fechagenreq, t.placa,
        t.folionot, t.fechanot, t.fechapago, t.fechacancelado, t.importe,
        t.clave, t.fechaalta, t.fechavenc, t.folioec, t.folioecmpio,
        t.gastos, t.remesa, t.fecharemesa
    FROM ta14_datos_mpio t
    WHERE t.remesa = remesa_param;
END;
$$ LANGUAGE plpgsql;