-- Actualización del Stored Procedure para listdesctomultafrm.vue
-- Usa las tablas existentes: publico.descmultampal y publico.multas

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_listdesctomultafrm'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_listdesctomultafrm(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal con filtro de texto
CREATE OR REPLACE FUNCTION publico.recaudadora_listdesctomultafrm(
    p_filtro VARCHAR DEFAULT ''
)
RETURNS TABLE (
    id_multa INTEGER,
    num_acta VARCHAR,
    axo_acta VARCHAR,
    contribuyente VARCHAR,
    tipo_descto VARCHAR,
    valor_descto NUMERIC,
    porcentaje NUMERIC,
    total_original NUMERIC,
    total_con_descto NUMERIC,
    estado VARCHAR,
    fecha_movto DATE,
    folio VARCHAR,
    observacion TEXT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_filtro VARCHAR;
BEGIN
    v_filtro := COALESCE(UPPER(TRIM(p_filtro)), '');

    -- Consultar descuentos de multas con JOIN a tabla multas
    RETURN QUERY
    SELECT
        d.id_multa::INTEGER,
        COALESCE(m.num_acta::TEXT, 'S/N')::VARCHAR AS num_acta,
        COALESCE(m.axo_acta::TEXT, '')::VARCHAR AS axo_acta,
        TRIM(COALESCE(m.contribuyente, 'NO ESPECIFICADO'))::VARCHAR AS contribuyente,
        CASE
            WHEN d.tipo_descto = 'P' THEN 'Porcentaje'
            WHEN d.tipo_descto = 'M' THEN 'Monto Fijo'
            WHEN d.tipo_descto = 'E' THEN 'Especial'
            WHEN d.tipo_descto IS NOT NULL THEN 'Tipo ' || d.tipo_descto
            ELSE 'No especificado'
        END::VARCHAR AS tipo_descto,
        COALESCE(d.valor, 0)::NUMERIC AS valor_descto,
        CASE
            WHEN d.tipo_descto = 'P' THEN COALESCE(d.valor, 0)
            WHEN COALESCE(m.total, 0) > 0 THEN
                ROUND((COALESCE(d.valor, 0) / m.total * 100)::NUMERIC, 2)
            ELSE 0
        END::NUMERIC AS porcentaje,
        COALESCE(m.total, m.calificacion, 0)::NUMERIC AS total_original,
        CASE
            WHEN d.tipo_descto = 'P' THEN
                COALESCE(m.total, m.calificacion, 0) -
                (COALESCE(m.total, m.calificacion, 0) * COALESCE(d.valor, 0) / 100)
            ELSE
                COALESCE(m.total, m.calificacion, 0) - COALESCE(d.valor, 0)
        END::NUMERIC AS total_con_descto,
        CASE
            WHEN d.estado = 'V' THEN 'VIGENTE'
            WHEN d.estado = 'C' THEN 'CANCELADO'
            WHEN d.estado = 'P' THEN 'PENDIENTE'
            ELSE 'DESCONOCIDO'
        END::VARCHAR AS estado,
        d.feccap AS fecha_movto,
        COALESCE(d.folio::TEXT, '')::VARCHAR AS folio,
        COALESCE(d.observacion, '')::TEXT AS observacion
    FROM publico.descmultampal d
    LEFT JOIN publico.multas m ON d.id_multa = m.id_multa
    WHERE
        (v_filtro = '' OR
         CAST(d.id_multa AS TEXT) ILIKE '%' || v_filtro || '%' OR
         CAST(m.num_acta AS TEXT) ILIKE '%' || v_filtro || '%' OR
         CAST(m.axo_acta AS TEXT) ILIKE '%' || v_filtro || '%' OR
         UPPER(TRIM(COALESCE(m.contribuyente, ''))) ILIKE '%' || v_filtro || '%' OR
         UPPER(COALESCE(d.tipo_descto, '')) ILIKE '%' || v_filtro || '%' OR
         CAST(d.folio AS TEXT) ILIKE '%' || v_filtro || '%' OR
         UPPER(d.estado) ILIKE '%' || v_filtro || '%' OR
         (v_filtro = 'VIGENTE' AND d.estado = 'V') OR
         (v_filtro = 'CANCELADO' AND d.estado = 'C') OR
         (v_filtro = 'PENDIENTE' AND d.estado = 'P'))
    ORDER BY d.feccap DESC, d.id_multa DESC
    LIMIT 100;

END;
$$;

-- Comentarios sobre el mapeo:
-- publico.descmultampal.id_multa -> id_multa
-- publico.multas.num_acta -> num_acta
-- publico.multas.axo_acta -> axo_acta (año del acta)
-- publico.multas.contribuyente -> contribuyente
-- publico.descmultampal.tipo_descto -> tipo_descto (P=Porcentaje, M=Monto, E=Especial)
-- publico.descmultampal.valor -> valor_descto (valor del descuento)
-- Calculado -> porcentaje (si tipo=P usa valor, sino calcula valor/total*100)
-- publico.multas.total o calificacion -> total_original (monto original de la multa)
-- Calculado -> total_con_descto (total - descuento aplicado)
-- publico.descmultampal.estado -> estado (V=VIGENTE, C=CANCELADO, P=PENDIENTE)
-- publico.descmultampal.feccap -> fecha_movto (fecha de captura del descuento)
-- publico.descmultampal.folio -> folio
-- publico.descmultampal.observacion -> observacion

-- FILTROS:
-- - Búsqueda de texto aplica a: id_multa, num_acta, axo_acta, contribuyente, tipo_descto, folio, estado
-- - Límite de 100 registros
-- - Ordenado por fecha descendente
-- - Case-insensitive con ILIKE

-- CÁLCULOS:
-- 1. Si tipo_descto = 'P': porcentaje = valor, total_con_descto = total - (total * valor / 100)
-- 2. Si tipo_descto != 'P': porcentaje = (valor / total * 100), total_con_descto = total - valor
-- 3. total_original = multas.total (o calificacion si total es NULL)

-- JOINS:
-- publico.descmultampal LEFT JOIN publico.multas ON id_multa
-- Esto permite obtener la información completa del descuento y la multa asociada
