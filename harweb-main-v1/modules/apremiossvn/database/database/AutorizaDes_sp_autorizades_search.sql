-- Stored Procedure: sp_autorizades_search
-- Tipo: CRUD
-- Descripción: Busca folio de requerimiento y devuelve datos, incluyendo descuentos autorizados vigentes.
-- Generado para formulario: AutorizaDes
-- Fecha: 2025-08-27 13:32:56

CREATE OR REPLACE FUNCTION sp_autorizades_search(
    p_folio INTEGER,
    p_id_rec INTEGER,
    p_id_modulo INTEGER,
    p_usuario_id INTEGER
) RETURNS TABLE (
    id_control INTEGER,
    zona INTEGER,
    modulo INTEGER,
    control_otr INTEGER,
    folio INTEGER,
    diligencia TEXT,
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    zona_apremio INTEGER,
    fecha_emision DATE,
    clave_practicado TEXT,
    fecha_practicado DATE,
    fecha_entrega1 DATE,
    fecha_entrega2 DATE,
    fecha_citatorio DATE,
    hora TIMESTAMP,
    ejecutor INTEGER,
    clave_secuestro INTEGER,
    clave_remate TEXT,
    fecha_remate DATE,
    porcentaje_multa INTEGER,
    observaciones TEXT,
    fecha_pago DATE,
    recaudadora INTEGER,
    caja TEXT,
    operacion INTEGER,
    importe_pago NUMERIC,
    vigencia TEXT,
    fecha_actualiz DATE,
    usuario INTEGER,
    clave_mov TEXT,
    hora_practicado TIMESTAMP,
    datos TEXT,
    autorizados JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_control, a.zona, a.modulo, a.control_otr, a.folio, a.diligencia, a.importe_global, a.importe_multa, a.importe_recargo, a.importe_gastos, a.zona_apremio, a.fecha_emision, a.clave_practicado, a.fecha_practicado, a.fecha_entrega1, a.fecha_entrega2, a.fecha_citatorio, a.hora, a.ejecutor, a.clave_secuestro, a.clave_remate, a.fecha_remate, a.porcentaje_multa, a.observaciones, a.fecha_pago, a.recaudadora, a.caja, a.operacion, a.importe_pago, a.vigencia, a.fecha_actualiz, a.usuario, a.clave_mov, a.hora_practicado,
        -- datos: concatenación según modulo
        CASE 
            WHEN a.modulo = 16 THEN 'No. Contrato ' || coalesce(ta_16_tipo_aseo.tipo_aseo,'') || '-' || coalesce(ta_16_contratos.num_contrato::text,'')
            WHEN a.modulo = 11 THEN 'Mercado No. ' || coalesce(ta_11_locales.num_mercado::text,'') || ' Categoria ' || coalesce(ta_11_locales.categoria::text,'') || ' Secc. ' || coalesce(ta_11_locales.seccion,'') || ' Local ' || coalesce(ta_11_locales.local::text,'') || '-' || coalesce(ta_11_locales.letra_local,'') || '-' || coalesce(ta_11_locales.bloque,'')
            WHEN a.modulo = 24 THEN 'Estacionamiento Publico No. ' || coalesce(pubmain.numesta::text,'')
            WHEN a.modulo = 28 THEN 'Estacionamiento Exclusivo No. ' || coalesce(ex_contrato.no_exclusivo::text,'')
            WHEN a.modulo = 14 THEN 'Placa No. ' || coalesce(ta_padron.placa,'')
            WHEN a.modulo = 13 THEN 'Folio: ' || coalesce(ta_13_datosrcm.control_rcm::text,'') || ' Cementerio:' || coalesce(ta_13_datosrcm.cementerio,'') || ' C-' || coalesce(ta_13_datosrcm.clase::text,'') || ' ' || coalesce(ta_13_datosrcm.clase_alfa,'') || ' S-' || coalesce(ta_13_datosrcm.seccion::text,'') || ' ' || coalesce(ta_13_datosrcm.seccion_alfa,'') || ' L-' || coalesce(ta_13_datosrcm.linea::text,'') || ' ' || coalesce(ta_13_datosrcm.linea_alfa,'') || ' F-' || coalesce(ta_13_datosrcm.fosa::text,'') || ' ' || coalesce(ta_13_datosrcm.fosa_alfa,'')
            ELSE NULL
        END as datos,
        (
            SELECT jsonb_agg(row_to_json(aut)) FROM (
                SELECT aut.*, q.quien, q.porcentajetope FROM ta_15_autorizados aut
                LEFT JOIN ta_15_quienautor q ON q.cveaut = aut.cveaut
                WHERE aut.control = a.id_control AND aut.estado <> 3
            ) aut
        ) as autorizados
    FROM ta_15_apremios a
    LEFT JOIN ta_16_contratos ON a.modulo = 16 AND a.control_otr = ta_16_contratos.control_contrato
    LEFT JOIN ta_16_tipo_aseo ON ta_16_contratos.ctrol_aseo = ta_16_tipo_aseo.ctrol_aseo
    LEFT JOIN ta_11_locales ON a.modulo = 11 AND a.control_otr = ta_11_locales.id_local
    LEFT JOIN pubmain ON a.modulo = 24 AND a.control_otr = pubmain.id
    LEFT JOIN ex_contrato ON a.modulo = 28 AND a.control_otr = ex_contrato.id
    LEFT JOIN ta_padron ON a.modulo = 14 AND a.control_otr = ta_padron.id
    LEFT JOIN ta_13_datosrcm ON a.modulo = 13 AND a.control_otr = ta_13_datosrcm.control_rcm
    WHERE a.zona = p_id_rec AND a.modulo = p_id_modulo AND a.folio = p_folio AND a.vigencia = '1' AND a.clave_practicado = 'P';
END;
$$ LANGUAGE plpgsql;