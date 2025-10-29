-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: AdeudosLocales.vue
-- DESCRIPCIÓN: Procedimientos almacenados para consulta de adeudos de locales
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP 1: SP_MERCADOS_ADEUDOS_LOCALES_LIST
-- Descripción: Lista de locales con adeudos por año, oficina y periodo
-- =============================================

CREATE PROCEDURE SP_MERCADOS_ADEUDOS_LOCALES_LIST(
    p_axo SMALLINT,
    p_oficina SMALLINT,
    p_periodo SMALLINT
)

RETURNING
    INT AS id_local,
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    VARCHAR(100) AS nombre_mercado,
    SMALLINT AS categoria,
    VARCHAR(2) AS seccion,
    SMALLINT AS num_local,
    VARCHAR(1) AS letra_local,
    VARCHAR(1) AS bloque,
    VARCHAR(30) AS nombre_comerciante,
    DECIMAL(10,2) AS superficie,
    SMALLINT AS clave_cuota,
    DECIMAL(14,2) AS total_adeudo,
    VARCHAR(50) AS recaudadora,
    VARCHAR(100) AS descripcion_cuota;

DEFINE v_id_local INT;
DEFINE v_oficina SMALLINT;
DEFINE v_num_mercado SMALLINT;
DEFINE v_nombre_mercado VARCHAR(100);
DEFINE v_categoria SMALLINT;
DEFINE v_seccion VARCHAR(2);
DEFINE v_num_local SMALLINT;
DEFINE v_letra_local VARCHAR(1);
DEFINE v_bloque VARCHAR(1);
DEFINE v_nombre VARCHAR(30);
DEFINE v_superficie DECIMAL(10,2);
DEFINE v_clave_cuota SMALLINT;
DEFINE v_total_adeudo DECIMAL(14,2);
DEFINE v_recaudadora VARCHAR(50);
DEFINE v_descripcion_cuota VARCHAR(100);

FOREACH
    SELECT
        loc.id_local,
        loc.oficina,
        loc.num_mercado,
        TRIM(merc.descripcion),
        loc.categoria,
        TRIM(loc.seccion),
        loc.local,
        TRIM(loc.letra_local),
        TRIM(loc.bloque),
        TRIM(loc.nombre),
        loc.superficie,
        loc.clave_cuota,
        SUM(NVL(ade.importe, 0)),
        TRIM(rec.recaudadora),
        TRIM(cuo.descripcion)
    INTO
        v_id_local,
        v_oficina,
        v_num_mercado,
        v_nombre_mercado,
        v_categoria,
        v_seccion,
        v_num_local,
        v_letra_local,
        v_bloque,
        v_nombre,
        v_superficie,
        v_clave_cuota,
        v_total_adeudo,
        v_recaudadora,
        v_descripcion_cuota
    FROM ta_11_adeudo_local ade
    INNER JOIN ta_11_locales loc
        ON ade.id_local = loc.id_local
    INNER JOIN ta_12_recaudadoras rec
        ON rec.id_rec = loc.oficina
    INNER JOIN ta_11_mercados merc
        ON merc.oficina = loc.oficina
        AND merc.num_mercado_nvo = loc.num_mercado
    LEFT OUTER JOIN ta_11_cuo_locales cuo
        ON cuo.axo = p_axo
        AND cuo.categoria = loc.categoria
        AND cuo.seccion = loc.seccion
        AND cuo.clave_cuota = loc.clave_cuota
    WHERE ade.axo = p_axo
      AND loc.oficina = p_oficina
      AND ade.periodo <= p_periodo
      AND loc.vigencia = 'A'
    GROUP BY
        loc.id_local,
        loc.oficina,
        loc.num_mercado,
        merc.descripcion,
        loc.categoria,
        loc.seccion,
        loc.local,
        loc.letra_local,
        loc.bloque,
        loc.nombre,
        loc.superficie,
        loc.clave_cuota,
        rec.recaudadora,
        cuo.descripcion
    ORDER BY
        loc.oficina,
        loc.num_mercado,
        loc.categoria,
        loc.seccion DESC,
        loc.local,
        loc.letra_local,
        loc.bloque

    RETURN
        v_id_local,
        v_oficina,
        v_num_mercado,
        v_nombre_mercado,
        v_categoria,
        v_seccion,
        v_num_local,
        v_letra_local,
        v_bloque,
        v_nombre,
        v_superficie,
        v_clave_cuota,
        v_total_adeudo,
        v_recaudadora,
        v_descripcion_cuota
    WITH RESUME;
