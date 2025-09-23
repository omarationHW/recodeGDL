-- Stored Procedure: sp_get_convenios_by_range
-- Tipo: Report
-- Descripción: Obtiene los convenios por rango de fechas
-- Generado para formulario: consmulconv
-- Fecha: 2025-08-26 23:27:45

CREATE OR REPLACE FUNCTION sp_get_convenios_by_range(p_fecha_inicio DATE, p_fecha_fin DATE)
RETURNS TABLE(
    id_conv_diver INTEGER,
    letras_exp VARCHAR,
    axo_exp INTEGER,
    numero_exp INTEGER,
    referencia VARCHAR,
    axo_desde INTEGER,
    bim_desde INTEGER,
    axo_hasta INTEGER,
    bim_hasta INTEGER,
    impuesto NUMERIC,
    recargos NUMERIC,
    gastos NUMERIC,
    multa NUMERIC,
    total NUMERIC,
    nombre VARCHAR,
    fecha_inicio DATE,
    fecha_venc DATE,
    vigencia VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id_conv_diver,
        c.letras_exp,
        c.axo_exp,
        c.numero_exp,
        c.referencia,
        c.axo_desde,
        c.bim_desde,
        c.axo_hasta,
        c.bim_hasta,
        c.impuesto,
        c.recargos,
        c.gastos,
        c.multa,
        c.total,
        c.nombre,
        c.fecha_inicio,
        c.fecha_venc,
        c.vigencia
    FROM convenios c
    WHERE c.fecha_inicio >= p_fecha_inicio
      AND c.fecha_venc <= p_fecha_fin;
END;
$$ LANGUAGE plpgsql;