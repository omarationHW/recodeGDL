-- =====================================================
-- Stored Procedure: recaudadora_sdosfavor_ctrlexp
-- Base de Datos: multas_reglamentos
-- Esquema: publico
-- Descripción: Control de expedientes de saldos a favor
--              Lista solicitudes de saldos a favor
-- =====================================================

-- Eliminar función si existe
DROP FUNCTION IF EXISTS publico.recaudadora_sdosfavor_ctrlexp(VARCHAR);

-- Crear función
CREATE OR REPLACE FUNCTION publico.recaudadora_sdosfavor_ctrlexp(
    p_clave_cuenta VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id_solicitud INTEGER,
    anio_folio INTEGER,
    folio INTEGER,
    cuenta TEXT,
    domicilio TEXT,
    exterior TEXT,
    interior TEXT,
    colonia TEXT,
    cp TEXT,
    telefono TEXT,
    solicitante TEXT,
    estatus TEXT,
    observaciones TEXT,
    fecha_captura TEXT,
    capturista TEXT,
    fecha_termino TEXT,
    inconformidad INTEGER,
    peticionario INTEGER,
    documentos TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.id_solic::INTEGER as id_solicitud,
        COALESCE(s.axofol, 0)::INTEGER as anio_folio,
        COALESCE(s.folio, 0)::INTEGER as folio,
        COALESCE(s.cvecuenta::TEXT, '') as cuenta,
        COALESCE(TRIM(s.domp)::TEXT, '') as domicilio,
        COALESCE(TRIM(s.extp)::TEXT, '') as exterior,
        COALESCE(TRIM(s.intp)::TEXT, '') as interior,
        COALESCE(TRIM(s.colp)::TEXT, '') as colonia,
        COALESCE(s.codp::TEXT, '') as cp,
        COALESCE(s.telefono::TEXT, '') as telefono,
        COALESCE(TRIM(s.solicitante)::TEXT, '') as solicitante,
        CASE
            WHEN TRIM(s.status) = 'P' THEN 'Pendiente'::TEXT
            WHEN TRIM(s.status) = 'T' THEN 'Terminado'::TEXT
            WHEN TRIM(s.status) = 'C' THEN 'Cancelado'::TEXT
            WHEN TRIM(s.status) = 'A' THEN 'Autorizado'::TEXT
            ELSE COALESCE(TRIM(s.status)::TEXT, 'Sin estatus')
        END as estatus,
        COALESCE(s.observaciones::TEXT, '') as observaciones,
        COALESCE(TO_CHAR(s.feccap, 'DD/MM/YYYY'), '') as fecha_captura,
        COALESCE(TRIM(s.capturista)::TEXT, '') as capturista,
        COALESCE(TO_CHAR(s.fecha_termino, 'DD/MM/YYYY'), '') as fecha_termino,
        COALESCE(s.inconf, 0)::INTEGER as inconformidad,
        COALESCE(s.peticionario, 0)::INTEGER as peticionario,
        COALESCE(s.doctos::TEXT, '') as documentos
    FROM public.solic_sdosfavor s
    WHERE 1=1
       AND (p_clave_cuenta IS NULL OR p_clave_cuenta = '' OR s.cvecuenta::TEXT ILIKE '%' || p_clave_cuenta || '%')
    ORDER BY s.id_solic DESC
    LIMIT 100;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION publico.recaudadora_sdosfavor_ctrlexp(VARCHAR) IS
'Control de expedientes de saldos a favor.
Lista solicitudes de saldos a favor de la tabla public.solic_sdosfavor.
Parámetros:
  - p_clave_cuenta: VARCHAR (requerido) - Cuenta del contribuyente a buscar
Retorna tabla con información completa de la solicitud incluyendo:
  - Identificación (id_solicitud, año/folio)
  - Datos de la cuenta
  - Domicilio completo
  - Datos del solicitante
  - Estatus (Pendiente/Terminado/Cancelado/Autorizado)
  - Observaciones
  - Fechas (captura, término)
  - Datos de control (inconformidad, peticionario, documentos)
Límite: 100 registros';

-- Otorgar permisos
GRANT EXECUTE ON FUNCTION publico.recaudadora_sdosfavor_ctrlexp(VARCHAR) TO refact;
GRANT EXECUTE ON FUNCTION publico.recaudadora_sdosfavor_ctrlexp(VARCHAR) TO PUBLIC;
