-- Actualización del Stored Procedure para dderechosLic
-- Usa la tabla detreqlic del esquema public
-- Desempaqueta los conceptos (forma, derechos, recargos) en filas separadas

DROP FUNCTION IF EXISTS publico.recaudadora_dderechoslic(INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_dderechoslic(
    p_licencia INTEGER DEFAULT 0
)
RETURNS TABLE (
    id_derecho INTEGER,
    licencia INTEGER,
    concepto VARCHAR,
    descripcion VARCHAR,
    importe NUMERIC,
    descuento NUMERIC,
    recargos NUMERIC,
    total NUMERIC,
    ejercicio INTEGER,
    estatus VARCHAR,
    fecha_registro TIMESTAMP
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    -- Desempaquetar cada concepto como una fila separada
    WITH conceptos AS (
        SELECT
            d.cvereq,
            d.id_licencia,
            d.id_anuncio,
            d.axo,
            d.forma,
            d.derechos,
            d.recargos AS recargos_campo,
            d.saldo,
            d.derechos2,
            d.actualizacion
        FROM public.detreqlic d
        WHERE
            (p_licencia = 0 OR d.id_licencia = p_licencia)
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY c.id_licencia, c.axo, concepto_orden)::integer AS id_derecho,
        c.id_licencia::integer AS licencia,
        concepto_nombre::varchar AS concepto,
        concepto_desc::varchar AS descripcion,
        concepto_importe::numeric AS importe,
        0::numeric AS descuento,
        CASE
            WHEN concepto_nombre = 'Recargos' THEN concepto_importe
            ELSE 0
        END::numeric AS recargos,
        concepto_importe::numeric AS total,
        c.axo::integer AS ejercicio,
        'Vigente'::varchar AS estatus,
        CURRENT_TIMESTAMP::timestamp without time zone AS fecha_registro
    FROM conceptos c
    CROSS JOIN LATERAL (
        VALUES
            (1, 'Forma', 'Forma de licencia', c.forma),
            (2, 'Derechos', 'Derechos de licencia', c.derechos),
            (3, 'Recargos', 'Recargos por pago tardío', c.recargos_campo),
            (4, 'Derechos 2', 'Derechos adicionales', c.derechos2),
            (5, 'Actualización', 'Actualización de derechos', c.actualizacion)
    ) AS conceptos_tabla(concepto_orden, concepto_nombre, concepto_desc, concepto_importe)
    WHERE concepto_importe > 0  -- Solo mostrar conceptos con importe
    ORDER BY c.id_licencia, c.axo DESC, concepto_orden;
END;
$$;

-- Comentarios sobre el mapeo:
-- cvereq -> usado en ROW_NUMBER() para id_derecho
-- id_licencia -> licencia
-- axo -> ejercicio
-- forma, derechos, recargos, derechos2, actualizacion -> desempaquetados como filas separadas
-- Cada concepto se convierte en una fila independiente
-- Solo se muestran conceptos con importe > 0
