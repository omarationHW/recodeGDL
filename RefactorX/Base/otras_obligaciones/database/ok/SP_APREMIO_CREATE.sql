--
-- SP_APREMIO_CREATE.sql
-- Descripción: Crea un nuevo registro de apremio
-- Parámetros: Todos los campos necesarios para un nuevo apremio
-- Retorna: 0 si es exitoso, -1 en caso de error
--

DROP PROCEDURE IF EXISTS SP_APREMIO_CREATE;

CREATE PROCEDURE SP_APREMIO_CREATE(
    p_modulo INTEGER,
    p_control_otr INTEGER,
    p_zona INTEGER,
    p_folio INTEGER,
    p_diligencia INTEGER,
    p_importe_global DECIMAL(16,2),
    p_importe_multa DECIMAL(16,2),
    p_importe_recargo DECIMAL(16,2),
    p_importe_gastos DECIMAL(16,2),
    p_zona_apremio INTEGER,
    p_fecha_emision DATE,
    p_clave_practicado CHAR(1),
    p_fecha_practicado DATE,
    p_hora_practicado CHAR(8),
    p_fecha_entrega1 DATE,
    p_fecha_entrega2 DATE,
    p_fecha_citatorio DATE,
    p_hora CHAR(8),
    p_ejecutor INTEGER,
    p_clave_secuestro CHAR(1),
    p_clave_remate CHAR(1),
    p_fecha_remate DATE,
    p_porcentaje_multa DECIMAL(5,2),
    p_observaciones VARCHAR(255)
)
RETURNING INTEGER;

DEFINE v_id_control INTEGER;
DEFINE v_result INTEGER;

ON EXCEPTION
    IN (-1)
        LET v_result = -1;
        RETURN v_result;
END EXCEPTION;

-- Obtener el siguiente ID de control
SELECT NVL(MAX(id_control), 0) + 1
INTO v_id_control
FROM ta_15_apremios;

-- Insertar el nuevo apremio
INSERT INTO ta_15_apremios (
    id_control,
    modulo,
    control_otr,
    zona,
    folio,
    diligencia,
    importe_global,
    importe_multa,
    importe_recargo,
    importe_gastos,
    zona_apremio,
    fecha_emision,
    clave_practicado,
    fecha_practicado,
    hora_practicado,
    fecha_entrega1,
    fecha_entrega2,
    fecha_citatorio,
    hora,
    ejecutor,
    clave_secuestro,
    clave_remate,
    fecha_remate,
    porcentaje_multa,
    observaciones,
    vigencia
) VALUES (
    v_id_control,
    p_modulo,
    p_control_otr,
    p_zona,
    p_folio,
    p_diligencia,
    p_importe_global,
    p_importe_multa,
    p_importe_recargo,
    p_importe_gastos,
    p_zona_apremio,
    p_fecha_emision,
    p_clave_practicado,
    p_fecha_practicado,
    p_hora_practicado,
    p_fecha_entrega1,
    p_fecha_entrega2,
    p_fecha_citatorio,
    p_hora,
    p_ejecutor,
    p_clave_secuestro,
    p_clave_remate,
    p_fecha_remate,
    p_porcentaje_multa,
    p_observaciones,
    '1'
);

LET v_result = 0;
RETURN v_result;

END PROCEDURE;
