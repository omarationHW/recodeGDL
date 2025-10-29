-- Stored Procedure: sp_cons_contratos_get_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle completo de un contrato por id_convenio
-- Generado para formulario: ConsContratos
-- Fecha: 2025-08-27 14:09:01

CREATE OR REPLACE FUNCTION sp_cons_contratos_get_detalle(p_id_convenio integer)
RETURNS TABLE(
    id_convenio integer,
    colonia smallint,
    calle smallint,
    folio integer,
    nombre varchar,
    desc_calle varchar,
    numero varchar,
    tipo_casa varchar,
    mtrs_frente float,
    mtrs_ancho float,
    metros2 float,
    entre_calle_1 varchar,
    entre_calle_2 varchar,
    pago_total numeric,
    pago_inicial numeric,
    pago_quincenal numeric,
    pagos_parciales smallint,
    fecha_firma date,
    fecha_vencimiento date,
    escritura varchar,
    propiedad varchar,
    compro_dom varchar,
    otros varchar,
    observacion varchar,
    fecha_impresion date,
    fecha_rev date,
    fecha_cancelado date,
    vigencia varchar,
    id_usuario integer,
    fecha_actual timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta_17_convenios WHERE id_convenio = p_id_convenio;
END;
$$ LANGUAGE plpgsql;