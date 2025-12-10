-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: RPTTITULOS (EXACTO del archivo original)
-- Archivo: 31_SP_CEMENTERIOS_RPTTITULOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
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
    FROM public.ta_13_titulos a
    JOIN public.ta_13_datosrcm b ON a.control_rcm = b.control_rcm
    JOIN tc_13_cementerios c ON b.cementerio = c.cementerio
    WHERE a.fecha = fechapag AND a.control_rcm = fol;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: RPTTITULOS (EXACTO del archivo original)
-- Archivo: 31_SP_CEMENTERIOS_RPTTITULOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
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

-- SP 4/4: sp_rpttitulos_reporte_titulos
-- Tipo: Report
-- Descripción: Genera reporte de títulos emitidos por rango de fechas y cementerio
-- NUEVO 2025-12-01
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rpttitulos_reporte_titulos(
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_cementerio VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    titulo INTEGER,
    fecha DATE,
    control_rcm INTEGER,
    nombre VARCHAR,
    cementerio VARCHAR,
    clase SMALLINT,
    clase_alfa VARCHAR,
    seccion SMALLINT,
    seccion_alfa VARCHAR,
    linea SMALLINT,
    linea_alfa VARCHAR,
    fosa SMALLINT,
    fosa_alfa VARCHAR,
    importe NUMERIC,
    recaudacion VARCHAR,
    libro INTEGER,
    axo SMALLINT,
    folio_libro INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.titulo,
        t.fecha,
        t.control_rcm,
        d.nombre,
        d.cementerio,
        d.clase,
        d.clase_alfa,
        d.seccion,
        d.seccion_alfa,
        d.linea,
        d.linea_alfa,
        d.fosa,
        d.fosa_alfa,
        t.importe,
        COALESCE(r.nombre, 'N/A') AS recaudacion,
        t.libro,
        t.axo,
        t.folio AS folio_libro
    FROM cementerio.ta_13_titulos t
    LEFT JOIN comun.ta_13_datosrcm d ON t.control_rcm = d.control_rcm
    LEFT JOIN padron_licencias.comun.ta_12_recaudadoras r ON t.id_rec = r.id_rec
    WHERE t.fecha BETWEEN p_fecha_desde AND p_fecha_hasta
      AND (p_cementerio IS NULL OR d.cementerio = p_cementerio)
    ORDER BY t.fecha DESC, t.titulo DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

