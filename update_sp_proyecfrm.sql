-- Actualización del Stored Procedure para proyecfrm.vue
-- Usando tabla aut_desctosotorgados (descuentos autorizados)

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_proyecfrm'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_proyecfrm(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para proyecfrm (proyectos)
CREATE OR REPLACE FUNCTION publico.recaudadora_proyecfrm(
    p_filtro VARCHAR DEFAULT ''
)
RETURNS TABLE (
    id_proyecto INTEGER,
    nombre_proyecto VARCHAR,
    descripcion VARCHAR,
    fecha_inicio DATE,
    fecha_fin DATE,
    estado VARCHAR,
    responsable VARCHAR,
    presupuesto NUMERIC,
    avance NUMERIC,
    departamento VARCHAR,
    prioridad VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Usamos tabla aut_desctosotorgados (descuentos autorizados otorgados)
    -- que tiene estructura similar a proyectos

    RETURN QUERY
    SELECT
        p.folio_descto::INTEGER AS id_proyecto,
        COALESCE(p.datos_descto, 'Sin nombre')::VARCHAR AS nombre_proyecto,
        COALESCE(p.motivo, 'Sin descripción')::VARCHAR AS descripcion,
        p.fecha_inicio,
        p.fecha_fin,
        CASE
            WHEN p.vigencia = 'A' THEN 'ACTIVO'
            WHEN p.vigencia = 'B' THEN 'BLOQUEADO'
            WHEN p.vigencia = 'C' THEN 'COMPLETADO'
            WHEN p.vigencia = 'P' THEN 'PENDIENTE'
            WHEN p.vigencia = 'CA' THEN 'CANCELADO'
            ELSE 'DESCONOCIDO'
        END::VARCHAR AS estado,
        COALESCE(TRIM(p.user_cap), 'Sin responsable')::VARCHAR AS responsable,
        COALESCE(p.monto_aut, 0)::NUMERIC AS presupuesto,
        COALESCE(p.por_aut, 0)::NUMERIC AS avance,
        CASE
            WHEN p.tipo = 1 THEN 'Predial'
            WHEN p.tipo = 2 THEN 'Licencias'
            WHEN p.tipo = 3 THEN 'Multas'
            WHEN p.tipo = 4 THEN 'Transmisión'
            WHEN p.tipo = 5 THEN 'Requerimientos'
            ELSE 'General'
        END::VARCHAR AS departamento,
        CASE
            WHEN p.tipo_descto = 'P' THEN 'ALTA'
            WHEN p.tipo_descto = 'T' THEN 'MEDIA'
            WHEN p.tipo_descto = 'L' THEN 'BAJA'
            ELSE 'NORMAL'
        END::VARCHAR AS prioridad
    FROM public.aut_desctosotorgados p
    WHERE
        CASE
            WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
            ELSE (
                p.datos_descto ILIKE '%' || p_filtro || '%'
                OR TRIM(p.user_cap) ILIKE '%' || p_filtro || '%'
                OR p.motivo ILIKE '%' || p_filtro || '%'
                OR p.vigencia ILIKE '%' || p_filtro || '%'
                OR p.tipo_descto ILIKE '%' || p_filtro || '%'
            )
        END
    ORDER BY p.fecha_inicio DESC, p.folio_descto DESC;

END;
$$;

-- Comentarios sobre la función:
-- publico.recaudadora_proyecfrm -> Retorna proyectos usando tabla aut_desctosotorgados
--
-- MAPEO DE CAMPOS:
-- - folio_descto -> id_proyecto (ID único)
-- - datos_descto -> nombre_proyecto (nombre/descripción del proyecto)
-- - motivo -> descripcion (motivo/descripción detallada)
-- - fecha_inicio -> fecha_inicio (fecha de inicio del proyecto)
-- - fecha_fin -> fecha_fin (fecha de finalización)
-- - vigencia -> estado (A=ACTIVO, B=BLOQUEADO, C=COMPLETADO, P=PENDIENTE, CA=CANCELADO)
-- - user_cap -> responsable (usuario capturista/responsable)
-- - monto_aut -> presupuesto (monto autorizado)
-- - por_aut -> avance (porcentaje autorizado, interpretado como avance)
-- - tipo -> departamento (1=Predial, 2=Licencias, 3=Multas, 4=Transmisión, 5=Requerimientos)
-- - tipo_descto -> prioridad (P=ALTA, T=MEDIA, L=BAJA)
--
-- TABLA BASE: public.aut_desctosotorgados (33 registros de descuentos autorizados)
--
-- EJEMPLO DE USO:
-- SELECT * FROM publico.recaudadora_proyecfrm('');  -- Todos los proyectos
-- SELECT * FROM publico.recaudadora_proyecfrm('ECOLOGIA');  -- Por nombre
-- SELECT * FROM publico.recaudadora_proyecfrm('lecorne');  -- Por responsable
