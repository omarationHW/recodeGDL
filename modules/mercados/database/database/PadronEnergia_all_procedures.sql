-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: PadronEnergia
-- Generado: 2025-08-27 00:17:27
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_padron_energia
-- Tipo: Report
-- Descripción: Obtiene el padrón de energía eléctrica para una recaudadora y mercado específico.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_padron_energia(p_id_rec integer, p_num_mercado_nvo integer)
RETURNS TABLE(
    descripcion varchar,
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar(2),
    local smallint,
    letra_local varchar(1),
    bloque varchar(1),
    descripcion_local varchar,
    cve_consumo varchar(1),
    local_adicional varchar(50),
    nombre varchar(30),
    cantidad float,
    vigencia varchar(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.descripcion, b.id_local, b.oficina, b.num_mercado, b.categoria, b.seccion, b.local, b.letra_local, b.bloque, b.descripcion_local,
           c.cve_consumo, c.local_adicional, b.nombre, c.cantidad, c.vigencia
    FROM ta_11_mercados a
    JOIN ta_11_locales b ON a.oficina = b.oficina AND a.num_mercado_nvo = b.num_mercado
    JOIN ta_11_energia c ON b.id_local = c.id_local
    WHERE a.oficina = p_id_rec
      AND a.num_mercado_nvo = p_num_mercado_nvo
    ORDER BY b.oficina, b.num_mercado, b.categoria, b.seccion, b.local, b.letra_local, b.bloque;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de recaudadoras.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE(id_rec integer, recaudadora varchar) AS $$
BEGIN
    RETURN QUERY SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_get_mercados_by_recaudadora
-- Tipo: Catalog
-- Descripción: Devuelve los mercados de una recaudadora que tienen energía eléctrica.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_mercados_by_recaudadora(p_id_rec integer)
RETURNS TABLE(num_mercado_nvo integer, descripcion varchar) AS $$
BEGIN
    RETURN QUERY SELECT num_mercado_nvo, descripcion FROM ta_11_mercados WHERE oficina = p_id_rec AND cuenta_energia > 0 ORDER BY num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

