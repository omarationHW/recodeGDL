-- Stored Procedure: sp_unit9_preview_zoom
-- Tipo: CRUD
-- Descripción: Ajusta el zoom de la vista previa (simulado).
-- Generado para formulario: UNIT9
-- Fecha: 2025-08-27 15:04:35

CREATE OR REPLACE FUNCTION sp_unit9_preview_zoom(zoom integer)
RETURNS json AS $$
BEGIN
    RETURN json_build_object('zoom', zoom);
END;
$$ LANGUAGE plpgsql;