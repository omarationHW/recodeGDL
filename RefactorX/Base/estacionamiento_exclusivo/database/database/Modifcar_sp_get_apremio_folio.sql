-- =====================================================
-- SP: sp_get_apremio_folio
-- Descripción: Obtiene un apremio específico por folio
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- =====================================================

CREATE OR REPLACE FUNCTION sp_get_apremio_folio(
    p_folio VARCHAR(50)
)
RETURNS TABLE (
    id_control INTEGER,
    zona SMALLINT,
    modulo SMALLINT,
    control_otr INTEGER,
    folio INTEGER,
    diligencia VARCHAR,
    importe_global NUMERIC(12,2),
    importe_multa NUMERIC(12,2),
    importe_recargo NUMERIC(12,2),
    importe_gastos NUMERIC(12,2),
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
    importe_pago NUMERIC(12,2),
    vigencia VARCHAR,
    fecha_actualiz DATE,
    usuario INTEGER,
    clave_mov VARCHAR,
    datos VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_control,
        a.zona,
        a.modulo,
        a.control_otr,
        a.folio,
        a.diligencia,
        a.importe_global,
        a.importe_multa,
        a.importe_recargo,
        a.importe_gastos,
        a.zona_apremio,
        a.fecha_emision,
        a.clave_practicado,
        a.fecha_practicado,
        a.fecha_entrega1,
        a.fecha_entrega2,
        a.fecha_citatorio,
        a.hora,
        a.ejecutor,
        a.clave_secuestro,
        a.clave_remate,
        a.fecha_remate,
        a.porcentaje_multa,
        a.observaciones,
        a.fecha_pago,
        a.recaudadora,
        a.caja,
        a.operacion,
        a.importe_pago,
        a.vigencia,
        a.fecha_actualiz,
        a.usuario,
        a.clave_mov,
        a.datos
    FROM ta_15_apremios a
    WHERE a.folio::VARCHAR = p_folio
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Ejemplo de uso:
-- SELECT * FROM sp_get_apremio_folio('12345');
-- SELECT folio, importe_global, vigencia FROM sp_get_apremio_folio('98765');
