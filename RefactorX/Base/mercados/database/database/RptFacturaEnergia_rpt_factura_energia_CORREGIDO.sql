-- ============================================
-- STORED PROCEDURE CORREGIDO
-- Formulario: RptFacturaEnergia
-- SP: rpt_factura_energia
-- Base: mercados.public
-- Fecha: 2025-12-03
-- ============================================

DROP FUNCTION IF EXISTS rpt_factura_energia(integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION rpt_factura_energia(
    p_oficina integer,
    p_axo integer,
    p_periodo integer,
    p_mercado integer
)
RETURNS TABLE (
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar(2),
    local smallint,
    letra_local varchar(1),
    bloque varchar(1),
    nombre varchar(30),
    local_adicional varchar(50),
    cantidad numeric,
    importe numeric,
    descripcion varchar(50),
    importe_1 numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.oficina::SMALLINT,
        a.num_mercado::SMALLINT,
        a.categoria::SMALLINT,
        a.seccion::VARCHAR(2),
        a.local::SMALLINT,
        a.letra_local::VARCHAR(1),
        a.bloque::VARCHAR(1),
        a.nombre::VARCHAR(30),
        d.local_adicional::VARCHAR(50),
        b.cantidad::NUMERIC,
        e.importe::NUMERIC,
        c.descripcion::VARCHAR(50),
        b.importe::NUMERIC as importe_1
    FROM publico.ta_11_locales a
    JOIN public.ta_11_energia d ON d.id_local = a.id_local
    JOIN public.ta_11_adeudo_energ b ON b.id_energia = d.id_energia
    JOIN publico.ta_11_mercados c ON a.oficina = c.oficina AND a.num_mercado = c.num_mercado_nvo
    JOIN public.ta_11_kilowhatts e ON b.axo = e.axo AND b.periodo = e.periodo
    WHERE a.oficina = p_oficina
      AND a.num_mercado = p_mercado
      AND b.axo = p_axo
      AND b.periodo = p_periodo
    ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque;
END;
$$ LANGUAGE plpgsql;
