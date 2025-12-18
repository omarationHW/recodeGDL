-- Stored Procedure para autdescto.vue
-- Accede a la tabla aut_desctosotorgados en el esquema public

DROP FUNCTION IF EXISTS publico.recaudadora_autdescto(TEXT) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_autdescto(
    p_clave_cuenta TEXT
)
RETURNS TABLE (
    cuenta TEXT,
    nombre TEXT,
    tipo_descuento TEXT,
    porcentaje NUMERIC,
    monto_descuento NUMERIC,
    fecha_autorizacion TIMESTAMP,
    autorizado_por TEXT,
    estatus TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        ado.id_multa::text AS cuenta,
        COALESCE(ado.datos_descto, 'Sin información')::text AS nombre,
        CASE
            WHEN ado.tipo_descto = 'P' THEN 'Descuento por pronto pago'
            WHEN ado.tipo_descto = 'A' THEN 'Descuento administrativo'
            WHEN ado.tipo_descto = 'E' THEN 'Descuento especial'
            WHEN ado.tipo_descto = 'I' THEN 'Descuento por inspección'
            ELSE COALESCE(ado.tipo_descto, 'Sin especificar')
        END::text AS tipo_descuento,
        COALESCE(ado.por_aut, 0)::numeric AS porcentaje,
        COALESCE(ado.monto_aut, 0)::numeric AS monto_descuento,
        COALESCE(ado.fecha_act, CURRENT_DATE)::timestamp AS fecha_autorizacion,
        COALESCE(TRIM(ado.user_cap), 'SISTEMA')::text AS autorizado_por,
        CASE
            WHEN ado.vigencia = 'S' THEN 'ACTIVO'
            WHEN ado.vigencia = 'N' THEN 'INACTIVO'
            WHEN ado.vigencia = 'B' THEN 'BAJA'
            WHEN ado.vigencia = 'C' THEN 'CANCELADO'
            ELSE 'DESCONOCIDO'
        END::text AS estatus
    FROM public.aut_desctosotorgados ado
    WHERE TRIM(ado.id_multa) = p_clave_cuenta
    ORDER BY ado.fecha_act DESC;
END;
$$;
