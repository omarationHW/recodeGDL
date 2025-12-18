-- Actualización del Stored Procedure para empresas
-- Usa la tabla receptcontrib del esquema public
-- Filtra por tipo='M' (Moral/Empresa) pero también incluye tipo='F' con razonsocial

DROP FUNCTION IF EXISTS publico.recaudadora_empresas(VARCHAR, INTEGER, INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_empresas(
    q VARCHAR DEFAULT '',
    p_offset INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
    id INTEGER,
    folio INTEGER,
    nombre VARCHAR,
    razon_social VARCHAR,
    rfc VARCHAR,
    telefono VARCHAR,
    email VARCHAR,
    contacto VARCHAR,
    direccion VARCHAR,
    colonia VARCHAR,
    codigo_postal INTEGER,
    tipo VARCHAR,
    fecha_registro DATE,
    total_count BIGINT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_total_count BIGINT;
BEGIN
    -- Primero obtener el conteo total
    SELECT COUNT(*) INTO v_total_count
    FROM public.receptcontrib e
    WHERE
        (e.tipo = 'M' OR (e.tipo = 'F' AND TRIM(e.razonsocial) != ''))
        AND (
            CASE
                WHEN q IS NULL OR q = '' THEN TRUE
                ELSE
                    TRIM(e.razonsocial) ILIKE '%' || q || '%'
                    OR TRIM(CONCAT(e.nombres, ' ', e.paterno, ' ', e.materno)) ILIKE '%' || q || '%'
                    OR TRIM(e.rfc) ILIKE '%' || q || '%'
                    OR CAST(e.folio AS VARCHAR) = q
            END
        );

    -- Retornar los registros paginados con el conteo total
    RETURN QUERY
    SELECT
        e.cvecont AS id,
        e.folio,
        CASE
            WHEN e.tipo = 'M' OR TRIM(e.razonsocial) != '' THEN
                COALESCE(TRIM(e.razonsocial), 'Sin nombre')
            ELSE
                TRIM(CONCAT(
                    COALESCE(TRIM(e.nombres), ''), ' ',
                    COALESCE(TRIM(e.paterno), ''), ' ',
                    COALESCE(TRIM(e.materno), '')
                ))
        END::varchar AS nombre,
        COALESCE(TRIM(e.razonsocial), '')::varchar AS razon_social,
        COALESCE(TRIM(e.rfc), '')::varchar AS rfc,
        COALESCE(TRIM(e.telefono), '')::varchar AS telefono,
        COALESCE(TRIM(e.correo), '')::varchar AS email,
        TRIM(CONCAT(
            COALESCE(TRIM(e.nombres), ''), ' ',
            COALESCE(TRIM(e.paterno), ''), ' ',
            COALESCE(TRIM(e.materno), '')
        ))::varchar AS contacto,
        CONCAT(
            COALESCE(e.notif_domicilio, ''),
            CASE WHEN e.noexterior IS NOT NULL THEN ' #' || TRIM(e.noexterior) ELSE '' END,
            CASE WHEN e.interior IS NOT NULL AND TRIM(e.interior) != '' THEN ' INT ' || TRIM(e.interior) ELSE '' END
        )::varchar AS direccion,
        COALESCE(TRIM(e.colonia), TRIM(e.notif_colonia), '')::varchar AS colonia,
        COALESCE(e.codpos, 0)::integer AS codigo_postal,
        CASE
            WHEN e.tipo = 'M' THEN 'Persona Moral'
            WHEN e.tipo = 'F' THEN 'Persona Física'
            ELSE 'Desconocido'
        END::varchar AS tipo,
        e.feccap AS fecha_registro,
        v_total_count AS total_count
    FROM public.receptcontrib e
    WHERE
        (e.tipo = 'M' OR (e.tipo = 'F' AND TRIM(e.razonsocial) != ''))
        AND (
            CASE
                WHEN q IS NULL OR q = '' THEN TRUE
                ELSE
                    TRIM(e.razonsocial) ILIKE '%' || q || '%'
                    OR TRIM(CONCAT(e.nombres, ' ', e.paterno, ' ', e.materno)) ILIKE '%' || q || '%'
                    OR TRIM(e.rfc) ILIKE '%' || q || '%'
                    OR CAST(e.folio AS VARCHAR) = q
            END
        )
    ORDER BY
        e.folio DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;

-- Comentarios sobre el mapeo:
-- receptcontrib.cvecont -> id (ID del contribuyente)
-- receptcontrib.folio -> folio (número de folio)
-- receptcontrib.razonsocial / nombres+paterno+materno -> nombre (nombre de la empresa o persona)
-- receptcontrib.razonsocial -> razon_social (razón social)
-- receptcontrib.rfc -> rfc (RFC)
-- receptcontrib.telefono -> telefono
-- receptcontrib.correo -> email
-- receptcontrib.nombres+paterno+materno -> contacto (persona de contacto)
-- receptcontrib.notif_domicilio + noexterior + interior -> direccion
-- receptcontrib.colonia / notif_colonia -> colonia
-- receptcontrib.codpos -> codigo_postal
-- receptcontrib.tipo -> tipo (M=Persona Moral/Empresa, F=Persona Física)
-- receptcontrib.feccap -> fecha_registro
--
-- NOTA: Se filtran registros donde tipo='M' (Empresas/Personas Morales)
-- También se incluyen tipo='F' que tienen razonsocial (algunas personas físicas con actividad empresarial)
