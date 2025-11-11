-- SP: sp_otras_oblig_get_tablas
-- Descripción: Obtiene el nombre de la tabla según clave
-- Parámetros: par_tab INTEGER
-- Retorna: Información de la tabla
-- Prioridad: ALTA
-- Componente: GConsulta2.vue

CREATE OR REPLACE FUNCTION sp_otras_oblig_get_tablas(
    par_tab INTEGER
)
RETURNS TABLE (
    cve_tab INTEGER,
    nombre VARCHAR(200),
    auto_tab BOOLEAN,
    descripcion VARCHAR(500)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.cve_tab,
        COALESCE(t.nombre, 'Sin nombre') AS nombre,
        COALESCE(t.auto_tab, false) AS auto_tab,
        COALESCE(t.descripcion, '') AS descripcion
    FROM t_34_tablas t
    WHERE t.cve_tab = par_tab;

    -- Si no existe, retornar registro vacío con clave
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            par_tab AS cve_tab,
            'Tabla desconocida'::VARCHAR(200) AS nombre,
            false AS auto_tab,
            ''::VARCHAR(500) AS descripcion;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Comentarios
COMMENT ON FUNCTION sp_otras_oblig_get_tablas(INTEGER) IS
'Obtiene la información básica de una tabla de otras obligaciones por su clave';
