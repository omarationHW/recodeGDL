-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: spublicosnewfrm
-- Generado: 2025-08-27 14:50:43
-- Total SPs: 3
-- ============================================

-- SP 1/3: sppubalta
-- Tipo: CRUD
-- Descripción: Alta de estacionamiento público. Inserta un registro en pubmain y retorna resultado, mensaje y el id nuevo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sppubalta(
    pubcategoria_id integer,
    numesta integer,
    sector varchar,
    zona integer,
    subzona integer,
    numlicencia integer,
    axolicencias integer,
    cvecuenta integer,
    nombre varchar,
    calle varchar,
    numext varchar,
    telefono varchar,
    cupo integer,
    fecha_at date,
    fecha_inicial date,
    fecha_vencimiento date,
    rfc varchar,
    movtos_no integer,
    movto_cve varchar,
    movto_usr integer,
    solicitud integer,
    control integer
) RETURNS TABLE(result integer, resultstr varchar, idnvo integer) AS $$
DECLARE
    new_id integer;
BEGIN
    INSERT INTO pubmain (
        pubcategoria_id, numesta, sector, zona, subzona, numlicencia, axolicencias, cvecuenta, nombre, calle, numext, telefono, cupo, fecha_at, fecha_inicial, fecha_vencimiento, rfc, solicitud, control, movtos_no, movto_cve, movto_usr
    ) VALUES (
        pubcategoria_id, numesta, sector, zona, subzona, numlicencia, axolicencias, cvecuenta, nombre, calle, numext, telefono, cupo, fecha_at, fecha_inicial, fecha_vencimiento, rfc, solicitud, control, movtos_no, movto_cve, movto_usr
    ) RETURNING id INTO new_id;
    result := 1;
    resultstr := 'Alta exitosa';
    idnvo := new_id;
    RETURN NEXT;
EXCEPTION WHEN OTHERS THEN
    result := 0;
    resultstr := 'Error: ' || SQLERRM;
    idnvo := NULL;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_pubadeudo_forma
-- Tipo: CRUD
-- Descripción: Alta de adeudo por formato (pubadeudo) para el estacionamiento público.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_pubadeudo_forma(
    pubmain_id integer,
    axo integer,
    mes integer,
    concepto varchar,
    ade_importe numeric,
    id_usuario integer
) RETURNS TABLE(result integer, resultstr varchar) AS $$
DECLARE
    new_id integer;
BEGIN
    INSERT INTO pubadeudo (
        fecha_at, pubmain_id, axo, mes, tipo, concepto, ade_importe, ade_descto, id_usuario
    ) VALUES (
        CURRENT_DATE, pubmain_id, axo, mes, 2, concepto, ade_importe, 0, id_usuario
    ) RETURNING id INTO new_id;
    result := 1;
    resultstr := 'Adeudo registrado';
    RETURN NEXT;
EXCEPTION WHEN OTHERS THEN
    result := 0;
    resultstr := 'Error: ' || SQLERRM;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: cons_predio
-- Tipo: CRUD
-- Descripción: Consulta de predio por clave predial. Retorna todos los datos relevantes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION cons_predio(
    opc integer,
    dato varchar
) RETURNS TABLE(
    cvecuenta integer,
    recaud integer,
    tipo varchar,
    cuenta integer,
    cvecatastral varchar,
    subpredio integer,
    contribuyente varchar,
    calle varchar,
    numext varchar,
    numint varchar,
    zona integer,
    subzona integer,
    status integer,
    mensaje varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecuenta, recaud, tipo, cuenta, cvecatastral, subpredio, contribuyente, calle, numext, numint, zona, subzona, status, mensaje
    FROM predios
    WHERE cvecatastral = dato
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

