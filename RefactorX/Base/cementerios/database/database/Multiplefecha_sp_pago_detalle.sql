-- Stored Procedure: sp_pago_detalle
-- Tipo: Report
-- Descripción: Devuelve el detalle de un pago individual por control_rcm
-- Generado para formulario: Multiplefecha
-- Fecha: 2025-08-27 14:40:23

-- PostgreSQL stored procedure for detalle individual
CREATE OR REPLACE FUNCTION sp_pago_detalle(
    p_control_rcm INTEGER
)
RETURNS TABLE (
    control_rcm INTEGER,
    cementerio VARCHAR(10),
    clase INTEGER,
    clase_alfa VARCHAR(10),
    seccion INTEGER,
    seccion_alfa VARCHAR(10),
    linea INTEGER,
    linea_alfa VARCHAR(10),
    fosa INTEGER,
    fosa_alfa VARCHAR(10),
    axo_pagado INTEGER,
    metros NUMERIC,
    nombre VARCHAR(100),
    domicilio VARCHAR(100),
    exterior VARCHAR(20),
    interior VARCHAR(20),
    colonia VARCHAR(50),
    observaciones VARCHAR(255),
    usuario INTEGER,
    fecha_mov DATE,
    tipo VARCHAR(2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, axo_pagado, metros, nombre, domicilio, exterior, interior, colonia, observaciones, usuario, fecha_mov, tipo
      FROM ta_13_datosrcm
     WHERE control_rcm = p_control_rcm;
END;
$$ LANGUAGE plpgsql;