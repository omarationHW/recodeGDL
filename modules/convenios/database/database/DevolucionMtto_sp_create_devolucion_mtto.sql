-- Stored Procedure: sp_create_devolucion_mtto
-- Tipo: CRUD
-- Descripción: Crea una nueva devolución de pago para un contrato de mantenimiento.
-- Generado para formulario: DevolucionMtto
-- Fecha: 2025-08-27 14:25:56

CREATE OR REPLACE FUNCTION sp_create_devolucion_mtto(
    p_id_convenio INTEGER,
    p_remesa VARCHAR(20),
    p_oficio VARCHAR(20),
    p_folio VARCHAR(15),
    p_fecha_solicitud DATE,
    p_rfc VARCHAR(20),
    p_importe NUMERIC,
    p_observacion VARCHAR(60),
    p_id_usuario INTEGER,
    p_fecha_actual TIMESTAMP
) RETURNS INTEGER AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO ta_17_devoluciones (
        id_convenio, remesa, oficio, folio, fecha_solicitud, rfc, importe, observacion, ejercicio, proc, crbo, id_usuario, fecha_actual
    ) VALUES (
        p_id_convenio, p_remesa, p_oficio, p_folio, p_fecha_solicitud, p_rfc, p_importe, p_observacion, 0, 0, 0, p_id_usuario, p_fecha_actual
    ) RETURNING id_devolucion INTO new_id;
    RETURN new_id;
END;
$$ LANGUAGE plpgsql;