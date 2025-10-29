-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SPUBREPORTS (EXACTO del archivo original)
-- Archivo: 49_SP_ESTACIONAMIENTOS_SPUBREPORTS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: spubreports_list
-- Tipo: Report
-- Descripción: Devuelve la lista de estacionamientos públicos según el tipo de ordenamiento (por categoría, sector, número, nombre, calle, zona/subzona).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spubreports_list(opc integer)
RETURNS TABLE (
    id integer,
    pubcategoria_id integer,
    categoria varchar(10),
    descripcion varchar(100),
    numesta integer,
    sector varchar(10),
    nomsector varchar(20),
    zona integer,
    subzona integer,
    numlicencia integer,
    axolicencias integer,
    cvecuenta integer,
    nombre varchar(100),
    calle varchar(100),
    numext varchar(10),
    telefono varchar(20),
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
    ORDER BY
        CASE WHEN opc = 1 THEN b.categoria END,
        CASE WHEN opc = 2 THEN a.sector END,
        CASE WHEN opc = 3 THEN a.numesta END,
        CASE WHEN opc = 4 THEN a.nombre END,
        CASE WHEN opc = 5 THEN a.calle END,
        CASE WHEN opc = 7 THEN a.zona END,
        CASE WHEN opc = 7 THEN a.subzona END,
        a.numesta;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SPUBREPORTS (EXACTO del archivo original)
-- Archivo: 49_SP_ESTACIONAMIENTOS_SPUBREPORTS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: spubreports_edocta
-- Tipo: Report
-- Descripción: Devuelve el estado de cuenta de un estacionamiento público por número de estacionamiento.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spubreports_edocta(numesta integer)
RETURNS TABLE (
    id integer,
    pubcategoria_id integer,
    numesta integer,
    sector varchar(10),
    zona integer,
    subzona integer,
    numlicencia integer,
    axolicencias integer,
    cvecuenta integer,
    nombre varchar(100),
    calle varchar(100),
    numext varchar(10),
    telefono varchar(20),
    cupo integer,
    fecha_at date,
    fecha_inicial date,
    fecha_vencimiento date,
    rfc varchar(20),
    solicitud integer,
    control integer,
    movtos_no integer,
    movto_cve varchar(10),
    movto_usr integer,
    descripcion varchar(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id, a.pubcategoria_id, a.numesta, a.sector, a.zona, a.subzona, a.numlicencia, a.axolicencias, a.cvecuenta,
           a.nombre, a.calle, a.numext, a.telefono, a.cupo, a.fecha_at, a.fecha_inicial, a.fecha_vencimiento,
           a.rfc, a.solicitud, a.control, a.movtos_no, a.movto_cve, a.movto_usr, b.descripcion
    FROM pubmain a
    JOIN pubcategoria b ON b.id = a.pubcategoria_id
    WHERE a.numesta = numesta AND a.movto_cve <> 'C';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SPUBREPORTS (EXACTO del archivo original)
-- Archivo: 49_SP_ESTACIONAMIENTOS_SPUBREPORTS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

