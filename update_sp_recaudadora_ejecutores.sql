-- Actualización del Stored Procedure para ejecutores
-- Usa la tabla ejecutor del esquema public

DROP FUNCTION IF EXISTS publico.recaudadora_ejecutores(VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_ejecutores(
    q VARCHAR DEFAULT ''
)
RETURNS TABLE (
    id_ejecutor INTEGER,
    numero_empleado VARCHAR,
    nombre_completo VARCHAR,
    cargo VARCHAR,
    area VARCHAR,
    telefono VARCHAR,
    extension VARCHAR,
    email VARCHAR,
    fecha_ingreso DATE,
    status VARCHAR,
    observaciones VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.cveejecutor::integer AS id_ejecutor,
        COALESCE(e.cveejecutor::varchar, '')::varchar AS numero_empleado,
        TRIM(CONCAT(
            COALESCE(TRIM(e.nombres), ''), ' ',
            COALESCE(TRIM(e.paterno), ''), ' ',
            COALESCE(TRIM(e.materno), '')
        ))::varchar AS nombre_completo,
        COALESCE(TRIM(e.oficio), 'Ejecutor')::varchar AS cargo,
        CASE
            WHEN e.recaud = 1 THEN 'Recaudación Predial'
            WHEN e.recaud = 2 THEN 'Recaudación Municipal'
            WHEN e.recaud = 3 THEN 'Multas'
            WHEN e.recaud = 4 THEN 'Licencias'
            ELSE 'Recaudación'
        END::varchar AS area,
        ''::varchar AS telefono,
        ''::varchar AS extension,
        ''::varchar AS email,
        e.fecing AS fecha_ingreso,
        CASE
            WHEN e.vigencia = 'V' THEN 'Activo'
            WHEN e.vigencia = 'C' THEN 'Cancelado'
            WHEN e.vigencia = 'B' THEN 'Baja'
            ELSE 'Inactivo'
        END::varchar AS status,
        COALESCE(
            'RFC: ' || TRIM(e.rfc) ||
            CASE WHEN e.fecbaj IS NOT NULL THEN ' | Fecha Baja: ' || e.fecbaj::text ELSE '' END,
            ''
        )::varchar AS observaciones
    FROM public.ejecutor e
    WHERE
        CASE
            WHEN q IS NULL OR q = '' THEN TRUE
            ELSE
                TRIM(CONCAT(e.nombres, ' ', e.paterno, ' ', e.materno)) ILIKE '%' || q || '%'
                OR TRIM(e.paterno) ILIKE '%' || q || '%'
                OR TRIM(e.nombres) ILIKE '%' || q || '%'
                OR TRIM(e.oficio) ILIKE '%' || q || '%'
                OR CAST(e.cveejecutor AS VARCHAR) = q
        END
    ORDER BY
        e.nombres, e.paterno
    LIMIT 200;
END;
$$;

-- Comentarios sobre el mapeo:
-- ejecutor.cveejecutor -> id_ejecutor (ID del ejecutor)
-- ejecutor.cveejecutor -> numero_empleado (usando el mismo ID como número de empleado)
-- ejecutor.nombres + paterno + materno -> nombre_completo (nombre completo concatenado)
-- ejecutor.oficio -> cargo (oficio del ejecutor, default: 'Ejecutor')
-- ejecutor.recaud -> area (área de recaudación: 1=Predial, 2=Municipal, 3=Multas, 4=Licencias)
-- ejecutor.fecing -> fecha_ingreso (fecha de ingreso)
-- ejecutor.vigencia -> status (V=Activo, C=Cancelado, B=Baja)
-- ejecutor.rfc + fecbaj -> observaciones (RFC y fecha de baja si existe)
--
-- NOTA: Los campos telefono, extension y email no existen en la tabla original
-- Se retornan como cadenas vacías para mantener compatibilidad con la interfaz
