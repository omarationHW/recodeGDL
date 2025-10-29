--
-- SP_APREMIO_UPDATE.sql
-- Descripción: Actualiza un registro de apremio existente
-- Parámetros: ID del control y todos los campos actualizables
-- Retorna: 0 si es exitoso, -1 en caso de error
--

DROP PROCEDURE IF EXISTS SP_APREMIO_UPDATE;

CREATE PROCEDURE SP_APREMIO_UPDATE(
    p_id_control INTEGER,
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

DEFINE v_result INTEGER;

ON EXCEPTION
    IN (-1)
        LET v_result = -1;
        RETURN v_result;
END EXCEPTION;

-- Actualizar el apremio
UPDATE ta_15_apremios
SET
    zona = p_zona,
    folio = p_folio,
    diligencia = p_diligencia,
    importe_global = p_importe_global,
    importe_multa = p_importe_multa,
    importe_recargo = p_importe_recargo,
    importe_gastos = p_importe_gastos,
    zona_apremio = p_zona_apremio,
    fecha_emision = p_fecha_emision,
    clave_practicado = p_clave_practicado,
    fecha_practicado = p_fecha_practicado,
    hora_practicado = p_hora_practicado,
    fecha_entrega1 = p_fecha_entrega1,
    fecha_entrega2 = p_fecha_entrega2,
    fecha_citatorio = p_fecha_citatorio,
    hora = p_hora,
    ejecutor = p_ejecutor,
    clave_secuestro = p_clave_secuestro,
    clave_remate = p_clave_remate,
    fecha_remate = p_fecha_remate,
    porcentaje_multa = p_porcentaje_multa,
    observaciones = p_observaciones
WHERE id_control = p_id_control
  AND vigencia = '1';

LET v_result = 0;
RETURN v_result;

END PROCEDURE;
