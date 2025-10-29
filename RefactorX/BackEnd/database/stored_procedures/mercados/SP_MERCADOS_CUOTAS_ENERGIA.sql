-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: CuotasEnergia.vue
-- DESCRIPCIÓN: Procedimientos almacenados para gestión de cuotas de energía
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP 1: SP_MERCADOS_CUOTAS_ENERGIA_LIST
-- Descripción: Lista todas las cuotas de energía
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CUOTAS_ENERGIA_LIST()

RETURNING
    INT AS id_kilowhatts,
    SMALLINT AS axo,
    SMALLINT AS periodo,
    DECIMAL(14,6) AS importe,
    DATETIME YEAR TO SECOND AS fecha_alta,
    VARCHAR(50) AS usuario;

DEFINE v_id_kilowhatts INT;
DEFINE v_axo SMALLINT;
DEFINE v_periodo SMALLINT;
DEFINE v_importe DECIMAL(14,6);
DEFINE v_fecha_alta DATETIME YEAR TO SECOND;
DEFINE v_usuario VARCHAR(50);

FOREACH
    SELECT
        k.id_kilowhatts,
        k.axo,
        k.periodo,
        k.importe,
        k.fecha_alta,
        TRIM(u.nombre)
    INTO
        v_id_kilowhatts,
        v_axo,
        v_periodo,
        v_importe,
        v_fecha_alta,
        v_usuario
    FROM ta_11_kilowhatts k
    LEFT JOIN ta_usuarios u ON k.id_usuario = u.id_usuario
    ORDER BY k.axo DESC, k.periodo DESC

    RETURN
        v_id_kilowhatts,
        v_axo,
        v_periodo,
        v_importe,
        v_fecha_alta,
        v_usuario
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 2: SP_MERCADOS_CUOTAS_ENERGIA_CREATE
-- Descripción: Crea una nueva cuota de energía
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CUOTAS_ENERGIA_CREATE(
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_importe DECIMAL(14,6),
    p_id_usuario INT
)

RETURNING
    VARCHAR(100) AS resultado;

-- Verificar que no existe una cuota para este periodo
DEFINE v_existe INT;

SELECT COUNT(*)
INTO v_existe
FROM ta_11_kilowhatts
WHERE axo = p_axo
  AND periodo = p_periodo;

IF v_existe > 0 THEN
    RAISE EXCEPTION 'Ya existe una cuota para este periodo';
END IF;

-- Insertar la cuota
INSERT INTO ta_11_kilowhatts (
    axo,
    periodo,
    importe,
    fecha_alta,
    id_usuario
) VALUES (
    p_axo,
    p_periodo,
    p_importe,
    CURRENT,
    p_id_usuario
);

RETURN 'Cuota creada correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- SP 3: SP_MERCADOS_CUOTAS_ENERGIA_UPDATE
-- Descripción: Actualiza una cuota de energía existente
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CUOTAS_ENERGIA_UPDATE(
    p_id_kilowhatts INT,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_importe DECIMAL(14,6)
)

RETURNING
    VARCHAR(100) AS resultado;

UPDATE ta_11_kilowhatts
SET
    axo = p_axo,
    periodo = p_periodo,
    importe = p_importe
WHERE id_kilowhatts = p_id_kilowhatts;

RETURN 'Cuota actualizada correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- SP 4: SP_MERCADOS_CUOTAS_ENERGIA_DELETE
-- Descripción: Elimina una cuota de energía
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CUOTAS_ENERGIA_DELETE(
    p_id_kilowhatts INT
)

RETURNING
    VARCHAR(100) AS resultado;

DELETE FROM ta_11_kilowhatts
WHERE id_kilowhatts = p_id_kilowhatts;

RETURN 'Cuota eliminada correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA CUOTAS DE ENERGÍA
-- =============================================
