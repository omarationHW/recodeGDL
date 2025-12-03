-- ============================================
-- STORED PROCEDURE CORREGIDO
-- Formulario: RptPadronEnergia
-- SP: rpt_padron_energia
-- Base: mercados.public
-- Fecha: 2025-12-03
-- ============================================

DROP FUNCTION IF EXISTS rpt_padron_energia(integer, integer);

CREATE OR REPLACE FUNCTION rpt_padron_energia(
    p_oficina integer,
    p_mercado integer
)
RETURNS TABLE (
    descripcion varchar(50),
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar(2),
    local smallint,
    letra_local varchar(1),
    bloque varchar(1),
    descripcion_local varchar(50),
    cve_consumo varchar(1),
    local_adicional varchar(50),
    nombre varchar(30),
    cantidad numeric,
    vigencia varchar(1),
    datoslocal varchar(100)
) AS $$
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
            b.letra_local || '-' ||
            b.bloque
        )::varchar(100) AS datoslocal
    FROM padron_licencias.comun.ta_11_mercados a
    JOIN padron_licencias.comun.ta_11_locales b
        ON a.oficina = b.oficina
        AND a.num_mercado_nvo = b.num_mercado
    JOIN mercados.public.ta_11_energia c
        ON b.id_local = c.id_local
    WHERE a.oficina = p_oficina
      AND a.num_mercado_nvo = p_mercado
    ORDER BY b.oficina ASC, b.num_mercado ASC, b.categoria ASC, b.seccion ASC, b.local ASC, b.letra_local ASC, b.bloque ASC;
END;
$$ LANGUAGE plpgsql;
