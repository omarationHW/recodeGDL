-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: Estad_adeudo (EXACTO del archivo original)
-- Archivo: 10_SP_CEMENTERIOS_ESTAD_ADEUDO_EXACTO_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_estad_adeudo_resumen
-- Tipo: Report
-- Descripción: Devuelve el resumen de adeudos por cementerio y año (UAP, cuenta).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_estad_adeudo_resumen()
RETURNS TABLE(
    cementerio VARCHAR,
    uap INTEGER,
    cuenta INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT cementerio, (axo_pagado-5) AS uap, COUNT(*) AS cuenta
    FROM public.ta_13_datosrcm
    GROUP BY cementerio, (axo_pagado-5)
    ORDER BY cementerio, uap;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_estad_adeudo_listado
-- Tipo: Report
-- Descripción: Devuelve el listado de registros con adeudos mayores o iguales al parámetro axop.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_estad_adeudo_listado(axop INTEGER)
RETURNS TABLE(
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
    nombre_1 VARCHAR,
    nombre_2 VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_rcm, a.cementerio, a.clase, a.clase_alfa, a.seccion, a.seccion_alfa, a.linea, a.linea_alfa, a.fosa, a.fosa_alfa, a.axo_pagado, a.metros, a.nombre, a.domicilio, a.exterior, a.interior, a.colonia, a.observaciones, a.usuario, a.fecha_mov, a.tipo, c.nombre AS nombre_1, e.nombre AS nombre_2
    FROM public.ta_13_datosrcm a
    JOIN public.tc_13_cementerios c ON a.cementerio = c.cementerio
    JOIN public.ta_12_passwords e ON a.usuario = e.id_usuario
    WHERE a.axo_pagado <= axop;
END;
$$ LANGUAGE plpgsql;

-- ============================================