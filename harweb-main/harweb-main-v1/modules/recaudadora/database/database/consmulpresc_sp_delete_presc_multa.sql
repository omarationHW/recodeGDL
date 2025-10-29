-- Stored Procedure: sp_delete_presc_multa
-- Tipo: CRUD
-- Descripción: Elimina una prescripción de multa por id.
-- Generado para formulario: consmulpresc
-- Fecha: 2025-08-26 23:33:22

CREATE OR REPLACE FUNCTION sp_delete_presc_multa(p_id_prescri INTEGER)
RETURNS TABLE (
    id_prescri INTEGER
) AS $$
BEGIN
    DELETE FROM presc_multas WHERE id_prescri = p_id_prescri RETURNING id_prescri;
END;
$$ LANGUAGE plpgsql;