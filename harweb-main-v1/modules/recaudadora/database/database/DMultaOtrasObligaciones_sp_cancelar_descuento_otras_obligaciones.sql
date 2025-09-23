-- Stored Procedure: sp_cancelar_descuento_otras_obligaciones
-- Tipo: CRUD
-- Descripción: Cancela un descuento vigente en t34_descmul para Otras Obligaciones
-- Generado para formulario: DMultaOtrasObligaciones
-- Fecha: 2025-08-27 00:31:21

CREATE OR REPLACE FUNCTION sp_cancelar_descuento_otras_obligaciones(
    p_id_datos INTEGER,
    p_minimo TEXT,
    p_maximo TEXT,
    p_usuario TEXT,
    p_porc INTEGER
) RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_id INTEGER;
BEGIN
    UPDATE t34_descmul
    SET vigencia = 'C', fecha_baja = NOW(), usuario_baja = p_usuario
    WHERE id_contrato = p_id_datos
      AND (axoinicio::text || LPAD(mesinicio::text,2,'0')) = p_minimo
      AND (axofin::text || LPAD(mesfin::text,2,'0')) = p_maximo
      AND porcentaje = p_porc
      AND vigencia = 'V'
    RETURNING id_descto INTO v_id;
    IF v_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'No se encontró descuento vigente para cancelar';
    ELSE
        RETURN QUERY SELECT TRUE, 'Descuento cancelado correctamente';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, SQLERRM;
END;
$$ LANGUAGE plpgsql;