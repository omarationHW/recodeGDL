-- Stored Procedure: sp_titulos_validate
-- Tipo: CRUD
-- Descripción: Valida la existencia de un título.
-- Generado para formulario: Titulos
-- Fecha: 2025-08-27 14:55:53

CREATE OR REPLACE FUNCTION sp_titulos_validate(p_fecha DATE, p_folio INTEGER, p_operacion INTEGER)
RETURNS TABLE(exists BOOLEAN) AS $$
BEGIN
    RETURN QUERY
    SELECT EXISTS(
        SELECT 1 FROM ta_13_titulos t
        WHERE t.fecha = p_fecha AND t.control_rcm = p_folio AND t.operacion = p_operacion
    );
END;
$$ LANGUAGE plpgsql;