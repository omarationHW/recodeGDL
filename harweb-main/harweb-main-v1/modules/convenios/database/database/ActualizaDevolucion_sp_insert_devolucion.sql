-- Stored Procedure: sp_insert_devolucion
-- Tipo: CRUD
-- Descripción: Inserta una devolución de pago en ta_17_devoluciones
-- Generado para formulario: ActualizaDevolucion
-- Fecha: 2025-08-27 13:34:35

CREATE OR REPLACE PROCEDURE sp_insert_devolucion(
    p_id_convenio INTEGER,
    p_remesa TEXT,
    p_oficio TEXT,
    p_folio TEXT,
    p_fecha_solicitud DATE,
    p_rfc TEXT,
    p_importe NUMERIC,
    p_observacion TEXT,
    p_ejercicio SMALLINT,
    p_proc SMALLINT,
    p_crbo INTEGER,
    p_id_usuario INTEGER,
    p_fecha_actual TIMESTAMP,
    p_id_devolucion INTEGER DEFAULT NULL,
    p_fecha_actual2 TIMESTAMP DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO ta_17_devoluciones (
        id_devolucion, id_convenio, remesa, oficio, folio, fecha_solicitud, rfc, importe, observacion, ejercicio, proc, crbo, id_usuario, fecha_actual
    ) VALUES (
        DEFAULT, p_id_convenio, p_remesa, p_oficio, p_folio, p_fecha_solicitud, p_rfc, p_importe, p_observacion, p_ejercicio, p_proc, p_crbo, p_id_usuario, COALESCE(p_fecha_actual, NOW())
    );
END;
$$;