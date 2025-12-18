-- Actualización del Stored Procedure para ModifMasiva.vue
-- Usa la tabla existente: public.reqbfpredial

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_modif_masiva'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_modif_masiva(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para modificación masiva
CREATE OR REPLACE FUNCTION publico.recaudadora_modif_masiva(
    p_parametros TEXT
)
RETURNS TABLE (
    total_encontrados BIGINT,
    mensaje TEXT,
    detalles JSONB
)
LANGUAGE plpgsql AS $$
DECLARE
    v_recaud INTEGER;
    v_folio_ini INTEGER;
    v_folio_fin INTEGER;
    v_estado VARCHAR;
    v_vigencia CHAR(1);
    v_count BIGINT;
BEGIN
    -- Parsear parámetros JSON
    -- Formato esperado: {"recaudadora": 1, "folio_inicio": 5000, "folio_fin": 5200, "estado": "ACTIVO"}

    BEGIN
        v_recaud := (p_parametros::jsonb->>'recaudadora')::INTEGER;
        v_folio_ini := (p_parametros::jsonb->>'folio_inicio')::INTEGER;
        v_folio_fin := (p_parametros::jsonb->>'folio_fin')::INTEGER;
        v_estado := COALESCE(p_parametros::jsonb->>'estado', 'ACTIVO');
    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            0::BIGINT,
            'Error al parsear parámetros JSON'::TEXT,
            jsonb_build_object('error', SQLERRM);
        RETURN;
    END;

    -- Mapear estado a vigencia
    v_vigencia := CASE v_estado
        WHEN 'ACTIVO' THEN 'V'
        WHEN 'VIGENTE' THEN 'V'
        WHEN 'CANCELADO' THEN 'C'
        WHEN 'PAGADO' THEN 'P'
        ELSE 'V'
    END;

    -- Contar registros que cumplen los criterios
    SELECT COUNT(*)
    INTO v_count
    FROM public.reqbfpredial
    WHERE recaud = v_recaud
      AND cvecuenta BETWEEN v_folio_ini AND v_folio_fin
      AND vigencia = v_vigencia;

    -- Retornar resultado
    RETURN QUERY
    SELECT
        v_count AS total_encontrados,
        CASE
            WHEN v_count = 0 THEN 'No se encontraron requerimientos con los criterios especificados'
            WHEN v_count = 1 THEN 'Se encontró 1 requerimiento que cumple los criterios'
            ELSE 'Se encontraron ' || v_count || ' requerimientos que cumplen los criterios'
        END::TEXT AS mensaje,
        jsonb_build_object(
            'recaudadora', v_recaud,
            'folio_inicio', v_folio_ini,
            'folio_fin', v_folio_fin,
            'estado', v_estado,
            'vigencia_codigo', v_vigencia,
            'total', v_count,
            'rango_cuentas', v_folio_fin - v_folio_ini + 1
        ) AS detalles;

END;
$$;

-- Función auxiliar para obtener los detalles de los requerimientos
CREATE OR REPLACE FUNCTION publico.recaudadora_modif_masiva_detalles(
    p_recaud INTEGER,
    p_folio_ini INTEGER,
    p_folio_fin INTEGER,
    p_estado VARCHAR DEFAULT 'ACTIVO'
)
RETURNS TABLE (
    cvecuenta INTEGER,
    recaudadora SMALLINT,
    vigencia VARCHAR,
    total NUMERIC,
    fecha_emision DATE,
    impuesto NUMERIC,
    recargos NUMERIC,
    gastos NUMERIC,
    multas NUMERIC
)
LANGUAGE plpgsql AS $$
DECLARE
    v_vigencia CHAR(1);
BEGIN
    -- Mapear estado a vigencia
    v_vigencia := CASE p_estado
        WHEN 'ACTIVO' THEN 'V'
        WHEN 'VIGENTE' THEN 'V'
        WHEN 'CANCELADO' THEN 'C'
        WHEN 'PAGADO' THEN 'P'
        ELSE 'V'
    END;

    RETURN QUERY
    SELECT
        r.cvecuenta,
        r.recaud AS recaudadora,
        CASE r.vigencia
            WHEN 'V' THEN 'Vigente/Activo'
            WHEN 'C' THEN 'Cancelado'
            WHEN 'P' THEN 'Pagado'
            ELSE r.vigencia
        END::VARCHAR AS vigencia,
        COALESCE(r.total, 0)::NUMERIC AS total,
        r.fecemi AS fecha_emision,
        COALESCE(r.impuesto, 0)::NUMERIC AS impuesto,
        COALESCE(r.recargos, 0)::NUMERIC AS recargos,
        COALESCE(r.gastos, 0)::NUMERIC AS gastos,
        COALESCE(r.multas, 0)::NUMERIC AS multas
    FROM public.reqbfpredial r
    WHERE r.recaud = p_recaud
      AND r.cvecuenta BETWEEN p_folio_ini AND p_folio_fin
      AND r.vigencia = v_vigencia
    ORDER BY r.cvecuenta
    LIMIT 1000;

END;
$$;

-- Comentarios sobre el mapeo:
-- public.reqbfpredial -> Tabla de requerimientos prediales
--
-- NOTA IMPORTANTE: En esta tabla, el campo "cvecuenta" se usa como "folio"
-- ya que no existe un campo folio directo. cvecuenta es la cuenta catastral.
--
-- Mapeo de campos:
-- folio → cvecuenta (cuenta catastral, rango numérico)
-- recaudadora → recaud (1-10)
-- estado → vigencia:
--   'ACTIVO' o 'VIGENTE' → 'V'
--   'CANCELADO' → 'C'
--   'PAGADO' → 'P'

-- FUNCIÓN PRINCIPAL: recaudadora_modif_masiva
-- Parámetros:
--   p_parametros: JSON con {"recaudadora": 1, "folio_inicio": 5000, "folio_fin": 5200, "estado": "ACTIVO"}
-- Retorna:
--   total_encontrados: Cantidad de registros encontrados
--   mensaje: Mensaje descriptivo
--   detalles: JSON con detalles de la búsqueda

-- FUNCIÓN AUXILIAR: recaudadora_modif_masiva_detalles
-- Parámetros:
--   p_recaud: Recaudadora (1-10)
--   p_folio_ini: Cuenta inicial
--   p_folio_fin: Cuenta final
--   p_estado: Estado ('ACTIVO', 'CANCELADO', 'PAGADO')
-- Retorna:
--   Lista de requerimientos que cumplen los criterios (máximo 1000)

-- ESTADÍSTICAS:
-- Total requerimientos: 118,842
-- Vigentes (V): 99,606 (83.8%)
-- Cancelados (C): 18 (0.02%)
-- Otros estados: 19,218 (16.2%)

-- DISTRIBUCIÓN POR RECAUDADORA:
-- Recaudadora 1: 26,994
-- Recaudadora 2: 20,331
-- Recaudadora 3: 45,449
-- Recaudadora 4: 26,068
