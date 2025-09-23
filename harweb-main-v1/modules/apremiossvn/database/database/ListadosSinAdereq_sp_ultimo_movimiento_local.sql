-- Stored Procedure: sp_ultimo_movimiento_local
-- Tipo: Report
-- Descripción: Devuelve el último movimiento (folio) de un local.
-- Generado para formulario: ListadosSinAdereq
-- Fecha: 2025-08-27 13:58:36

CREATE OR REPLACE FUNCTION sp_ultimo_movimiento_local(
    p_id_local INTEGER
) RETURNS TABLE (
    id_control INTEGER,
    zona SMALLINT,
    modulo SMALLINT,
    control_otr INTEGER,
    folio INTEGER,
    diligencia TEXT,
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    zona_apremio SMALLINT,
    fecha_emision DATE,
    clave_practicado TEXT,
    fecha_practicado DATE,
    fecha_entrega1 DATE,
    fecha_entrega2 DATE,
    fecha_citatorio DATE,
    hora TIMESTAMP,
    ejecutor SMALLINT,
    clave_secuestro SMALLINT,
    clave_remate TEXT,
    fecha_remate DATE,
    porcentaje_multa SMALLINT,
    observaciones TEXT,
    fecha_pago DATE,
    recaudadora SMALLINT,
    caja TEXT,
    operacion INTEGER,
    importe_pago NUMERIC,
    vigencia TEXT,
    fecha_actualiz DATE,
    usuario INTEGER,
    clave_mov TEXT,
    hora_practicado TIMESTAMP,
    vigen TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT *,
        CASE WHEN vigencia='1' THEN 'Vigente' WHEN vigencia='2' THEN 'Pagado' WHEN vigencia='P' THEN 'Pagado' ELSE 'Cancelado' END AS vigen
    FROM ta_15_apremios
    WHERE control_otr = p_id_local AND modulo = 11
    ORDER BY id_control DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;