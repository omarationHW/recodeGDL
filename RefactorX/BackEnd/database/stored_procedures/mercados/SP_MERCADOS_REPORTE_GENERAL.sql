-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: ReporteGeneralMercados.vue
-- DESCRIPCIÓN: Procedimientos almacenados para reporte general estadístico
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP 1: SP_MERCADOS_ESTADISTICAS_GENERALES
-- Descripción: Obtiene estadísticas generales del sistema
-- =============================================

CREATE PROCEDURE SP_MERCADOS_ESTADISTICAS_GENERALES()

RETURNING
    INT AS total_recaudadoras,
    INT AS total_mercados,
    INT AS total_locales,
    INT AS locales_vigentes,
    INT AS locales_baja,
    INT AS total_secciones,
    INT AS total_giros,
    INT AS total_zonas,
    INT AS servicios_energia,
    DECIMAL(15,2) AS area_total_metros;

DEFINE v_total_recaudadoras INT;
DEFINE v_total_mercados INT;
DEFINE v_total_locales INT;
DEFINE v_locales_vigentes INT;
DEFINE v_locales_baja INT;
DEFINE v_total_secciones INT;
DEFINE v_total_giros INT;
DEFINE v_total_zonas INT;
DEFINE v_servicios_energia INT;
DEFINE v_area_total DECIMAL(15,2);

-- Total recaudadoras
SELECT COUNT(*) INTO v_total_recaudadoras FROM ta_11_recaudadora WHERE TRIM(vigencia) = 'V';

-- Total mercados
SELECT COUNT(*) INTO v_total_mercados FROM ta_11_mercados;

-- Total locales
SELECT COUNT(*) INTO v_total_locales FROM ta_11_locales;

-- Locales vigentes
SELECT COUNT(*) INTO v_locales_vigentes FROM ta_11_locales WHERE TRIM(vigencia) = 'V';

-- Locales de baja
SELECT COUNT(*) INTO v_locales_baja FROM ta_11_locales WHERE TRIM(vigencia) = 'B';

-- Total secciones
SELECT COUNT(*) INTO v_total_secciones FROM ta_11_secciones;

-- Total giros
SELECT COUNT(*) INTO v_total_giros FROM ta_11_giros WHERE TRIM(vigencia) = 'V';

-- Total zonas
SELECT COUNT(*) INTO v_total_zonas FROM ta_11_zonas WHERE TRIM(vigencia) = 'V';

-- Servicios de energía
SELECT COUNT(*) INTO v_servicios_energia FROM ta_11_energia;

-- Área total de locales
SELECT NVL(SUM(area), 0) INTO v_area_total FROM ta_11_locales WHERE TRIM(vigencia) = 'V';

RETURN
    v_total_recaudadoras,
    v_total_mercados,
    v_total_locales,
    v_locales_vigentes,
    v_locales_baja,
    v_total_secciones,
    v_total_giros,
    v_total_zonas,
    v_servicios_energia,
    v_area_total
WITH RESUME;

END PROCEDURE;

-- =============================================
-- SP 2: SP_MERCADOS_REPORTE_POR_RECAUDADORA
-- Descripción: Reporte detallado por recaudadora
-- =============================================

CREATE PROCEDURE SP_MERCADOS_REPORTE_POR_RECAUDADORA()

RETURNING
    SMALLINT AS oficina,
    VARCHAR(100) AS recaudadora,
    INT AS total_mercados,
    INT AS total_locales,
    INT AS locales_vigentes,
    INT AS servicios_energia,
    DECIMAL(15,2) AS area_total;

DEFINE v_oficina SMALLINT;
DEFINE v_recaudadora VARCHAR(100);
DEFINE v_total_mercados INT;
DEFINE v_total_locales INT;
DEFINE v_locales_vigentes INT;
DEFINE v_servicios_energia INT;
DEFINE v_area_total DECIMAL(15,2);

FOREACH
    SELECT
        r.oficina,
        TRIM(r.recaudadora),
        (SELECT COUNT(*) FROM ta_11_mercados m WHERE m.oficina = r.oficina),
        (SELECT COUNT(*) FROM ta_11_locales l WHERE l.oficina = r.oficina),
        (SELECT COUNT(*) FROM ta_11_locales l WHERE l.oficina = r.oficina AND TRIM(l.vigencia) = 'V'),
        (SELECT COUNT(*) FROM ta_11_energia e
         INNER JOIN ta_11_locales l ON e.id_local = l.id_local
         WHERE l.oficina = r.oficina),
        (SELECT NVL(SUM(l.area), 0) FROM ta_11_locales l
         WHERE l.oficina = r.oficina AND TRIM(l.vigencia) = 'V')
    INTO
        v_oficina,
        v_recaudadora,
        v_total_mercados,
        v_total_locales,
        v_locales_vigentes,
        v_servicios_energia,
        v_area_total
    FROM ta_11_recaudadora r
    WHERE TRIM(r.vigencia) = 'V'
    ORDER BY r.oficina

    RETURN
        v_oficina,
        v_recaudadora,
        v_total_mercados,
        v_total_locales,
        v_locales_vigentes,
        v_servicios_energia,
        v_area_total
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 3: SP_MERCADOS_REPORTE_POR_ZONA
-- Descripción: Reporte detallado por zona geográfica
-- =============================================

CREATE PROCEDURE SP_MERCADOS_REPORTE_POR_ZONA()

RETURNING
    SMALLINT AS id_zona,
    VARCHAR(100) AS descripcion,
    INT AS total_mercados,
    INT AS total_locales,
    DECIMAL(15,2) AS area_total;

DEFINE v_id_zona SMALLINT;
DEFINE v_descripcion VARCHAR(100);
DEFINE v_total_mercados INT;
DEFINE v_total_locales INT;
DEFINE v_area_total DECIMAL(15,2);

FOREACH
    SELECT
        z.id_zona,
        TRIM(z.descripcion),
        (SELECT COUNT(*) FROM ta_11_mercados m WHERE m.id_zona = z.id_zona),
        (SELECT COUNT(*) FROM ta_11_locales l
         INNER JOIN ta_11_mercados m ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
         WHERE m.id_zona = z.id_zona),
        (SELECT NVL(SUM(l.area), 0) FROM ta_11_locales l
         INNER JOIN ta_11_mercados m ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
         WHERE m.id_zona = z.id_zona AND TRIM(l.vigencia) = 'V')
    INTO
        v_id_zona,
        v_descripcion,
        v_total_mercados,
        v_total_locales,
        v_area_total
    FROM ta_11_zonas z
    WHERE TRIM(z.vigencia) = 'V'
    ORDER BY z.id_zona

    RETURN
        v_id_zona,
        v_descripcion,
        v_total_mercados,
        v_total_locales,
        v_area_total
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA REPORTE GENERAL
-- =============================================
