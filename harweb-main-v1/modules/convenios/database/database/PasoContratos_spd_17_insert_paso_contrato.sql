-- Stored Procedure: spd_17_insert_paso_contrato
-- Tipo: CRUD
-- Descripción: Inserta un registro en la tabla de paso de contratos (ta_17_paso_cont)
-- Generado para formulario: PasoContratos
-- Fecha: 2025-08-27 15:10:36

CREATE OR REPLACE FUNCTION spd_17_insert_paso_contrato(
    consecutivo integer,
    colonia varchar,
    calle varchar,
    folio varchar,
    nombre varchar,
    desc_calle varchar,
    numero varchar,
    tipo varchar,
    mtrs_frente varchar,
    mtrs_ancho varchar,
    metros2 varchar,
    entre_calle_1 varchar,
    entre_calle_2 varchar,
    pago_total varchar,
    pago_inicial varchar,
    pago_quincenal varchar,
    fecha_firma varchar,
    escritura varchar,
    propiedad varchar,
    com_domicilio varchar,
    otros varchar,
    observaciones varchar,
    fecha_imp varchar,
    fecha_rev varchar,
    fecha_canc varchar,
    clave varchar,
    saldoprra varchar,
    mensualidad varchar,
    descuento varchar,
    motivo varchar,
    fecha_inicio varchar,
    fecha_fin varchar,
    saldo_insoluto varchar,
    documentacion varchar,
    impobra_conv varchar,
    recargos_conv varchar,
    clave_historia varchar,
    todo varchar
) RETURNS void AS $$
BEGIN
    INSERT INTO ta_17_paso_cont (
        consecutivo, colonia, calle, folio, nombre, desc_calle, numero, tipo, mtrs_frente, mtrs_ancho, metros2, entre_calle_1, entre_calle_2, pago_total, pago_inicial, pago_quincenal, fecha_firma, escritura, propiedad, com_domicilio, otros, observaciones, fecha_imp, fecha_rev, fecha_canc, clave, saldoprra, mensualidad, descuento, motivo, fecha_inicio, fecha_fin, saldo_insoluto, documentacion, impobra_conv, recargos_conv, clave_historia, todo
    ) VALUES (
        consecutivo, colonia, calle, folio, nombre, desc_calle, numero, tipo, mtrs_frente, mtrs_ancho, metros2, entre_calle_1, entre_calle_2, pago_total, pago_inicial, pago_quincenal, fecha_firma, escritura, propiedad, com_domicilio, otros, observaciones, fecha_imp, fecha_rev, fecha_canc, clave, saldoprra, mensualidad, descuento, motivo, fecha_inicio, fecha_fin, saldo_insoluto, documentacion, impobra_conv, recargos_conv, clave_historia, todo
    );
END;
$$ LANGUAGE plpgsql;