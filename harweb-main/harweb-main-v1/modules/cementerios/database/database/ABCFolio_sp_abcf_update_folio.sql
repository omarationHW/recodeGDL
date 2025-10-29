-- Stored Procedure: sp_abcf_update_folio
-- Tipo: CRUD
-- Descripción: Actualiza los datos principales de un folio.
-- Generado para formulario: ABCFolio
-- Fecha: 2025-08-27 14:01:11

CREATE OR REPLACE PROCEDURE sp_abcf_update_folio(
    p_folio INTEGER,
    p_cementerio VARCHAR,
    p_clase SMALLINT,
    p_clase_alfa VARCHAR,
    p_seccion SMALLINT,
    p_seccion_alfa VARCHAR,
    p_linea SMALLINT,
    p_linea_alfa VARCHAR,
    p_fosa SMALLINT,
    p_fosa_alfa VARCHAR,
    p_axo_pagado INTEGER,
    p_metros FLOAT,
    p_nombre VARCHAR,
    p_domicilio VARCHAR,
    p_exterior VARCHAR,
    p_interior VARCHAR,
    p_colonia VARCHAR,
    p_observaciones VARCHAR,
    p_tipo VARCHAR,
    p_usuario INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ta_13_datosrcm SET
        cementerio = p_cementerio,
        clase = p_clase,
        clase_alfa = p_clase_alfa,
        seccion = p_seccion,
        seccion_alfa = p_seccion_alfa,
        linea = p_linea,
        linea_alfa = p_linea_alfa,
        fosa = p_fosa,
        fosa_alfa = p_fosa_alfa,
        axo_pagado = p_axo_pagado,
        metros = p_metros,
        nombre = p_nombre,
        domicilio = p_domicilio,
        exterior = p_exterior,
        interior = p_interior,
        colonia = p_colonia,
        observaciones = p_observaciones,
        usuario = p_usuario,
        fecha_mov = CURRENT_DATE,
        tipo = p_tipo
    WHERE control_rcm = p_folio;
    -- Lógica de histórico
    CALL sp_13_historia(p_folio);
END;
$$;