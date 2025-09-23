-- Stored Procedure: delete_licencia_reglamentada
-- Tipo: CRUD
-- Descripción: Elimina una licencia reglamentada por su ID.
-- Generado para formulario: frmImpLicenciaReglamentada
-- Fecha: 2025-08-26 16:31:02

CREATE OR REPLACE FUNCTION delete_licencia_reglamentada(
    p_id INTEGER
)
RETURNS TABLE (
    deleted BOOLEAN
) AS $$
BEGIN
    DELETE FROM licencias_reglamentadas WHERE id = p_id;
    RETURN QUERY SELECT TRUE AS deleted;
END;
$$ LANGUAGE plpgsql;