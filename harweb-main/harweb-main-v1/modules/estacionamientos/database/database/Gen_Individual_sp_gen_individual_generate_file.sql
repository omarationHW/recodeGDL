-- Stored Procedure: sp_gen_individual_generate_file
-- Tipo: Report
-- Descripción: Devuelve los datos de la remesa en formato de texto plano, cada campo separado por '|'.
-- Generado para formulario: Gen_Individual
-- Fecha: 2025-08-27 13:46:40

CREATE OR REPLACE FUNCTION sp_gen_individual_generate_file(
    p_remesa varchar
) RETURNS TABLE(
    idrmunicipio integer,
    tipoact varchar,
    folio varchar,
    fechagenreq varchar,
    placa varchar,
    folionot varchar,
    fechanot varchar,
    fechapago varchar,
    fechacancelado varchar,
    importe numeric,
    clave integer,
    fechaalta varchar,
    fechavenc varchar,
    folioec numeric,
    folioecmpio varchar,
    gastos numeric,
    remesa varchar,
    fecharemesa varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        idrmunicipio,
        tipoact,
        folio::varchar,
        to_char(fechagenreq, 'MM/DD/YYYY'),
        placa,
        folionot,
        to_char(fechanot, 'MM/DD/YYYY'),
        to_char(fechapago, 'MM/DD/YYYY'),
        to_char(fechacancelado, 'MM/DD/YYYY'),
        importe,
        clave,
        to_char(fechaalta, 'MM/DD/YYYY'),
        to_char(fechavenc, 'MM/DD/YYYY'),
        folioec,
        folioecmpio,
        gastos,
        remesa,
        to_char(fecharemesa, 'MM/DD/YYYY')
    FROM ta14_datos_mpio
    WHERE remesa = p_remesa;
END;
$$ LANGUAGE plpgsql;