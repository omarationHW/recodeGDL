-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: MULTIPLERCM (EXACTO del archivo original)
-- Archivo: 27_SP_CEMENTERIOS_MULTIPLERCM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_multiple_rcm_search
-- Tipo: Report
-- Descripción: Busca hasta 100 registros en ta_13_datosrcm a partir de los parámetros de búsqueda, similar a la lógica Delphi.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_multiple_rcm_search(
    p_cementerio VARCHAR,
    p_clase INTEGER,
    p_clase_alfa VARCHAR,
    p_seccion INTEGER,
    p_seccion_alfa VARCHAR,
    p_linea INTEGER,
    p_linea_alfa VARCHAR,
    p_fosa INTEGER,
    p_fosa_alfa VARCHAR,
    p_cuenta INTEGER
)
RETURNS TABLE (
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase INTEGER,
    clase_alfa VARCHAR,
    seccion INTEGER,
    seccion_alfa VARCHAR,
    linea INTEGER,
    linea_alfa VARCHAR,
    fosa INTEGER,
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
    fecha_mov DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa,
        axo_pagado, metros, nombre, domicilio, exterior, interior, colonia, observaciones, usuario, fecha_mov
    FROM public.ta_13_datosrcm
    WHERE cementerio = p_cementerio
      AND clase >= p_clase
      AND clase_alfa >= p_clase_alfa
      AND seccion >= p_seccion
      AND seccion_alfa >= p_seccion_alfa
      AND linea >= p_linea
      AND linea_alfa >= p_linea_alfa
      AND fosa >= p_fosa
      AND fosa <= (p_fosa + 100)
      AND fosa_alfa >= p_fosa_alfa
      AND control_rcm > p_cuenta
    ORDER BY clase, seccion, linea, fosa
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- ============================================

