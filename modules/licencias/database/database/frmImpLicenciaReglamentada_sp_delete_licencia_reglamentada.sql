-- Stored Procedure: sp_delete_licencia_reglamentada
-- Tipo: CRUD
-- Descripción: Elimina una licencia reglamentada por ID.
-- Generado para formulario: frmImpLicenciaReglamentada
-- Fecha: 2025-08-27 18:04:38

CREATE OR REPLACE FUNCTION sp_delete_licencia_reglamentada(
    p_id INTEGER
) RETURNS TABLE(
    deleted BOOLEAN
) AS $$
BEGIN
    DELETE FROM licencias_reglamentadas WHERE id = p_id;
    RETURN QUERY SELECT TRUE AS deleted;
END;
$$ LANGUAGE plpgsql;