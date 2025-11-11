-- =====================================================
-- SP: sp_modificar_bien
-- Descripción: Modifica datos de bien embargado en apremios
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- =====================================================

CREATE OR REPLACE FUNCTION sp_modificar_bien(
    p_folio VARCHAR(50),
    p_descripcion_bien TEXT,
    p_valor_bien DECIMAL(12,2)
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR(255)
) AS $$
DECLARE
    v_affected INTEGER;
BEGIN
    -- Actualizar el bien embargado
    UPDATE ta_15_apremios
    SET
        observaciones = p_descripcion_bien,
        importe_gastos = p_valor_bien,
        fecha_actualiz = CURRENT_DATE
    WHERE folio::VARCHAR = p_folio;

    GET DIAGNOSTICS v_affected = ROW_COUNT;

    IF v_affected > 0 THEN
        RETURN QUERY SELECT TRUE, 'Bien modificado exitosamente'::VARCHAR(255);
    ELSE
        RETURN QUERY SELECT FALSE, 'No se encontró el folio especificado'::VARCHAR(255);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Ejemplo de uso:
-- SELECT * FROM sp_modificar_bien('12345', 'Vehículo marca Toyota modelo Corolla 2020', 150000.00);
-- SELECT * FROM sp_modificar_bien('98765', 'Muebles de oficina varios', 25000.00);
