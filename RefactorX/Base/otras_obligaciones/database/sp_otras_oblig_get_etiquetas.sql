-- SP: sp_otras_oblig_get_etiquetas
-- Descripción: Obtiene las etiquetas de columnas según la tabla
-- Parámetros: par_tab INTEGER
-- Retorna: Etiquetas configuradas para la tabla
-- Prioridad: ALTA
-- Componente: GConsulta2.vue

CREATE OR REPLACE FUNCTION sp_otras_oblig_get_etiquetas(
    par_tab INTEGER
)
RETURNS TABLE (
    cve_tab INTEGER,
    etiq_control VARCHAR(50),
    concesionario VARCHAR(50),
    ubicacion VARCHAR(50),
    nombre_comercial VARCHAR(50),
    lugar VARCHAR(50),
    obs VARCHAR(50),
    superficie VARCHAR(50),
    fecha_inicio VARCHAR(50),
    recaudadora VARCHAR(50),
    sector VARCHAR(50),
    zona VARCHAR(50),
    licencia VARCHAR(50),
    unidad VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.cve_tab,
        COALESCE(t.etiq_control, 'Control') AS etiq_control,
        COALESCE(t.etiq_conces, 'Concesionario') AS concesionario,
        COALESCE(t.etiq_ubica, 'Ubicación') AS ubicacion,
        COALESCE(t.etiq_nomcomer, 'Nombre Comercial') AS nombre_comercial,
        COALESCE(t.etiq_lugar, 'Lugar') AS lugar,
        COALESCE(t.etiq_obs, 'Observaciones') AS obs,
        COALESCE(t.etiq_superf, 'Superficie') AS superficie,
        COALESCE(t.etiq_fechaini, 'Fecha Inicio') AS fecha_inicio,
        COALESCE(t.etiq_recaud, 'Recaudadora') AS recaudadora,
        COALESCE(t.etiq_sector, 'Sector') AS sector,
        COALESCE(t.etiq_zona, 'Zona') AS zona,
        COALESCE(t.etiq_lic, 'Licencia') AS licencia,
        COALESCE(t.etiq_unidad, 'Unidad') AS unidad
    FROM t_34_tablas t
    WHERE t.cve_tab = par_tab;

    -- Si no existe registro, retornar valores por defecto
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            par_tab AS cve_tab,
            'Control'::VARCHAR(50) AS etiq_control,
            'Concesionario'::VARCHAR(50) AS concesionario,
            'Ubicación'::VARCHAR(50) AS ubicacion,
            'Nombre Comercial'::VARCHAR(50) AS nombre_comercial,
            'Lugar'::VARCHAR(50) AS lugar,
            'Observaciones'::VARCHAR(50) AS obs,
            'Superficie'::VARCHAR(50) AS superficie,
            'Fecha Inicio'::VARCHAR(50) AS fecha_inicio,
            'Recaudadora'::VARCHAR(50) AS recaudadora,
            'Sector'::VARCHAR(50) AS sector,
            'Zona'::VARCHAR(50) AS zona,
            'Licencia'::VARCHAR(50) AS licencia,
            'Unidad'::VARCHAR(50) AS unidad;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Comentarios
COMMENT ON FUNCTION sp_otras_oblig_get_etiquetas(INTEGER) IS
'Obtiene las etiquetas personalizadas de columnas para una tabla específica de otras obligaciones';
