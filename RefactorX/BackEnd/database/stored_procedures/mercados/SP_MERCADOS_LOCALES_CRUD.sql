-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: LocalesMtto.vue
-- DESCRIPCIÓN: Procedimientos almacenados para CRUD de locales
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP 1: SP_MERCADOS_SECCIONES_LIST
-- Descripción: Lista de secciones disponibles
-- =============================================

CREATE PROCEDURE SP_MERCADOS_SECCIONES_LIST()

RETURNING
    SMALLINT AS id_seccion,
    VARCHAR(2) AS seccion,
    VARCHAR(50) AS descripcion;

DEFINE v_id SMALLINT;
DEFINE v_seccion VARCHAR(2);
DEFINE v_descripcion VARCHAR(50);

FOREACH
    SELECT
        id_seccion,
        TRIM(seccion),
        TRIM(descripcion)
    INTO
        v_id,
        v_seccion,
        v_descripcion
    FROM ta_11_secciones
    ORDER BY seccion

    RETURN v_id, v_seccion, v_descripcion WITH RESUME;
END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 2: SP_MERCADOS_ZONAS_LIST
-- Descripción: Lista de zonas/sectores
-- =============================================

CREATE PROCEDURE SP_MERCADOS_ZONAS_LIST()

RETURNING
    INT AS id_zona,
    SMALLINT AS zona,
    VARCHAR(100) AS descripcion;

DEFINE v_id INT;
DEFINE v_zona SMALLINT;
DEFINE v_descripcion VARCHAR(100);

FOREACH
    SELECT
        id_zona,
        zona,
        TRIM(descripcion)
    INTO
        v_id,
        v_zona,
        v_descripcion
    FROM ta_11_zonas
    ORDER BY zona

    RETURN v_id, v_zona, v_descripcion WITH RESUME;
END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 3: SP_MERCADOS_CUOTAS_LIST
-- Descripción: Lista de claves de cuota por categoría y sección
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CUOTAS_LIST(
    p_anio SMALLINT,
    p_categoria SMALLINT,
    p_seccion VARCHAR(2)
)

RETURNING
    SMALLINT AS clave_cuota,
    VARCHAR(30) AS descripcion,
    DECIMAL(12,2) AS importe_cuota;

DEFINE v_clave SMALLINT;
DEFINE v_descripcion VARCHAR(30);
DEFINE v_importe DECIMAL(12,2);

FOREACH
    SELECT
        clave_cuota,
        TRIM(descripcion),
        importe_cuota
    INTO
        v_clave,
        v_descripcion,
        v_importe
    FROM ta_11_cuo_locales
    WHERE axo = p_anio
      AND categoria = p_categoria
      AND seccion = p_seccion
    ORDER BY clave_cuota

    RETURN v_clave, v_descripcion, v_importe WITH RESUME;
END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 4: SP_MERCADOS_CATEGORIAS_LIST
-- Descripción: Lista de categorías disponibles
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CATEGORIAS_LIST()

RETURNING
    SMALLINT AS categoria,
    VARCHAR(100) AS descripcion;

DEFINE v_categoria SMALLINT;
DEFINE v_descripcion VARCHAR(100);

FOREACH
    SELECT DISTINCT
        categoria,
        TRIM(descripcion)
    INTO
        v_categoria,
        v_descripcion
    FROM ta_11_mercados
    WHERE vigencia = 'A'
    ORDER BY categoria

    RETURN v_categoria, v_descripcion WITH RESUME;
END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 5: SP_MERCADOS_LOCAL_INSERTAR
-- Descripción: Inserta un nuevo local en el sistema
-- =============================================

CREATE PROCEDURE SP_MERCADOS_LOCAL_INSERTAR(
    p_oficina SMALLINT,
    p_num_mercado SMALLINT,
    p_categoria SMALLINT,
    p_seccion VARCHAR(2),
    p_local SMALLINT,
    p_letra_local VARCHAR(1),
    p_bloque VARCHAR(1),
    p_nombre VARCHAR(30),
    p_arrendatario VARCHAR(30),
    p_domicilio VARCHAR(100),
    p_sector VARCHAR(2),
    p_zona SMALLINT,
    p_descripcion_local VARCHAR(100),
    p_superficie DECIMAL(10,2),
    p_giro SMALLINT,
    p_clave_cuota SMALLINT,
    p_fecha_alta DATE,
    p_vigencia VARCHAR(1),
    p_id_usuario INT
)

RETURNING INT AS id_local;

DEFINE v_id_local INT;
DEFINE v_fecha_mod DATETIME YEAR TO SECOND;

-- Establecer fecha de modificación
LET v_fecha_mod = CURRENT YEAR TO SECOND;

