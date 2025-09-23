-- Stored Procedure: sp_update_apremio
-- Tipo: CRUD
-- Descripción: Actualiza un registro de apremio existente.
-- Generado para formulario: Apremios
-- Fecha: 2025-08-28 12:35:37

CREATE OR REPLACE FUNCTION sp_update_apremio(
    id_control integer,
    zona smallint,
    folio integer,
    diligencia char(1),
    importe_global numeric(15,2),
    importe_multa numeric(15,2),
    importe_recargo numeric(15,2),
    importe_gastos numeric(15,2),
    zona_apremio smallint,
    fecha_emision date,
    clave_practicado char(1),
    fecha_practicado date,
    hora_practicado time,
    fecha_entrega1 date,
    fecha_entrega2 date,
    fecha_citatorio date,
    hora time,
    ejecutor integer,
    clave_secuestro smallint,
    clave_remate char(1),
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar(255),
    modulo integer,
    control_otr integer
) RETURNS SETOF ta_15_apremios AS $$
BEGIN
    UPDATE ta_15_apremios SET
        zona = zona,
        folio = folio,
        diligencia = diligencia,
        importe_global = importe_global,
        importe_multa = importe_multa,
        importe_recargo = importe_recargo,
        importe_gastos = importe_gastos,
        zona_apremio = zona_apremio,
        fecha_emision = fecha_emision,
        clave_practicado = clave_practicado,
        fecha_practicado = fecha_practicado,
        hora_practicado = hora_practicado,
        fecha_entrega1 = fecha_entrega1,
        fecha_entrega2 = fecha_entrega2,
        fecha_citatorio = fecha_citatorio,
        hora = hora,
        ejecutor = ejecutor,
        clave_secuestro = clave_secuestro,
        clave_remate = clave_remate,
        fecha_remate = fecha_remate,
        porcentaje_multa = porcentaje_multa,
        observaciones = observaciones,
        modulo = modulo,
        control_otr = control_otr
    WHERE id_control = id_control;
    RETURN QUERY SELECT * FROM ta_15_apremios WHERE id_control = id_control;
END;
$$ LANGUAGE plpgsql;