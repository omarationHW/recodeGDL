-- =============================================
-- SP_MERCADOS_ESTADISTICAS
-- Estadísticas de adeudos
-- =============================================

-- Estadísticas globales de adeudos
CREATE PROCEDURE SP_MERCADOS_ESTADISTICAS_GLOBAL(
    p_year SMALLINT,
    p_month SMALLINT
)
RETURNING
    SMALLINT AS oficina,
    VARCHAR(100) AS recaudadora,
    SMALLINT AS num_mercado,
    VARCHAR(100) AS mercado,
    INT AS total_locales,
    INT AS locales_adeudo,
    DECIMAL(12,2) AS importe_total,
    DECIMAL(12,2) AS recargos_total;

    FOREACH
        SELECT
            l.oficina,
            NVL(r.descripcion, '') AS recaudadora,
            l.num_mercado,
            NVL(m.descripcion, '') AS mercado,
            COUNT(DISTINCT l.id_local) AS total_locales,
            COUNT(DISTINCT a.id_local) AS locales_adeudo,
            NVL(SUM(a.importe), 0) AS importe_total,
            NVL(SUM(a.recargos), 0) AS recargos_total
        INTO
            oficina,
            recaudadora,
            num_mercado,
            mercado,
            total_locales,
            locales_adeudo,
            importe_total,
            recargos_total
        FROM locales l
        LEFT JOIN adeudos a ON l.id_local = a.id_local
            AND a.axo <= p_year
            AND a.periodo <= p_month
        LEFT JOIN recaudadoras r ON l.oficina = r.oficina
        LEFT JOIN mercados m ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
        WHERE l.vigencia = 'S'
        GROUP BY l.oficina, r.descripcion, l.num_mercado, m.descripcion
        ORDER BY l.oficina, l.num_mercado

        RETURN oficina, recaudadora, num_mercado, mercado, total_locales,
               locales_adeudo, importe_total, recargos_total WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- Estadísticas de adeudos mayores o iguales a importe
CREATE PROCEDURE SP_MERCADOS_ESTADISTICAS_IMPORTE(
    p_year SMALLINT,
    p_month SMALLINT,
    p_importe DECIMAL(12,2)
)
RETURNING
    SMALLINT AS oficina,
    VARCHAR(100) AS recaudadora,
    SMALLINT AS num_mercado,
    VARCHAR(100) AS mercado,
    INT AS locales_adeudo,
    DECIMAL(12,2) AS importe_total,
    DECIMAL(12,2) AS recargos_total;

    FOREACH
        SELECT
            l.oficina,
            NVL(r.descripcion, '') AS recaudadora,
            l.num_mercado,
            NVL(m.descripcion, '') AS mercado,
            COUNT(DISTINCT l.id_local) AS locales_adeudo,
            NVL(SUM(ad.total_adeudo), 0) AS importe_total,
            NVL(SUM(ad.total_recargos), 0) AS recargos_total
        INTO
            oficina,
            recaudadora,
            num_mercado,
            mercado,
            locales_adeudo,
            importe_total,
            recargos_total
        FROM (
            SELECT
                a.id_local,
                SUM(a.importe) AS total_adeudo,
                SUM(a.recargos) AS total_recargos
            FROM adeudos a
            WHERE a.axo <= p_year
              AND a.periodo <= p_month
            GROUP BY a.id_local
            HAVING SUM(a.importe) >= p_importe
        ) ad
        INNER JOIN locales l ON ad.id_local = l.id_local
        LEFT JOIN recaudadoras r ON l.oficina = r.oficina
        LEFT JOIN mercados m ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
        WHERE l.vigencia = 'S'
        GROUP BY l.oficina, r.descripcion, l.num_mercado, m.descripcion
        ORDER BY l.oficina, l.num_mercado

        RETURN oficina, recaudadora, num_mercado, mercado, locales_adeudo,
               importe_total, recargos_total WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- Desglose de adeudos mayores o iguales a importe
CREATE PROCEDURE SP_MERCADOS_DESGLOSE_ADEUDOS_IMPORTE(
    p_year SMALLINT,
    p_month SMALLINT,
    p_importe DECIMAL(12,2)
)
RETURNING
    INT AS id_local,
    VARCHAR(100) AS local,
    VARCHAR(200) AS nombre,
    SMALLINT AS oficina,
    VARCHAR(100) AS recaudadora,
    SMALLINT AS num_mercado,
    VARCHAR(100) AS mercado,
    DECIMAL(12,2) AS importe_adeudo,
    DECIMAL(12,2) AS recargos,
    INT AS num_periodos;

    FOREACH
        SELECT
            l.id_local,
            NVL(l.local, '') AS local,
            NVL(TRIM(l.nombre), '') AS nombre,
            l.oficina,
            NVL(r.descripcion, '') AS recaudadora,
            l.num_mercado,
            NVL(m.descripcion, '') AS mercado,
            NVL(ad.total_adeudo, 0) AS importe_adeudo,
            NVL(ad.total_recargos, 0) AS recargos,
            NVL(ad.num_periodos, 0) AS num_periodos
        INTO
            id_local,
            local,
            nombre,
            oficina,
            recaudadora,
            num_mercado,
            mercado,
            importe_adeudo,
            recargos,
            num_periodos
        FROM (
            SELECT
                a.id_local,
                SUM(a.importe) AS total_adeudo,
                SUM(a.recargos) AS total_recargos,
                COUNT(*) AS num_periodos
            FROM adeudos a
            WHERE a.axo <= p_year
              AND a.periodo <= p_month
            GROUP BY a.id_local
            HAVING SUM(a.importe) >= p_importe
        ) ad
        INNER JOIN locales l ON ad.id_local = l.id_local
        LEFT JOIN recaudadoras r ON l.oficina = r.oficina
        LEFT JOIN mercados m ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
        WHERE l.vigencia = 'S'
        ORDER BY ad.total_adeudo DESC, l.oficina, l.num_mercado, l.local

        RETURN id_local, local, nombre, oficina, recaudadora, num_mercado,
               mercado, importe_adeudo, recargos, num_periodos WITH RESUME;
    END FOREACH;

END PROCEDURE;
