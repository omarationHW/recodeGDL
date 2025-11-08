-- Stored Procedure: sp_abcf_get_folio
-- Tipo: CRUD
-- Descripción: Obtiene todos los datos de un folio, incluyendo datos adicionales y adeudos.
-- Generado para formulario: ABCFolio
-- Fecha: 2025-08-27 14:01:11

CREATE OR REPLACE FUNCTION sp_abcf_get_folio(p_folio INTEGER)
RETURNS TABLE (
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
    fecha_alta DATE,
    vigencia VARCHAR,
    usuario_nombre VARCHAR,
    id_rec SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_rcm, a.cementerio, a.clase, a.clase_alfa, a.seccion, a.seccion_alfa, a.linea, a.linea_alfa, a.fosa, a.fosa_alfa, a.axo_pagado, a.metros, a.nombre, a.domicilio, a.exterior, a.interior, a.colonia, a.observaciones, a.usuario, a.fecha_mov, a.tipo, a.fecha_alta, a.vigencia, c.nombre, c.id_rec
    FROM ta_13_datosrcm a
    LEFT JOIN ta_12_passwords c ON a.usuario = c.id_usuario
    WHERE a.control_rcm = p_folio;
END;
$$ LANGUAGE plpgsql;