-- Stored Procedure: sp_get_requerimientos_by_local
-- Tipo: Catalog
-- Descripción: Obtiene los requerimientos de un local por módulo y control_otr
-- Generado para formulario: ConsRequerimientos
-- Fecha: 2025-08-26 23:23:01

CREATE OR REPLACE FUNCTION sp_get_requerimientos_by_local(
    p_modulo smallint,
    p_control_otr integer
)
RETURNS TABLE (
    id_control integer,
    modulo smallint,
    control_otr integer,
    folio integer,
    diligencia varchar,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_gastos numeric,
    fecha_emision date,
    clave_practicado varchar,
    vigencia varchar,
    fecha_actualiz date,
    usuario integer,
    id_usuario integer,
    usuario_1 varchar,
    nombre varchar,
    estado varchar,
    id_rec smallint,
    nivel smallint,
    zona smallint,
    zona_apremio smallint,
    fecha_practicado date,
    fecha_entrega1 date,
    fecha_entrega2 date,
    fecha_citatorio date,
    hora timestamp,
    ejecutor smallint,
    clave_secuestro smallint,
    clave_remate varchar,
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar,
    fecha_pago date,
    recaudadora smallint,
    caja varchar,
    operacion integer,
    importe_pago numeric,
    clave_mov varchar,
    hora_practicado timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_control, a.modulo, a.control_otr, a.folio, a.diligencia, a.importe_global, a.importe_multa, a.importe_recargo, a.importe_gastos,
           a.fecha_emision, a.clave_practicado, a.vigencia, a.fecha_actualiz, a.usuario, b.id_usuario, b.usuario, b.nombre, b.estado, b.id_rec, b.nivel,
           a.zona, a.zona_apremio, a.fecha_practicado, a.fecha_entrega1, a.fecha_entrega2, a.fecha_citatorio, a.hora, a.ejecutor, a.clave_secuestro,
           a.clave_remate, a.fecha_remate, a.porcentaje_multa, a.observaciones, a.fecha_pago, a.recaudadora, a.caja, a.operacion, a.importe_pago,
           a.clave_mov, a.hora_practicado
    FROM ta_15_apremios a
    JOIN ta_12_passwords b ON a.usuario = b.id_usuario
    WHERE a.modulo = p_modulo AND a.control_otr = p_control_otr
    ORDER BY a.fecha_emision, a.folio;
END;
$$ LANGUAGE plpgsql;