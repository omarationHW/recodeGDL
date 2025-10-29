-- Stored Procedure: sp_unit9_preview_pagewidth
-- Tipo: CRUD
-- Descripción: Ajusta la vista previa al ancho de la página (simulado).
-- Generado para formulario: UNIT9
-- Fecha: 2025-08-27 15:04:35

CREATE OR REPLACE FUNCTION sp_unit9_preview_pagewidth()
RETURNS json AS $$
BEGIN
    RETURN json_build_object('view', 'pagewidth');
END;
$$ LANGUAGE plpgsql;