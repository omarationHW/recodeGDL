-- Stored Procedure: sp_bonificaciones_delete
-- Tipo: CRUD
-- Descripción: Elimina una bonificación de ta_13_bonifrcm
-- Generado para formulario: Bonificaciones
-- Fecha: 2025-08-28 17:48:25

CREATE OR REPLACE FUNCTION sp_bonificaciones_delete(
    p_oficio integer,
    p_axo integer,
    p_doble varchar,
    p_usuario integer
) RETURNS void AS $$
BEGIN
    DELETE FROM ta_13_bonifrcm
    WHERE oficio = p_oficio AND axo = p_axo AND doble = p_doble;
END;
$$ LANGUAGE plpgsql;