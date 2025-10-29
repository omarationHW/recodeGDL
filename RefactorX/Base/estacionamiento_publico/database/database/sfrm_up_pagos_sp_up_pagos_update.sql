-- Stored Procedure: sp_up_pagos_update
-- Tipo: CRUD
-- Descripción: Actualiza la tabla ta_14_folios con la fecha de baja y pago, y marca el movimiento como 'R'. Devuelve éxito o error.
-- Generado para formulario: sfrm_up_pagos
-- Fecha: 2025-08-27 14:43:37

CREATE OR REPLACE FUNCTION sp_up_pagos_update(
    p_alo integer,
    p_folio integer,
    p_fecbaj date
) RETURNS TABLE(success boolean, message text) AS $$
BEGIN
    UPDATE ta_14_folios
    SET fecha_baja = p_fecbaj,
        cve_mov = 'R',
        fecha_pago = p_fecbaj
    WHERE aso = p_alo AND folio = p_folio;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Actualización exitosa';
    ELSE
        RETURN QUERY SELECT false, 'No se encontró el registro para actualizar';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT false, SQLERRM;
END;
$$ LANGUAGE plpgsql;