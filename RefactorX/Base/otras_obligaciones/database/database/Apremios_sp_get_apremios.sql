-- Stored Procedure: sp_get_apremios
-- Tipo: Catalog
-- Descripción: Obtiene los registros de apremios filtrados por módulo y control, incluyendo el nombre del ejecutor.
-- Generado para formulario: Apremios
-- Fecha: 2025-08-28 12:35:37

CREATE OR REPLACE FUNCTION sp_get_apremios(par_modulo integer, par_control integer)
RETURNS TABLE (
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
    ejecutor varchar(50),
    clave_secuestro smallint,
    clave_remate char(1),
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar(255)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_control, a.zona, a.folio, a.diligencia,
           a.importe_global, a.importe_multa, a.importe_recargo, a.importe_gastos,
           a.zona_apremio, a.fecha_emision, a.clave_practicado, a.fecha_practicado, a.hora_practicado::time,
           a.fecha_entrega1, a.fecha_entrega2, a.fecha_citatorio, a.hora::time, b.usuario AS ejecutor,
           a.clave_secuestro, a.clave_remate, a.fecha_remate, a.porcentaje_multa, a.observaciones
    FROM ta_15_apremios a
    JOIN ta_12_passwords b ON b.id_usuario = a.ejecutor
    WHERE a.modulo = par_modulo
      AND a.control_otr = par_control
      AND a.vigencia = '1'
      AND a.clave_practicado = 'P';
END;
$$ LANGUAGE plpgsql;