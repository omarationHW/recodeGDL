-- Stored Procedure: sp_cons_pagos_energia_fecha_pago
-- Tipo: Report
-- Descripción: Consulta pagos de energía por fecha de pago y criterios asociados.
-- Generado para formulario: ConsPagosEnergia
-- Fecha: 2025-08-26 23:19:24

CREATE OR REPLACE FUNCTION sp_cons_pagos_energia_fecha_pago(
    p_fecha_pago date,
    p_oficina_pago integer,
    p_caja_pago varchar,
    p_operacion_pago integer,
    p_orden varchar DEFAULT 'fecha_pago,oficina_pago,caja_pago,operacion_pago',
    p_limit integer DEFAULT 1000,
    p_offset integer DEFAULT 0
)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    local smallint,
    letra_local varchar,
    bloque varchar,
    id_contribuy_prop integer,
    id_contribuy_renta integer,
    nombre varchar,
    arrendatario varchar,
    domicilio varchar,
    sector varchar,
    zona smallint,
    descripcion_local varchar,
    superficie float,
    giro smallint,
    fecha_alta date,
    fecha_baja date,
    fecha_modificacion timestamp,
    vigencia varchar,
    id_usuario integer,
    clave_cuota smallint,
    id_pago_energia integer,
    id_energia integer,
    axo smallint,
    periodo smallint,
    fecha_pago date,
    oficina_pago smallint,
    caja_pago varchar,
    operacion_pago integer,
    importe_pago numeric,
    folio varchar,
    fecha_modificacion_1 timestamp,
    id_usuario_1 integer,
    id_usuario_2 integer,
    usuario varchar,
    nombre_1 varchar,
    estado varchar,
    id_rec smallint,
    nivel smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque,
           a.id_contribuy_prop, a.id_contribuy_renta, a.nombre, a.arrendatario, a.domicilio, a.sector, a.zona,
           a.descripcion_local, a.superficie, a.giro, a.fecha_alta, a.fecha_baja, a.fecha_modificacion, a.vigencia,
           a.id_usuario, a.clave_cuota,
           b.id_pago_energia, b.id_energia, b.axo, b.periodo, b.fecha_pago, b.oficina_pago, b.caja_pago, b.operacion_pago,
           b.importe_pago, b.folio, b.fecha_modificacion AS fecha_modificacion_1, b.id_usuario AS id_usuario_1,
           c.id_usuario AS id_usuario_2, c.usuario, c.nombre AS nombre_1, c.estado, c.id_rec, c.nivel
    FROM ta_11_locales a
    JOIN ta_11_energia e ON a.id_local = e.id_local
    JOIN ta_11_pago_energia b ON e.id_energia = b.id_energia
    JOIN ta_12_passwords c ON b.id_usuario = c.id_usuario
    WHERE b.fecha_pago = p_fecha_pago
      AND b.oficina_pago = COALESCE(p_oficina_pago, b.oficina_pago)
      AND (p_caja_pago IS NULL OR b.caja_pago = p_caja_pago)
      AND b.operacion_pago = COALESCE(p_operacion_pago, b.operacion_pago)
    ORDER BY
      CASE WHEN p_orden = 'fecha_pago,oficina_pago,caja_pago,operacion_pago' THEN b.fecha_pago END ASC,
      CASE WHEN p_orden = 'fecha_pago,oficina_pago,caja_pago,operacion_pago' THEN b.oficina_pago END ASC,
      CASE WHEN p_orden = 'fecha_pago,oficina_pago,caja_pago,operacion_pago' THEN b.caja_pago END ASC,
      CASE WHEN p_orden = 'fecha_pago,oficina_pago,caja_pago,operacion_pago' THEN b.operacion_pago END ASC
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;