-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: AdeudosLocales
-- Generado: 2025-08-26 22:39:11
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_get_adeudos_locales
-- Tipo: Report
-- Descripción: Obtiene el listado de adeudos de locales para un año, oficina y periodo dados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_adeudos_locales(p_axo INTEGER, p_oficina INTEGER, p_periodo INTEGER)
RETURNS TABLE(
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    nombre VARCHAR(30),
    superficie FLOAT,
    clave_cuota SMALLINT,
    adeudo NUMERIC,
    recaudadora VARCHAR(50),
    descripcion VARCHAR(30),
    local INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.letra_local, c.bloque, c.nombre, c.superficie, c.clave_cuota,
           SUM(a.importe) AS adeudo, d.recaudadora, e.descripcion, c.local
    FROM ta_11_adeudo_local a
    JOIN ta_11_locales c ON a.id_local = c.id_local
    JOIN ta_12_recaudadoras d ON d.id_rec = c.oficina
    JOIN ta_11_mercados e ON e.oficina = c.oficina AND e.num_mercado_nvo = c.num_mercado
    WHERE a.axo = p_axo
      AND c.oficina = p_oficina
      AND a.periodo <= p_periodo
      AND c.vigencia = 'A'
    GROUP BY c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque, c.nombre, c.superficie, c.clave_cuota, d.recaudadora, e.descripcion
    ORDER BY c.oficina, c.num_mercado, c.categoria, c.seccion DESC, c.local, c.letra_local, c.bloque;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_get_meses_adeudo
-- Tipo: Report
-- Descripción: Obtiene los meses de adeudo de un local para un año dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_meses_adeudo(p_id_local INTEGER, p_axo INTEGER)
RETURNS TABLE(
    id_local INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    importe NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, axo, periodo, importe
    FROM ta_11_adeudo_local
    WHERE id_local = p_id_local AND axo = p_axo
    ORDER BY id_local, axo, periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_get_renta
-- Tipo: Report
-- Descripción: Obtiene la renta de un local según año, categoría, sección y clave de cuota.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_renta(p_axo INTEGER, p_categoria INTEGER, p_seccion VARCHAR, p_clave_cuota INTEGER)
RETURNS TABLE(
    id_cuotas INTEGER,
    axo SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    clave_cuota SMALLINT,
    importe_cuota NUMERIC,
    fecha_alta TIMESTAMP,
    id_usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_cuotas, axo, categoria, seccion, clave_cuota, importe_cuota, fecha_alta, id_usuario
    FROM ta_11_cuo_locales
    WHERE axo = p_axo AND categoria = p_categoria AND seccion = p_seccion AND clave_cuota = p_clave_cuota;
END;
$$ LANGUAGE plpgsql;

-- ============================================

