-- Stored Procedure: sp_unit9_preview_navigate
-- Tipo: CRUD
-- Descripción: Navega entre páginas de la vista previa del reporte (first, prev, next, last).
-- Generado para formulario: UNIT9
-- Fecha: 2025-08-27 15:04:35

CREATE OR REPLACE FUNCTION sp_unit9_preview_navigate(action_in text)
RETURNS json AS $$
DECLARE
    result json;
BEGIN
    -- Simulación: Retornar datos de página según acción
    IF action_in = 'first' THEN
        result := json_build_object('page', 1, 'content', 'Contenido de la primera página');
    ELSIF action_in = 'prev' THEN
        result := json_build_object('page', 2, 'content', 'Contenido de la página anterior');
    ELSIF action_in = 'next' THEN
        result := json_build_object('page', 3, 'content', 'Contenido de la página siguiente');
    ELSIF action_in = 'last' THEN
        result := json_build_object('page', 10, 'content', 'Contenido de la última página');
    ELSE
        result := json_build_object('page', 1, 'content', 'Página desconocida');
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;