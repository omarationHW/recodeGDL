-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sfrm_consultapublicos
-- Generado: 2025-08-27 16:04:06
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_get_public_parking_list
-- Tipo: Catalog
-- Descripción: Obtiene la lista de estacionamientos públicos con sus datos principales.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_public_parking_list()
RETURNS TABLE (
    id integer,
    pubcategoria_id integer,
    categoria varchar(2),
    descripcion varchar,
    numesta integer,
    sector varchar(1),
    nomsector varchar(8),
    zona integer,
    subzona integer,
    numlicencia integer,
    axolicencias integer,
    cvecuenta integer,
    nombre varchar(100),
    calle varchar(100),
    numext varchar(6),
    telefono varchar(15),
    cupo integer,
    fecha_at date,
    fecha_inicial date,
    fecha_vencimiento date
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id, a.pubcategoria_id, b.categoria, b.descripcion, a.numesta,
           a.sector,
           CASE a.sector
               WHEN 'J' THEN 'JUAREZ'
               WHEN 'H' THEN 'HIDALGO'
               WHEN 'L' THEN 'LIBERTAD'
               WHEN 'R' THEN 'REFORMA'
               ELSE 'S/N'
           END AS nomsector,
           a.zona, a.subzona, a.numlicencia, a.axolicencias, a.cvecuenta,
           a.nombre, a.calle, a.numext, a.telefono, a.cupo, a.fecha_at, a.fecha_inicial, a.fecha_vencimiento
    FROM pubmain a
    JOIN pubcategoria b ON b.id = a.pubcategoria_id
    WHERE a.movto_cve <> 'C'
    ORDER BY b.categoria, a.numesta;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_get_public_parking_debts
-- Tipo: Report
-- Descripción: Obtiene los adeudos de un estacionamiento público por su ID.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_public_parking_debts(pubid integer)
RETURNS TABLE (
    concepto varchar(50),
    axo integer,
    mes integer,
    adeudo numeric(12,2),
    recargos numeric(12,2)
) AS $$
BEGIN
    -- Aquí debe ir la lógica de cálculo de adeudos, por ejemplo:
    RETURN QUERY
    SELECT concepto, axo, mes, adeudo, recargos
    FROM cajero_pub_detalle(3, pubid, 0, 0);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_get_public_parking_fines
-- Tipo: Report
-- Descripción: Obtiene las multas asociadas a un número de licencia.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_public_parking_fines(numlicencia integer)
RETURNS TABLE (
    id_multa integer,
    id_dependencia smallint,
    axo_acta smallint,
    num_acta integer,
    fecha_acta date,
    fecha_recepcion date,
    contribuyente varchar(50),
    domicilio varchar(80),
    recaud smallint,
    num_licencia integer,
    giro varchar(80),
    id_ley smallint,
    id_infraccion smallint,
    expediente varchar(50),
    calificacion numeric(12,2),
    multa numeric(12,2),
    gastos numeric(12,2),
    total numeric(12,2),
    fecha_plazo date,
    comentario varchar(255),
    tipo varchar(1),
    noexterior varchar(6),
    interior varchar(5)
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_multa, id_dependencia, axo_acta, num_acta, fecha_acta,
           fecha_recepcion, contribuyente, domicilio, recaud, num_licencia, giro,
           id_ley, id_infraccion, expediente, calificacion, multa, gastos, total,
           fecha_plazo, comentario, tipo, noexterior, interior
    FROM multas
    WHERE num_licencia = numlicencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_get_license_general
-- Tipo: Report
-- Descripción: Obtiene los datos generales de una licencia por su número.
-- --------------------------------------------

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

-- ============================================

-- SP 5/5: sp_get_license_totals
-- Tipo: Report
-- Descripción: Obtiene los totales de una licencia (conceptos e importes).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_license_totals(id_licencia integer, tipo_l varchar, redon varchar)
RETURNS TABLE (
    cuenta integer,
    obliga varchar(1),
    concepto varchar(150),
    importe numeric(12,2),
    licanun integer
) AS $$
BEGIN
    -- Aquí debe ir la lógica de obtención de totales de licencia
    RETURN QUERY
    SELECT cuenta, obliga, concepto, importe, licanun
    FROM vw_licencias_totales
    WHERE id_licencia = id_licencia AND tipo_l = tipo_l AND redon = redon;
END;
$$ LANGUAGE plpgsql;

-- ============================================

