-- Stored Procedure: sp_elaboro_convenio_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de quien elaboró convenio.
-- Generado para formulario: ElaboroConvenio
-- Fecha: 2025-08-27 14:31:25

CREATE OR REPLACE FUNCTION sp_elaboro_convenio_delete(
    p_id_control integer
) RETURNS TABLE (
    id_control integer
) AS $$
BEGIN
    DELETE FROM ta_17_elaboroficio WHERE id_control = p_id_control RETURNING id_control;
END;
$$ LANGUAGE plpgsql;