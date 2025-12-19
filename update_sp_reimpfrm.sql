-- Actualización del Stored Procedure para reimpfrm.vue
-- Usando tabla noadeudo (documentos de no adeudo)

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_reimpfrm'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_reimpfrm(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para reimpfrm (reimprimir documentos)
CREATE OR REPLACE FUNCTION publico.recaudadora_reimpfrm(
    p_folio INTEGER DEFAULT NULL,
    p_tipo_documento VARCHAR DEFAULT NULL,
    p_id_dependencia INTEGER DEFAULT NULL,
    p_filtro VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    folio INTEGER,
    tipo_documento VARCHAR,
    fecha DATE,
    contribuyente VARCHAR,
    dependencia VARCHAR,
    axo_acta INTEGER,
    num_acta VARCHAR,
    importe NUMERIC,
    estatus VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Usamos tabla noadeudo (constancias de no adeudo)
    -- que tiene 636,322 registros con folios para reimprimir

    RETURN QUERY
    SELECT
        d.folio,
        'NO ADEUDO'::VARCHAR AS tipo_documento,
        d.fecha,
        COALESCE(TRIM(d.autoriza), 'Sin nombre')::VARCHAR AS contribuyente,
        CASE
            WHEN d.recaud = 1 THEN 'Recaudación 1'
            WHEN d.recaud = 2 THEN 'Recaudación 2'
            WHEN d.recaud = 3 THEN 'Recaudación 3'
            WHEN d.recaud = 4 THEN 'Recaudación 4'
            ELSE 'Recaudación ' || d.recaud::VARCHAR
        END::VARCHAR AS dependencia,
        d.axo::INTEGER AS axo_acta,
        d.solicitud::VARCHAR AS num_acta,
        0::NUMERIC AS importe,
        CASE
            WHEN d.vigencia = 'V' THEN 'VIGENTE'
            WHEN d.vigencia IS NULL THEN 'PROCESADO'
            ELSE 'INACTIVO'
        END::VARCHAR AS estatus
    FROM public.noadeudo d
    WHERE
        -- Filtro por folio específico
        (p_folio IS NULL OR d.folio = p_folio)
        -- Ignorar filtro de tipo_documento ya que solo hay tipo NO ADEUDO
        -- Filtro por dependencia (recaudación)
        AND (p_id_dependencia IS NULL OR d.recaud = p_id_dependencia)
        -- Filtro adicional por texto libre
        AND (p_filtro IS NULL OR p_filtro = '' OR
             d.folio::VARCHAR ILIKE '%' || p_filtro || '%' OR
             TRIM(d.autoriza) ILIKE '%' || p_filtro || '%' OR
             d.solicitud::VARCHAR ILIKE '%' || p_filtro || '%')
    ORDER BY d.fecha DESC NULLS LAST, d.folio DESC
    LIMIT 100;

END;
$$;

-- Comentarios sobre la función:
-- publico.recaudadora_reimpfrm -> Retorna documentos para reimprimir
--
-- TABLA BASE: public.noadeudo (636,322 registros de constancias de no adeudo)
--
-- CAMPOS MAPEADOS:
-- - folio -> folio (folio del documento)
-- - 'NO ADEUDO' -> tipo_documento (constante, tipo de documento)
-- - fecha -> fecha (fecha de emisión)
-- - autoriza -> contribuyente (nombre de quien autoriza/solicita)
-- - recaud -> dependencia (recaudación 1-4)
-- - axo -> axo_acta (año del documento)
-- - solicitud -> num_acta (número de solicitud)
-- - 0 -> importe (no aplica para no adeudo)
-- - vigencia -> estatus (V=VIGENTE, NULL=PROCESADO, otro=INACTIVO)
--
-- PARÁMETROS:
-- - p_folio: INTEGER (filtro por folio específico)
-- - p_tipo_documento: VARCHAR (filtro por tipo, siempre NO ADEUDO)
-- - p_id_dependencia: INTEGER (filtro por recaudación 1-4)
-- - p_filtro: VARCHAR (búsqueda adicional en folio, autoriza, solicitud)
--
-- ESTADÍSTICAS:
-- - Total registros: 636,322
-- - Años disponibles: 2015-2024
-- - Distribución reciente:
--   * 2024: 29,152 registros
--   * 2023: 31,353 registros
--   * 2022: 30,715 registros
-- - Vigencia:
--   * PROCESADO (NULL): 632,316 (99.4%)
--   * VIGENTE (V): 4,006 (0.6%)
--
-- LÍMITE:
-- - La función retorna máximo 100 registros para evitar sobrecarga
-- - Ordenados por fecha más reciente primero
--
-- EJEMPLOS DE USO:
--
-- 1. Buscar por folio específico:
-- SELECT * FROM publico.recaudadora_reimpfrm(6448661, NULL, NULL, NULL);
--
-- 2. Buscar por recaudación:
-- SELECT * FROM publico.recaudadora_reimpfrm(NULL, NULL, 2, NULL);
--
-- 3. Buscar por texto libre (nombre, folio, solicitud):
-- SELECT * FROM publico.recaudadora_reimpfrm(NULL, NULL, NULL, 'KARLA');
--
-- 4. Buscar todos (últimos 100):
-- SELECT * FROM publico.recaudadora_reimpfrm(NULL, NULL, NULL, NULL);
--
-- 5. Buscar por año (usando filtro):
-- SELECT * FROM publico.recaudadora_reimpfrm(NULL, NULL, NULL, NULL)
-- WHERE axo_acta = 2024;
