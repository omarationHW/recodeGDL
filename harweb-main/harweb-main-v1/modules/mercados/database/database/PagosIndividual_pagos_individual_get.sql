-- Stored Procedure: pagos_individual_get
-- Tipo: Report
-- Descripción: Obtiene la información completa de un pago individual de local, incluyendo datos de mercado y usuario.
-- Generado para formulario: PagosIndividual
-- Fecha: 2025-08-27 00:24:24

CREATE OR REPLACE FUNCTION pagos_individual_get(p_id_local integer, p_axo integer, p_periodo integer)
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
    id_pago_local integer,
    id_local_1 integer,
    axo smallint,
    periodo smallint,
    fecha_pago date,
    oficina_pago smallint,
    caja_pago varchar,
    operacion_pago integer,
    importe_pago numeric,
    folio varchar,
    fecha_modificacion_1 timestamp,
    usuario varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_local,
        b.oficina,
        b.num_mercado,
        b.categoria,
        b.seccion,
        b.local,
        b.letra_local,
        b.bloque,
        b.id_contribuy_prop,
        b.id_contribuy_renta,
        b.nombre,
        b.arrendatario,
        b.domicilio,
        b.sector,
        b.zona,
        b.descripcion_local,
        b.superficie,
        b.giro,
        b.fecha_alta,
        b.fecha_baja,
        b.fecha_modificacion,
        b.vigencia,
        b.id_usuario,
        b.clave_cuota,
        a.id_pago_local,
        a.id_local as id_local_1,
        a.axo,
        a.periodo,
        a.fecha_pago,
        a.oficina_pago,
        a.caja_pago,
        a.operacion_pago,
        a.importe_pago,
        a.folio,
        a.fecha_modificacion as fecha_modificacion_1,
        u.usuario
    FROM ta_11_pagos_local a
    JOIN ta_11_locales b ON a.id_local = b.id_local
    LEFT JOIN ta_12_passwords u ON a.id_usuario = u.id_usuario
    WHERE a.id_local = p_id_local AND a.axo = p_axo AND a.periodo = p_periodo
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;