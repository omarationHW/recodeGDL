-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: MultipleNombre
-- Generado: 2025-08-27 14:42:42
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_multiple_nombre_search
-- Tipo: Report
-- Descripción: Busca registros en ta_13_datosrcm por nombre, cementerio y control_rcm (paginado)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_multiple_nombre_search(
    p_nombre VARCHAR,
    p_cuenta INTEGER,
    p_cem1 VARCHAR,
    p_cem2 VARCHAR,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE (
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
    fecha_mov DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, axo_pagado, metros, nombre, domicilio, exterior, interior, colonia, observaciones, usuario, fecha_mov
    FROM ta_13_datosrcm
    WHERE nombre ILIKE p_nombre
      AND control_rcm > p_cuenta
      AND cementerio >= p_cem1 AND cementerio <= p_cem2
    ORDER BY nombre
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_cementerios_list
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de cementerios
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cementerios_list()
RETURNS TABLE (
    cementerio VARCHAR,
    nombre VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT cementerio, nombre FROM tc_13_cementerios ORDER BY cementerio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

