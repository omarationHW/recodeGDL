-- Stored Procedure: sp_get_requerimientos_abastos
-- Tipo: Report
-- Descripción: Obtiene los requerimientos (apremios) asociados a un local para abastos.
-- Generado para formulario: RptEmisionRbosAbastos
-- Fecha: 2025-08-27 00:59:26
-- CORREGIDO: Esquemas cross-database según postgreok.csv

CREATE OR REPLACE FUNCTION public.sp_get_requerimientos_abastos(
    p_id_local integer
) RETURNS TABLE (
    id_control integer,
    modulo integer,
    control_otr integer,
    folio integer,
    diligencia text,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_gastos numeric,
    fecha_emision date,
    clave_practicado text,
    vigencia text,
    fecha_actualiz date,
    usuario integer,
    observaciones text
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_control::INTEGER,
        a.modulo::INTEGER,
        a.control_otr::INTEGER,
        a.folio::INTEGER,
        a.diligencia::TEXT,
        a.importe_global::NUMERIC,
        a.importe_multa::NUMERIC,
        a.importe_recargo::NUMERIC,
        a.importe_gastos::NUMERIC,
        a.fecha_emision::DATE,
        a.clave_practicado::TEXT,
        a.vigencia::TEXT,
        a.fecha_actualiz::DATE,
        a.usuario::INTEGER,
        a.observaciones::TEXT
    FROM publico.ta_15_apremios a
    WHERE a.modulo = 11 AND a.control_otr = p_id_local AND a.vigencia = '1' AND a.clave_practicado = 'P'
    ORDER BY a.folio;
END;
$$ LANGUAGE plpgsql;
