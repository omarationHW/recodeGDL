DROP FUNCTION IF EXISTS recaudadora_resolucion_juez(VARCHAR, INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION recaudadora_resolucion_juez(
    p_clave_cuenta VARCHAR DEFAULT NULL,
    p_folio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    id_resolucion INTEGER,
    folio INTEGER,
    cuenta INTEGER,
    periodo TEXT,
    axo_inicio INTEGER,
    bim_inicio INTEGER,
    axo_fin INTEGER,
    bim_fin INTEGER,
    accesorios TEXT,
    fecha_calcular DATE,
    vigencia TEXT,
    cvepago INTEGER,
    notificaciones_canceladas TEXT,
    observaciones TEXT,
    fecha_alta TIMESTAMP,
    usuario_alta TEXT,
    fecha_baja TIMESTAMP,
    usuario_baja TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id_resolucion,
        r.id_resolucion as folio,
        r.cvecuenta as cuenta,
        CONCAT(r.axoini, '/', r.bimini, ' - ', r.axofin, '/', r.bimfin) as periodo,
        r.axoini as axo_inicio,
        r.bimini as bim_inicio,
        r.axofin as axo_fin,
        r.bimfin as bim_fin,
        CASE
            WHEN r.accesorios = 'C' THEN 'Con accesorios'::TEXT
            WHEN r.accesorios = 'S' THEN 'Sin accesorios'::TEXT
            ELSE COALESCE(r.accesorios::TEXT, 'N/A')
        END as accesorios,
        r.fecha_calcular,
        CASE
            WHEN r.vigencia = 'V' THEN 'Vigente'::TEXT
            WHEN r.vigencia = 'C' THEN 'Cancelado'::TEXT
            WHEN r.vigencia = 'A' THEN 'Activo'::TEXT
            ELSE COALESCE(r.vigencia::TEXT, 'Sin estatus')
        END as vigencia,
        r.cvepago,
        COALESCE(r.not_canceladas::TEXT, '') as notificaciones_canceladas,
        COALESCE(r.observaciones::TEXT, '') as observaciones,
        r.fecha_alta,
        COALESCE(TRIM(r.usuario_alta)::TEXT, '') as usuario_alta,
        r.fecha_baja,
        COALESCE(TRIM(r.usuario_baja)::TEXT, '') as usuario_baja
    FROM catastro_gdl.resolucion_juez r
    WHERE 1=1
       AND (p_clave_cuenta IS NULL OR p_clave_cuenta = '' OR r.cvecuenta::TEXT ILIKE '%' || p_clave_cuenta || '%')
       AND (p_folio IS NULL OR p_folio = 0 OR r.id_resolucion = p_folio)
    ORDER BY r.id_resolucion DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;
