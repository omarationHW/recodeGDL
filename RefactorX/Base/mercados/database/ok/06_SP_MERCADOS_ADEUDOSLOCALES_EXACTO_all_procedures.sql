-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: mercados
-- ESQUEMA: public
-- NOTA: Usa solo tablas locales de mercados (sin referencias cruzadas)
-- ============================================
\c mercados;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: AdeudosLocales
-- Generado: 2025-11-18 (Actualizado sin referencias cruzadas)
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_get_adeudos_locales (original)
-- Tipo: Report
-- Descripción: Obtiene el listado de adeudos de locales para un año, oficina y periodo dados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_adeudos_locales(p_axo INTEGER, p_oficina INTEGER, p_periodo INTEGER)
RETURNS TABLE(
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion CHARACTER(2),
    letra_local CHARACTER VARYING(3),
    bloque CHARACTER VARYING(2),
    nombre VARCHAR(30),
    superficie FLOAT,
    clave_cuota SMALLINT,
    adeudo NUMERIC,
    recaudadora VARCHAR(50),
    descripcion VARCHAR(30),
    local SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_local, l.oficina, l.num_mercado, l.categoria, l.seccion, l.letra_local, l.bloque, l.nombre,
           l.superficie::FLOAT, l.clave_cuota,
           COALESCE(SUM(a.importe), 0) AS adeudo,
           COALESCE(r.recaudadora, 'SIN NOMBRE') AS recaudadora,
           COALESCE(m.descripcion, 'SIN DESCRIPCION') AS descripcion,
           l.local
    FROM public.ta_11_localpaso l
    LEFT JOIN public.ta_11_adeudo_local a ON a.id_local = l.id_local
                                         AND a.axo = p_axo
                                         AND a.periodo <= p_periodo
    LEFT JOIN public.ta_12_recaudadoras r ON r.id_rec = l.oficina
    LEFT JOIN public.ta_11_mercados m ON m.oficina = l.oficina AND m.num_mercado_nvo = l.num_mercado
    WHERE l.oficina = p_oficina
      AND l.vigencia = 'A'
    GROUP BY l.id_local, l.oficina, l.num_mercado, l.categoria, l.seccion, l.local,
             l.letra_local, l.bloque, l.nombre, l.superficie, l.clave_cuota,
             r.recaudadora, m.descripcion
    HAVING COALESCE(SUM(a.importe), 0) > 0
    ORDER BY l.oficina, l.num_mercado, l.categoria, l.seccion DESC, l.local, l.letra_local, l.bloque;
END;
$$ LANGUAGE plpgsql;

-- SP 1.1/4: sp_adeudos_locales (alias - nombre usado por Vue)
-- Tipo: Report
-- Descripción: Alias de sp_get_adeudos_locales para compatibilidad con Vue
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_adeudos_locales(p_axo INTEGER, p_oficina INTEGER, p_periodo INTEGER)
RETURNS TABLE(
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion CHARACTER(2),
    letra_local CHARACTER VARYING(3),
    bloque CHARACTER VARYING(2),
    nombre VARCHAR(30),
    superficie FLOAT,
    clave_cuota SMALLINT,
    adeudo NUMERIC,
    recaudadora VARCHAR(50),
    descripcion VARCHAR(30),
    local SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM sp_get_adeudos_locales(p_axo, p_oficina, p_periodo);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_get_meses_adeudo
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
    SELECT al.id_local, al.axo, al.periodo, al.importe
    FROM public.ta_11_adeudo_local al
    WHERE al.id_local = p_id_local AND al.axo = p_axo
    ORDER BY al.id_local, al.axo, al.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_get_renta
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
    FROM public.ta_11_cuo_locales
    WHERE axo = p_axo AND categoria = p_categoria AND seccion = p_seccion AND clave_cuota = p_clave_cuota;
END;
$$ LANGUAGE plpgsql;

-- ============================================