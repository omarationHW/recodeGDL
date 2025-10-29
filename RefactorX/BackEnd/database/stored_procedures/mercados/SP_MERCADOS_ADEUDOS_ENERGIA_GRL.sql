-- ================================================================
-- STORED PROCEDURES PARA ADEUDOS GENERALES DE ENERGÍA
-- ================================================================

-- Procedimiento para obtener mercados por recaudadora
CREATE PROCEDURE SP_MERCADOS_GET_MERCADOS_BY_RECAUDADORA(
    p_id_rec SMALLINT
)
RETURNING
    SMALLINT AS num_mercado_nvo,
    VARCHAR(100) AS descripcion,
    SMALLINT AS oficina;

    FOREACH
        SELECT num_mercado_nvo, descripcion, oficina
        INTO num_mercado_nvo, descripcion, oficina
        FROM mercados
        WHERE oficina = p_id_rec
        ORDER BY num_mercado_nvo

        RETURN num_mercado_nvo, descripcion, oficina WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- Procedimiento para obtener adeudos generales de energía
CREATE PROCEDURE SP_MERCADOS_GET_ADEUDOS_ENERGIA_GRL(
    p_id_rec SMALLINT,
    p_num_mercado SMALLINT,
    p_axo SMALLINT,
    p_mes SMALLINT
)
RETURNING
    INT AS id_local,
    INT AS id_energia,
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    SMALLINT AS categoria,
    CHAR(2) AS seccion,
    VARCHAR(7) AS local,
    CHAR(1) AS letra_local,
    VARCHAR(10) AS bloque,
    VARCHAR(100) AS nombre,
    VARCHAR(50) AS local_adicional,
    DECIMAL(12,2) AS cuota,
    SMALLINT AS axo,
    DECIMAL(12,2) AS adeudo,
    VARCHAR(100) AS mesesadeudos;

    FOREACH
        SELECT
            l.id_local,
            e.id_energia,
            l.oficina,
            l.num_mercado,
            l.categoria,
            l.seccion,
            l.local,
            NVL(l.letra_local, ' ') AS letra_local,
            NVL(l.bloque, ' ') AS bloque,
            NVL(l.nombre, ' ') AS nombre,
            NVL(l.local_adicional, ' ') AS local_adicional,
            NVL(e.cuota, 0) AS cuota,
            ae.axo,
            NVL(ae.adeudo, 0) AS adeudo,
            NVL(ae.periodos_adeudo, ' ') AS mesesadeudos
        INTO
            id_local, id_energia, oficina, num_mercado, categoria,
            seccion, local, letra_local, bloque, nombre,
            local_adicional, cuota, axo, adeudo, mesesadeudos
        FROM locales l
        INNER JOIN energia e ON e.id_local = l.id_local
        INNER JOIN adeudos_energia ae ON ae.id_energia = e.id_energia
        WHERE l.oficina = p_id_rec
          AND l.num_mercado = p_num_mercado
          AND ae.axo <= p_axo
          AND (ae.axo < p_axo OR (ae.axo = p_axo AND ae.periodo <= p_mes))
          AND ae.adeudo > 0
        ORDER BY l.num_mercado, l.categoria, l.seccion, l.local, ae.axo

        RETURN id_local, id_energia, oficina, num_mercado, categoria,
               seccion, local, letra_local, bloque, nombre,
               local_adicional, cuota, axo, adeudo, mesesadeudos WITH RESUME;
    END FOREACH;

END PROCEDURE;
