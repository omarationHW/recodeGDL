-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: spubreports
-- Generado: 2025-08-27 14:52:31
-- Total SPs: 4
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

-- SP 2/4: spubreports_sector_summary
-- Tipo: Report
-- Descripción: Resumen de estacionamientos públicos por categoría y sector (Juarez, Reforma, Libertad, Hidalgo, Total).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spubreports_sector_summary()
RETURNS TABLE (
    categoria varchar(10),
    descripcion varchar(100),
    cant_j integer, capac_j integer,
    cant_r integer, capac_r integer,
    cant_l integer, capac_l integer,
    cant_h integer, capac_h integer,
    cant_t integer, capac_t integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.categoria,
        c.descripcion,
        SUM(CASE WHEN m.sector = 'J' THEN 1 ELSE 0 END) AS cant_j,
        SUM(CASE WHEN m.sector = 'J' THEN m.cupo ELSE 0 END) AS capac_j,
        SUM(CASE WHEN m.sector = 'R' THEN 1 ELSE 0 END) AS cant_r,
        SUM(CASE WHEN m.sector = 'R' THEN m.cupo ELSE 0 END) AS capac_r,
        SUM(CASE WHEN m.sector = 'L' THEN 1 ELSE 0 END) AS cant_l,
        SUM(CASE WHEN m.sector = 'L' THEN m.cupo ELSE 0 END) AS capac_l,
        SUM(CASE WHEN m.sector = 'H' THEN 1 ELSE 0 END) AS cant_h,
        SUM(CASE WHEN m.sector = 'H' THEN m.cupo ELSE 0 END) AS capac_h,
        COUNT(*) AS cant_t,
        SUM(m.cupo) AS capac_t
    FROM pubmain m
    JOIN pubcategoria c ON c.id = m.pubcategoria_id
    WHERE m.movto_cve <> 'C'
    GROUP BY c.categoria, c.descripcion
    ORDER BY c.categoria;
END;
$$ LANGUAGE plpgsql;

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

-- SP 4/4: spubreports_adeudos
-- Tipo: Report
-- Descripción: Devuelve la relación de adeudos y pagos de todos los estacionamientos públicos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spubreports_adeudos()
RETURNS TABLE (
    id integer,
    pubcategoria_id integer,
    categoria varchar(10),
    descripcion varchar(100),
    numesta integer,
    sector varchar(10),
    nomsector varchar(20),
    nombre varchar(100),
    calle varchar(100),
    numext varchar(10),
    cupo integer,
    axo_adeudo smallint,
    mes_ini_adeudo smallint,
    adeudos_ant numeric,
    adeudos_act numeric,
    axo_ult_pago smallint,
    mes_ult_pago smallint,
    proyectado numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id, a.pubcategoria_id, b.categoria, b.descripcion, a.numesta, a.sector,
        CASE a.sector
            WHEN 'J' THEN 'JUAREZ'
            WHEN 'H' THEN 'HIDALGO'
            WHEN 'L' THEN 'LIBERTAD'
            WHEN 'R' THEN 'REFORMA'
            ELSE 'S/N'
        END AS nomsector,
        a.nombre, a.calle, a.numext, a.cupo,
        (
            SELECT min(d.axo) FROM pubadeudo d WHERE d.pubmain_id = a.id AND tipo = 10
        ) AS axo_adeudo,
        (
            SELECT min(d.mes) FROM pubadeudo d WHERE d.pubmain_id = a.id AND tipo = 10
                AND axo = (
                    SELECT min(d2.axo) FROM pubadeudo d2 WHERE d2.pubmain_id = a.id AND tipo = 10
                )
        ) AS mes_ini_adeudo,
        (
            SELECT sum(c.ade_importe) FROM pubadeudo c WHERE c.pubmain_id = a.id AND c.axo < EXTRACT(YEAR FROM CURRENT_DATE)
        ) AS adeudos_ant,
        (
            SELECT sum(c.ade_importe) FROM pubadeudo c WHERE c.pubmain_id = a.id AND c.axo = EXTRACT(YEAR FROM CURRENT_DATE) AND (c.axo * 100) + c.mes <= (EXTRACT(YEAR FROM CURRENT_DATE) * 100) + EXTRACT(MONTH FROM CURRENT_DATE)
        ) AS adeudos_act,
        (
            SELECT sum(c.ade_importe) FROM pubadeudo c WHERE c.pubmain_id = a.id AND c.axo = EXTRACT(YEAR FROM CURRENT_DATE) AND (c.axo * 100) + c.mes > (EXTRACT(YEAR FROM CURRENT_DATE) * 100) + EXTRACT(MONTH FROM CURRENT_DATE)
        ) AS proyectado,
        (
            SELECT max(d.axo) FROM pubadeudo_histo d WHERE d.pubmain_id = a.id AND motivo = 'Pago En Reca'
        ) AS axo_ult_pago,
        (
            SELECT max(d.mes) FROM pubadeudo_histo d WHERE d.pubmain_id = a.id AND motivo = 'Pago En Reca' AND axo = (
                SELECT max(d2.axo) FROM pubadeudo_histo d2 WHERE d2.pubmain_id = a.id AND motivo = 'Pago En Reca'
            )
        ) AS mes_ult_pago
    FROM pubmain a
    JOIN pubcategoria b ON b.id = a.pubcategoria_id
    WHERE a.movto_cve <> 'C'
    ORDER BY a.numesta;
END;
$$ LANGUAGE plpgsql;

-- ============================================

