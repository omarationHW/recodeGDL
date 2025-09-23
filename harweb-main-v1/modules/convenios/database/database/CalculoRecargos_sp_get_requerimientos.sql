-- Stored Procedure: sp_get_requerimientos
-- Tipo: Catalog
-- Descripción: Obtiene los requerimientos (apremios) asociados a un contrato
-- Generado para formulario: CalculoRecargos
-- Fecha: 2025-08-27 13:55:28

CREATE OR REPLACE FUNCTION sp_get_requerimientos(p_id_convenio INTEGER)
RETURNS TABLE(
    id_control INTEGER,
    zona SMALLINT,
    modulo SMALLINT,
    control_otr INTEGER,
    folio INTEGER,
    diligencia VARCHAR,
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    zona_apremio SMALLINT,
    fecha_emision DATE,
    clave_practicado VARCHAR,
    fecha_practicado DATE,
    fecha_entrega1 DATE,
    fecha_entrega2 DATE,
    fecha_citatorio DATE,
    hora TIMESTAMP,
    ejecutor SMALLINT,
    clave_secuestro SMALLINT,
    clave_remate VARCHAR,
    fecha_remate DATE,
    porcentaje_multa SMALLINT,
    observaciones VARCHAR,
    fecha_pago DATE,
    recaudadora SMALLINT,
    caja VARCHAR,
    operacion INTEGER,
    importe_pago NUMERIC,
    vigencia VARCHAR,
    fecha_actualiz DATE,
    usuario INTEGER,
    clave_mov VARCHAR,
    hora_practicado TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta_15_apremios WHERE modulo = 17 AND control_otr = p_id_convenio;
END;
$$ LANGUAGE plpgsql;