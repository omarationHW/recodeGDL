--
-- SP_PERIODOS_GET.sql
-- Descripción: Obtiene los períodos asociados a un apremio
-- Parámetros:
--   p_id_control: ID del control del apremio
-- Retorna: Lista de períodos con sus importes y recargos
--

DROP PROCEDURE IF EXISTS SP_PERIODOS_GET;

CREATE PROCEDURE SP_PERIODOS_GET(
    p_id_control INTEGER
)

RETURNING
    INTEGER,       -- ayo
    INTEGER,       -- periodo
    DECIMAL(16,2), -- importe
    DECIMAL(16,2), -- recargos
    INTEGER,       -- cantidad
    CHAR(1);       -- tipo

DEFINE v_ayo INTEGER;
DEFINE v_periodo INTEGER;
DEFINE v_importe DECIMAL(16,2);
DEFINE v_recargos DECIMAL(16,2);
DEFINE v_cantidad INTEGER;
DEFINE v_tipo CHAR(1);

ON EXCEPTION
    IN (-1)
        RETURN;
END EXCEPTION;

FOREACH
    SELECT
        ayo,
        periodo,
        importe,
        recargos,
        cantidad,
        tipo
    INTO
        v_ayo,
        v_periodo,
        v_importe,
        v_recargos,
        v_cantidad,
        v_tipo
    FROM ta_15_periodos
    WHERE control_otr = p_id_control

    RETURN
        v_ayo,
        v_periodo,
        v_importe,
        v_recargos,
        v_cantidad,
        v_tipo
    WITH RESUME;

END FOREACH;

END PROCEDURE;
