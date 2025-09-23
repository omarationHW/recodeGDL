-- Stored Procedure: rptreq_merc_reporte
-- Tipo: Report
-- Descripción: Obtiene el reporte de requerimiento de pago y embargo para mercados, filtrando por oficina y rango de folios.
-- Generado para formulario: RptReq_Merc
-- Fecha: 2025-08-27 15:08:39

CREATE OR REPLACE FUNCTION rptreq_merc_reporte(
    p_ofna integer,
    p_folio1 integer,
    p_folio2 integer
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
    descripcion_local varchar(40),
    superficie float,
    giro smallint,
    fecha_alta date,
    fecha_baja date,
    fecha_modificacion timestamp,
    vigencia varchar(1),
    id_usuario integer,
    clave_cuota smallint,
    descripcion varchar(60),
    id_control integer,
    zona_1 smallint,
    modulo smallint,
    control_otr integer,
    folio integer,
    diligencia varchar(1),
    importe_global numeric(18,2),
    importe_multa numeric(18,2),
    importe_recargo numeric(18,2),
    importe_gastos numeric(18,2),
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
    importe_pago numeric(18,2),
    vigencia_1 varchar(1),
    fecha_actualiz date,
    usuario integer,
    clave_mov varchar(2),
    hora_practicado timestamp,
    id_control_1 integer,
    control_otr_1 integer,
    ayo smallint,
    periodo smallint,
    importe numeric(18,2),
    recargos numeric(18,2),
    cantidad numeric(18,2),
    total_gasto numeric(18,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque,
           a.id_contribuy_prop, a.id_contribuy_renta, a.nombre, a.arrendatario, a.domicilio, a.sector, a.zona,
           a.descripcion_local, a.superficie, a.giro, a.fecha_alta, a.fecha_baja, a.fecha_modificacion, a.vigencia,
           a.id_usuario, a.clave_cuota, b.descripcion, c.id_control, c.zona as zona_1, c.modulo, c.control_otr, c.folio,
           c.diligencia, c.importe_global, c.importe_multa, c.importe_recargo, c.importe_gastos, c.zona_apremio,
           c.fecha_emision, c.clave_practicado, c.fecha_practicado, c.fecha_entrega1, c.fecha_entrega2, c.fecha_citatorio,
           c.hora, c.ejecutor, c.clave_secuestro, c.clave_remate, c.fecha_remate, c.porcentaje_multa, c.observaciones,
           c.fecha_pago, c.recaudadora, c.caja, c.operacion, c.importe_pago, c.vigencia as vigencia_1, c.fecha_actualiz,
           c.usuario, c.clave_mov, c.hora_practicado, d.id_control as id_control_1, d.control_otr as control_otr_1,
           d.ayo, d.periodo, d.importe, d.recargos, b.cantidad,
           (
             SELECT COALESCE(SUM(importe_gastos),0)
             FROM ta_15_apremios
             WHERE modulo=11 AND control_otr=a.id_local AND folio<=c.folio AND clave_practicado='P' AND vigencia='1'
           ) AS total_gasto
    FROM ta_11_locales a
    JOIN ta_11_mercados b ON a.num_mercado = b.num_mercado_nvo AND a.oficina = b.oficina
    JOIN ta_15_apremios c ON c.modulo = 11 AND c.zona = p_ofna AND (c.folio >= p_folio1 AND c.folio <= p_folio2) AND c.control_otr = a.id_local
    JOIN ta_15_periodos d ON c.id_control = d.control_otr
    ORDER BY c.folio;
END;
$$ LANGUAGE plpgsql;