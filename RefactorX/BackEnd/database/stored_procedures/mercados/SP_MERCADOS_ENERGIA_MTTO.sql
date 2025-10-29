-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: EnergiaMtto.vue
-- DESCRIPCIÓN: Procedimientos almacenados para mantenimiento de energía eléctrica
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP 1: SP_MERCADOS_SECCIONES_LIST
-- Descripción: Lista de secciones
-- =============================================

CREATE PROCEDURE SP_MERCADOS_SECCIONES_LIST()

RETURNING
    VARCHAR(2) AS seccion,
    VARCHAR(50) AS descripcion;

DEFINE v_seccion VARCHAR(2);
DEFINE v_descripcion VARCHAR(50);

FOREACH
    SELECT
        TRIM(seccion),
        TRIM(descripcion)
    INTO
        v_seccion,
        v_descripcion
    FROM ta_11_secciones
    ORDER BY seccion

    RETURN
        v_seccion,
        v_descripcion
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 2: SP_MERCADOS_BUSCAR_LOCAL_ENERGIA
-- Descripción: Busca un local para alta de energía (verifica que no tenga energía)
-- =============================================

CREATE PROCEDURE SP_MERCADOS_BUSCAR_LOCAL_ENERGIA(
    p_oficina SMALLINT,
    p_num_mercado SMALLINT,
    p_categoria SMALLINT,
    p_seccion VARCHAR(2),
    p_local SMALLINT,
    p_letra_local VARCHAR(1),
    p_bloque VARCHAR(1)
)

RETURNING
    INT AS id_local,
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    SMALLINT AS categoria,
    VARCHAR(2) AS seccion,
    SMALLINT AS local,
    VARCHAR(1) AS letra_local,
    VARCHAR(1) AS bloque,
    VARCHAR(30) AS nombre;

DEFINE v_id_local INT;
DEFINE v_oficina SMALLINT;
DEFINE v_num_mercado SMALLINT;
DEFINE v_categoria SMALLINT;
DEFINE v_seccion VARCHAR(2);
DEFINE v_local SMALLINT;
DEFINE v_letra_local VARCHAR(1);
DEFINE v_bloque VARCHAR(1);
DEFINE v_nombre VARCHAR(30);
DEFINE v_tiene_energia INT;

-- Buscar el local
SELECT
    l.id_local,
    l.oficina,
    l.num_mercado,
    l.categoria,
    TRIM(l.seccion),
    l.local,
    TRIM(l.letra_local),
    TRIM(l.bloque),
    TRIM(l.nombre)
INTO
    v_id_local,
    v_oficina,
    v_num_mercado,
    v_categoria,
    v_seccion,
    v_local,
    v_letra_local,
    v_bloque,
    v_nombre
FROM ta_11_locales l
WHERE l.oficina = p_oficina
  AND l.num_mercado = p_num_mercado
  AND l.categoria = p_categoria
  AND l.seccion = p_seccion
  AND l.local = p_local
  AND (p_letra_local IS NULL OR p_letra_local = '' OR l.letra_local = p_letra_local)
  AND (p_bloque IS NULL OR p_bloque = '' OR l.bloque = p_bloque);

IF v_id_local IS NULL THEN
    -- Local no encontrado
    RAISE EXCEPTION 'Local no encontrado';
END IF;

-- Verificar si ya tiene energía
SELECT COUNT(*)
INTO v_tiene_energia
FROM ta_11_energia
WHERE id_local = v_id_local;

IF v_tiene_energia > 0 THEN
    RAISE EXCEPTION 'El local ya tiene energía registrada';
END IF;

-- Retornar el local encontrado
RETURN
    v_id_local,
    v_oficina,
    v_num_mercado,
    v_categoria,
    v_seccion,
    v_local,
    v_letra_local,
    v_bloque,
    v_nombre
WITH RESUME;

END PROCEDURE;

-- =============================================
-- SP 3: SP_MERCADOS_ALTA_ENERGIA
-- Descripción: Da de alta un registro de energía con historial y adeudos
-- =============================================

