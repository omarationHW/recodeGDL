-- Stored Procedure: sp_reasignar_folio
-- Tipo: CRUD
-- Descripción: Reasigna un folio a un nuevo ejecutor y actualiza la fecha de entrega y usuario.
-- Generado para formulario: Reasignacion
-- Fecha: 2025-08-27 14:23:03

CREATE OR REPLACE FUNCTION sp_reasignar_folio(
    p_id_control INTEGER,
    p_nuevo_ejecutor INTEGER,
    p_fecha_entrega2 DATE,
    p_usuario INTEGER,
    p_fecha_actualiz DATE
) RETURNS TEXT AS $$
DECLARE
BEGIN
    UPDATE ta_15_apremios
    SET ejecutor = p_nuevo_ejecutor,
        fecha_entrega2 = p_fecha_entrega2,
        usuario = p_usuario,
        fecha_actualiz = p_fecha_actualiz
    WHERE id_control = p_id_control;
    RETURN 'OK';
EXCEPTION WHEN OTHERS THEN
    RETURN 'ERROR: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;