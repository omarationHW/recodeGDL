-- Actualización del Stored Procedure para listchq.vue
-- Usa las tablas existentes: public.cheqpag y publico.pagos

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_listchq'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_listchq(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal con filtro de texto
CREATE OR REPLACE FUNCTION publico.recaudadora_listchq(
    p_filtro TEXT DEFAULT ''
)
RETURNS TABLE (
    fecha DATE,
    banco VARCHAR,
    cheque VARCHAR,
    cuenta VARCHAR,
    importe NUMERIC,
    tipo_pag VARCHAR,
    folio_completo VARCHAR,
    id_rec INTEGER,
    caja VARCHAR,
    operacion INTEGER
)
LANGUAGE plpgsql AS $$
DECLARE
    v_filtro TEXT;
BEGIN
    v_filtro := COALESCE(UPPER(TRIM(p_filtro)), '');

    -- Consultar pagos con cheques aplicando filtro de texto
    RETURN QUERY
    SELECT
        p.fecha AS fecha,
        CASE
            WHEN c.cvebanco = 1 THEN 'BANAMEX'
            WHEN c.cvebanco = 2 THEN 'BANCOMER'
            WHEN c.cvebanco = 3 THEN 'SANTANDER'
            WHEN c.cvebanco = 4 THEN 'HSBC'
            WHEN c.cvebanco = 5 THEN 'BANORTE'
            WHEN c.cvebanco = 6 THEN 'SCOTIABANK'
            WHEN c.cvebanco = 7 THEN 'INBURSA'
            WHEN c.cvebanco IS NOT NULL THEN 'BANCO ' || c.cvebanco::TEXT
            ELSE 'SIN ESPECIFICAR'
        END::VARCHAR AS banco,
        TRIM(COALESCE(c.numcheq, 'S/N'))::VARCHAR AS cheque,
        TRIM(COALESCE(c.ncta, 'S/N'))::VARCHAR AS cuenta,
        COALESCE(c.importe, p.importe, 0)::NUMERIC AS importe,
        CASE
            WHEN c.cvepago IS NOT NULL THEN 'Cheque'
            ELSE 'Efectivo'
        END::VARCHAR AS tipo_pag,
        (COALESCE(p.recaud::TEXT, '') || '-' ||
         COALESCE(p.caja, '') || '-' ||
         COALESCE(p.folio::TEXT, ''))::VARCHAR AS folio_completo,
        p.recaud::INTEGER AS id_rec,
        TRIM(COALESCE(p.caja, ''))::VARCHAR AS caja,
        COALESCE(p.folio, 0)::INTEGER AS operacion
    FROM publico.pagos p
    LEFT JOIN public.cheqpag c ON p.cvepago = c.cvepago
    WHERE c.cvepago IS NOT NULL  -- Solo pagos con cheque
      AND p.cvecanc IS NULL  -- Excluir pagos cancelados
      AND (v_filtro = '' OR
           UPPER(TRIM(COALESCE(c.numcheq, ''))) LIKE '%' || v_filtro || '%' OR
           UPPER(TRIM(COALESCE(c.ncta, ''))) LIKE '%' || v_filtro || '%' OR
           UPPER(COALESCE(p.recaud::TEXT, '') || '-' || COALESCE(p.caja, '') || '-' || COALESCE(p.folio::TEXT, '')) LIKE '%' || v_filtro || '%' OR
           CASE
               WHEN c.cvebanco = 1 THEN 'BANAMEX'
               WHEN c.cvebanco = 2 THEN 'BANCOMER'
               WHEN c.cvebanco = 3 THEN 'SANTANDER'
               WHEN c.cvebanco = 4 THEN 'HSBC'
               WHEN c.cvebanco = 5 THEN 'BANORTE'
               WHEN c.cvebanco = 6 THEN 'SCOTIABANK'
               WHEN c.cvebanco = 7 THEN 'INBURSA'
               ELSE 'BANCO ' || c.cvebanco::TEXT
           END LIKE '%' || v_filtro || '%')
    ORDER BY p.fecha DESC, p.cvepago DESC
    LIMIT 100;

END;
$$;

-- Comentarios sobre el mapeo:
-- publico.pagos.fecha -> fecha (fecha del pago)
-- public.cheqpag.cvebanco -> banco (catálogo de bancos: 1=BANAMEX, 2=BANCOMER, etc.)
-- public.cheqpag.numcheq -> cheque (número de cheque)
-- public.cheqpag.ncta -> cuenta (número de cuenta)
-- public.cheqpag.importe -> importe (monto del cheque)
-- 'Cheque' -> tipo_pag (tipo de pago fijo)
-- CONCAT(recaud, caja, folio) -> folio_completo (folio construido)
-- publico.pagos.recaud -> id_rec (recaudadora)
-- publico.pagos.caja -> caja (caja de pago)
-- publico.pagos.folio -> operacion (número de operación)

-- FILTROS:
-- - Últimos 30 días por defecto
-- - Excluye pagos cancelados (cvecanc IS NULL)
-- - Solo pagos con cheque (JOIN con cheqpag)
-- - Límite de 100 registros
-- - Ordenado por fecha descendente

-- JOINS:
-- publico.pagos LEFT JOIN public.cheqpag ON cvepago
-- Esto permite obtener la información completa del pago y el cheque asociado