END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 2: SP_MERCADOS_MESES_ADEUDO
-- Descripción: Detalle de meses con adeudo para un local específico
-- =============================================

CREATE PROCEDURE SP_MERCADOS_MESES_ADEUDO(
    p_id_local INT,
    p_axo SMALLINT,
    p_periodo SMALLINT
)

RETURNING
    INT AS id_local,
    SMALLINT AS axo,
    SMALLINT AS periodo,
    DECIMAL(14,2) AS importe,
    VARCHAR(50) AS nombre_mes;

DEFINE v_id_local INT;
DEFINE v_axo SMALLINT;
DEFINE v_periodo SMALLINT;
DEFINE v_importe DECIMAL(14,2);
DEFINE v_nombre_mes VARCHAR(50);

FOREACH
    SELECT
        id_local,
        axo,
        periodo,
        importe,
        CASE periodo
            WHEN 1 THEN 'Enero'
            WHEN 2 THEN 'Febrero'
            WHEN 3 THEN 'Marzo'
            WHEN 4 THEN 'Abril'
            WHEN 5 THEN 'Mayo'
            WHEN 6 THEN 'Junio'
            WHEN 7 THEN 'Julio'
            WHEN 8 THEN 'Agosto'
            WHEN 9 THEN 'Septiembre'
            WHEN 10 THEN 'Octubre'
            WHEN 11 THEN 'Noviembre'
            WHEN 12 THEN 'Diciembre'
            ELSE 'Desconocido'
        END
    INTO
        v_id_local,
        v_axo,
        v_periodo,
        v_importe,
        v_nombre_mes
    FROM ta_11_adeudo_local
    WHERE id_local = p_id_local
      AND axo = p_axo
      AND periodo <= p_periodo
    ORDER BY axo, periodo

    RETURN v_id_local, v_axo, v_periodo, v_importe, v_nombre_mes WITH RESUME;
END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 3: SP_MERCADOS_RENTA_CUOTA
-- Descripción: Obtiene información de renta/cuota para cálculo
-- =============================================

CREATE PROCEDURE SP_MERCADOS_RENTA_CUOTA(
    p_axo SMALLINT,
    p_categoria SMALLINT,
    p_seccion VARCHAR(2),
    p_clave_cuota SMALLINT
)

RETURNING
    INT AS id_cuotas,
    SMALLINT AS axo,
    SMALLINT AS categoria,
    VARCHAR(2) AS seccion,
    SMALLINT AS clave_cuota,
    DECIMAL(12,2) AS importe_cuota,
    DATE AS fecha_alta,
    INT AS id_usuario;

DEFINE v_id_cuotas INT;
DEFINE v_axo SMALLINT;
DEFINE v_categoria SMALLINT;
DEFINE v_seccion VARCHAR(2);
DEFINE v_clave_cuota SMALLINT;
DEFINE v_importe_cuota DECIMAL(12,2);
DEFINE v_fecha_alta DATE;
DEFINE v_id_usuario INT;

FOREACH
    SELECT
        id_cuotas,
        axo,
        categoria,
        TRIM(seccion),
        clave_cuota,
        importe_cuota,
        fecha_alta,
        id_usuario
    INTO
        v_id_cuotas,
        v_axo,
        v_categoria,
        v_seccion,
        v_clave_cuota,
        v_importe_cuota,
        v_fecha_alta,
        v_id_usuario
    FROM ta_11_cuo_locales
    WHERE axo = p_axo
      AND categoria = p_categoria
      AND seccion = p_seccion
      AND clave_cuota = p_clave_cuota

    RETURN
        v_id_cuotas,
        v_axo,
        v_categoria,
        v_seccion,
        v_clave_cuota,
        v_importe_cuota,
        v_fecha_alta,
        v_id_usuario
    WITH RESUME;
