-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptPadronEnergia
-- Generado: 2025-08-27 01:24:59
-- Total SPs: 1
-- ============================================

-- SP 1/1: rpt_padron_energia
-- Tipo: Report
-- Descripción: Devuelve el padrón de energía eléctrica del mercado, con todos los campos requeridos y el campo calculado datoslocal.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_padron_energia(p_oficina integer, p_mercado integer)
RETURNS TABLE (
    descripcion text,
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar(2),
    local smallint,
    letra_local varchar(1),
    bloque varchar(1),
    descripcion_local text,
    cve_consumo varchar(1),
    local_adicional varchar(50),
    nombre text,
    cantidad numeric(12,2),
    vigencia varchar(1),
    datoslocal text
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
        ) AS datoslocal
    FROM ta_11_mercados a
    JOIN ta_11_locales b ON a.oficina = b.oficina AND a.num_mercado_nvo = b.num_mercado
    JOIN ta_11_energia c ON b.id_local = c.id_local
    WHERE a.oficina = p_oficina
      AND a.num_mercado_nvo = p_mercado
    ORDER BY b.oficina ASC, b.num_mercado ASC, b.categoria ASC, b.seccion ASC, b.local ASC, b.letra_local ASC, b.bloque ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

