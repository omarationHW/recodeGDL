-- Stored Procedure: sp_get_splash_info
-- Tipo: Catalog
-- Descripción: Obtiene la información principal del splash screen (nombre app, versión, copyright, etc)
-- Generado para formulario: psplash
-- Fecha: 2025-08-26 17:36:56

CREATE OR REPLACE FUNCTION sp_get_splash_info()
RETURNS TABLE(
    app_name TEXT,
    version TEXT,
    copyright TEXT
) AS $$
BEGIN
    -- Valores hardcodeados o pueden venir de una tabla de configuración
    RETURN QUERY SELECT
        'Padrón y Licencias'::TEXT AS app_name,
        sp_get_app_version() AS version,
        '© 2024 Municipio Ejemplo'::TEXT AS copyright;
END;
$$ LANGUAGE plpgsql;