END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 4: SP_MERCADOS_CALCULAR_RENTA
-- Descripción: Calcula la renta de un local según reglas de negocio
-- Nota: Basado en lógica original de AdeudosLocales.pas
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CALCULAR_RENTA(
    p_id_local INT,
    p_axo SMALLINT,
    p_superficie DECIMAL(10,2),
    p_categoria SMALLINT,
    p_seccion VARCHAR(2),
    p_num_mercado SMALLINT,
    p_clave_cuota SMALLINT
)

RETURNING DECIMAL(14,2) AS renta_calculada;

DEFINE v_importe_cuota DECIMAL(12,2);
DEFINE v_renta DECIMAL(14,2);
DEFINE v_sabados_acum SMALLINT;
DEFINE v_mes_actual SMALLINT;

-- Inicializar variables
LET v_renta = 0;
LET v_sabados_acum = 0;
LET v_mes_actual = MONTH(TODAY);

-- Obtener el importe de la cuota
SELECT importe_cuota
INTO v_importe_cuota
FROM ta_11_cuo_locales
WHERE axo = p_axo
  AND categoria = p_categoria
  AND seccion = p_seccion
  AND clave_cuota = p_clave_cuota;

-- Si no se encuentra la cuota, retornar 0
IF v_importe_cuota IS NULL THEN
    LET v_importe_cuota = 0;
END IF;

-- Aplicar reglas de cálculo según sección y mercado
-- Regla 1: Sección PS (Pago Semanal)
IF TRIM(p_seccion) = 'PS' THEN
    IF p_clave_cuota = 4 THEN
        -- PS con clave 4: superficie × cuota
        LET v_renta = NVL(p_superficie, 0) * NVL(v_importe_cuota, 0);
    ELSE
        -- PS con otras claves: (cuota × superficie) × 30
        LET v_renta = (NVL(v_importe_cuota, 0) * NVL(p_superficie, 0)) * 30;
    END IF;
-- Regla 2: Mercado 214 (tianguis con cálculo por sábados)
ELIF p_num_mercado = 214 THEN
    -- Obtener sábados acumulados del mes actual
    SELECT sabadosacum
    INTO v_sabados_acum
    FROM ta_11_vencimiento_rec
    WHERE mes = v_mes_actual;

    IF v_sabados_acum IS NULL THEN
        LET v_sabados_acum = 4; -- Default: 4 sábados por mes
    END IF;

    LET v_renta = (NVL(p_superficie, 0) * NVL(v_importe_cuota, 0)) * v_sabados_acum;
ELSE
    -- Regla general: superficie × cuota
    LET v_renta = NVL(p_superficie, 0) * NVL(v_importe_cuota, 0);
END IF;

RETURN v_renta;

END PROCEDURE;

-- =============================================
-- SP 5: SP_MERCADOS_VENCIMIENTO_RECARGOS
-- Descripción: Obtiene información de vencimientos y recargos por mes
-- =============================================

CREATE PROCEDURE SP_MERCADOS_VENCIMIENTO_RECARGOS(
    p_mes SMALLINT
)

RETURNING
    SMALLINT AS mes,
    DATE AS fecha_recargos,
    DATE AS fecha_descuento,
    SMALLINT AS trimestre,
    SMALLINT AS sabados,
    SMALLINT AS sabadosacum;

DEFINE v_mes SMALLINT;
DEFINE v_fecha_recargos DATE;
DEFINE v_fecha_descuento DATE;
DEFINE v_trimestre SMALLINT;
DEFINE v_sabados SMALLINT;
DEFINE v_sabadosacum SMALLINT;

FOREACH
    SELECT
        mes,
        fecha_recargos,
        fecha_descuento,
        trimestre,
        sabados,
        sabadosacum
    INTO
        v_mes,
        v_fecha_recargos,
        v_fecha_descuento,
        v_trimestre,
        v_sabados,
        v_sabadosacum
    FROM ta_11_vencimiento_rec
    WHERE mes = p_mes

    RETURN
        v_mes,
        v_fecha_recargos,
        v_fecha_descuento,
        v_trimestre,
        v_sabados,
        v_sabadosacum
    WITH RESUME;
END FOREACH;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA ADEUDOS DE LOCALES
-- =============================================
