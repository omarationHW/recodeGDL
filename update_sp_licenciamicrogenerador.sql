-- Actualización del Stored Procedure para LicenciaMicrogeneradorEcologia
-- Usa tabla publico.licencias existente en lugar de crear nuevas tablas

DROP FUNCTION IF EXISTS publico.recaudadora_licenciamicrogeneradorecologia() CASCADE;
DROP FUNCTION IF EXISTS publico.recaudadora_licenciamicrogeneradorecologia(character varying) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_licenciamicrogeneradorecologia(
    p_rfc VARCHAR
)
RETURNS TABLE (
    id_licencia INTEGER,
    rfc VARCHAR,
    folio_licencia VARCHAR,
    nombre_solicitante VARCHAR,
    domicilio VARCHAR,
    tipo_energia VARCHAR,
    capacidad_kw NUMERIC,
    fecha_emision DATE,
    fecha_vencimiento DATE,
    estatus VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Validar entrada
    IF p_rfc IS NULL OR TRIM(p_rfc) = '' THEN
        RETURN;
    END IF;

    -- Buscar licencias por RFC en la tabla publico.licencias
    RETURN QUERY
    SELECT
        l.id_licencia::INTEGER,
        TRIM(COALESCE(l.rfc, ''))::VARCHAR AS rfc,
        ('LIC-' || COALESCE(l.licencia::TEXT, l.id_licencia::TEXT))::VARCHAR AS folio_licencia,
        (TRIM(COALESCE(l.propietario, '')) || ' ' ||
         TRIM(COALESCE(l.primer_ap, '')) || ' ' ||
         TRIM(COALESCE(l.segundo_ap, '')))::VARCHAR AS nombre_solicitante,
        CASE
            WHEN l.ubicacion IS NOT NULL AND TRIM(l.ubicacion) != '' THEN
                TRIM(l.ubicacion) ||
                CASE WHEN l.numext_ubic IS NOT NULL THEN ' #' || l.numext_ubic::TEXT ELSE '' END ||
                CASE WHEN l.colonia_ubic IS NOT NULL THEN ', ' || TRIM(l.colonia_ubic) ELSE '' END
            WHEN l.domicilio IS NOT NULL AND TRIM(l.domicilio) != '' THEN
                TRIM(l.domicilio) ||
                CASE WHEN l.numext_prop IS NOT NULL THEN ' #' || l.numext_prop::TEXT ELSE '' END ||
                CASE WHEN l.colonia_prop IS NOT NULL THEN ', ' || TRIM(l.colonia_prop) ELSE '' END
            ELSE 'DOMICILIO NO DISPONIBLE'
        END::VARCHAR AS domicilio,
        CASE
            WHEN l.actividad IS NOT NULL AND TRIM(l.actividad) != '' THEN
                'Actividad: ' || TRIM(l.actividad)
            WHEN l.id_giro IS NOT NULL AND l.id_giro > 0 THEN
                'Giro ID: ' || l.id_giro::TEXT
            ELSE 'No especificado'
        END::VARCHAR AS tipo_energia,
        COALESCE(l.sup_autorizada, 0)::NUMERIC AS capacidad_kw,
        l.fecha_otorgamiento AS fecha_emision,
        CASE
            WHEN l.fecha_otorgamiento IS NOT NULL THEN
                (l.fecha_otorgamiento + INTERVAL '1 year')::DATE
            ELSE NULL
        END AS fecha_vencimiento,
        CASE
            WHEN UPPER(l.vigente) = 'S' THEN 'VIGENTE'
            WHEN UPPER(l.vigente) = 'N' THEN 'NO VIGENTE'
            WHEN l.fecha_baja IS NOT NULL THEN 'BAJA'
            ELSE 'DESCONOCIDO'
        END::VARCHAR AS estatus
    FROM publico.licencias l
    WHERE UPPER(TRIM(COALESCE(l.rfc, ''))) = UPPER(TRIM(p_rfc))
    ORDER BY l.fecha_otorgamiento DESC
    LIMIT 100;

END;
$$;

-- Comentarios sobre el mapeo:
-- publico.licencias.id_licencia -> id_licencia
-- publico.licencias.rfc -> rfc
-- publico.licencias.licencia -> folio_licencia (con prefijo 'LIC-')
-- publico.licencias.propietario + apellidos -> nombre_solicitante
-- publico.licencias.ubicacion o domicilio -> domicilio (con número y colonia)
-- publico.licencias.actividad o id_giro -> tipo_energia (adaptado)
-- publico.licencias.sup_autorizada -> capacidad_kw (superficie autorizada)
-- publico.licencias.fecha_otorgamiento -> fecha_emision
-- fecha_otorgamiento + 1 año -> fecha_vencimiento (calculado)
-- publico.licencias.vigente -> estatus (S=VIGENTE, N=NO VIGENTE)

-- Campos de la tabla licencias usados:
-- id_licencia: ID único de la licencia
-- licencia: Número de licencia
-- rfc: RFC del propietario
-- propietario, primer_ap, segundo_ap: Nombre completo
-- domicilio, numext_prop, colonia_prop: Domicilio del propietario
-- ubicacion, numext_ubic, colonia_ubic: Ubicación del establecimiento
-- actividad: Tipo de actividad
-- id_giro: ID del giro comercial
-- sup_autorizada: Superficie autorizada (usado como capacidad)
-- fecha_otorgamiento: Fecha de emisión de la licencia
-- vigente: Estado de vigencia (S/N)
-- fecha_baja: Fecha de baja (si aplica)
