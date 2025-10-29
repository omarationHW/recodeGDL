--
-- SP_APREMIOS_GET.sql
-- Descripción: Obtiene los apremios de una obligación específica
-- Parámetros:
--   par_modulo: ID del módulo
--   par_control: ID del control de la obligación
-- Retorna: Lista de apremios con información del ejecutor
--

DROP PROCEDURE IF EXISTS SP_APREMIOS_GET;

CREATE PROCEDURE SP_APREMIOS_GET(
    par_modulo INTEGER,
    par_control INTEGER
)

RETURNING
    INTEGER,      -- id_control
    INTEGER,      -- zona
    INTEGER,      -- folio
    INTEGER,      -- diligencia
    DECIMAL(16,2), -- importe_global
    DECIMAL(16,2), -- importe_multa
    DECIMAL(16,2), -- importe_recargo
    DECIMAL(16,2), -- importe_gastos
    INTEGER,      -- zona_apremio
    DATE,         -- fecha_emision
    CHAR(1),      -- clave_practicado
    DATE,         -- fecha_practicado
    CHAR(8),      -- hora_practicado
    DATE,         -- fecha_entrega1
    DATE,         -- fecha_entrega2
    DATE,         -- fecha_citatorio
    CHAR(8),      -- hora
    CHAR(30),     -- ejecutor (usuario)
    CHAR(1),      -- clave_secuestro
    CHAR(1),      -- clave_remate
    DATE,         -- fecha_remate
    DECIMAL(5,2), -- porcentaje_multa
    VARCHAR(255); -- observaciones

DEFINE v_id_control INTEGER;
DEFINE v_zona INTEGER;
DEFINE v_folio INTEGER;
DEFINE v_diligencia INTEGER;
DEFINE v_importe_global DECIMAL(16,2);
DEFINE v_importe_multa DECIMAL(16,2);
DEFINE v_importe_recargo DECIMAL(16,2);
DEFINE v_importe_gastos DECIMAL(16,2);
DEFINE v_zona_apremio INTEGER;
DEFINE v_fecha_emision DATE;
DEFINE v_clave_practicado CHAR(1);
DEFINE v_fecha_practicado DATE;
DEFINE v_hora_practicado CHAR(8);
DEFINE v_fecha_entrega1 DATE;
DEFINE v_fecha_entrega2 DATE;
DEFINE v_fecha_citatorio DATE;
DEFINE v_hora CHAR(8);
DEFINE v_ejecutor CHAR(30);
DEFINE v_clave_secuestro CHAR(1);
DEFINE v_clave_remate CHAR(1);
DEFINE v_fecha_remate DATE;
DEFINE v_porcentaje_multa DECIMAL(5,2);
DEFINE v_observaciones VARCHAR(255);

ON EXCEPTION
    IN (-1)
        RETURN;
END EXCEPTION;

FOREACH
    SELECT
        a.id_control,
        a.zona,
        a.folio,
        a.diligencia,
        a.importe_global,
        a.importe_multa,
        a.importe_recargo,
        a.importe_gastos,
        a.zona_apremio,
        a.fecha_emision,
        a.clave_practicado,
        a.fecha_practicado,
        a.hora_practicado,
        a.fecha_entrega1,
        a.fecha_entrega2,
        a.fecha_citatorio,
        a.hora,
        b.usuario,
        a.clave_secuestro,
        a.clave_remate,
        a.fecha_remate,
        a.porcentaje_multa,
        a.observaciones
    INTO
        v_id_control,
        v_zona,
        v_folio,
        v_diligencia,
        v_importe_global,
        v_importe_multa,
        v_importe_recargo,
        v_importe_gastos,
        v_zona_apremio,
        v_fecha_emision,
        v_clave_practicado,
        v_fecha_practicado,
        v_hora_practicado,
        v_fecha_entrega1,
        v_fecha_entrega2,
        v_fecha_citatorio,
        v_hora,
        v_ejecutor,
        v_clave_secuestro,
        v_clave_remate,
        v_fecha_remate,
        v_porcentaje_multa,
        v_observaciones
    FROM ta_15_apremios a
    INNER JOIN ta_12_passwords b ON b.id_usuario = a.ejecutor
    WHERE a.modulo = par_modulo
      AND a.control_otr = par_control
      AND a.vigencia = '1'
      AND a.clave_practicado = 'P'

    RETURN
        v_id_control,
        v_zona,
        v_folio,
        v_diligencia,
        v_importe_global,
        v_importe_multa,
        v_importe_recargo,
        v_importe_gastos,
        v_zona_apremio,
        v_fecha_emision,
        v_clave_practicado,
        v_fecha_practicado,
        v_hora_practicado,
        v_fecha_entrega1,
        v_fecha_entrega2,
        v_fecha_citatorio,
        v_hora,
        v_ejecutor,
        v_clave_secuestro,
        v_clave_remate,
        v_fecha_remate,
        v_porcentaje_multa,
        v_observaciones
    WITH RESUME;

END FOREACH;

END PROCEDURE;
