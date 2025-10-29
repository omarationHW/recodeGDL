-- =============================================
-- SP_MERCADOS_CUOTAS_MNTTO
-- Mantenimiento de cuotas de energía eléctrica
-- =============================================

-- Listar cuotas con filtros opcionales
CREATE PROCEDURE SP_MERCADOS_CUOTAS_LIST_FILTER(
    p_axo SMALLINT,
    p_periodo SMALLINT
)
RETURNING
    INT AS id_kilowhatts,
    SMALLINT AS axo,
    SMALLINT AS periodo,
    DECIMAL(12,6) AS importe,
    DATETIME YEAR TO SECOND AS fecha_alta,
    INT AS id_usuario,
    VARCHAR(100) AS usuario;

    FOREACH
        SELECT
            k.id_kilowhatts,
            k.axo,
            k.periodo,
            k.importe,
            k.fecha_alta,
            k.id_usuario,
            NVL(u.nombre, '') AS usuario
        INTO
            id_kilowhatts,
            axo,
            periodo,
            importe,
            fecha_alta,
            id_usuario,
            usuario
        FROM kilowhatts k
        LEFT JOIN usuarios u ON k.id_usuario = u.id_usuario
        WHERE (p_axo IS NULL OR k.axo = p_axo)
          AND (p_periodo IS NULL OR k.periodo = p_periodo)
        ORDER BY k.axo DESC, k.periodo DESC

        RETURN id_kilowhatts, axo, periodo, importe, fecha_alta, id_usuario, usuario WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- Insertar nueva cuota
CREATE PROCEDURE SP_MERCADOS_CUOTA_INSERT(
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_importe DECIMAL(12,6),
    p_id_usuario INT
)

    DEFINE v_count INT;
    DEFINE v_id INT;

    -- Verificar duplicados
    SELECT COUNT(*) INTO v_count
    FROM kilowhatts
    WHERE axo = p_axo
      AND periodo = p_periodo;

    IF v_count > 0 THEN
        RAISE EXCEPTION -746, 0, 'Ya existe una cuota para este año y periodo';
    END IF;

    -- Obtener nuevo ID
    SELECT NVL(MAX(id_kilowhatts), 0) + 1 INTO v_id
    FROM kilowhatts;

    -- Insertar
    INSERT INTO kilowhatts (
        id_kilowhatts,
        axo,
        periodo,
        importe,
        fecha_alta,
        id_usuario
    ) VALUES (
        v_id,
        p_axo,
        p_periodo,
        p_importe,
        CURRENT,
        p_id_usuario
    );

END PROCEDURE;

-- Actualizar cuota existente
CREATE PROCEDURE SP_MERCADOS_CUOTA_UPDATE(
    p_id_kilowhatts INT,
    p_importe DECIMAL(12,6),
    p_id_usuario INT
)

    DEFINE v_count INT;

    -- Verificar existencia
    SELECT COUNT(*) INTO v_count
    FROM kilowhatts
    WHERE id_kilowhatts = p_id_kilowhatts;

    IF v_count = 0 THEN
        RAISE EXCEPTION -746, 0, 'No existe la cuota especificada';
    END IF;

    -- Actualizar
    UPDATE kilowhatts
    SET importe = p_importe,
        fecha_modificacion = CURRENT,
        id_usuario = p_id_usuario
    WHERE id_kilowhatts = p_id_kilowhatts;

END PROCEDURE;
