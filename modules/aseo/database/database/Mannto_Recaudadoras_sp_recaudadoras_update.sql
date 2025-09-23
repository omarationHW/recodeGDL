-- Stored Procedure: sp_recaudadoras_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de una recaudadora.
-- Generado para formulario: Mannto_Recaudadoras
-- Fecha: 2025-08-27 14:49:12

CREATE OR REPLACE PROCEDURE sp_recaudadoras_update(p_num_rec SMALLINT, p_descripcion VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ta_16_recaudadoras SET descripcion = p_descripcion WHERE num_rec = p_num_rec;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe la recaudadora con ese número.';
    END IF;
END;
$$;