-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: ConsultaDatosLocales.vue
-- DESCRIPCIÓN: Procedimiento almacenado para consulta de datos de locales
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP: SP_MERCADOS_CONSULTA_DATOS_LOCALES
-- Descripción: Consulta información detallada de locales con filtros múltiples
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CONSULTA_DATOS_LOCALES(
    p_oficina SMALLINT,
    p_num_mercado SMALLINT,
    p_categoria SMALLINT,
    p_seccion SMALLINT,
    p_local SMALLINT,
    p_letra_local VARCHAR(1),
    p_bloque VARCHAR(10),
    p_nombre_comerciante VARCHAR(100),
    p_vigencia VARCHAR(1)
)

RETURNING
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
    VARCHAR(20) AS telefono,
    VARCHAR(100) AS domicilio,
    VARCHAR(100) AS colonia,
    INT AS codigo_postal,
    VARCHAR(10) AS giro,
    VARCHAR(100) AS desc_giro,
    DATE AS fecha_alta,
    DATE AS fecha_baja,
    VARCHAR(1) AS vigencia,
    DECIMAL(10,2) AS area,
    DECIMAL(10,2) AS frente,
    DECIMAL(10,2) AS fondo,
    VARCHAR(100) AS observaciones;

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
DEFINE v_telefono VARCHAR(20);
DEFINE v_domicilio VARCHAR(100);
DEFINE v_colonia VARCHAR(100);
DEFINE v_codigo_postal INT;
DEFINE v_giro VARCHAR(10);
DEFINE v_desc_giro VARCHAR(100);
DEFINE v_fecha_alta DATE;
DEFINE v_fecha_baja DATE;
DEFINE v_vigencia VARCHAR(1);
DEFINE v_area DECIMAL(10,2);
DEFINE v_frente DECIMAL(10,2);
DEFINE v_fondo DECIMAL(10,2);
DEFINE v_observaciones VARCHAR(100);

FOREACH
    SELECT
        a.id_local,
        a.oficina,
        a.num_mercado,
        TRIM(b.descripcion),
        a.categoria,
        a.seccion,
        a.local,
        TRIM(a.letra_local),
        TRIM(a.bloque),
        TRIM(a.nombre),
        TRIM(a.telefono),
        TRIM(a.domicilio),
        TRIM(a.colonia),
        a.codigo_postal,
        TRIM(a.giro),
        TRIM(c.descripcion),
        a.fecha_alta,
        a.fecha_baja,
        TRIM(a.vigencia),
        NVL(a.area, 0),
        NVL(a.frente, 0),
        NVL(a.fondo, 0),
        TRIM(a.observaciones)
    INTO
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
        v_telefono,
        v_domicilio,
        v_colonia,
        v_codigo_postal,
        v_giro,
        v_desc_giro,
        v_fecha_alta,
        v_fecha_baja,
        v_vigencia,
        v_area,
        v_frente,
        v_fondo,
        v_observaciones
    FROM ta_11_locales a
    INNER JOIN ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
    LEFT JOIN ta_11_giros c ON a.giro = c.cve_giro
    WHERE (p_oficina IS NULL OR a.oficina = p_oficina)
      AND (p_num_mercado IS NULL OR a.num_mercado = p_num_mercado)
      AND (p_categoria IS NULL OR a.categoria = p_categoria)
      AND (p_seccion IS NULL OR a.seccion = p_seccion)
      AND (p_local IS NULL OR a.local = p_local)
      AND (p_letra_local IS NULL OR TRIM(a.letra_local) = TRIM(p_letra_local))
      AND (p_bloque IS NULL OR TRIM(a.bloque) = TRIM(p_bloque))
      AND (p_nombre_comerciante IS NULL OR UPPER(a.nombre) LIKE '%' || UPPER(p_nombre_comerciante) || '%')
      AND (p_vigencia IS NULL OR TRIM(a.vigencia) = TRIM(p_vigencia))
    ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local

    RETURN
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
        v_telefono,
        v_domicilio,
        v_colonia,
        v_codigo_postal,
        v_giro,
        v_desc_giro,
        v_fecha_alta,
        v_fecha_baja,
        v_vigencia,
        v_area,
        v_frente,
        v_fondo,
        v_observaciones
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTO PARA CONSULTA DE DATOS DE LOCALES
-- =============================================
