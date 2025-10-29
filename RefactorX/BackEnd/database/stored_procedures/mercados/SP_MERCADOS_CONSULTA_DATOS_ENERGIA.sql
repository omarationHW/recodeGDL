-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: ConsultaDatosEnergia.vue
-- DESCRIPCIÓN: Procedimiento almacenado para consulta de datos de energía
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP: SP_MERCADOS_CONSULTA_DATOS_ENERGIA
-- Descripción: Consulta información detallada de servicios de energía con filtros
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CONSULTA_DATOS_ENERGIA(
    p_oficina SMALLINT,
    p_num_mercado SMALLINT,
    p_categoria SMALLINT,
    p_cve_consumo VARCHAR(1),
    p_vigencia VARCHAR(1)
)

RETURNING
    INT AS id_energia,
    INT AS id_local,
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    VARCHAR(100) AS desc_mercado,
    SMALLINT AS categoria,
    SMALLINT AS seccion,
    SMALLINT AS local,
    VARCHAR(1) AS letra_local,
    VARCHAR(10) AS bloque,
    VARCHAR(100) AS nombre,
    VARCHAR(1) AS cve_consumo,
    VARCHAR(50) AS desc_consumo,
    DECIMAL(10,2) AS cantidad,
    DECIMAL(10,2) AS cuota,
    VARCHAR(10) AS local_adicional,
    DATE AS fecha_alta,
    DATE AS fecha_baja,
    VARCHAR(1) AS vigencia;

DEFINE v_id_energia INT;
DEFINE v_id_local INT;
DEFINE v_oficina SMALLINT;
DEFINE v_num_mercado SMALLINT;
DEFINE v_desc_mercado VARCHAR(100);
DEFINE v_categoria SMALLINT;
DEFINE v_seccion SMALLINT;
DEFINE v_local SMALLINT;
DEFINE v_letra_local VARCHAR(1);
DEFINE v_bloque VARCHAR(10);
DEFINE v_nombre VARCHAR(100);
DEFINE v_cve_consumo VARCHAR(1);
DEFINE v_desc_consumo VARCHAR(50);
DEFINE v_cantidad DECIMAL(10,2);
DEFINE v_cuota DECIMAL(10,2);
DEFINE v_local_adicional VARCHAR(10);
DEFINE v_fecha_alta DATE;
DEFINE v_fecha_baja DATE;
DEFINE v_vigencia VARCHAR(1);

FOREACH
    SELECT
        e.id_energia,
        l.id_local,
        l.oficina,
        l.num_mercado,
        TRIM(m.descripcion),
        l.categoria,
        l.seccion,
        l.local,
        TRIM(l.letra_local),
        TRIM(l.bloque),
        TRIM(l.nombre),
        TRIM(e.cve_consumo),
        CASE
            WHEN TRIM(e.cve_consumo) = 'K' THEN 'Kilowatts'
            WHEN TRIM(e.cve_consumo) = 'C' THEN 'Cuota Fija'
            WHEN TRIM(e.cve_consumo) = 'M' THEN 'Mixto'
            ELSE 'Desconocido'
        END,
        NVL(e.cantidad, 0),
        NVL(e.cuota, 0),
        TRIM(e.local_adicional),
        e.fecha_alta,
        e.fecha_baja,
        TRIM(l.vigencia)
    INTO
        v_id_energia,
        v_id_local,
        v_oficina,
        v_num_mercado,
        v_desc_mercado,
        v_categoria,
        v_seccion,
        v_local,
        v_letra_local,
        v_bloque,
        v_nombre,
        v_cve_consumo,
        v_desc_consumo,
        v_cantidad,
        v_cuota,
        v_local_adicional,
        v_fecha_alta,
        v_fecha_baja,
        v_vigencia
    FROM ta_11_energia e
    INNER JOIN ta_11_locales l ON e.id_local = l.id_local
    INNER JOIN ta_11_mercados m ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
    WHERE (p_oficina IS NULL OR l.oficina = p_oficina)
      AND (p_num_mercado IS NULL OR l.num_mercado = p_num_mercado)
      AND (p_categoria IS NULL OR l.categoria = p_categoria)
      AND (p_cve_consumo IS NULL OR TRIM(e.cve_consumo) = TRIM(p_cve_consumo))
      AND (p_vigencia IS NULL OR TRIM(l.vigencia) = TRIM(p_vigencia))
    ORDER BY l.oficina, l.num_mercado, l.categoria, l.seccion, l.local

    RETURN
        v_id_energia,
        v_id_local,
        v_oficina,
        v_num_mercado,
        v_desc_mercado,
        v_categoria,
        v_seccion,
        v_local,
        v_letra_local,
        v_bloque,
        v_nombre,
        v_cve_consumo,
        v_desc_consumo,
        v_cantidad,
        v_cuota,
        v_local_adicional,
        v_fecha_alta,
        v_fecha_baja,
        v_vigencia
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTO PARA CONSULTA DE DATOS DE ENERGÍA
-- =============================================
