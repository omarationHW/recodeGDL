-- Stored Procedure: rptfact_merc_get_report
-- Tipo: Report
-- Descripción: Obtiene el reporte de facturación de requerimientos de mercados para una zona y rango de folios.
-- Generado para formulario: RptFact_Merc
-- Fecha: 2025-08-27 14:49:04

CREATE OR REPLACE FUNCTION rptfact_merc_get_report(
    p_rec integer,
    p_fol1 integer,
    p_fol2 integer
)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar(2),
    local smallint,
    letra_local varchar(1),
    bloque varchar(1),
    id_contribuy_prop integer,
    id_contribuy_renta integer,
    nombre varchar(60),
    arrendatario varchar(60),
    domicilio varchar(40),
    sector varchar(1),
    zona smallint,
    descripcion_local varchar(20),
    superficie float8,
    giro smallint,
    fecha_alta date,
    fecha_baja date,
    fecha_modificacion timestamp,
    vigencia varchar(1),
    id_usuario integer,
    clave_cuota smallint,
    id_control integer,
    zona_1 smallint,
    modulo smallint,
    control_otr integer,
    folio integer,
    diligencia varchar(1),
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_gastos numeric,
    zona_apremio smallint,
    fecha_emision date,
    clave_practicado varchar(1),
    fecha_practicado date,
    fecha_entrega1 date,
    fecha_entrega2 date,
    fecha_citatorio date,
    hora timestamp,
    ejecutor smallint,
    clave_secuestro smallint,
    clave_remate varchar(1),
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar(255),
    fecha_pago date,
    recaudadora smallint,
    caja varchar(1),
    operacion integer,
    importe_pago numeric,
    vigencia_1 varchar(1),
    fecha_actualiz date,
    usuario integer,
    clave_mov varchar(2),
    hora_practicado timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque,
           a.id_contribuy_prop, a.id_contribuy_renta, a.nombre, a.arrendatario, a.domicilio, a.sector, a.zona,
           a.descripcion_local, a.superficie, a.giro, a.fecha_alta, a.fecha_baja, a.fecha_modificacion, a.vigencia,
           a.id_usuario, a.clave_cuota, a.id_control, a.zona_1, a.modulo, a.control_otr,
           b.folio, b.diligencia, b.importe_global, b.importe_multa, b.importe_recargo, b.importe_gastos,
           b.zona_apremio, b.fecha_emision, b.clave_practicado, b.fecha_practicado, b.fecha_entrega1, b.fecha_entrega2,
           b.fecha_citatorio, b.hora, b.ejecutor, b.clave_secuestro, b.clave_remate, b.fecha_remate, b.porcentaje_multa,
           b.observaciones, b.fecha_pago, b.recaudadora, b.caja, b.operacion, b.importe_pago, b.vigencia_1,
           b.fecha_actualiz, b.usuario, b.clave_mov, b.hora_practicado
    FROM ta_11_locales a
    JOIN ta_15_apremios b ON a.id_local = b.control_otr
    WHERE b.zona = p_rec
      AND b.folio >= p_fol1
      AND b.folio <= p_fol2;
END;
$$ LANGUAGE plpgsql;