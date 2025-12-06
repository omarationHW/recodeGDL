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
    seccion char(2),
    local smallint,
    letra_local varchar(3),
    bloque varchar(2),
    id_contribuy_prop integer,
    id_contribuy_renta integer,
    nombre varchar(30),
    arrendatario varchar(30),
    domicilio varchar(70),
    sector char(2),
    zona smallint,
    descripcion_local char(20),
    superficie numeric,
    giro smallint,
    fecha_alta date,
    fecha_baja date,
    fecha_modificacion timestamp,
    vigencia char(1),
    id_usuario integer,
    clave_cuota smallint,
    id_pago_local integer,
    id_local_1 integer,
    axo smallint,
    periodo smallint,
    fecha_pago date,
    oficina_pago smallint,
    caja_pago char(2),
    operacion_pago integer,
    importe_pago numeric,
    folio varchar(20),
    fecha_modificacion_1 timestamp,
    usuario varchar(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.id_local,
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
    FROM public.ta_11_pago_local a
    JOIN public.ta_11_localpaso b ON a.id_local = b.id_local
    LEFT JOIN public.usuarios u ON a.id_usuario = u.id
    WHERE a.id_local = p_id_local AND a.axo = p_axo AND a.periodo = p_periodo
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;