-- Actualización del Stored Procedure para ListaDiferencias.vue
-- Usa la tabla existente: public.diferencias_glosa

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_lista_diferencias'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_lista_diferencias(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal con filtro de texto
CREATE OR REPLACE FUNCTION publico.recaudadora_lista_diferencias(
    p_filtro VARCHAR DEFAULT ''
)
RETURNS TABLE (
    id_diferencia INTEGER,
    tipo_registro VARCHAR,
    campo_afectado VARCHAR,
    valor_sistema VARCHAR,
    valor_registrado VARCHAR,
    diferencia_monto NUMERIC,
    folio VARCHAR,
    fecha_deteccion DATE,
    estado VARCHAR,
    responsable VARCHAR,
    observaciones TEXT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_filtro VARCHAR;
BEGIN
    v_filtro := COALESCE(UPPER(TRIM(p_filtro)), '');

    -- Consultar diferencias de glosa
    RETURN QUERY
    SELECT
        d.id::INTEGER AS id_diferencia,
        CASE
            WHEN d.tipo_dif = 'P' THEN 'PREDIAL'
            WHEN d.tipo_dif = 'N' THEN 'NORMAL'
            WHEN d.tipo_dif IS NOT NULL THEN 'TIPO ' || TRIM(d.tipo_dif)
            ELSE 'NO ESPECIFICADO'
        END::VARCHAR AS tipo_registro,
        CASE
            WHEN d.diferen = 'I' THEN 'IMPUESTO BASE'
            WHEN d.diferen = 'R' THEN 'RECARGOS'
            WHEN d.diferen = 'M' THEN 'MULTAS'
            WHEN d.diferen IS NOT NULL THEN 'CAMPO ' || TRIM(d.diferen)
            ELSE 'NO ESPECIFICADO'
        END::VARCHAR AS campo_afectado,
        ('Suma: $' || COALESCE(ROUND(
            COALESCE(d.importe_base, 0) +
            COALESCE(d.recargos, 0) +
            COALESCE(d.multas, 0) +
            COALESCE(d.multasext, 0) +
            COALESCE(d.imp_ot, 0) +
            COALESCE(d.gastos, 0)
        , 2)::TEXT, '0'))::VARCHAR AS valor_sistema,
        ('Total: $' || COALESCE(ROUND(d.total, 2)::TEXT, '0'))::VARCHAR AS valor_registrado,
        CASE
            WHEN d.total IS NOT NULL THEN
                ABS(d.total - (
                    COALESCE(d.importe_base, 0) +
                    COALESCE(d.recargos, 0) +
                    COALESCE(d.multas, 0) +
                    COALESCE(d.multasext, 0) +
                    COALESCE(d.imp_ot, 0) +
                    COALESCE(d.gastos, 0)
                ))
            ELSE 0
        END::NUMERIC AS diferencia_monto,
        CASE
            WHEN d.foliot IS NOT NULL THEN 'T-' || d.foliot::TEXT
            WHEN d.folio_glosa IS NOT NULL THEN 'G-' || d.folio_glosa::TEXT
            ELSE 'S/N'
        END::VARCHAR AS folio,
        d.fecha_alta AS fecha_deteccion,
        CASE
            WHEN d.vigencia = 'V' THEN 'VIGENTE'
            WHEN d.vigencia = 'C' THEN 'CANCELADO'
            WHEN d.vigencia = 'P' THEN 'PENDIENTE'
            ELSE 'DESCONOCIDO'
        END::VARCHAR AS estado,
        TRIM(COALESCE(d.usu_alta, 'DESCONOCIDO'))::VARCHAR AS responsable,
        COALESCE(d.observaciones, '')::TEXT AS observaciones
    FROM public.diferencias_glosa d
    WHERE
        (v_filtro = '' OR
         CAST(d.id AS TEXT) ILIKE '%' || v_filtro || '%' OR
         CAST(d.foliot AS TEXT) ILIKE '%' || v_filtro || '%' OR
         CAST(d.folio_glosa AS TEXT) ILIKE '%' || v_filtro || '%' OR
         CAST(d.cvecuenta AS TEXT) ILIKE '%' || v_filtro || '%' OR
         UPPER(TRIM(COALESCE(d.tipo_dif, ''))) ILIKE '%' || v_filtro || '%' OR
         UPPER(TRIM(COALESCE(d.diferen, ''))) ILIKE '%' || v_filtro || '%' OR
         UPPER(TRIM(COALESCE(d.usu_alta, ''))) ILIKE '%' || v_filtro || '%' OR
         UPPER(d.vigencia) ILIKE '%' || v_filtro || '%' OR
         (v_filtro = 'VIGENTE' AND d.vigencia = 'V') OR
         (v_filtro = 'CANCELADO' AND d.vigencia = 'C') OR
         (v_filtro = 'PENDIENTE' AND d.vigencia = 'P') OR
         (v_filtro = 'PREDIAL' AND d.tipo_dif = 'P') OR
         (v_filtro = 'NORMAL' AND d.tipo_dif = 'N') OR
         (v_filtro = 'IMPUESTO' AND d.diferen = 'I') OR
         (v_filtro = 'RECARGOS' AND d.diferen = 'R') OR
         (v_filtro = 'MULTAS' AND d.diferen = 'M'))
    ORDER BY d.fecha_alta DESC, d.id DESC
    LIMIT 100;

END;
$$;

-- Comentarios sobre el mapeo:
-- public.diferencias_glosa.id -> id_diferencia
-- public.diferencias_glosa.tipo_dif -> tipo_registro (P=PREDIAL, N=NORMAL)
-- public.diferencias_glosa.diferen -> campo_afectado (I=IMPUESTO, R=RECARGOS, M=MULTAS)
-- Calculado suma de componentes -> valor_sistema (suma de importe_base + recargos + multas + etc)
-- public.diferencias_glosa.total -> valor_registrado (total registrado)
-- Calculado ABS(total - suma) -> diferencia_monto (diferencia absoluta)
-- public.diferencias_glosa.foliot o folio_glosa -> folio (T-XXXX o G-XXXX)
-- public.diferencias_glosa.fecha_alta -> fecha_deteccion
-- public.diferencias_glosa.vigencia -> estado (V=VIGENTE, C=CANCELADO, P=PENDIENTE)
-- public.diferencias_glosa.usu_alta -> responsable (usuario que registró)
-- public.diferencias_glosa.observaciones -> observaciones

-- FILTROS:
-- - Búsqueda de texto aplica a: id, foliot, folio_glosa, cvecuenta, tipo_dif, diferen, usu_alta, vigencia
-- - También busca por palabras completas: VIGENTE, CANCELADO, PENDIENTE, PREDIAL, NORMAL, IMPUESTO, RECARGOS, MULTAS
-- - Límite de 100 registros
-- - Ordenado por fecha descendente
-- - Case-insensitive con ILIKE

-- CÁLCULOS:
-- 1. valor_sistema = suma de todos los componentes (importe_base + recargos + multas + multasext + imp_ot + gastos)
-- 2. valor_registrado = total registrado
-- 3. diferencia_monto = |total - suma_componentes| (valor absoluto de la diferencia)

-- CAMPOS DE LA TABLA:
-- - id: ID único
-- - foliot: Folio de transmisión
-- - cvecuenta: Cuenta catastral
-- - fecha_alta: Fecha de registro
-- - usu_alta: Usuario que registró
-- - vigencia: Estado (V/C/P)
-- - importe_base, recargos, multas, multasext, imp_ot, gastos: Componentes del monto
-- - total: Total registrado
-- - observaciones: Observaciones
-- - tipo_dif: Tipo de diferencia (P/N)
-- - diferen: Campo afectado (I/R/M)
