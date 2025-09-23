-- Stored Procedure: sp_alta_descuento_otras_obligaciones
-- Tipo: CRUD
-- Descripción: Da de alta un descuento en t34_descmul para Otras Obligaciones
-- Generado para formulario: DMultaOtrasObligaciones
-- Fecha: 2025-08-27 00:31:21

CREATE OR REPLACE FUNCTION sp_alta_descuento_otras_obligaciones(
    p_id_datos INTEGER,
    p_axoi INTEGER,
    p_mesi INTEGER,
    p_axof INTEGER,
    p_mesf INTEGER,
    p_usuario TEXT,
    p_porc INTEGER,
    p_autoriza INTEGER
) RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_id INTEGER;
BEGIN
    INSERT INTO t34_descmul (
        id_descto, id_contrato, axoinicio, mesinicio, axofin, mesfin, fecha_alta, usuario_alta, vigencia, porcentaje, autoriza
    ) VALUES (
        DEFAULT, p_id_datos, p_axoi, p_mesi, p_axof, p_mesf, NOW(), p_usuario, 'V', p_porc, p_autoriza
    ) RETURNING id_descto INTO v_id;
    RETURN QUERY SELECT TRUE, 'Descuento registrado correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, SQLERRM;
END;
$$ LANGUAGE plpgsql;