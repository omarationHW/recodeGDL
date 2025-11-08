-- Stored Procedure: sp_cves_operacion_delete
-- Tipo: CRUD
-- Descripción: Elimina una clave de operación (solo si no tiene pagos asociados)
-- Generado para formulario: ABC_Cves_Operacion
-- Fecha: 2025-08-27 13:21:19

CREATE OR REPLACE FUNCTION sp_cves_operacion_delete(p_ctrol_operacion integer)
RETURNS VOID AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_16_pagos WHERE ctrol_operacion = p_ctrol_operacion) THEN
        RAISE EXCEPTION 'No se puede eliminar: existen pagos asociados a esta clave.';
    END IF;
    DELETE FROM ta_16_operacion WHERE ctrol_operacion = p_ctrol_operacion;
END;
$$ LANGUAGE plpgsql;