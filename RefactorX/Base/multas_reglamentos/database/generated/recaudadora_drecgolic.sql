-- ================================================================
-- SP: recaudadora_drecgolic
-- Módulo: multas_reglamentos
-- Descripción: Consulta derechos de licencias comerciales
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-01
-- ================================================================

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_drecgolic(
    p_licencia VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id_licencia TEXT,
    licencia TEXT,
    empresa TEXT,
    recaud TEXT,
    id_giro TEXT,
    zona TEXT,
    subzona TEXT,
    tipo_registro TEXT,
    actividad TEXT,
    cvecuenta TEXT,
    fecha_otorgamiento TEXT,
    propietario TEXT,
    primer_ap TEXT,
    segundo_ap TEXT,
    rfc TEXT,
    curp TEXT,
    domicilio TEXT,
    numext_prop TEXT,
    coordenadas TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Retornar información de licencias
    RETURN QUERY
    SELECT
        CAST(h.id_licencia AS TEXT) AS id_licencia,
        CAST(h.licencia AS TEXT) AS licencia,
        CAST(h.empresa AS TEXT) AS empresa,
        CAST(h.recaud AS TEXT) AS recaud,
        CAST(h.id_giro AS TEXT) AS id_giro,
        CAST(h.zona AS TEXT) AS zona,
        CAST(h.subzona AS TEXT) AS subzona,
        CAST(TRIM(h.tipo_registro) AS TEXT) AS tipo_registro,
        CAST(TRIM(h.actividad) AS TEXT) AS actividad,
        CAST(h.cvecuenta AS TEXT) AS cvecuenta,
        CAST(h.fecha_otorgamiento AS TEXT) AS fecha_otorgamiento,
        CAST(TRIM(h.propietario) AS TEXT) AS propietario,
        CAST(TRIM(h.primer_ap) AS TEXT) AS primer_ap,
        CAST(TRIM(h.segundo_ap) AS TEXT) AS segundo_ap,
        CAST(TRIM(h.rfc) AS TEXT) AS rfc,
        CAST(TRIM(h.curp) AS TEXT) AS curp,
        CAST(TRIM(h.domicilio) AS TEXT) AS domicilio,
        CAST(h.numext_prop AS TEXT) AS numext_prop,
        CAST('(' || h.x || ', ' || h.y || ')' AS TEXT) AS coordenadas
    FROM catastro_gdl.h_licencias h
    WHERE
        (p_licencia IS NULL OR p_licencia = '' OR CAST(h.licencia AS VARCHAR) = p_licencia)
    ORDER BY h.licencia, h.id_licencia;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_drecgolic(VARCHAR) IS 'Consulta derechos de licencias comerciales desde catastro_gdl.h_licencias.';
