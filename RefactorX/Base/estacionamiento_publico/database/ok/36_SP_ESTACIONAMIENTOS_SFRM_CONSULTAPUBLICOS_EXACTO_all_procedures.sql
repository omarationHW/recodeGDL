-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_CONSULTAPUBLICOS (EXACTO del archivo original)
-- Archivo: 36_SP_ESTACIONAMIENTOS_SFRM_CONSULTAPUBLICOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_CONSULTAPUBLICOS (EXACTO del archivo original)
-- Archivo: 36_SP_ESTACIONAMIENTOS_SFRM_CONSULTAPUBLICOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_CONSULTAPUBLICOS (EXACTO del archivo original)
-- Archivo: 36_SP_ESTACIONAMIENTOS_SFRM_CONSULTAPUBLICOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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

