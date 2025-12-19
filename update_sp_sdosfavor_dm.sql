-- =====================================================
-- Stored Procedure: recaudadora_sdosfavor_dm
-- Base de Datos: multas_reglamentos
-- Esquema: publico
-- Descripción: Consulta de saldos a favor (Derechos Municipales)
--              Lista saldos a favor con su estado y aplicaciones
-- =====================================================

-- Eliminar función si existe
DROP FUNCTION IF EXISTS publico.recaudadora_sdosfavor_dm(VARCHAR);

-- Crear función
CREATE OR REPLACE FUNCTION publico.recaudadora_sdosfavor_dm(
    p_clave_cuenta VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    cvecuenta INTEGER,
    id_convenio INTEGER,
    folio TEXT,
    saldo_inicial NUMERIC,
    importe_aplicado NUMERIC,
    saldo_restante NUMERIC,
    fecha_alta DATE,
    fecha_cancelacion DATE,
    usuario_alta TEXT,
    usuario_cancelacion TEXT,
    estado TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.cvecuenta,
        s.id_convenio,
        TRIM(s.folio)::TEXT as folio,
        s.saldoinicial as saldo_inicial,
        s.importeaplicado as importe_aplicado,
        (s.saldoinicial - s.importeaplicado) as saldo_restante,
        s.fechaalta as fecha_alta,
        s.fechacan as fecha_cancelacion,
        TRIM(s.usu_alta)::TEXT as usuario_alta,
        TRIM(s.usu_can)::TEXT as usuario_cancelacion,
        CASE
            WHEN s.fechacan IS NOT NULL THEN 'Cancelado'::TEXT
            WHEN (s.saldoinicial - s.importeaplicado) > 0 THEN 'Pendiente'::TEXT
            WHEN (s.saldoinicial - s.importeaplicado) = 0 THEN 'Liquidado'::TEXT
            ELSE 'Aplicado'::TEXT
        END as estado
    FROM public.saldosafavor s
    WHERE (p_clave_cuenta IS NULL OR p_clave_cuenta = '' OR s.cvecuenta::TEXT ILIKE '%' || p_clave_cuenta || '%')
    ORDER BY s.cvecuenta DESC
    LIMIT 100;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION publico.recaudadora_sdosfavor_dm(VARCHAR) IS
'Consulta de saldos a favor (Derechos Municipales).
Lista saldos a favor de la tabla public.saldosafavor.
Parámetros:
  - p_clave_cuenta: VARCHAR (opcional) - Cuenta del contribuyente a buscar
Retorna tabla con información completa del saldo incluyendo:
  - Identificación (cuenta, convenio, folio)
  - Montos (saldo inicial, importe aplicado, saldo restante)
  - Estado (Pendiente/Liquidado/Cancelado/Aplicado)
  - Fechas (alta, cancelación)
  - Usuarios (alta, cancelación)
Límite: 100 registros';

-- Otorgar permisos
GRANT EXECUTE ON FUNCTION publico.recaudadora_sdosfavor_dm(VARCHAR) TO refact;
GRANT EXECUTE ON FUNCTION publico.recaudadora_sdosfavor_dm(VARCHAR) TO PUBLIC;
