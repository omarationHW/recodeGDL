-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: ESTAD_ADEUDO (EXACTO del archivo original)
-- Archivo: 22_SP_CEMENTERIOS_ESTAD_ADEUDO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Actualizado: 2025-12-01
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_estad_adeudo_resumen
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
    SELECT d.cementerio, (d.axo_pagado-5) AS uap, COUNT(*)::INTEGER AS cuenta
    FROM comun.ta_13_datosrcm d
    WHERE d.vigencia = 'A'
    GROUP BY d.cementerio, (d.axo_pagado-5)
    ORDER BY d.cementerio, uap;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_estad_adeudo_listado
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
    SELECT a.control_rcm, a.cementerio, a.clase, a.clase_alfa, a.seccion, a.seccion_alfa,
           a.linea, a.linea_alfa, a.fosa, a.fosa_alfa, a.axo_pagado, a.metros, a.nombre,
           a.domicilio, a.exterior, a.interior, a.colonia, a.observaciones, a.usuario,
           a.fecha_mov, a.tipo, c.nombre AS nombre_1, e.nombre AS nombre_2
    FROM comun.ta_13_datosrcm a
    JOIN comun.tc_13_cementerios c ON a.cementerio = c.cementerio
    JOIN padron_licencias.comun.ta_12_passwords e ON a.usuario = e.id_usuario
    WHERE a.axo_pagado <= axop AND a.vigencia = 'A';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_cem_estadisticas_adeudos
-- Tipo: Report
-- Descripción: Genera estadísticas de folios al corriente vs atrasados por cementerio
-- NUEVO 2025-12-01
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cem_estadisticas_adeudos(
    p_cementerio VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    cementerio VARCHAR,
    nombre_cementerio VARCHAR,
    total_folios BIGINT,
    folios_al_corriente BIGINT,
    folios_atrasados BIGINT
) AS $$
DECLARE
    v_anio_actual INTEGER;
BEGIN
    -- Obtener el año actual
    v_anio_actual := EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;

    RETURN QUERY
    SELECT
        d.cementerio,
        c.nombre AS nombre_cementerio,
        COUNT(*) AS total_folios,
        COUNT(*) FILTER (WHERE d.axo_pagado >= v_anio_actual) AS folios_al_corriente,
        COUNT(*) FILTER (WHERE d.axo_pagado < v_anio_actual) AS folios_atrasados
    FROM comun.ta_13_datosrcm d
    INNER JOIN comun.tc_13_cementerios c ON d.cementerio = c.cementerio
    WHERE d.vigencia = 'A'
      AND (p_cementerio IS NULL OR d.cementerio = p_cementerio)
    GROUP BY d.cementerio, c.nombre
    ORDER BY d.cementerio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
