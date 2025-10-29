-- =============================================
-- SP_MERCADOS_REQUERIMIENTOS
-- Consulta de requerimientos
-- =============================================

CREATE PROCEDURE SP_MERCADOS_GET_LOCALES_BY_MERCADO(
    p_oficina SMALLINT,
    p_num_mercado SMALLINT,
    p_categoria SMALLINT,
    p_seccion VARCHAR(2),
    p_local VARCHAR(7),
    p_letra_local VARCHAR(1),
    p_bloque VARCHAR(1)
)
RETURNING
    INT AS id_local,
    INT AS calcregistro,
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    SMALLINT AS categoria,
    VARCHAR(2) AS seccion,
    VARCHAR(7) AS local,
    VARCHAR(1) AS letra_local,
    VARCHAR(1) AS bloque;

    FOREACH
        SELECT
            l.id_local,
            l.id_local AS calcregistro,
            l.oficina,
            l.num_mercado,
            l.categoria,
            NVL(l.seccion, '') AS seccion,
            NVL(l.local, '') AS local,
            NVL(l.letra_local, '') AS letra_local,
            NVL(l.bloque, '') AS bloque
        INTO id_local, calcregistro, oficina, num_mercado, categoria,
             seccion, local, letra_local, bloque
        FROM locales l
        WHERE l.oficina = p_oficina
          AND l.num_mercado = p_num_mercado
          AND l.categoria = p_categoria
          AND l.seccion = p_seccion
          AND l.local LIKE p_local || '%'
          AND (p_letra_local IS NULL OR l.letra_local = p_letra_local)
          AND (p_bloque IS NULL OR l.bloque = p_bloque)
        ORDER BY l.id_local

        RETURN id_local, calcregistro, oficina, num_mercado, categoria,
               seccion, local, letra_local, bloque WITH RESUME;
    END FOREACH;

END PROCEDURE;

CREATE PROCEDURE SP_MERCADOS_GET_REQ_BY_LOCAL(
    p_modulo SMALLINT,
    p_control_otr INT
)
RETURNING
    INT AS id_control,
    VARCHAR(50) AS folio,
    DATE AS fecha_emision,
    VARCHAR(1) AS vigencia,
    VARCHAR(1) AS diligencia,
    VARCHAR(10) AS clave_practicado,
    DECIMAL(12,2) AS importe_global,
    DECIMAL(12,2) AS importe_multa,
    DECIMAL(12,2) AS importe_recargo,
    DECIMAL(12,2) AS importe_gastos,
    INT AS control_otr;

    FOREACH
        SELECT
            r.id_control,
            NVL(r.folio, '') AS folio,
            r.fecha_emision,
            NVL(r.vigencia, 'N') AS vigencia,
            NVL(r.diligencia, 'N') AS diligencia,
            NVL(r.clave_practicado, '') AS clave_practicado,
            NVL(r.importe_global, 0) AS importe_global,
            NVL(r.importe_multa, 0) AS importe_multa,
            NVL(r.importe_recargo, 0) AS importe_recargo,
            NVL(r.importe_gastos, 0) AS importe_gastos,
            r.control_otr
        INTO id_control, folio, fecha_emision, vigencia, diligencia,
             clave_practicado, importe_global, importe_multa,
             importe_recargo, importe_gastos, control_otr
        FROM requerimientos r
        WHERE r.modulo = p_modulo
          AND r.control_otr = p_control_otr
        ORDER BY r.fecha_emision DESC

        RETURN id_control, folio, fecha_emision, vigencia, diligencia,
               clave_practicado, importe_global, importe_multa,
               importe_recargo, importe_gastos, control_otr WITH RESUME;
    END FOREACH;

END PROCEDURE;

CREATE PROCEDURE SP_MERCADOS_GET_PERIODOS_REQ(
    p_control_otr INT
)
RETURNING
    INT AS id_control,
    SMALLINT AS ayo,
    SMALLINT AS periodo,
    DECIMAL(12,2) AS importe,
    DECIMAL(12,2) AS recargos;

    FOREACH
        SELECT
            pr.id_control,
            pr.ayo,
            pr.periodo,
            NVL(pr.importe, 0) AS importe,
            NVL(pr.recargos, 0) AS recargos
        INTO id_control, ayo, periodo, importe, recargos
        FROM periodos_requerimientos pr
        WHERE pr.id_control = p_control_otr
        ORDER BY pr.ayo, pr.periodo

        RETURN id_control, ayo, periodo, importe, recargos WITH RESUME;
    END FOREACH;

END PROCEDURE;
