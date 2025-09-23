-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptTitulos
-- Generado: 2025-08-27 14:51:51
-- Total SPs: 3
-- ============================================

-- SP 1/3: rpt_titulos_get_report
-- Tipo: Report
-- Descripción: Obtiene el reporte de títulos con todos los datos requeridos para una fecha y folio dados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_titulos_get_report(fechapag date, fol integer)
RETURNS TABLE (
    titulo integer,
    control_rcm integer,
    fecha date,
    id_rec smallint,
    caja varchar,
    operacion integer,
    importe numeric,
    observaciones varchar,
    control_rcm_1 integer,
    cementerio varchar,
    clase smallint,
    clase_alfa varchar,
    seccion smallint,
    seccion_alfa varchar,
    linea smallint,
    linea_alfa varchar,
    fosa smallint,
    fosa_alfa varchar,
    axo_pagado integer,
    metros float,
    nombre varchar,
    domicilio varchar,
    exterior varchar,
    interior varchar,
    colonia varchar,
    observaciones_1 varchar,
    usuario integer,
    fecha_mov date,
    tipo varchar,
    nombre_1 varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.titulo, a.control_rcm, a.fecha, a.id_rec, a.caja, a.operacion, a.importe, a.observaciones,
           b.control_rcm as control_rcm_1, b.cementerio, b.clase, b.clase_alfa, b.seccion, b.seccion_alfa, b.linea, b.linea_alfa, b.fosa, b.fosa_alfa, b.axo_pagado, b.metros, b.nombre, b.domicilio, b.exterior, b.interior, b.colonia, b.observaciones as observaciones_1, b.usuario, b.fecha_mov, b.tipo,
           c.nombre as nombre_1
    FROM ta_13_titulos a
    JOIN ta_13_datosrcm b ON a.control_rcm = b.control_rcm
    JOIN tc_13_cementerios c ON b.cementerio = c.cementerio
    WHERE a.fecha = fechapag AND a.control_rcm = fol;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: rpt_titulos_get_recaudadora
-- Tipo: Catalog
-- Descripción: Obtiene los datos de la recaudadora por id_rec.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_titulos_get_recaudadora(rec smallint)
RETURNS TABLE (
    recing smallint,
    nomre varchar,
    titulo varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT recing, nomre, titulo
    FROM ta_12_nombrerec
    WHERE recing = rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: rpt_titulos_fecha_aletras_corta
-- Tipo: CRUD
-- Descripción: Convierte una fecha a formato 'dd-Mes-aaaa' en español abreviado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_titulos_fecha_aletras_corta(fecha date)
RETURNS varchar AS $$
DECLARE
    meses text[] := ARRAY['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    d integer;
    m integer;
    y integer;
BEGIN
    d := EXTRACT(DAY FROM fecha);
    m := EXTRACT(MONTH FROM fecha);
    y := EXTRACT(YEAR FROM fecha);
    RETURN d::text || '-' || meses[m] || '-' || y::text;
END;
$$ LANGUAGE plpgsql;

-- ============================================

