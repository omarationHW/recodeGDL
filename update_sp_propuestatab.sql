-- Actualización del Stored Procedure para Propuestatab.vue
-- Como no existe tabla de propuestas_pago, retorna conjunto vacío

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_propuestatab'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_propuestatab(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para propuestatab (propuestas de pago)
CREATE OR REPLACE FUNCTION publico.recaudadora_propuestatab(
    p_filtro VARCHAR DEFAULT ''
)
RETURNS TABLE (
    id_propuesta INTEGER,
    cvepago VARCHAR,
    cvecuenta VARCHAR,
    recaud VARCHAR,
    caja VARCHAR,
    folio VARCHAR,
    fecha DATE,
    hora TIME,
    importe NUMERIC,
    cajero VARCHAR,
    cveconcepto VARCHAR,
    estado VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Como no existe la tabla propuestas_pago, retornamos conjunto vacío
    -- con la estructura esperada

    RETURN QUERY
    SELECT
        0::INTEGER AS id_propuesta,
        ''::VARCHAR AS cvepago,
        ''::VARCHAR AS cvecuenta,
        ''::VARCHAR AS recaud,
        ''::VARCHAR AS caja,
        ''::VARCHAR AS folio,
        NULL::DATE AS fecha,
        NULL::TIME AS hora,
        0::NUMERIC AS importe,
        ''::VARCHAR AS cajero,
        ''::VARCHAR AS cveconcepto,
        ''::VARCHAR AS estado
    WHERE FALSE;  -- Esto hace que no retorne ninguna fila

END;
$$;

-- Comentarios sobre la función:
-- publico.recaudadora_propuestatab -> Retorna propuestas de pago (conjunto vacío)
--
-- IMPORTANTE:
-- - Esta función retorna un conjunto VACÍO porque la tabla propuestas_pago NO EXISTE
-- - No hay datos de propuestas de pago disponibles en la base de datos
-- - Estructura de retorno:
--   * id_propuesta: ID de la propuesta
--   * cvepago: Código de pago
--   * cvecuenta: Clave de cuenta
--   * recaud: Código de recaudación
--   * caja: Número de caja
--   * folio: Folio de la propuesta
--   * fecha: Fecha de la propuesta
--   * hora: Hora de la propuesta
--   * importe: Monto de la propuesta
--   * cajero: Usuario/cajero
--   * cveconcepto: Clave de concepto
--   * estado: Estado de la propuesta
--
-- NOTA:
-- Si se requiere funcionalidad real de propuestas de pago,
-- se debe crear la tabla propuestas_pago con estos campos:
--   - id_propuesta SERIAL PRIMARY KEY
--   - cvepago INTEGER
--   - cvecuenta INTEGER
--   - recaud SMALLINT (recaudación)
--   - caja SMALLINT (número de caja)
--   - folio VARCHAR (folio de propuesta)
--   - fecha DATE (fecha de propuesta)
--   - hora TIME (hora de propuesta)
--   - importe NUMERIC (monto)
--   - cajero VARCHAR (usuario/cajero)
--   - cveconcepto INTEGER (clave de concepto)
--   - estado VARCHAR (estado: PENDIENTE, APROBADA, RECHAZADA)
--
-- Y luego actualizar este stored procedure para:
-- SELECT
--     p.id_propuesta,
--     p.cvepago::VARCHAR,
--     p.cvecuenta::VARCHAR,
--     p.recaud::VARCHAR,
--     p.caja::VARCHAR,
--     p.folio,
--     p.fecha,
--     p.hora,
--     p.importe,
--     p.cajero,
--     p.cveconcepto::VARCHAR,
--     p.estado
-- FROM public.propuestas_pago p
-- WHERE
--     (p_filtro = '' OR p_filtro IS NULL OR
--      p.cvecuenta::VARCHAR ILIKE '%' || p_filtro || '%' OR
--      p.folio ILIKE '%' || p_filtro || '%' OR
--      p.cajero ILIKE '%' || p_filtro || '%' OR
--      p.cvepago::VARCHAR ILIKE '%' || p_filtro || '%')
-- ORDER BY p.fecha DESC, p.hora DESC, p.id_propuesta DESC;
--
-- EJEMPLO DE USO:
-- SELECT * FROM publico.recaudadora_propuestatab('');  -- Sin filtro
-- SELECT * FROM publico.recaudadora_propuestatab('12345');  -- Por cuenta o folio
