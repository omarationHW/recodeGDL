-- Stored Procedure: sp_update_devolucion_mtto
-- Tipo: CRUD
-- Descripción: Actualiza una devolución de pago existente.
-- Generado para formulario: DevolucionMtto
-- Fecha: 2025-08-27 14:25:56

CREATE OR REPLACE PROCEDURE sp_update_devolucion_mtto(
    p_id_devolucion INTEGER,
    p_remesa VARCHAR(20),
    p_oficio VARCHAR(20),
    p_folio VARCHAR(15),
    p_fecha_solicitud DATE,
    p_rfc VARCHAR(20),
    p_importe NUMERIC,
    p_observacion VARCHAR(60),
    p_id_usuario INTEGER,
    p_fecha_actual TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ta_17_devoluciones SET
        remesa = p_remesa,
        oficio = p_oficio,
        folio = p_folio,
        fecha_solicitud = p_fecha_solicitud,
        rfc = p_rfc,
        importe = p_importe,
        observacion = p_observacion,
        id_usuario = p_id_usuario,
        fecha_actual = p_fecha_actual
    WHERE id_devolucion = p_id_devolucion;
END;
$$;