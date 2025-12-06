-- Stored Procedure: sp_quitar_prescripcion
-- Tipo: CRUD
-- Descripción: Quita la prescripción/condonación y restaura el adeudo de energía eléctrica.
-- Generado para formulario: Prescripcion
-- Fecha: 2025-08-27 00:31:46

CREATE OR REPLACE FUNCTION sp_quitar_prescripcion(
    p_id_energia integer,
    p_axo smallint,
    p_periodo smallint,
    p_cve_consumo varchar,
    p_cantidad numeric,
    p_importe numeric,
    p_id_usuario integer,
    p_id_cancelacion integer
) RETURNS void AS $$
BEGIN
    INSERT INTO ta_11_adeudo_energ (
        id_adeudo_energia, id_energia, axo, periodo, cve_consumo, cantidad, importe, fecha_alta, id_usuario
    ) VALUES (
        DEFAULT, p_id_energia, p_axo, p_periodo, p_cve_consumo, p_cantidad, p_importe, NOW(), p_id_usuario
    );
    DELETE FROM ta_11_ade_ene_canc
    WHERE id_cancelacion = p_id_cancelacion;
END;
$$ LANGUAGE plpgsql;