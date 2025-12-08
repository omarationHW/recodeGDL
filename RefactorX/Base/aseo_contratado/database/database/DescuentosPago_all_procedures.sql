-- =============================================
-- Aseo Contratado - DescuentosPago Module
-- Stored Procedures for Payment Discounts Management
-- Database: aseo_contratado
-- Schema: public
-- =============================================

-- =============================================
-- Function: descuentospago_sp_get_config
-- Description: Get payment discount configuration
-- =============================================
CREATE OR REPLACE FUNCTION public.descuentospago_sp_get_config()
RETURNS TABLE (
    id_config INTEGER,
    descripcion VARCHAR,
    porcentaje_descuento NUMERIC(5,2),
    meses_anticipados SMALLINT,
    fecha_inicio DATE,
    fecha_fin DATE,
    activo CHAR(1),
    fecha_registro TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        1 as id_config,
        'Descuento por Pago Anticipado' as descripcion,
        10.00 as porcentaje_descuento,
        3::SMALLINT as meses_anticipados,
        CURRENT_DATE as fecha_inicio,
        CURRENT_DATE + INTERVAL '6 months' as fecha_fin,
        'S'::CHAR(1) as activo,
        CURRENT_TIMESTAMP as fecha_registro;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- Function: descuentospago_sp_calcular_descuento
-- Description: Calculate discount for payment
-- =============================================
CREATE OR REPLACE FUNCTION public.descuentospago_sp_calcular_descuento(
    p_control_contrato INTEGER,
    p_monto_pago NUMERIC(12,2),
    p_meses_adelantados SMALLINT
)
RETURNS TABLE (
    monto_original NUMERIC(12,2),
    porcentaje_descuento NUMERIC(5,2),
    monto_descuento NUMERIC(12,2),
    monto_final NUMERIC(12,2)
) AS $$
DECLARE
    v_porcentaje NUMERIC(5,2);
BEGIN
    -- Determine discount percentage based on months paid in advance
    v_porcentaje := CASE
        WHEN p_meses_adelantados >= 12 THEN 15.00
        WHEN p_meses_adelantados >= 6 THEN 10.00
        WHEN p_meses_adelantados >= 3 THEN 5.00
        ELSE 0.00
    END;

    RETURN QUERY
    SELECT
        p_monto_pago as monto_original,
        v_porcentaje as porcentaje_descuento,
        ROUND(p_monto_pago * v_porcentaje / 100, 2) as monto_descuento,
        ROUND(p_monto_pago - (p_monto_pago * v_porcentaje / 100), 2) as monto_final;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.descuentospago_sp_get_config() IS 'Get payment discount configuration - RefactorX Aseo Contratado';
COMMENT ON FUNCTION public.descuentospago_sp_calcular_descuento(INTEGER, NUMERIC, SMALLINT) IS 'Calculate payment discount - RefactorX Aseo Contratado';
