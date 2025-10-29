-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: TITULOSSIN (EXACTO del archivo original)
-- Archivo: 32_SP_CEMENTERIOS_TITULOSSIN_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_titulosin_get_folio
-- Tipo: CRUD
-- Descripción: Obtiene los datos del folio para impresión de título sin referencias.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_titulosin_get_folio(
    p_folio INTEGER,
    p_fecha DATE,
    p_operacion INTEGER
) RETURNS TABLE(
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
    nombre_1 VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.control_rcm, b.cementerio, b.clase, b.clase_alfa, b.seccion, b.seccion_alfa, b.linea, b.linea_alfa, b.fosa, b.fosa_alfa, b.axo_pagado, b.metros, b.nombre, b.domicilio, b.exterior, b.interior, b.colonia, b.observaciones, b.usuario, b.fecha_mov, b.tipo, c.nombre as nombre_1
    FROM public.ta_13_datosrcm b
    JOIN tc_13_cementerios c ON b.cementerio = c.cementerio
    WHERE b.control_rcm = p_folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: TITULOSSIN (EXACTO del archivo original)
-- Archivo: 32_SP_CEMENTERIOS_TITULOSSIN_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp_titulosin_get_ingresos
-- Tipo: CRUD
-- Descripción: Obtiene los datos de ingresos para la impresión del título.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_titulosin_get_ingresos(
    p_fecha DATE,
    p_ofna SMALLINT,
    p_caja VARCHAR,
    p_operacion INTEGER
) RETURNS TABLE(
    fecha DATE,
    id_rec SMALLINT,
    caja VARCHAR,
    operacion INTEGER,
    importe NUMERIC,
    cvepago VARCHAR,
    id_modulo INTEGER,
    id_regmodulo INTEGER,
    id_rec_cta SMALLINT,
    regmunur VARCHAR,
    mesdesde SMALLINT,
    axodesde SMALLINT,
    meshasta SMALLINT,
    axohasta SMALLINT,
    nombre VARCHAR,
    domicilio VARCHAR,
    concepto VARCHAR,
    rfcini VARCHAR,
    rfcnumero INTEGER,
    rfccolonia SMALLINT,
    obra SMALLINT,
    axofolio INTEGER,
    id_usuario INTEGER,
    fecha_act TIMESTAMP,
    cajero VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.*, (SELECT nombre FROM public.ta_12_passwords WHERE id_usuario = a.id_usuario) as cajero
    FROM public.ta_12_recibos a
    WHERE a.fecha = p_fecha
      AND a.id_rec = p_ofna
      AND a.caja = p_caja
      AND a.operacion = p_operacion
      AND a.id_modulo = 12
      AND (
        SELECT COUNT(*) FROM public.ta_12_recibosdet
        WHERE fecha = a.fecha AND a.id_rec = id_rec AND a.caja = caja AND a.operacion = operacion
          AND cuenta IN (44304, 44301, 44307, 44314, 44311, 44310, 44450)
      ) > 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: TITULOSSIN (EXACTO del archivo original)
-- Archivo: 32_SP_CEMENTERIOS_TITULOSSIN_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

