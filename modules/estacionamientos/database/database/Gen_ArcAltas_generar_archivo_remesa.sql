-- Stored Procedure: generar_archivo_remesa
-- Tipo: Report
-- Descripción: Devuelve los registros de la remesa para exportar a archivo de texto.
-- Generado para formulario: Gen_ArcAltas
-- Fecha: 2025-08-27 13:40:51

-- PostgreSQL function to get remesa data
CREATE OR REPLACE FUNCTION generar_archivo_remesa(p_remesa text)
RETURNS TABLE(
    idrmunicipio integer,
    tipoact text,
    folio text,
    fechagenreq text,
    placa text,
    folionot text,
    fechanot text,
    fechapago text,
    fechacancelado text,
    importe numeric,
    clave integer,
    fechaalta text,
    fechavenc text,
    folioec numeric,
    folioecmpio text,
    gastos numeric,
    remesa text,
    fecharemesa text
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        idrmunicipio,
        tipoact,
        folio,
        to_char(fechagenreq, 'MM/DD/YYYY'),
        placa,
        trim(folionot),
        to_char(fechanot, 'MM/DD/YYYY'),
        to_char(fechapago, 'MM/DD/YYYY'),
        to_char(fechacancelado, 'MM/DD/YYYY'),
        importe,
        clave,
        to_char(fechaalta, 'MM/DD/YYYY'),
        to_char(fechavenc, 'MM/DD/YYYY'),
        folioec,
        trim(folioecmpio),
        gastos,
        remesa,
        to_char(fecharemesa, 'MM/DD/YYYY')
    FROM ta14_datos_mpio WHERE remesa = p_remesa;
END;
$$ LANGUAGE plpgsql;