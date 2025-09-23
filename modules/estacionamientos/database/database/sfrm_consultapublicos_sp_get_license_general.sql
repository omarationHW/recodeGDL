-- Stored Procedure: sp_get_license_general
-- Tipo: Report
-- Descripción: Obtiene los datos generales de una licencia por su número.
-- Generado para formulario: sfrm_consultapublicos
-- Fecha: 2025-08-27 16:04:06

CREATE OR REPLACE FUNCTION sp_get_license_general(numlicencia integer, cero integer, reca integer)
RETURNS TABLE (
    clave integer,
    msg varchar(100),
    id integer,
    bloq integer,
    vigente varchar(1),
    id_giro integer,
    desc_giro varchar(96),
    actividad varchar(130),
    reglamentada varchar(1),
    propietario varchar(80),
    ubicacion varchar(50),
    numext integer,
    letext varchar(3),
    numint varchar(5),
    letint varchar(3),
    colonia varchar(25),
    zona integer,
    subzona integer,
    espubic varchar(100),
    asiento integer,
    curp varchar(18),
    sup_autorizada float,
    num_cajones integer,
    aforo integer,
    rhorario varchar(70),
    fecha_consejo date,
    cvecatnva varchar(11),
    subpredio integer,
    mensaje1 varchar(85),
    v_mensaje2 varchar(85),
    mensaje3 varchar(200),
    mensaje4 varchar(250),
    mensaje4_1 varchar(250),
    tipotramite varchar(50),
    desc_reglam varchar(50),
    rfc varchar(13),
    licencia integer,
    mensaje5 varchar(250),
    mensaje6 varchar(250),
    mensaje7 varchar(250),
    mensaje8 varchar(250)
) AS $$
BEGIN
    -- Aquí debe ir la lógica de obtención de datos generales de licencia
    RETURN QUERY
    SELECT clave, msg, id, bloq, vigente, id_giro, desc_giro, actividad, reglamentada, propietario,
           ubicacion, numext, letext, numint, letint, colonia, zona, subzona, espubic, asiento, curp,
           sup_autorizada, num_cajones, aforo, rhorario, fecha_consejo, cvecatnva, subpredio, mensaje1,
           v_mensaje2, mensaje3, mensaje4, mensaje4_1, tipotramite, desc_reglam, rfc, licencia,
           mensaje5, mensaje6, mensaje7, mensaje8
    FROM vw_licencias_generales
    WHERE licencia = numlicencia;
END;
$$ LANGUAGE plpgsql;