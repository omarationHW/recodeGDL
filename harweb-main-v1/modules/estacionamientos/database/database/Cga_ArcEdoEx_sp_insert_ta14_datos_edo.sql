-- Stored Procedure: sp_insert_ta14_datos_edo
-- Tipo: CRUD
-- Descripción: Inserta un registro en ta14_datos_edo para la carga de pagos.
-- Generado para formulario: Cga_ArcEdoEx
-- Fecha: 2025-08-27 13:27:09

CREATE OR REPLACE FUNCTION sp_insert_ta14_datos_edo(
    vMpio integer,
    vTipoAct varchar,
    vFolio numeric,
    vPlaca varchar,
    vFecPago date,
    vImporte numeric,
    vFecAlta date,
    vRemesa varchar,
    vFecRemesa date
) RETURNS TABLE(success boolean, msg text) AS $$
BEGIN
    INSERT INTO ta14_datos_edo (
        mpio, tipoact, folio, teso_cve, placa,
        campo6, campo7, fecpago, campo9,
        importe, campo11, fecalta, campo13,
        campo14, campo15, campo16, remesa, fecharemesa, campo19, campo20, campo21
    ) VALUES (
        vMpio, vTipoAct, vFolio, NULL, vPlaca,
        NULL, NULL, vFecPago, NULL,
        vImporte, NULL, vFecAlta, NULL,
        NULL, NULL, NULL, vRemesa, vFecRemesa, NULL, NULL, NULL
    );
    RETURN QUERY SELECT true, 'OK';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, 'Error en la carga de folios: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;