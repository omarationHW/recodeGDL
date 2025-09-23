-- Stored Procedure: sp_get_contrato
-- Tipo: Catalog
-- Descripción: Obtiene los datos principales del contrato/convenio
-- Generado para formulario: CalculoRecargos
-- Fecha: 2025-08-27 13:55:28

CREATE OR REPLACE FUNCTION sp_get_contrato(p_id_convenio INTEGER)
RETURNS TABLE(
    id_convenio INTEGER,
    pago_inicial NUMERIC,
    pago_quincenal NUMERIC,
    pagos_parciales INTEGER,
    fecha_vencimiento DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_convenio, pago_inicial, pago_quincenal, pagos_parciales, fecha_vencimiento
    FROM ta_17_convenios
    WHERE id_convenio = p_id_convenio;
END;
$$ LANGUAGE plpgsql;