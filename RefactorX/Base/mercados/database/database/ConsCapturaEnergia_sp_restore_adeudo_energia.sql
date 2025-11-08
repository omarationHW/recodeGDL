-- Stored Procedure: sp_restore_adeudo_energia
-- Tipo: CRUD
-- Descripción: Restaura el adeudo de energía eléctrica si no existe para el periodo dado
-- Generado para formulario: ConsCapturaEnergia
-- Fecha: 2025-08-26 23:12:09

CREATE OR REPLACE FUNCTION sp_restore_adeudo_energia(
    p_id_energia INTEGER,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_cve_consumo VARCHAR(2),
    p_cantidad NUMERIC(12,2),
    p_importe NUMERIC(12,2),
    p_usuario_id INTEGER
) RETURNS TEXT AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM ta_11_adeudo_energ
    WHERE id_energia = p_id_energia AND axo = p_axo AND periodo = p_periodo;
    IF v_count = 0 THEN
        INSERT INTO ta_11_adeudo_energ (
            id_adeudo_energia, id_energia, axo, periodo, cve_consumo, cantidad, importe, fecha_alta, id_usuario
        ) VALUES (
            DEFAULT, p_id_energia, p_axo, p_periodo, p_cve_consumo, p_cantidad, p_importe, NOW(), p_usuario_id
        );
        RETURN 'Adeudo restaurado correctamente';
    ELSE
        RETURN 'Ya existe el adeudo para este periodo';
    END IF;
END;
$$ LANGUAGE plpgsql;