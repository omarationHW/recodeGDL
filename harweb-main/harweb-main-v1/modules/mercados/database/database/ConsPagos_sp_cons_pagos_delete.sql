-- Stored Procedure: sp_cons_pagos_delete
-- Tipo: CRUD
-- Descripción: Elimina un pago por su id_pago_local.
-- Generado para formulario: ConsPagos
-- Fecha: 2025-08-27 16:01:41

CREATE OR REPLACE FUNCTION sp_cons_pagos_delete(p_id_pago_local INTEGER)
RETURNS BOOLEAN AS $$
BEGIN
    DELETE FROM ta_11_pagos_local WHERE id_pago_local = p_id_pago_local;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;