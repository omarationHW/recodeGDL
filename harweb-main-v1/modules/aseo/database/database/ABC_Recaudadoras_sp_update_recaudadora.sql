-- Stored Procedure: sp_update_recaudadora
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de una recaudadora existente.
-- Generado para formulario: ABC_Recaudadoras
-- Fecha: 2025-08-27 13:27:06

CREATE OR REPLACE FUNCTION sp_update_recaudadora(p_num_rec SMALLINT, p_descripcion VARCHAR)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ta_16_recaudadoras WHERE num_rec = p_num_rec) THEN
        RETURN QUERY SELECT FALSE, 'No existe la recaudadora.';
    ELSE
        UPDATE ta_16_recaudadoras SET descripcion = p_descripcion WHERE num_rec = p_num_rec;
        RETURN QUERY SELECT TRUE, 'Recaudadora actualizada correctamente.';
    END IF;
END;
$$ LANGUAGE plpgsql;