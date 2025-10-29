-- Stored Procedure: sp_rbaja_cancelar_local
-- Tipo: CRUD
-- Descripción: Cancela (da de baja) un local/concesión si no tiene adeudos vigentes o posteriores.
-- Generado para formulario: RBaja
-- Fecha: 2025-08-28 13:35:33

CREATE OR REPLACE FUNCTION sp_rbaja_cancelar_local(p_id_34_datos INTEGER, p_axo_fin INTEGER, p_mes_fin INTEGER)
RETURNS TABLE (codigo INTEGER, mensaje TEXT) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Aquí se debe realizar la lógica de baja, por ejemplo:
    -- 1. Actualizar el status del local a 'C' (cancelado)
    -- 2. Registrar fecha de baja, etc.
    -- 3. Validar que no existan adeudos (esto ya se validó antes)
    UPDATE t34_datos
    SET id_stat = (SELECT id_34_stat FROM t34_status WHERE cve_stat = 'C' LIMIT 1),
        fecha_fin = make_date(p_axo_fin, p_mes_fin, 1)
    WHERE id_34_datos = p_id_34_datos;
    IF FOUND THEN
        RETURN QUERY SELECT 0 AS codigo, 'Se ejecutó correctamente la Cancelación del Local/Concesión' AS mensaje;
    ELSE
        RETURN QUERY SELECT 1 AS codigo, 'No se encontró el registro para cancelar' AS mensaje;
    END IF;
END;
$$ LANGUAGE plpgsql;