-- Stored Procedure: sp_unit9_preview_onepage
-- Tipo: CRUD
-- Descripción: Cambia la vista a una sola página (simulado).
-- Generado para formulario: UNIT9
-- Fecha: 2025-08-27 15:04:35

CREATE OR REPLACE FUNCTION sp_unit9_preview_onepage()
RETURNS json AS $$
BEGIN
    RETURN json_build_object('view', 'onepage');
END;
$$ LANGUAGE plpgsql;