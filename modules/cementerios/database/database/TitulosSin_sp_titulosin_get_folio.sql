-- Stored Procedure: sp_titulosin_get_folio
-- Tipo: CRUD
-- Descripción: Obtiene los datos del folio para impresión de título sin referencias.
-- Generado para formulario: TitulosSin
-- Fecha: 2025-08-27 14:58:45

CREATE OR REPLACE FUNCTION sp_titulosin_get_folio(
    p_folio INTEGER,
    p_fecha DATE,
    p_operacion INTEGER
) RETURNS TABLE(
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase SMALLINT,
    clase_alfa VARCHAR,
    seccion SMALLINT,
    seccion_alfa VARCHAR,
    linea SMALLINT,
    linea_alfa VARCHAR,
    fosa SMALLINT,
    fosa_alfa VARCHAR,
    axo_pagado INTEGER,
    metros FLOAT,
    nombre VARCHAR,
    domicilio VARCHAR,
    exterior VARCHAR,
    interior VARCHAR,
    colonia VARCHAR,
    observaciones VARCHAR,
    usuario INTEGER,
    fecha_mov DATE,
    tipo VARCHAR,
    nombre_1 VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.control_rcm, b.cementerio, b.clase, b.clase_alfa, b.seccion, b.seccion_alfa, b.linea, b.linea_alfa, b.fosa, b.fosa_alfa, b.axo_pagado, b.metros, b.nombre, b.domicilio, b.exterior, b.interior, b.colonia, b.observaciones, b.usuario, b.fecha_mov, b.tipo, c.nombre as nombre_1
    FROM ta_13_datosrcm b
    JOIN tc_13_cementerios c ON b.cementerio = c.cementerio
    WHERE b.control_rcm = p_folio;
END;
$$ LANGUAGE plpgsql;