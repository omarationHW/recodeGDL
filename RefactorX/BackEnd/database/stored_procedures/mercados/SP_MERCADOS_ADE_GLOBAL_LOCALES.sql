-- =============================================
-- SP_MERCADOS_ADE_GLOBAL_LOCALES
-- Listado de adeudo global con accesorios
-- =============================================

CREATE PROCEDURE SP_MERCADOS_GET_ADE_GLOBAL_LOCALES(
    p_oficina SMALLINT,
    p_mercado SMALLINT,
    p_year SMALLINT,
    p_month SMALLINT
)
RETURNING
    INT AS id_local,
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    SMALLINT AS categoria,
    VARCHAR(2) AS seccion,
    VARCHAR(7) AS local,
    VARCHAR(1) AS letra_local,
    VARCHAR(1) AS bloque,
    VARCHAR(200) AS nombre,
    DECIMAL(12,2) AS adeudo,
    DECIMAL(12,2) AS recargos,
    DECIMAL(12,2) AS multa,
    DECIMAL(12,2) AS gastos;

    FOREACH
        SELECT
            l.id_local,
            l.oficina,
            l.num_mercado,
            l.categoria,
            NVL(l.seccion, '') AS seccion,
            NVL(l.local, '') AS local,
            NVL(l.letra_local, '') AS letra_local,
            NVL(l.bloque, '') AS bloque,
            NVL(TRIM(l.nombre), '') AS nombre,
            NVL(SUM(a.importe), 0) AS adeudo,
            NVL(SUM(a.recargos), 0) AS recargos,
            NVL(SUM(r.importe_multa), 0) AS multa,
            NVL(SUM(r.importe_gastos), 0) AS gastos
        INTO id_local, oficina, num_mercado, categoria, seccion, local,
             letra_local, bloque, nombre, adeudo, recargos, multa, gastos
        FROM locales l
        LEFT JOIN adeudos a ON l.id_local = a.id_local
            AND a.axo <= p_year
            AND a.periodo <= p_month
        LEFT JOIN requerimientos r ON l.id_local = r.control_otr
            AND r.vigencia = 'S'
        WHERE l.oficina = p_oficina
          AND l.num_mercado = p_mercado
          AND l.vigencia = 'S'
        GROUP BY l.id_local, l.oficina, l.num_mercado, l.categoria,
                 l.seccion, l.local, l.letra_local, l.bloque, l.nombre
        HAVING SUM(a.importe) > 0
            OR SUM(r.importe_multa) > 0
            OR SUM(r.importe_gastos) > 0
        ORDER BY l.oficina, l.num_mercado, l.local

        RETURN id_local, oficina, num_mercado, categoria, seccion, local,
               letra_local, bloque, nombre, adeudo, recargos, multa, gastos WITH RESUME;
    END FOREACH;

END PROCEDURE;

CREATE PROCEDURE SP_MERCADOS_GET_LOCALES_SIN_ADEUDO(
    p_mercado SMALLINT,
    p_year SMALLINT,
    p_month SMALLINT
)
RETURNING
    INT AS id_local,
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    SMALLINT AS categoria,
    VARCHAR(2) AS seccion,
    VARCHAR(7) AS local,
    VARCHAR(1) AS letra_local,
    VARCHAR(1) AS bloque,
    VARCHAR(200) AS nombre,
    DECIMAL(12,2) AS adeudo,
    DECIMAL(12,2) AS recargos,
    DECIMAL(12,2) AS multas,
    DECIMAL(12,2) AS gastos;

    FOREACH
        SELECT
            l.id_local,
            l.oficina,
            l.num_mercado,
            l.categoria,
            NVL(l.seccion, '') AS seccion,
            NVL(l.local, '') AS local,
            NVL(l.letra_local, '') AS letra_local,
            NVL(l.bloque, '') AS bloque,
            NVL(TRIM(l.nombre), '') AS nombre,
            0 AS adeudo,
            0 AS recargos,
            0 AS multas,
            0 AS gastos
        INTO id_local, oficina, num_mercado, categoria, seccion, local,
             letra_local, bloque, nombre, adeudo, recargos, multas, gastos
        FROM locales l
        WHERE l.num_mercado = p_mercado
          AND l.vigencia = 'S'
          AND NOT EXISTS (
              SELECT 1 FROM adeudos a
              WHERE a.id_local = l.id_local
                AND a.axo <= p_year
                AND a.periodo <= p_month
          )
          AND NOT EXISTS (
              SELECT 1 FROM requerimientos r
              WHERE r.control_otr = l.id_local
                AND r.vigencia = 'S'
          )
        ORDER BY l.oficina, l.num_mercado, l.local

        RETURN id_local, oficina, num_mercado, categoria, seccion, local,
               letra_local, bloque, nombre, adeudo, recargos, multas, gastos WITH RESUME;
    END FOREACH;

END PROCEDURE;
