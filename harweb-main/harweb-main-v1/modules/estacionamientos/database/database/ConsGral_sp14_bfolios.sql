-- Stored Procedure: sp14_bfolios
-- Tipo: Report
-- Descripción: Devuelve los folios asociados a una placa desde la fuente secundaria (equivalente a la consulta de ta14_datos_mpio en Delphi).
-- Generado para formulario: ConsGral
-- Fecha: 2025-08-27 13:28:56

CREATE OR REPLACE FUNCTION sp14_bfolios(parPlaca VARCHAR)
RETURNS TABLE (
    tipoact VARCHAR(2),
    placa VARCHAR(9),
    axo INTEGER,
    folio INTEGER,
    fechaalta DATE,
    fechapago DATE,
    fechacancelado DATE,
    importe NUMERIC(18,2),
    folioecmpio VARCHAR(50),
    remesa VARCHAR(50),
    fecharemesa DATE,
    concepto VARCHAR(120),
    fecha_in DATE,
    fecha_fin DATE,
    fecha_aplic DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.tipoact,
        b.placa,
        b.axo,
        b.folio,
        b.fechaalta,
        b.fechapago,
        b.fechacancelado,
        b.importe,
        b.folioecmpio,
        b.remesa,
        b.fecharemesa,
        b.concepto,
        b.fecha_in,
        b.fecha_fin,
        b.fecha_aplic
    FROM ta14_datos_mpio b
    WHERE b.placa = parPlaca;
END;
$$ LANGUAGE plpgsql;