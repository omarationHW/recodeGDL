-- =====================================================
-- Stored Procedure: recaudadora_sdosfavor_pagos
-- Base de Datos: multas_reglamentos
-- Esquema: publico
-- Descripción: Consulta de pagos de saldos a favor
--              Lista pagos relacionados con solicitudes de saldos a favor
-- =====================================================

-- Eliminar función si existe
DROP FUNCTION IF EXISTS publico.recaudadora_sdosfavor_pagos(VARCHAR);

-- Crear función
CREATE OR REPLACE FUNCTION publico.recaudadora_sdosfavor_pagos(
    p_clave_cuenta VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id_pago_favor INTEGER,
    cvecuenta INTEGER,
    folio INTEGER,
    ejercicio INTEGER,
    imp_inconform NUMERIC,
    imp_pago NUMERIC,
    saldo_favor NUMERIC,
    fecha_pago TEXT,
    solicitante TEXT,
    status_pago TEXT,
    cvepago INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        ps.id_solic::INTEGER as id_pago_favor,
        s.cvecuenta::INTEGER as cvecuenta,
        COALESCE(s.folio, 0)::INTEGER as folio,
        COALESCE(s.axofol, 0)::INTEGER as ejercicio,
        COALESCE(s.inconf, 0)::NUMERIC as imp_inconform,
        0::NUMERIC as imp_pago,
        0::NUMERIC as saldo_favor,
        COALESCE(TO_CHAR(s.feccap, 'DD/MM/YYYY'), '')::TEXT as fecha_pago,
        COALESCE(TRIM(s.solicitante), '')::TEXT as solicitante,
        CASE
            WHEN TRIM(ps.status) = 'P' THEN 'Pendiente'::TEXT
            WHEN TRIM(ps.status) = 'T' THEN 'Terminado'::TEXT
            WHEN TRIM(ps.status) = 'C' THEN 'Cancelado'::TEXT
            ELSE COALESCE(TRIM(ps.status), 'Sin estado')::TEXT
        END as status_pago,
        ps.cvepago::INTEGER as cvepago
    FROM public.pagos_sdosfavor ps
    LEFT JOIN public.solic_sdosfavor s ON ps.id_solic = s.id_solic
    WHERE 1=1
       AND (p_clave_cuenta IS NULL OR p_clave_cuenta = '' OR s.cvecuenta::TEXT ILIKE '%' || p_clave_cuenta || '%')
    ORDER BY ps.id_solic DESC
    LIMIT 100;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION publico.recaudadora_sdosfavor_pagos(VARCHAR) IS
'Consulta de pagos de saldos a favor.
Lista pagos relacionados con solicitudes de saldos a favor.
Parámetros:
  - p_clave_cuenta: VARCHAR (opcional) - Cuenta del contribuyente a buscar
Retorna tabla con información del pago incluyendo:
  - Identificación (id, cuenta, folio, ejercicio)
  - Importe de inconformidad
  - Solicitante
  - Estado del pago (Pendiente/Terminado/Cancelado)
  - CVE Pago
Nota: Los campos imp_pago y saldo_favor retornan 0 ya que no están disponibles en la tabla actual.
Límite: 100 registros';

-- Otorgar permisos
GRANT EXECUTE ON FUNCTION publico.recaudadora_sdosfavor_pagos(VARCHAR) TO refact;
GRANT EXECUTE ON FUNCTION publico.recaudadora_sdosfavor_pagos(VARCHAR) TO PUBLIC;
