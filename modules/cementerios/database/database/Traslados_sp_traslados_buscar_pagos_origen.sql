-- Stored Procedure: sp_traslados_buscar_pagos_origen
-- Tipo: CRUD
-- Descripción: Busca los pagos en la ubicación origen según los parámetros de búsqueda.
-- Generado para formulario: Traslados
-- Fecha: 2025-08-27 15:19:30

CREATE OR REPLACE FUNCTION sp_traslados_buscar_pagos_origen(
    p_cementerio VARCHAR,
    p_clase INTEGER,
    p_clase_alfa VARCHAR,
    p_seccion INTEGER,
    p_seccion_alfa VARCHAR,
    p_linea INTEGER,
    p_linea_alfa VARCHAR,
    p_fosa INTEGER,
    p_fosa_alfa VARCHAR
)
RETURNS TABLE (
    control_id INTEGER,
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
    fecing DATE,
    importe_anual NUMERIC,
    vigencia VARCHAR,
    usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT control_id, control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, fecing, importe_anual, vigencia, usuario
    FROM ta_13_pagosrcm
    WHERE cementerio = p_cementerio
      AND clase = p_clase
      AND (clase_alfa = p_clase_alfa OR (p_clase_alfa IS NULL OR p_clase_alfa = ''))
      AND seccion = p_seccion
      AND (seccion_alfa = p_seccion_alfa OR (p_seccion_alfa IS NULL OR p_seccion_alfa = ''))
      AND linea = p_linea
      AND (linea_alfa = p_linea_alfa OR (p_linea_alfa IS NULL OR p_linea_alfa = ''))
      AND fosa = p_fosa
      AND (fosa_alfa = p_fosa_alfa OR (p_fosa_alfa IS NULL OR p_fosa_alfa = ''));
END;
$$ LANGUAGE plpgsql;