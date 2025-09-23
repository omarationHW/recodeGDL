-- Stored Procedure: actualiza_pub_pago
-- Tipo: CRUD
-- Descripción: Aplica un pago a un adeudo de estacionamiento
-- Generado para formulario: spubActualizacionfrm
-- Fecha: 2025-08-27 14:48:13

CREATE OR REPLACE FUNCTION actualiza_pub_pago(
    p_opc integer,
    p_pubmain_id integer,
    p_axo integer,
    p_mes integer,
    p_tipo integer,
    p_fecha date,
    p_reca integer,
    p_caja varchar,
    p_operacion integer
) RETURNS TABLE(id integer, mensaje varchar) AS $$
BEGIN
    -- Lógica de aplicación de pago
    -- Aquí se debe actualizar pubadeudo y/o insertar en pubadeudo_histo
    -- Ejemplo:
    UPDATE pubadeudo
    SET pagado = TRUE, fecha_movto = p_fecha
    WHERE pubmain_id = p_pubmain_id AND axo = p_axo AND mes = p_mes AND tipo = p_tipo;
    IF FOUND THEN
        id := 1;
        mensaje := 'Pago aplicado correctamente';
    ELSE
        id := 0;
        mensaje := 'No se encontró el adeudo';
    END IF;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;