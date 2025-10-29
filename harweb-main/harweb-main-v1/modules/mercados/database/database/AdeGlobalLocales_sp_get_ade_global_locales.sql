-- Stored Procedure: sp_get_ade_global_locales
-- Tipo: Report
-- Descripción: Obtiene el listado de locales con adeudo global y accesorios para una oficina, mercado, año y mes.
-- Generado para formulario: AdeGlobalLocales
-- Fecha: 2025-08-26 20:49:01

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
            SELECT COALESCE(SUM(porcentaje_mes),0) FROM ta_12_recargos WHERE (axo = b.axo AND mes >= b.periodo) OR (axo > b.axo)
        ) / 100, 2)) AS recargos,
        COALESCE((SELECT SUM(CASE WHEN r.vigencia = '1' AND r.clave_practicado = 'P' THEN r.importe_multa ELSE 0 END) FROM ta_15_apremios r WHERE r.modulo = 11 AND r.control_otr = a.id_local), 0) AS multa,
        COALESCE((SELECT SUM(CASE WHEN r.vigencia = '1' AND r.clave_practicado = 'P' THEN r.importe_gastos ELSE 0 END) FROM ta_15_apremios r WHERE r.modulo = 11 AND r.control_otr = a.id_local), 0) AS gastos
    FROM ta_11_locales a
    JOIN ta_11_adeudo_local b ON a.id_local = b.id_local
    JOIN ta_11_mercados c ON a.oficina = c.oficina AND a.num_mercado = c.num_mercado_nvo
    WHERE a.oficina = p_office_id
      AND a.num_mercado = p_market_id
      AND a.vigencia = 'A'
      AND ((b.axo = p_year AND b.periodo <= p_month) OR (b.axo < p_year))
    GROUP BY a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre, a.descripcion_local, c.descripcion;
END;
$$ LANGUAGE plpgsql;