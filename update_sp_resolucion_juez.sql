-- =====================================================
-- Stored Procedure: recaudadora_resolucion_juez
-- Base de Datos: multas_reglamentos
-- Esquema: publico
-- Descripción: Consultar resoluciones de juez
--              Lista resoluciones judiciales sobre prediales
-- =====================================================

-- Eliminar función si existe
DROP FUNCTION IF EXISTS publico.recaudadora_resolucion_juez(VARCHAR, INTEGER);

-- Crear función
CREATE OR REPLACE FUNCTION publico.recaudadora_resolucion_juez(
    p_clave_cuenta VARCHAR DEFAULT NULL,
    p_folio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    id_resolucion INTEGER,
    folio INTEGER,
    cuenta TEXT,
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
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id_resolucion,
        r.id_resolucion as folio,
        COALESCE(r.cvecuenta::TEXT, '') as cuenta,
        CONCAT(COALESCE(r.axoini::TEXT, ''), '/', COALESCE(r.bimini::TEXT, ''), ' - ',
               COALESCE(r.axofin::TEXT, ''), '/', COALESCE(r.bimfin::TEXT, '')) as periodo,
        COALESCE(r.axoini, 0) as axo_inicio,
        COALESCE(r.bimini, 0) as bim_inicio,
        COALESCE(r.axofin, 0) as axo_fin,
        COALESCE(r.bimfin, 0) as bim_fin,
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
            WHEN r.vigencia = 'P' THEN 'Pendiente'::TEXT
            ELSE COALESCE(r.vigencia::TEXT, 'Sin estatus')
        END as vigencia,
        COALESCE(r.cvepago, 0) as cvepago,
        COALESCE(r.not_canceladas::TEXT, '') as notificaciones_canceladas,
        COALESCE(r.observaciones::TEXT, '') as observaciones,
        r.fecha_alta,
        COALESCE(TRIM(r.usuario_alta)::TEXT, '') as usuario_alta,
        r.fecha_baja,
        COALESCE(TRIM(r.usuario_baja)::TEXT, '') as usuario_baja
    FROM public.resolucion_juez r
    WHERE 1=1
       AND (p_clave_cuenta IS NULL OR p_clave_cuenta = '' OR r.cvecuenta::TEXT ILIKE '%' || p_clave_cuenta || '%')
       AND (p_folio IS NULL OR p_folio = 0 OR r.id_resolucion = p_folio)
    ORDER BY r.id_resolucion DESC
    LIMIT 100;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION publico.recaudadora_resolucion_juez(VARCHAR, INTEGER) IS
'Consultar resoluciones de juez sobre impuesto predial.
Lista resoluciones judiciales de la tabla public.resolucion_juez.
Parámetros:
  - p_clave_cuenta: VARCHAR (opcional) - Cuenta a buscar
  - p_folio: INTEGER (opcional) - Folio/ID de la resolución (0 o NULL = todos)
Retorna tabla con información completa de la resolución incluyendo:
  - Identificación (id_resolucion, folio, cuenta)
  - Periodo (años y bimestres inicial y final)
  - Accesorios (Con/Sin)
  - Fecha de cálculo
  - Vigencia (Vigente/Cancelado/Activo/Pendiente)
  - CVE Pago
  - Notificaciones canceladas
  - Observaciones
  - Auditoría (fechas y usuarios de alta/baja)
Límite: 100 registros';

-- Otorgar permisos
GRANT EXECUTE ON FUNCTION publico.recaudadora_resolucion_juez(VARCHAR, INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION publico.recaudadora_resolucion_juez(VARCHAR, INTEGER) TO PUBLIC;
