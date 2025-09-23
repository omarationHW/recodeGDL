-- Stored Procedure: sp_consultareg_cementerios
-- Tipo: Catalog
-- Descripción: Busca un registro de cementerio por folio.
-- Generado para formulario: ConsultaReg
-- Fecha: 2025-08-27 13:40:42

CREATE OR REPLACE FUNCTION sp_consultareg_cementerios(
    p_folio integer
) RETURNS TABLE (
    control_rcm integer,
    cementerio varchar,
    clase smallint,
    clase_alfa varchar,
    seccion smallint,
    seccion_alfa varchar,
    linea smallint,
    linea_alfa varchar,
    fosa smallint,
    fosa_alfa varchar,
    axo_pagado integer,
    metros float,
    nombre varchar,
    domicilio varchar,
    exterior varchar,
    interior varchar,
    colonia varchar,
    observaciones varchar,
    usuario integer,
    fecha_mov date,
    tipo varchar,
    fecha_alta date,
    vigencia varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta_13_datosrcm WHERE control_rcm = p_folio LIMIT 1;
END;
$$ LANGUAGE plpgsql;