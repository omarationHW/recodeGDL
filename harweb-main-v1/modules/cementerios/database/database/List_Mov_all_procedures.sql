-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: List_Mov
-- Generado: 2025-08-27 14:36:39
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_list_movements
-- Tipo: Report
-- Descripción: Obtiene el listado de movimientos de cementerios entre dos fechas y por recaudadora.
-- --------------------------------------------

-- PostgreSQL stored procedure for List_Mov
CREATE OR REPLACE FUNCTION sp_list_movements(
    p_fecha1 DATE,
    p_fecha2 DATE,
    p_reca INTEGER
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
    fecha_mov DATE,
    tipo VARCHAR,
    nombre_1 VARCHAR,
    llave VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.control_rcm,
        a.cementerio,
        a.clase,
        a.clase_alfa,
        a.seccion,
        a.seccion_alfa,
        a.linea,
        a.linea_alfa,
        a.fosa,
        a.fosa_alfa,
        a.axo_pagado,
        a.metros,
        a.nombre,
        a.domicilio,
        a.exterior,
        a.interior,
        a.colonia,
        a.observaciones,
        a.usuario,
        a.fecha_mov,
        a.tipo,
        b.nombre as nombre_1,
        CONCAT_WS('-', a.cementerio, a.clase, a.clase_alfa, a.seccion, a.seccion_alfa, a.linea, a.linea_alfa, a.fosa, a.fosa_alfa) as llave
    FROM ta_13_datosrcm a
    JOIN ta_12_passwords b ON a.usuario = b.id_usuario
    WHERE a.fecha_mov BETWEEN p_fecha1 AND p_fecha2
      AND b.id_rec = p_reca;
END;
$$ LANGUAGE plpgsql;

-- ============================================

