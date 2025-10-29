-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: CuotasMdo.vue
-- DESCRIPCIÓN: Procedimientos almacenados para gestión de cuotas de mercados
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP 1: SP_MERCADOS_CUOTAS_LIST
-- Descripción: Lista todas las cuotas de mercados
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CUOTAS_LIST()

RETURNING
    INT AS id_cuota,
    SMALLINT AS oficina,
    VARCHAR(100) AS recaudadora,
    SMALLINT AS num_mercado,
    VARCHAR(100) AS desc_mercado,
    SMALLINT AS categoria,
    DECIMAL(10,2) AS cuota_diaria,
    DECIMAL(10,2) AS cuota_mensual,
    INT AS axo,
    VARCHAR(1) AS vigencia;

DEFINE v_id_cuota INT;
DEFINE v_oficina SMALLINT;
DEFINE v_recaudadora VARCHAR(100);
DEFINE v_num_mercado SMALLINT;
DEFINE v_desc_mercado VARCHAR(100);
DEFINE v_categoria SMALLINT;
DEFINE v_cuota_diaria DECIMAL(10,2);
DEFINE v_cuota_mensual DECIMAL(10,2);
DEFINE v_axo INT;
DEFINE v_vigencia VARCHAR(1);

FOREACH
    SELECT
        c.id_cuota,
        c.oficina,
        TRIM(r.recaudadora),
        c.num_mercado,
        TRIM(m.descripcion),
        c.categoria,
        NVL(c.cuota_diaria, 0),
        NVL(c.cuota_mensual, 0),
        c.axo,
        TRIM(c.vigencia)
    INTO
        v_id_cuota,
        v_oficina,
        v_recaudadora,
        v_num_mercado,
        v_desc_mercado,
        v_categoria,
        v_cuota_diaria,
        v_cuota_mensual,
        v_axo,
        v_vigencia
    FROM ta_11_cuotas_mdo c
    INNER JOIN ta_11_recaudadora r ON c.oficina = r.oficina
    INNER JOIN ta_11_mercados m ON c.oficina = m.oficina AND c.num_mercado = m.num_mercado_nvo
    ORDER BY c.axo DESC, c.oficina, c.num_mercado, c.categoria

    RETURN
        v_id_cuota,
        v_oficina,
        v_recaudadora,
        v_num_mercado,
        v_desc_mercado,
        v_categoria,
        v_cuota_diaria,
        v_cuota_mensual,
        v_axo,
        v_vigencia
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 2: SP_MERCADOS_CUOTAS_BY_FILTROS
-- Descripción: Lista cuotas filtradas por oficina, mercado y año
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CUOTAS_BY_FILTROS(
    p_oficina SMALLINT,
    p_num_mercado SMALLINT,
    p_axo INT,
    p_vigencia VARCHAR(1)
)

RETURNING
    INT AS id_cuota,
    SMALLINT AS oficina,
    VARCHAR(100) AS recaudadora,
    SMALLINT AS num_mercado,
    VARCHAR(100) AS desc_mercado,
    SMALLINT AS categoria,
    DECIMAL(10,2) AS cuota_diaria,
    DECIMAL(10,2) AS cuota_mensual,
    INT AS axo,
    VARCHAR(1) AS vigencia;

DEFINE v_id_cuota INT;
DEFINE v_oficina SMALLINT;
DEFINE v_recaudadora VARCHAR(100);
DEFINE v_num_mercado SMALLINT;
DEFINE v_desc_mercado VARCHAR(100);
DEFINE v_categoria SMALLINT;
DEFINE v_cuota_diaria DECIMAL(10,2);
DEFINE v_cuota_mensual DECIMAL(10,2);
DEFINE v_axo INT;
DEFINE v_vigencia VARCHAR(1);

