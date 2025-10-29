-- Stored Procedure: sp_get_ingreso_operacion
-- Tipo: CRUD
-- Descripción: Obtiene el ingreso de una operación de caja para validación
-- Generado para formulario: CargaPagMercado
-- Fecha: 2025-08-26 22:58:28

CREATE OR REPLACE FUNCTION sp_get_ingreso_operacion(
    p_fecha_ingreso date,
    p_oficina integer,
    p_caja varchar,
    p_operacion integer,
    p_oficina_mercado integer,
    p_mercado integer
) RETURNS TABLE(
    num_mercado_nvo smallint,
    cuenta_ingreso integer,
    cta_aplicacion integer,
    ingreso numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.num_mercado_nvo, b.cuenta_ingreso, a.cta_aplicacion, COALESCE(SUM(a.importe_cta),0) ingreso
    FROM ta_12_importes a
    JOIN ta_11_mercados b ON b.oficina = p_oficina_mercado AND b.num_mercado_nvo = p_mercado
    WHERE a.fecing = p_fecha_ingreso
      AND a.recing = p_oficina
      AND a.cajing = p_caja
      AND a.opcaja = p_operacion
      AND (a.cta_aplicacion BETWEEN 44501 AND 44588 OR a.cta_aplicacion=44119 OR a.cta_aplicacion=44214)
    GROUP BY b.num_mercado_nvo, b.cuenta_ingreso, a.cta_aplicacion;
END;
$$ LANGUAGE plpgsql;