-- SP: sp_otras_oblig_buscar_coincide
-- Descripción: Busca controles que coinciden con criterio de búsqueda
-- Parámetros: par_tab INTEGER, tipo_busqueda INTEGER, dato_busqueda VARCHAR
-- Retorna: Lista de controles que coinciden
-- Prioridad: CRÍTICA
-- Componente: GConsulta2.vue

CREATE OR REPLACE FUNCTION sp_otras_oblig_buscar_coincide(
    par_tab INTEGER,
    tipo_busqueda INTEGER,
    dato_busqueda VARCHAR
)
RETURNS TABLE (
    control VARCHAR(20)
) AS $$
DECLARE
    tabla_name VARCHAR(50);
    query_sql TEXT;
BEGIN
    -- Obtener nombre de tabla física según clave
    SELECT 't_34_datos' INTO tabla_name;

    -- Construir query dinámico según tipo de búsqueda
    -- 1: Control/Etiqueta
    -- 2: Concesionario
    -- 3: Ubicación
    -- 4: Nombre Comercial
    -- 5: Lugar
    -- 6: Observaciones

    query_sql := format('
        SELECT DISTINCT d.control::VARCHAR(20)
        FROM t_34_datos d
        WHERE d.cve_tab = %L
        AND d.status = ''V''', par_tab);

    -- Agregar condición según tipo de búsqueda (búsqueda parcial con ILIKE)
    CASE tipo_busqueda
        WHEN 1 THEN
            query_sql := query_sql || format(' AND d.control ILIKE %L', '%' || dato_busqueda || '%');
        WHEN 2 THEN
            query_sql := query_sql || format(' AND d.concesionario ILIKE %L', '%' || dato_busqueda || '%');
        WHEN 3 THEN
            query_sql := query_sql || format(' AND d.ubicacion ILIKE %L', '%' || dato_busqueda || '%');
        WHEN 4 THEN
            query_sql := query_sql || format(' AND d.nomcomercial ILIKE %L', '%' || dato_busqueda || '%');
        WHEN 5 THEN
            query_sql := query_sql || format(' AND d.lugar ILIKE %L', '%' || dato_busqueda || '%');
        WHEN 6 THEN
            query_sql := query_sql || format(' AND d.obs ILIKE %L', '%' || dato_busqueda || '%');
        ELSE
            query_sql := query_sql || format(' AND d.control ILIKE %L', '%' || dato_busqueda || '%');
    END CASE;

    query_sql := query_sql || ' ORDER BY d.control LIMIT 1000';

    -- Ejecutar query dinámico
    RETURN QUERY EXECUTE query_sql;
END;
$$ LANGUAGE plpgsql;

-- Comentarios
COMMENT ON FUNCTION sp_otras_oblig_buscar_coincide(INTEGER, INTEGER, VARCHAR) IS
'Busca controles que coinciden con el criterio de búsqueda especificado. Soporta 6 tipos de búsqueda: Control, Concesionario, Ubicación, Nombre Comercial, Lugar, Observaciones';
