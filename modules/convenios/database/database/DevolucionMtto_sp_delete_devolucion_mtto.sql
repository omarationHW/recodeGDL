-- Stored Procedure: sp_delete_devolucion_mtto
-- Tipo: CRUD
-- Descripción: Elimina una devolución de pago.
-- Generado para formulario: DevolucionMtto
-- Fecha: 2025-08-27 14:25:56

CREATE OR REPLACE PROCEDURE sp_delete_devolucion_mtto(
    p_id_devolucion INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM ta_17_devoluciones WHERE id_devolucion = p_id_devolucion;
END;
$$;