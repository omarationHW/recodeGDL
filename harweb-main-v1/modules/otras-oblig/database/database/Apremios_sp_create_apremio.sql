-- Stored Procedure: sp_create_apremio
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de apremio.
-- Generado para formulario: Apremios
-- Fecha: 2025-08-28 12:35:37

CREATE OR REPLACE FUNCTION sp_create_apremio(
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
DECLARE
    new_id integer;
BEGIN
    INSERT INTO ta_15_apremios (
        zona, folio, diligencia, importe_global, importe_multa, importe_recargo, importe_gastos,
        zona_apremio, fecha_emision, clave_practicado, fecha_practicado, hora_practicado,
        fecha_entrega1, fecha_entrega2, fecha_citatorio, hora, ejecutor, clave_secuestro,
        clave_remate, fecha_remate, porcentaje_multa, observaciones, modulo, control_otr, vigencia
    ) VALUES (
        zona, folio, diligencia, importe_global, importe_multa, importe_recargo, importe_gastos,
        zona_apremio, fecha_emision, clave_practicado, fecha_practicado, hora_practicado,
        fecha_entrega1, fecha_entrega2, fecha_citatorio, hora, ejecutor, clave_secuestro,
        clave_remate, fecha_remate, porcentaje_multa, observaciones, modulo, control_otr, '1'
    ) RETURNING id_control INTO new_id;
    RETURN QUERY SELECT * FROM ta_15_apremios WHERE id_control = new_id;
END;
$$ LANGUAGE plpgsql;