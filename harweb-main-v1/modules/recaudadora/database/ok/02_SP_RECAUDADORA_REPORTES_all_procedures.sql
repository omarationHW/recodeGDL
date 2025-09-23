-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO RECAUDADORA - REPORTES ADICIONALES
-- Archivo: 02_SP_RECAUDADORA_REPORTES_all_procedures.sql
-- ============================================

-- SP_RECAUDADORA_CORTE_CAJA - Corte de caja por cajero y turno
CREATE OR REPLACE FUNCTION SP_RECAUDADORA_CORTE_CAJA(
    p_cajero VARCHAR(255),
    p_fecha DATE,
    p_turno VARCHAR(20) DEFAULT NULL
) RETURNS TABLE(
    concepto VARCHAR(50),
    cantidad_recibos INTEGER,
    monto_efectivo NUMERIC(15,2),
    monto_cheque NUMERIC(15,2),
    monto_tarjeta NUMERIC(15,2),
    monto_total NUMERIC(15,2)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.concepto,
        COUNT(*)::INTEGER as cantidad_recibos,
        SUM(CASE WHEN r.forma_pago = 'EFECTIVO' THEN r.monto ELSE 0 END) as monto_efectivo,
        SUM(CASE WHEN r.forma_pago = 'CHEQUE' THEN r.monto ELSE 0 END) as monto_cheque,
        SUM(CASE WHEN r.forma_pago = 'TARJETA' THEN r.monto ELSE 0 END) as monto_tarjeta,
        SUM(r.monto) as monto_total
    FROM public.ingresos r
    WHERE r.cajero = p_cajero 
    AND r.fecha_pago = p_fecha
    AND (p_turno IS NULL OR r.turno = p_turno)
    GROUP BY r.concepto
    ORDER BY monto_total DESC;
END;
$$;