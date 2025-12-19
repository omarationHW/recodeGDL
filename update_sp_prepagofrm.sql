-- Actualización del Stored Procedure para prepagofrm.vue
-- Usando la tabla lic_pago_alt (pagos alternativos de licencias)

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_prepagofrm'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_prepagofrm(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para prepagofrm (prepagos/pagos alternativos)
-- Usa la tabla lic_pago_alt para pagos alternativos de licencias
CREATE OR REPLACE FUNCTION publico.recaudadora_prepagofrm(
    p_busqueda VARCHAR DEFAULT ''
)
RETURNS TABLE (
    cvepago INTEGER,
    cvecuenta VARCHAR,
    folio VARCHAR,
    fecha_pago DATE,
    importe NUMERIC,
    caja VARCHAR,
    cajero VARCHAR,
    cancelado VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.cvepago,
        p.licencia::VARCHAR AS cvecuenta,
        p.s_trans::VARCHAR AS folio,
        p.fecha_registro AS fecha_pago,
        p.t_importe AS importe,
        CASE
            WHEN p.s_origen = 1 THEN 'Caja 1'
            WHEN p.s_origen = 2 THEN 'Caja 2'
            WHEN p.s_origen = 3 THEN 'Caja 3'
            ELSE 'Caja ' || p.s_origen::VARCHAR
        END::VARCHAR AS caja,
        COALESCE(p.linea, 'N/A')::VARCHAR AS cajero,
        CASE
            WHEN p.fecha_concilia IS NOT NULL THEN 'NO'
            ELSE 'PENDIENTE'
        END::VARCHAR AS cancelado
    FROM public.lic_pago_alt p
    WHERE
        CASE
            WHEN p_busqueda = '' OR p_busqueda IS NULL THEN TRUE
            ELSE (
                p.cvepago::VARCHAR ILIKE '%' || p_busqueda || '%'
                OR p.licencia::VARCHAR ILIKE '%' || p_busqueda || '%'
                OR p.s_trans::VARCHAR ILIKE '%' || p_busqueda || '%'
            )
        END
    ORDER BY p.fecha_registro DESC, p.cvepago DESC
    LIMIT 100;

END;
$$;

-- Comentarios sobre la función:
-- publico.recaudadora_prepagofrm -> Retorna prepagos/pagos alternativos de licencias
--
-- IMPORTANTE:
-- - Esta función usa la tabla public.lic_pago_alt (30,547 registros)
-- - Retorna pagos alternativos de licencias que funcionan como prepagos
-- - Permite búsqueda por cvepago, licencia o folio de transacción
-- - Límite de 100 resultados por consulta
-- - Estructura de retorno:
--   * cvepago: Código de pago
--   * cvecuenta: Número de licencia
--   * folio: Folio de transacción (s_trans)
--   * fecha_pago: Fecha de registro del pago
--   * importe: Importe total del pago
--   * caja: Origen del pago (Caja 1, 2, 3, etc.)
--   * cajero: Línea de captura/cajero
--   * cancelado: NO si está conciliado, PENDIENTE si no
--
-- MAPEO DE CAMPOS:
-- - cvepago: Directo de lic_pago_alt.cvepago
-- - cvecuenta: Mapeado desde lic_pago_alt.licencia
-- - folio: Mapeado desde lic_pago_alt.s_trans (folio de transacción)
-- - fecha_pago: Mapeado desde lic_pago_alt.fecha_registro
-- - importe: Mapeado desde lic_pago_alt.t_importe (total importe)
-- - caja: Construido desde lic_pago_alt.s_origen (1=Caja 1, etc.)
-- - cajero: Mapeado desde lic_pago_alt.linea
-- - cancelado: Construido desde lic_pago_alt.fecha_concilia (NULL=PENDIENTE)
--
-- NOTAS:
-- - Tabla tiene 30,547 registros de pagos de licencias
-- - Fechas desde 2007 en adelante
-- - s_origen indica la caja/origen del pago
-- - fecha_concilia indica si el pago fue conciliado
-- - Pagos sin conciliar se marcan como PENDIENTE
-- - Límite de 100 registros para rendimiento
--
-- EJEMPLO DE USO:
-- SELECT * FROM publico.recaudadora_prepagofrm('');  -- Todos (últimos 100)
-- SELECT * FROM publico.recaudadora_prepagofrm('200277');  -- Por licencia
-- SELECT * FROM publico.recaudadora_prepagofrm('3337');  -- Por folio
