-- Stored Procedure: sp_insert_recaudadora
-- Tipo: CRUD
-- Descripción: Inserta una nueva recaudadora si no existe el número.
-- Generado para formulario: ABC_Recaudadoras
-- Fecha: 2025-08-27 13:27:06

CREATE OR REPLACE FUNCTION sp_insert_recaudadora(p_num_rec SMALLINT, p_descripcion VARCHAR)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_16_recaudadoras WHERE num_rec = p_num_rec) THEN
        RETURN QUERY SELECT FALSE, 'Ya existe una recaudadora con ese número.';
    ELSE
        INSERT INTO ta_16_recaudadoras(num_rec, descripcion) VALUES (p_num_rec, p_descripcion);
        RETURN QUERY SELECT TRUE, 'Recaudadora agregada correctamente.';
    END IF;
END;
$$ LANGUAGE plpgsql;