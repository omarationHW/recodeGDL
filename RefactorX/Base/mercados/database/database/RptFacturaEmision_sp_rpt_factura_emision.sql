-- Stored Procedure: sp_rpt_factura_emision
-- Tipo: Report
-- Descripción: Obtiene la facturación de estados de cuenta para una oficina, año, periodo y mercado (o todos los mercados). Calcula campos como datoslocal e importe según reglas de negocio.
-- Generado para formulario: RptFacturaEmision
-- Fecha: 2025-08-27 01:04:38

CREATE OR REPLACE FUNCTION sp_rpt_factura_emision(
    p_oficina integer,
    p_axo integer,
    p_periodo integer,
    p_mercado integer,
    p_opc integer
)
RETURNS TABLE (
    oficina integer,
    num_mercado integer,
    categoria integer,
    seccion varchar,
    local integer,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    superficie numeric,
    descripcion varchar,
    recaudadora varchar,
    importe_cuota numeric,
    clave_cuota integer,
    datoslocal varchar,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.oficina,
        a.num_mercado,
        a.categoria,
        a.seccion,
        a.local,
        a.letra_local,
        a.bloque,
        a.nombre,
        a.superficie,
        c.descripcion,
        upper(d.recaudadora) as recaudadora,
        b.importe_cuota,
        a.clave_cuota,
        (
            cast(a.oficina as varchar) || ' ' || cast(a.num_mercado as varchar) || ' ' ||
            cast(a.categoria as varchar) || ' ' || a.seccion || ' ' ||
            cast(a.local as varchar) || ' ' || coalesce(a.letra_local,'') || ' ' || coalesce(a.bloque,'')
        ) as datoslocal,
        CASE 
            WHEN a.seccion = 'PS' THEN
                CASE WHEN a.clave_cuota = 4 THEN a.superficie * b.importe_cuota
                     ELSE (b.importe_cuota * a.superficie) * 30 END
            WHEN a.num_mercado = 214 THEN (a.superficie * b.importe_cuota) * (
                SELECT sabadosacum FROM ta_11_fecha_desc WHERE mes = p_periodo LIMIT 1
            )
            ELSE a.superficie * b.importe_cuota
        END as importe
    FROM ta_11_locales a
    JOIN ta_11_mercados c ON a.oficina = c.oficina AND a.num_mercado = c.num_mercado_nvo
    JOIN ta_12_recaudadoras d ON a.oficina = d.id_rec
    JOIN ta_11_cuo_locales b ON b.axo = p_axo AND b.categoria = a.categoria AND b.seccion = a.seccion AND b.clave_cuota = a.clave_cuota
    WHERE a.oficina = p_oficina
      AND a.num_mercado BETWEEN (CASE WHEN p_opc = 1 THEN p_mercado ELSE 1 END) AND (CASE WHEN p_opc = 1 THEN p_mercado ELSE 119 END)
      AND c.tipo_emision <> 'B'
      AND a.vigencia = 'A'
      AND a.bloqueo < 4
      AND a.id_local NOT IN (
        SELECT id_local FROM ta_11_pagos_local WHERE id_local = a.id_local AND axo = p_axo AND periodo = p_periodo
      )
    ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque;
END;
$$ LANGUAGE plpgsql;