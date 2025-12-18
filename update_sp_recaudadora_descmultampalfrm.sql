-- Actualización del Stored Procedure para descmultampalfrm
-- Usa la tabla descmultampal del esquema public

DROP FUNCTION IF EXISTS publico.recaudadora_descmultampalfrm(TEXT) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_descmultampalfrm(
    p_clave_cuenta TEXT
)
RETURNS TABLE (
    id_multa VARCHAR,
    tipo_descto VARCHAR,
    valor_descuento NUMERIC,
    cvepago VARCHAR,
    fecha_descuento VARCHAR,
    capturista VARCHAR,
    autoriza VARCHAR,
    estado_desc VARCHAR,
    folio VARCHAR,
    observacion TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id_multa::varchar AS id_multa,
        d.tipo_descto::varchar AS tipo_descto,
        d.valor::numeric AS valor_descuento,
        COALESCE(d.cvepago::varchar, '') AS cvepago,
        COALESCE(TO_CHAR(d.feccap, 'YYYY-MM-DD'), '')::varchar AS fecha_descuento,
        COALESCE(TRIM(d.capturista), '')::varchar AS capturista,
        COALESCE(d.autoriza::varchar, '') AS autoriza,
        CASE
            WHEN d.estado = 'P' THEN 'Pagado'::varchar
            WHEN d.estado = 'C' THEN 'Cancelado'::varchar
            WHEN d.estado = 'A' THEN 'Activo'::varchar
            WHEN d.estado = 'V' THEN 'Vigente'::varchar
            ELSE COALESCE(d.estado, 'Desconocido')::varchar
        END AS estado_desc,
        COALESCE(d.folio::varchar, '') AS folio,
        COALESCE(d.observacion, '') AS observacion
    FROM public.descmultampal d
    WHERE d.id_multa::text = p_clave_cuenta
    ORDER BY d.feccap DESC;
END;
$$;

-- Comentarios sobre el mapeo:
-- id_multa -> id_multa (identificador de la multa)
-- tipo_descto -> tipo_descto (tipo de descuento: P=Porcentaje, I=Importe)
-- valor -> valor_descuento (monto o porcentaje del descuento)
-- cvepago -> cvepago (clave de pago asociado)
-- feccap -> fecha_descuento (fecha de captura del descuento)
-- capturista -> capturista (usuario que capturó el descuento)
-- autoriza -> autoriza (quien autorizó el descuento)
-- estado -> estado_desc (P=Pagado, C=Cancelado, A=Activo, V=Vigente)
-- folio -> folio (folio del descuento)
-- observacion -> observacion (observaciones del descuento)
