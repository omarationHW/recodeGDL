-- Stored Procedure: sp_get_app_version
-- Tipo: Catalog
-- Descripción: Obtiene la versión actual de la aplicación (puede ser hardcodeada o leída de tabla de versiones)
-- Generado para formulario: psplash
-- Fecha: 2025-08-26 17:36:56

CREATE OR REPLACE FUNCTION sp_get_app_version()
RETURNS TEXT AS $$
DECLARE
    v_version TEXT;
BEGIN
    -- Puede ser hardcodeada o leída de tabla
    v_version := '1.0.0.0';
    RETURN v_version;
END;
$$ LANGUAGE plpgsql;