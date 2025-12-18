-- Actualización del Stored Procedure para DescDerechosMerc
-- Usa la tabla ta_11_descderechos del esquema public

DROP FUNCTION IF EXISTS publico.recaudadora_descderechos_merc(TEXT, INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_descderechos_merc(
    p_clave_cuenta TEXT DEFAULT '',
    p_ejercicio INTEGER DEFAULT 0
)
RETURNS TABLE (
    id INTEGER,
    clave_cuenta VARCHAR,
    descuento NUMERIC,
    desde DATE,
    hasta DATE,
    estatus VARCHAR,
    ejercicio INTEGER,
    observaciones TEXT,
    fecha_registro TIMESTAMP
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id_descuento AS id,
        d.id_local::varchar AS clave_cuenta,
        d.porcentaje::numeric AS descuento,
        -- Construir fecha desde (año y mes inicial)
        CASE
            WHEN d.axoini IS NOT NULL AND d.mesini IS NOT NULL THEN
                MAKE_DATE(d.axoini, d.mesini, 1)
            ELSE NULL
        END AS desde,
        -- Construir fecha hasta (año y mes final, último día del mes)
        CASE
            WHEN d.axofin IS NOT NULL AND d.mesfin IS NOT NULL THEN
                (MAKE_DATE(d.axofin, d.mesfin, 1) + INTERVAL '1 month - 1 day')::date
            ELSE NULL
        END AS hasta,
        -- Mapear estado a texto descriptivo
        CASE
            WHEN d.estado = 'P' THEN 'Pagado'::varchar
            WHEN d.estado = 'C' THEN 'Cancelado'::varchar
            WHEN d.estado = 'A' THEN 'Activo'::varchar
            WHEN d.estado = 'V' THEN 'Vigente'::varchar
            ELSE 'Desconocido'::varchar
        END AS estatus,
        -- Ejercicio (usar año inicial como referencia)
        d.axoini AS ejercicio,
        -- Observaciones (construir a partir de datos disponibles)
        CONCAT(
            'Descuento del ', d.porcentaje, '% autorizado por usuario: ', COALESCE(d.autoriza::text, 'N/A'),
            CASE WHEN d.id_pago IS NOT NULL THEN '. Pago ID: ' || d.id_pago::text ELSE '' END,
            CASE WHEN d.fecha_baja IS NOT NULL THEN '. Dado de baja por: ' || COALESCE(d.usu_baja, 'N/A') ELSE '' END
        )::text AS observaciones,
        -- Fecha de registro
        COALESCE(d.fecha_alta, CURRENT_TIMESTAMP)::timestamp AS fecha_registro
    FROM public.ta_11_descderechos d
    WHERE
        (p_clave_cuenta = '' OR d.id_local::text = p_clave_cuenta)
        AND (p_ejercicio = 0 OR d.axoini = p_ejercicio OR d.axofin = p_ejercicio)
    ORDER BY d.axoini DESC, d.mesini DESC;
END;
$$;

-- Comentarios sobre el mapeo:
-- id_descuento -> id
-- id_local -> clave_cuenta (identificador del local comercial en el mercado)
-- porcentaje -> descuento (porcentaje de descuento aplicado)
-- axoini + mesini -> desde (fecha inicial del descuento)
-- axofin + mesfin -> hasta (fecha final del descuento)
-- estado -> estatus (P=Pagado, C=Cancelado, A=Activo, V=Vigente)
-- axoini -> ejercicio (año de referencia)
-- autoriza, id_pago, usu_baja -> observaciones (información adicional)
-- fecha_alta -> fecha_registro
