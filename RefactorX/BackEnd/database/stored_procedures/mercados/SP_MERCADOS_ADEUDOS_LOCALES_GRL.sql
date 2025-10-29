-- ================================================================
-- STORED PROCEDURES PARA ADEUDOS GENERALES DE LOCALES
-- ================================================================

CREATE PROCEDURE SP_MERCADOS_GET_ADEUDOS_LOCALES_GRL(
    p_id_rec SMALLINT,
    p_num_mercado SMALLINT,
    p_axo SMALLINT,
    p_mes SMALLINT
)
RETURNING
    INT AS id_local,
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    SMALLINT AS categoria,
    CHAR(2) AS seccion,
    VARCHAR(7) AS local,
    CHAR(1) AS letra_local,
    VARCHAR(10) AS bloque,
    VARCHAR(100) AS nombre,
    DECIMAL(10,2) AS superficie,
    VARCHAR(10) AS clave_cuota,
    DECIMAL(12,2) AS adeudo,
    VARCHAR(50) AS recaudadora,
    VARCHAR(100) AS descripcion,
    INT AS meses,
    DECIMAL(12,2) AS renta,
    VARCHAR(100) AS folios;

    FOREACH
        SELECT
            l.id_local,
            l.oficina,
            l.num_mercado,
            l.categoria,
            l.seccion,
            l.local,
            NVL(l.letra_local, ' ') AS letra_local,
            NVL(l.bloque, ' ') AS bloque,
            NVL(l.nombre, ' ') AS nombre,
            NVL(l.superficie, 0) AS superficie,
            NVL(l.clave_cuota, ' ') AS clave_cuota,
            NVL(SUM(a.importe), 0) AS adeudo,
            NVL(r.recaudadora, ' ') AS recaudadora,
            NVL(m.descripcion, ' ') AS descripcion,
            COUNT(a.periodo) AS meses,
            NVL(l.renta, 0) AS renta,
            NVL(GROUP_CONCAT(req.folio_req), ' ') AS folios
        INTO
            id_local, oficina, num_mercado, categoria, seccion,
            local, letra_local, bloque, nombre, superficie,
            clave_cuota, adeudo, recaudadora, descripcion,
            meses, renta, folios
        FROM locales l
        INNER JOIN adeudos a ON a.id_local = l.id_local
        LEFT JOIN recaudadoras r ON r.id_rec = l.oficina
        LEFT JOIN mercados m ON m.num_mercado_nvo = l.num_mercado AND m.oficina = l.oficina
        LEFT JOIN requerimientos req ON req.id_local = l.id_local AND req.axo = a.axo
        WHERE l.oficina = p_id_rec
          AND (p_num_mercado IS NULL OR l.num_mercado = p_num_mercado)
          AND a.axo <= p_axo
          AND (a.axo < p_axo OR (a.axo = p_axo AND a.periodo <= p_mes))
        GROUP BY l.id_local, l.oficina, l.num_mercado, l.categoria,
                 l.seccion, l.local, l.letra_local, l.bloque,
                 l.nombre, l.superficie, l.clave_cuota, l.renta,
                 r.recaudadora, m.descripcion
        HAVING SUM(a.importe) > 0
        ORDER BY l.oficina, l.num_mercado, l.categoria, l.seccion, l.local

        RETURN id_local, oficina, num_mercado, categoria, seccion,
               local, letra_local, bloque, nombre, superficie,
               clave_cuota, adeudo, recaudadora, descripcion,
               meses, renta, folios WITH RESUME;
    END FOREACH;

END PROCEDURE;