CREATE PROCEDURE SP_MERCADOS_ALTA_ENERGIA(
    p_id_local INT,
    p_cve_consumo VARCHAR(1),
    p_descripcion VARCHAR(50),
    p_cantidad DECIMAL(10,2),
    p_vigencia VARCHAR(1),
    p_fecha_alta DATE,
    p_axo SMALLINT,
    p_numero VARCHAR(20),
    p_id_usuario INT
)

RETURNING
    VARCHAR(100) AS resultado;

DEFINE v_id_energia INT;
DEFINE v_periodo SMALLINT;
DEFINE v_peralt DATE;
DEFINE v_cant DECIMAL(10,2);
DEFINE v_mes SMALLINT;
DEFINE v_alo SMALLINT;
DEFINE v_fecha_hoy DATE;

-- Fecha actual
LET v_fecha_hoy = TODAY;

-- Insertar en ta_11_energia
INSERT INTO ta_11_energia (
    id_local,
    cve_consumo,
    local_adicional,
    cantidad,
    vigencia,
    fecha_alta,
    fecha_baja,
    fecha_modificacion,
    id_usuario
)
VALUES (
    p_id_local,
    p_cve_consumo,
    p_descripcion,
    p_cantidad,
    p_vigencia,
    p_fecha_alta,
    NULL,
    CURRENT YEAR TO SECOND,
    p_id_usuario
);

-- Obtener el ID generado
SELECT MAX(id_energia)
INTO v_id_energia
FROM ta_11_energia
WHERE id_local = p_id_local;

-- Insertar en historial
INSERT INTO ta_11_energia_hist (
    id_energia,
    axo,
    numero,
    cve_consumo,
    local_adicional,
    cantidad,
    vigencia,
    fecha_alta,
    fecha_baja,
    fecha_modificacion,
    id_usuario,
    tipo_mov,
    fecha_mov,
    id_usuario_mov
)
VALUES (
    v_id_energia,
    p_axo,
    p_numero,
    p_cve_consumo,
    p_descripcion,
    p_cantidad,
    p_vigencia,
    p_fecha_alta,
    NULL,
    CURRENT YEAR TO SECOND,
    p_id_usuario,
    'A',
    CURRENT YEAR TO SECOND,
    p_id_usuario
);

-- Generar adeudos desde fecha de alta hasta hoy
LET v_peralt = p_fecha_alta;

WHILE v_peralt <= v_fecha_hoy
    LET v_alo = YEAR(v_peralt);
    LET v_mes = MONTH(v_peralt);

    -- Determinar periodo según año
    IF v_alo <= 2002 THEN
        -- Bimestral
        IF v_mes >= 1 AND v_mes <= 2 THEN
            LET v_periodo = 1;
        ELIF v_mes >= 3 AND v_mes <= 4 THEN
            LET v_periodo = 2;
        ELIF v_mes >= 5 AND v_mes <= 6 THEN
            LET v_periodo = 3;
        ELIF v_mes >= 7 AND v_mes <= 8 THEN
            LET v_periodo = 4;
        ELIF v_mes >= 9 AND v_mes <= 10 THEN
            LET v_periodo = 5;
        ELSE
            LET v_periodo = 6;
        END IF;
        LET v_cant = p_cantidad * 2;
    ELSE
        -- Mensual
        LET v_periodo = v_mes;
        LET v_cant = p_cantidad;
    END IF;

    -- Insertar adeudo
    INSERT INTO ta_11_adeudo_energ (
        id_energia,
        axo,
        periodo,
        cve_consumo,
        cantidad,
        importe,
        fecha_alta,
        id_usuario
    )
    VALUES (
        v_id_energia,
        v_alo,
        v_periodo,
        p_cve_consumo,
        v_cant,
        v_cant,
        CURRENT YEAR TO SECOND,
        p_id_usuario
    );

    -- Siguiente periodo
    IF v_alo <= 2002 THEN
        -- Avanzar 60 días (bimestral)
        LET v_peralt = v_peralt + 60 UNITS DAY;
    ELSE
        -- Avanzar 30 días (mensual)
        LET v_peralt = v_peralt + 30 UNITS DAY;
    END IF;

END WHILE;

RETURN 'Energía registrada correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA MANTENIMIENTO DE ENERGÍA
-- =============================================