-- Insertar el local
INSERT INTO ta_11_locales (
    oficina,
    num_mercado,
    categoria,
    seccion,
    local,
    letra_local,
    bloque,
    nombre,
    arrendatario,
    domicilio,
    sector,
    zona,
    descripcion_local,
    superficie,
    giro,
    clave_cuota,
    fecha_alta,
    fecha_modificacion,
    vigencia,
    id_usuario
) VALUES (
    p_oficina,
    p_num_mercado,
    p_categoria,
    p_seccion,
    p_local,
    p_letra_local,
    p_bloque,
    p_nombre,
    p_arrendatario,
    p_domicilio,
    p_sector,
    p_zona,
    p_descripcion_local,
    p_superficie,
    p_giro,
    p_clave_cuota,
    p_fecha_alta,
    v_fecha_mod,
    p_vigencia,
    p_id_usuario
);

-- Obtener el ID generado
LET v_id_local = DBINFO('sqlca.sqlerrd1');

RETURN v_id_local;

END PROCEDURE;

-- =============================================
-- SP 6: SP_MERCADOS_LOCAL_ACTUALIZAR
-- Descripción: Actualiza los datos de un local existente
-- =============================================

CREATE PROCEDURE SP_MERCADOS_LOCAL_ACTUALIZAR(
    p_id_local INT,
    p_nombre VARCHAR(30),
    p_arrendatario VARCHAR(30),
    p_domicilio VARCHAR(100),
    p_sector VARCHAR(2),
    p_zona SMALLINT,
    p_descripcion_local VARCHAR(100),
    p_superficie DECIMAL(10,2),
    p_giro SMALLINT,
    p_clave_cuota SMALLINT,
    p_fecha_baja DATE,
    p_vigencia VARCHAR(1),
    p_id_usuario INT
)

RETURNING INT AS rows_affected;

DEFINE v_fecha_mod DATETIME YEAR TO SECOND;
DEFINE v_rows INT;

-- Establecer fecha de modificación
LET v_fecha_mod = CURRENT YEAR TO SECOND;

-- Actualizar el local
UPDATE ta_11_locales
SET
    nombre = p_nombre,
    arrendatario = p_arrendatario,
    domicilio = p_domicilio,
    sector = p_sector,
    zona = p_zona,
    descripcion_local = p_descripcion_local,
    superficie = p_superficie,
    giro = p_giro,
    clave_cuota = p_clave_cuota,
    fecha_baja = p_fecha_baja,
    fecha_modificacion = v_fecha_mod,
    vigencia = p_vigencia,
    id_usuario = p_id_usuario
WHERE id_local = p_id_local;

-- Obtener filas afectadas
GET DIAGNOSTICS v_rows = ROW_COUNT;

RETURN v_rows;

END PROCEDURE;

-- =============================================
-- SP 7: SP_MERCADOS_LOCAL_CAMBIAR_VIGENCIA
-- Descripción: Cambia la vigencia de un local (activar/desactivar)
-- =============================================

CREATE PROCEDURE SP_MERCADOS_LOCAL_CAMBIAR_VIGENCIA(
    p_id_local INT,
    p_vigencia VARCHAR(1),
    p_fecha_baja DATE,
    p_id_usuario INT
)

RETURNING INT AS rows_affected;

DEFINE v_fecha_mod DATETIME YEAR TO SECOND;
DEFINE v_rows INT;

LET v_fecha_mod = CURRENT YEAR TO SECOND;

UPDATE ta_11_locales
SET
    vigencia = p_vigencia,
    fecha_baja = p_fecha_baja,
    fecha_modificacion = v_fecha_mod,
    id_usuario = p_id_usuario
WHERE id_local = p_id_local;

GET DIAGNOSTICS v_rows = ROW_COUNT;

RETURN v_rows;

END PROCEDURE;

-- =============================================
-- SP 8: SP_MERCADOS_LOCAL_BUSCAR
-- Descripción: Busca locales por múltiples criterios
-- =============================================

