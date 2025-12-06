-- Stored Procedure: sp_get_requerimientos
-- Tipo: Catalog
-- Descripción: Obtiene los datos de requerimiento por modulo, folio y control_otr
-- Generado para formulario: DatosRequerimientos
-- Fecha: 2025-08-26 23:47:56

DROP FUNCTION IF EXISTS sp_get_requerimientos(smallint, integer, integer);

CREATE OR REPLACE FUNCTION sp_get_requerimientos(p_modulo smallint, p_folio integer, p_control_otr integer)
RETURNS TABLE (
    id_control integer,
    modulo smallint,
    control_otr integer,
    folio integer,
    diligencia char(1),
    importe_global numeric(16,2),
    importe_multa numeric(16,2),
    importe_recargo numeric(16,2),
    importe_gastos numeric(16,2),
    fecha_emision date,
    clave_practicado char(1),
    vigencia char(1),
    fecha_actualiz date,
    usuario integer,
    id integer,
    usuario_1 varchar(20),
    nombre varchar(100),
    estado char(1),
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
    clave_remate char(1),
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar(13055),
    fecha_pago date,
    recaudadora smallint,
    caja char(2),
    operacion integer,
    importe_pago numeric(16,2),
    clave_mov char(2),
    hora_practicado timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_control, a.modulo, a.control_otr, a.folio, a.diligencia,
           a.importe_global, a.importe_multa, a.importe_recargo, a.importe_gastos,
           a.fecha_emision, a.clave_practicado, a.vigencia, a.fecha_actualiz,
           a.usuario, b.id, b.usuario as usuario_1, b.nombre, b.estado, b.id_rec, b.nivel,
           a.zona, a.zona_apremio, a.fecha_practicado, a.fecha_entrega1, a.fecha_entrega2,
           a.fecha_citatorio, a.hora, a.ejecutor, a.clave_secuestro, a.clave_remate,
           a.fecha_remate, a.porcentaje_multa, a.observaciones, a.fecha_pago,
           a.recaudadora, a.caja, a.operacion, a.importe_pago, a.clave_mov, a.hora_practicado
    FROM publico.ta_15_apremios a
    LEFT JOIN public.usuarios b ON a.usuario = b.id
    WHERE a.modulo = p_modulo AND a.folio = p_folio AND a.control_otr = p_control_otr;
END;
$$ LANGUAGE plpgsql;