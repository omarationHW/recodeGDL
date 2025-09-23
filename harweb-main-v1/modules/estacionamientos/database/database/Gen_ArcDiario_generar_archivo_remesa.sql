-- Stored Procedure: generar_archivo_remesa
-- Tipo: Report
-- Descripción: Devuelve los registros de la remesa para generar el archivo de texto
-- Generado para formulario: Gen_ArcDiario
-- Fecha: 2025-08-27 20:40:42

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
        idrmunicipio, tipoact, folio, 
        TO_CHAR(fechagenreq, 'MM/DD/YYYY'), 
        placa, TRIM(folionot), TO_CHAR(fechanot, 'MM/DD/YYYY'), 
        TO_CHAR(fechapago, 'MM/DD/YYYY'), 
        TO_CHAR(fechacancelado, 'MM/DD/YYYY'), 
        importe, clave, 
        TO_CHAR(fechaalta, 'MM/DD/YYYY'), 
        TO_CHAR(fechavenc, 'MM/DD/YYYY'), 
        folioec, TRIM(folioecmpio), gastos, remesa, 
        TO_CHAR(fecharemesa, 'MM/DD/YYYY')
    FROM ta14_datos_mpio WHERE remesa = p_remesa;
END;
$$ LANGUAGE plpgsql;