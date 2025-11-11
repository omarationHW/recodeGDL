-- Stored Procedure: sp_get_remesa_detalle_edo
-- Tipo: Report
-- Descripción: Obtiene el detalle de una remesa del estado (tabla ta14_datos_edo) por nombre de remesa.
-- Generado para formulario: ConsRemesas
-- Fecha: 2025-08-27 13:30:41

CREATE OR REPLACE FUNCTION sp_get_remesa_detalle_edo(remesa_param character varying)
RETURNS TABLE(
    mpio integer,
    tipoact varchar,
    folio numeric,
    teso_cve varchar,
    placa varchar,
    campo6 varchar,
    campo7 varchar,
    fecpago date,
    campo9 varchar,
    importe numeric,
    campo11 varchar,
    fecalta date,
    campo13 varchar,
    campo14 varchar,
    campo15 varchar,
    campo16 varchar,
    remesa varchar,
    fecharemesa date,
    campo19 varchar,
    campo20 varchar,
    campo21 varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.mpio, t.tipoact, t.folio, t.teso_cve, t.placa,
        t.campo6, t.campo7, t.fecpago, t.campo9,
        t.importe, t.campo11, t.fecalta, t.campo13,
        t.campo14, t.campo15, t.campo16, t.remesa, t.fecharemesa, t.campo19, t.campo20, t.campo21
    FROM ta14_datos_edo t
    WHERE t.remesa = remesa_param;
END;
$$ LANGUAGE plpgsql;