FOREACH
    SELECT
        c.id_cuota,
        c.oficina,
        TRIM(r.recaudadora),
        c.num_mercado,
        TRIM(m.descripcion),
        c.categoria,
        NVL(c.cuota_diaria, 0),
        NVL(c.cuota_mensual, 0),
        c.axo,
        TRIM(c.vigencia)
    INTO
        v_id_cuota,
        v_oficina,
        v_recaudadora,
        v_num_mercado,
        v_desc_mercado,
        v_categoria,
        v_cuota_diaria,
        v_cuota_mensual,
        v_axo,
        v_vigencia
    FROM ta_11_cuotas_mdo c
    INNER JOIN ta_11_recaudadora r ON c.oficina = r.oficina
    INNER JOIN ta_11_mercados m ON c.oficina = m.oficina AND c.num_mercado = m.num_mercado_nvo
    WHERE (p_oficina IS NULL OR c.oficina = p_oficina)
      AND (p_num_mercado IS NULL OR c.num_mercado = p_num_mercado)
      AND (p_axo IS NULL OR c.axo = p_axo)
      AND (p_vigencia IS NULL OR TRIM(c.vigencia) = TRIM(p_vigencia))
    ORDER BY c.axo DESC, c.oficina, c.num_mercado, c.categoria

    RETURN
        v_id_cuota,
        v_oficina,
        v_recaudadora,
        v_num_mercado,
        v_desc_mercado,
        v_categoria,
        v_cuota_diaria,
        v_cuota_mensual,
        v_axo,
        v_vigencia
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 3: SP_MERCADOS_CUOTAS_CREATE
-- Descripción: Crea una nueva cuota de mercado
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CUOTAS_CREATE(
    p_oficina SMALLINT,
    p_num_mercado SMALLINT,
    p_categoria SMALLINT,
    p_cuota_diaria DECIMAL(10,2),
    p_cuota_mensual DECIMAL(10,2),
    p_axo INT,
    p_vigencia VARCHAR(1)
)

RETURNING
    VARCHAR(100) AS resultado;

-- Verificar si ya existe para ese año, mercado y categoría
DEFINE v_existe INT;

SELECT COUNT(*)
INTO v_existe
FROM ta_11_cuotas_mdo
WHERE oficina = p_oficina
  AND num_mercado = p_num_mercado
  AND categoria = p_categoria
  AND axo = p_axo;

IF v_existe > 0 THEN
    RAISE EXCEPTION 'Ya existe una cuota para este mercado, categoría y año';
END IF;

-- Insertar
INSERT INTO ta_11_cuotas_mdo (
    oficina,
    num_mercado,
    categoria,
    cuota_diaria,
    cuota_mensual,
    axo,
    vigencia
) VALUES (
    p_oficina,
    p_num_mercado,
    p_categoria,
    p_cuota_diaria,
    p_cuota_mensual,
    p_axo,
    p_vigencia
);

RETURN 'Cuota creada correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- SP 4: SP_MERCADOS_CUOTAS_UPDATE
-- Descripción: Actualiza una cuota de mercado existente
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CUOTAS_UPDATE(
    p_id_cuota INT,
    p_cuota_diaria DECIMAL(10,2),
    p_cuota_mensual DECIMAL(10,2),
    p_vigencia VARCHAR(1)
)

RETURNING
    VARCHAR(100) AS resultado;

UPDATE ta_11_cuotas_mdo
SET
    cuota_diaria = p_cuota_diaria,
    cuota_mensual = p_cuota_mensual,
    vigencia = p_vigencia
WHERE id_cuota = p_id_cuota;

RETURN 'Cuota actualizada correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- SP 5: SP_MERCADOS_CUOTAS_DELETE
-- Descripción: Elimina una cuota de mercado
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CUOTAS_DELETE(
    p_id_cuota INT
)

RETURNING
    VARCHAR(100) AS resultado;

DELETE FROM ta_11_cuotas_mdo
WHERE id_cuota = p_id_cuota;

RETURN 'Cuota eliminada correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA CUOTAS DE MERCADOS
-- =============================================
