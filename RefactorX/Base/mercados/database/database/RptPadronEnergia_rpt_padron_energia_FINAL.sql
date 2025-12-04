-- ============================================
-- STORED PROCEDURE
-- Formulario: RptPadronEnergia
-- SP: rpt_padron_energia
-- Base: padron_licencias
-- Esquemas: padron_licencias.comun, padron_licencias.db_ingresos
-- Fecha: 2025-12-04 (Corregido cross-database ref + tipos)
-- ============================================

DROP FUNCTION IF EXISTS rpt_padron_energia(integer, integer);

CREATE OR REPLACE FUNCTION rpt_padron_energia(
    p_oficina INTEGER,
    p_mercado INTEGER
)
RETURNS TABLE (
    descripcion VARCHAR(30),      -- Coincide con ta_11_mercados
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion CHAR(2),              -- CHAR(2), no VARCHAR
    local INTEGER,                -- INTEGER, no SMALLINT
    letra_local VARCHAR(3),       -- VARCHAR(3), no (1)
    bloque VARCHAR(2),            -- VARCHAR(2), no (1)
    descripcion_local CHAR(20),   -- CHAR(20), no VARCHAR(50)
    cve_consumo CHAR(1),          -- CHAR(1), no VARCHAR
    local_adicional CHAR(50),     -- CHAR(50), no VARCHAR
    nombre VARCHAR(60),           -- VARCHAR(60), no (30)
    cantidad NUMERIC,
    vigencia CHAR(1),             -- CHAR(1), no VARCHAR
    datoslocal VARCHAR(100)
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.descripcion,
        b.id_local,
        b.oficina,
        b.num_mercado,
        b.categoria,
        b.seccion,
        b.local,
        b.letra_local,
        b.bloque,
        b.descripcion_local,
        c.cve_consumo,
        c.local_adicional,
        b.nombre,
        c.cantidad,
        c.vigencia,
        (
            CAST(b.oficina AS TEXT) || '-' ||
            CAST(b.num_mercado AS TEXT) || '-' ||
            CAST(b.categoria AS TEXT) || '-' ||
            b.seccion || '-' ||
            CAST(b.local AS TEXT) || '-' ||
            COALESCE(b.letra_local, '') || '-' ||
            COALESCE(b.bloque, '')
        )::VARCHAR(100) AS datoslocal
    FROM comun.ta_11_mercados a
    JOIN comun.ta_11_locales b
        ON a.oficina = b.oficina
        AND a.num_mercado_nvo = b.num_mercado
    JOIN db_ingresos.ta_11_energia c  -- ✅ Corregido: mismo database
        ON b.id_local = c.id_local
    WHERE a.oficina = p_oficina
      AND a.num_mercado_nvo = p_mercado
    ORDER BY b.oficina, b.num_mercado, b.categoria,
             b.seccion, b.local, b.letra_local, b.bloque;
END;
$$;

COMMENT ON FUNCTION rpt_padron_energia(INTEGER, INTEGER) IS
'Reporte de padrón de energía por mercado. Retorna locales con registro de consumo eléctrico.';
