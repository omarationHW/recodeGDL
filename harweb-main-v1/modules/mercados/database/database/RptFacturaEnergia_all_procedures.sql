-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptFacturaEnergia
-- Generado: 2025-08-27 01:07:17
-- Total SPs: 1
-- ============================================

-- SP 1/1: rpt_factura_energia
-- Tipo: Report
-- Descripción: Devuelve el reporte de factura de energía eléctrica para una oficina, año, periodo y mercado dados.
-- --------------------------------------------

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
        a.oficina,
        a.num_mercado,
        a.categoria,
        a.seccion,
        a.local,
        a.letra_local,
        a.bloque,
        a.nombre,
        d.local_adicional,
        b.cantidad,
        e.importe,
        c.descripcion,
        b.importe as importe_1
    FROM ta_11_locales a
    JOIN ta_11_adeudo_energ b ON a.id_local = b.id_local
    JOIN ta_11_mercados c ON a.oficina = c.oficina AND a.num_mercado = c.num_mercado_nvo
    JOIN ta_11_energia d ON d.id_energia = b.id_energia
    JOIN ta_11_kilowhatts e ON b.axo = e.axo AND b.periodo = e.periodo
    WHERE a.oficina = p_oficina
      AND a.num_mercado = p_mercado
      AND b.axo = p_axo
      AND b.periodo = p_periodo
    ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque;
END;
$$ LANGUAGE plpgsql;

-- ============================================

