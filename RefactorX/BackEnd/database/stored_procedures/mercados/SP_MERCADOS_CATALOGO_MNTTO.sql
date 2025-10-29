-- =============================================
-- SP_MERCADOS_CATALOGO_MNTTO
-- Mantenimiento del catálogo de mercados
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CATALOGO_LIST()
RETURNING
    SMALLINT AS oficina,
    SMALLINT AS num_mercado_nvo,
    VARCHAR(100) AS descripcion,
    SMALLINT AS categoria,
    VARCHAR(20) AS id_zona,
    VARCHAR(20) AS cuenta_ingreso,
    VARCHAR(20) AS cuenta_energia,
    CHAR(1) AS tipo_emision;

    FOREACH
        SELECT
            m.oficina,
            m.num_mercado_nvo,
            NVL(TRIM(m.descripcion), '') AS descripcion,
            m.categoria,
            NVL(m.id_zona, '') AS id_zona,
            NVL(m.cuenta_ingreso, '') AS cuenta_ingreso,
            NVL(m.cuenta_energia, '') AS cuenta_energia,
            NVL(m.tipo_emision, 'M') AS tipo_emision
        INTO oficina, num_mercado_nvo, descripcion, categoria, id_zona,
             cuenta_ingreso, cuenta_energia, tipo_emision
        FROM mercados m
        ORDER BY m.oficina, m.num_mercado_nvo

        RETURN oficina, num_mercado_nvo, descripcion, categoria, id_zona,
               cuenta_ingreso, cuenta_energia, tipo_emision WITH RESUME;
    END FOREACH;

END PROCEDURE;

CREATE PROCEDURE SP_MERCADOS_CATALOGO_INSERT(
    p_oficina SMALLINT,
    p_num_mercado_nvo SMALLINT,
    p_categoria SMALLINT,
    p_descripcion VARCHAR(100),
    p_cuenta_ingreso VARCHAR(20),
    p_cuenta_energia VARCHAR(20),
    p_zona VARCHAR(20),
    p_tipo_emision CHAR(1)
)

    INSERT INTO mercados (
        oficina, num_mercado_nvo, categoria, descripcion,
        cuenta_ingreso, cuenta_energia, id_zona, tipo_emision
    ) VALUES (
        p_oficina, p_num_mercado_nvo, p_categoria, p_descripcion,
        p_cuenta_ingreso, p_cuenta_energia, p_zona, p_tipo_emision
    );

END PROCEDURE;

CREATE PROCEDURE SP_MERCADOS_CATALOGO_UPDATE(
    p_oficina SMALLINT,
    p_num_mercado_nvo SMALLINT,
    p_categoria SMALLINT,
    p_descripcion VARCHAR(100),
    p_cuenta_ingreso VARCHAR(20),
    p_cuenta_energia VARCHAR(20),
    p_zona VARCHAR(20),
    p_tipo_emision CHAR(1)
)

    UPDATE mercados
    SET categoria = p_categoria,
        descripcion = p_descripcion,
        cuenta_ingreso = p_cuenta_ingreso,
        cuenta_energia = p_cuenta_energia,
        id_zona = p_zona,
        tipo_emision = p_tipo_emision
    WHERE oficina = p_oficina
      AND num_mercado_nvo = p_num_mercado_nvo;

END PROCEDURE;
