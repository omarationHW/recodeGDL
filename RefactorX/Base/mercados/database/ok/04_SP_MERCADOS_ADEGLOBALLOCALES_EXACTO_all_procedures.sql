-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: mercados
-- ESQUEMA: public
-- NOTA: Usa tablas cross-database de padron_licencias.comun
-- ============================================
\c mercados;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: AdeGlobalLocales
-- Generado: 2025-08-26 20:49:01
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_get_ade_global_locales
-- Tipo: Report
-- Descripción: Obtiene el listado de locales con adeudo global y accesorios para una oficina, mercado, año y mes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_ade_global_locales(
    p_office_id INTEGER,
    p_market_id INTEGER,
    p_year INTEGER,
    p_month INTEGER
) RETURNS TABLE (
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    local INTEGER,
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    nombre VARCHAR(30),
    descripcion_local VARCHAR,
    descripcion VARCHAR(30),
    adeudo NUMERIC,
    recargos NUMERIC,
    multa NUMERIC,
    gastos NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_local,
        a.oficina,
        a.num_mercado,
        a.categoria,
        a.seccion,
        a.local,
        a.letra_local,
        a.bloque,
        a.nombre,
        a.descripcion_local,
        c.descripcion,
        SUM(b.importe) AS adeudo,
        SUM(ROUND((b.importe) * (
            SELECT COALESCE(SUM(porcentaje_mes),0) FROM padron_licencias.comun.ta_12_recargos WHERE (axo = b.axo AND mes >= b.periodo) OR (axo > b.axo)
        ) / 100, 2)) AS recargos,
        COALESCE((SELECT SUM(CASE WHEN r.vigencia = '1' AND r.clave_practicado = 'P' THEN r.importe_multa ELSE 0 END) FROM padron_licencias.comun.ta_15_apremios r WHERE r.modulo = 11 AND r.control_otr = a.id_local), 0) AS multa,
        COALESCE((SELECT SUM(CASE WHEN r.vigencia = '1' AND r.clave_practicado = 'P' THEN r.importe_gastos ELSE 0 END) FROM padron_licencias.comun.ta_15_apremios r WHERE r.modulo = 11 AND r.control_otr = a.id_local), 0) AS gastos
    FROM padron_licencias.comun.ta_11_locales a
    JOIN padron_licencias.comun.ta_11_adeudo_local b ON a.id_local = b.id_local
    JOIN padron_licencias.comun.ta_11_mercados c ON a.oficina = c.oficina AND a.num_mercado = c.num_mercado_nvo
    WHERE a.oficina = p_office_id
      AND a.num_mercado = p_market_id
      AND a.vigencia = 'A'
      AND ((b.axo = p_year AND b.periodo <= p_month) OR (b.axo < p_year))
    GROUP BY a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre, a.descripcion_local, c.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_get_locales_sin_adeudo_con_accesorios
-- Tipo: Report
-- Descripción: Obtiene el listado de locales sin adeudo pero con accesorios (multas/gastos) para un mercado, año y mes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_locales_sin_adeudo_con_accesorios(
    p_market_id INTEGER,
    p_year INTEGER,
    p_month INTEGER,
    p_year2 INTEGER
) RETURNS TABLE (
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    local INTEGER,
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    nombre VARCHAR(30),
    adeudo NUMERIC,
    recargos NUMERIC,
    multas NUMERIC,
    gastos NUMERIC,
    id_local INTEGER
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
        COALESCE(SUM(b.importe),0) AS adeudo,
        SUM(ROUND((b.importe) * (
            SELECT COALESCE(SUM(porcentaje_mes),0) FROM padron_licencias.comun.ta_12_recargos WHERE (axo = b.axo AND mes >= b.periodo) OR (axo > b.axo)
        ) / 100, 2)) AS recargos,
        COALESCE((SELECT SUM(CASE WHEN r.vigencia = '1' AND r.clave_practicado = 'P' THEN r.importe_multa ELSE 0 END) FROM padron_licencias.comun.ta_15_apremios r WHERE r.modulo = 11 AND r.control_otr = a.id_local), 0) AS multas,
        COALESCE((SELECT SUM(CASE WHEN r.vigencia = '1' AND r.clave_practicado = 'P' THEN r.importe_gastos ELSE 0 END) FROM padron_licencias.comun.ta_15_apremios r WHERE r.modulo = 11 AND r.control_otr = a.id_local), 0) AS gastos,
        a.id_local
    FROM padron_licencias.comun.ta_11_locales a
    LEFT JOIN padron_licencias.comun.ta_11_adeudo_local b ON a.id_local = b.id_local AND ((b.axo = p_year AND b.periodo <= p_month) OR (b.axo < p_year2))
    JOIN padron_licencias.comun.ta_15_apremios c ON c.modulo = 11 AND c.control_otr = a.id_local AND c.vigencia = '1' AND c.clave_practicado = 'P'
    WHERE a.num_mercado = p_market_id
    GROUP BY a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre
    HAVING COUNT(b.id_adeudo_local) = 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================