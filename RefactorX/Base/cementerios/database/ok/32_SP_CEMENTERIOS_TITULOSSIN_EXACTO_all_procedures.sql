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
--
-- CORRECCIONES POSTGRESQL - AGENTE CATALIZADOR
-- Fecha: 2025-12-04
-- Total Correcciones: 24
--
-- Correcciones aplicadas:
-- SP 1: sp_titulosin_get_folio
-- 1. cementerio: VARCHAR → CHAR(1)
-- 2. clase_alfa: VARCHAR → VARCHAR(10)
-- 3. seccion_alfa: VARCHAR → VARCHAR(10)
-- 4. linea_alfa: VARCHAR → VARCHAR(20)
-- 5. fosa_alfa: VARCHAR → VARCHAR(20)
-- 6. metros: FLOAT → NUMERIC
-- 7. nombre: VARCHAR → VARCHAR(60) (2 ocurrencias)
-- 8. domicilio: VARCHAR → VARCHAR(60)
-- 9. exterior: VARCHAR → CHAR(6)
-- 10. interior: VARCHAR → CHAR(6)
-- 11. colonia: VARCHAR → VARCHAR(30)
-- 12. observaciones: VARCHAR → VARCHAR(60)
-- 13. tipo: VARCHAR → CHAR(1)
--
-- SP 3: sp_titulosin_get_ingresos
-- 14. caja: VARCHAR → CHAR(2) (2 ocurrencias)
-- 15. importe: NUMERIC → NUMERIC(16,2)
-- 16. cvepago: VARCHAR → CHAR(1)
-- 17. regmunur: VARCHAR → CHAR(1)
-- 18. nombre: VARCHAR → VARCHAR(60)
-- 19. domicilio: VARCHAR → VARCHAR(60)
-- 20. concepto: VARCHAR → VARCHAR(60)
-- 21. rfcini: VARCHAR → CHAR(3)
-- 22. obra: SMALLINT → INTEGER
-- 23. cajero: VARCHAR → VARCHAR(50)
-- ============================================

-- SP 1/4: sp_titulosin_get_folio
-- Tipo: CRUD
-- Descripción: Obtiene los datos del folio para impresión de título sin referencias.
-- --------------------------------------------


CREATE OR REPLACE FUNCTION sp_titulosin_get_folio(
    p_folio INTEGER
) RETURNS TABLE(
    control_rcm INTEGER,
    cementerio CHAR(1),
    clase SMALLINT,
    clase_alfa VARCHAR(10),
    seccion SMALLINT,
    seccion_alfa VARCHAR(10),
    linea SMALLINT,
    linea_alfa VARCHAR(20),
    fosa SMALLINT,
    fosa_alfa VARCHAR(20),
    axo_pagado INTEGER,
    metros NUMERIC,
    nombre VARCHAR(60),
    domicilio VARCHAR(60),
    exterior CHAR(6),
    interior CHAR(6),
    colonia VARCHAR(30),
    observaciones VARCHAR(60),
    usuario INTEGER,
    fecha_mov DATE,
    tipo CHAR(1),
    nombre_1 VARCHAR(60)
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
    p_caja CHAR(2),
    p_operacion INTEGER
) RETURNS TABLE(
    fecha DATE,
    id_rec SMALLINT,
    caja CHAR(2),
    operacion INTEGER,
    importe NUMERIC(16,2),
    cvepago CHAR(1),
    id_modulo INTEGER,
    id_regmodulo INTEGER,
    id_rec_cta SMALLINT,
    regmunur CHAR(1),
    mesdesde SMALLINT,
    axodesde SMALLINT,
    meshasta SMALLINT,
    axohasta SMALLINT,
    nombre VARCHAR(60),
    domicilio VARCHAR(60),
    concepto VARCHAR(60),
    rfcini CHAR(3),
    rfcnumero INTEGER,
    rfccolonia SMALLINT,
    obra INTEGER,
    axofolio INTEGER,
    id_usuario INTEGER,
    fecha_act TIMESTAMP,
    cajero VARCHAR(50)
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

