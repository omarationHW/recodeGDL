-- =============================================
-- MÓDULO: Consulta por Nombre de Cementerios
-- ARCHIVO: 07_SP_CEMENTERIOS_CONSULTANOMBRE_EXACTO_all_procedures.sql
-- DESCRIPCIÓN: SP para búsqueda de folios por nombre del titular
-- FECHA: 2025-11-25
-- ESQUEMAS SEGÚN postgreok.csv:
--   - ta_13_datosrcm → padron_licencias.comun
-- =============================================

-- =============================================
-- SP: sp_consultanombre_buscar
-- Busca folios por nombre del titular (LIKE)
-- Origen: ConsultaNombre.pas línea 387, ConsultaNombre.dfm línea 2025
-- Query original: SELECT FIRST 50 * FROM ta_13_datosrcm WHERE nombre LIKE :nomb
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_consultanombre_buscar(
    p_nombre VARCHAR(60)
)
RETURNS TABLE(
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
    vigencia CHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.control_rcm,
        d.cementerio,
        d.clase,
        d.clase_alfa,
        d.seccion,
        d.seccion_alfa,
        d.linea,
        d.linea_alfa,
        d.fosa,
        d.fosa_alfa,
        d.axo_pagado,
        d.metros,
        d.nombre,
        d.domicilio,
        d.exterior,
        d.interior,
        d.colonia,
        d.observaciones,
        d.usuario,
        d.fecha_mov,
        d.tipo,
        d.vigencia
    --FROM public.ta_13_datosrcm d
    FROM public.ta_13_datosrcm d
    WHERE UPPER(d.nombre) LIKE UPPER(p_nombre || '%')
      AND d.vigencia = 'A'
    ORDER BY d.nombre
    LIMIT 50;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- COMENTARIOS Y NOTAS:
-- 1. Usa esquema correcto según postgreok.csv: ta_13_datosrcm → padron_licencias.comun
-- 2. LIKE case-insensitive con UPPER()
-- 3. Limita a 50 registros como el original (FIRST 50)
-- 4. Solo registros activos (vigencia = 'A')
-- 5. Ordenado por nombre
-- =============================================