CREATE PROCEDURE SP_MERCADOS_LOCAL_BUSCAR(
    p_oficina SMALLINT,
    p_num_mercado SMALLINT,
    p_categoria SMALLINT,
    p_seccion VARCHAR(2),
    p_local SMALLINT,
    p_zona SMALLINT,
    p_clave_cuota SMALLINT,
    p_nombre VARCHAR(30),
    p_vigencia VARCHAR(1)
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
    VARCHAR(30) AS arrendatario,
    VARCHAR(100) AS domicilio,
    VARCHAR(2) AS sector,
    SMALLINT AS zona,
    VARCHAR(100) AS descripcion_local,
    DECIMAL(10,2) AS superficie,
    SMALLINT AS giro,
    SMALLINT AS clave_cuota,
    DATE AS fecha_alta,
    DATE AS fecha_baja,
    VARCHAR(1) AS vigencia;

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
DEFINE v_arrendatario VARCHAR(30);
DEFINE v_domicilio VARCHAR(100);
DEFINE v_sector VARCHAR(2);
DEFINE v_zona SMALLINT;
DEFINE v_descripcion VARCHAR(100);
DEFINE v_superficie DECIMAL(10,2);
DEFINE v_giro SMALLINT;
DEFINE v_clave_cuota SMALLINT;
DEFINE v_fecha_alta DATE;
DEFINE v_fecha_baja DATE;
DEFINE v_vigencia VARCHAR(1);

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
        TRIM(loc.arrendatario),
        TRIM(loc.domicilio),
        TRIM(loc.sector),
        loc.zona,
        TRIM(loc.descripcion_local),
        loc.superficie,
        loc.giro,
        loc.clave_cuota,
        loc.fecha_alta,
        loc.fecha_baja,
        loc.vigencia
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
        v_arrendatario,
        v_domicilio,
        v_sector,
        v_zona,
        v_descripcion,
        v_superficie,
        v_giro,
        v_clave_cuota,
        v_fecha_alta,
        v_fecha_baja,
        v_vigencia
    FROM ta_11_locales loc
    INNER JOIN ta_11_mercados merc
        ON loc.oficina = merc.oficina
        AND loc.num_mercado = merc.num_mercado_nvo
    WHERE (p_oficina IS NULL OR loc.oficina = p_oficina)
      AND (p_num_mercado IS NULL OR loc.num_mercado = p_num_mercado)
      AND (p_categoria IS NULL OR loc.categoria = p_categoria)
      AND (p_seccion IS NULL OR loc.seccion = p_seccion)
      AND (p_local IS NULL OR loc.local = p_local)
      AND (p_zona IS NULL OR loc.zona = p_zona)
      AND (p_clave_cuota IS NULL OR loc.clave_cuota = p_clave_cuota)
      AND (p_nombre IS NULL OR UPPER(loc.nombre) LIKE '%' || UPPER(p_nombre) || '%')
      AND (p_vigencia IS NULL OR loc.vigencia = p_vigencia)
    ORDER BY
        loc.oficina,
        loc.num_mercado,
        loc.categoria,
        loc.seccion,
        loc.local

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
        v_arrendatario,
        v_domicilio,
        v_sector,
        v_zona,
        v_descripcion,
        v_superficie,
        v_giro,
        v_clave_cuota,
        v_fecha_alta,
        v_fecha_baja,
        v_vigencia
    WITH RESUME;
END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 9: SP_MERCADOS_LOCAL_VALIDAR_DUPLICADO
-- Descripción: Valida si ya existe un local con la misma ubicación
-- =============================================

CREATE PROCEDURE SP_MERCADOS_LOCAL_VALIDAR_DUPLICADO(
    p_oficina SMALLINT,
    p_num_mercado SMALLINT,
    p_categoria SMALLINT,
    p_seccion VARCHAR(2),
    p_local SMALLINT,
    p_letra_local VARCHAR(1),
    p_bloque VARCHAR(1),
    p_id_local INT
)

RETURNING INT AS existe;

DEFINE v_count INT;

SELECT COUNT(*)
INTO v_count
FROM ta_11_locales
WHERE oficina = p_oficina
  AND num_mercado = p_num_mercado
  AND categoria = p_categoria
  AND seccion = p_seccion
  AND local = p_local
  AND (letra_local = p_letra_local OR (letra_local IS NULL AND p_letra_local IS NULL))
  AND (bloque = p_bloque OR (bloque IS NULL AND p_bloque IS NULL))
  AND (p_id_local IS NULL OR id_local <> p_id_local)
  AND vigencia = 'A';

RETURN v_count;

END PROCEDURE;

-- =============================================
-- SP 10: SP_MERCADOS_GIROS_LIST
-- Descripción: Lista de giros/actividades comerciales
-- =============================================

CREATE PROCEDURE SP_MERCADOS_GIROS_LIST()

RETURNING
    SMALLINT AS id_giro,
    VARCHAR(100) AS descripcion;

DEFINE v_id SMALLINT;
DEFINE v_descripcion VARCHAR(100);

FOREACH
    SELECT
        id_giro,
        TRIM(descripcion)
    INTO
        v_id,
        v_descripcion
    FROM ta_11_giros
    WHERE vigencia = 'A'
    ORDER BY descripcion

    RETURN v_id, v_descripcion WITH RESUME;
END FOREACH;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS CRUD PARA LOCALES
-- =============================================
