-- Stored Procedure: sp_padron_global
-- Tipo: Report
-- Descripción: Obtiene el padrón global de locales con cálculo de renta y leyenda de adeudo/corriente.
-- Generado para formulario: PadronGlobal
-- Fecha: 2025-08-27 00:18:40

CREATE OR REPLACE FUNCTION sp_padron_global(p_axo integer, p_mes integer, p_vig character varying)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar(2),
    local integer,
    letra_local varchar(1),
    bloque varchar(1),
    nombre varchar(30),
    descripcion_local varchar,
    superficie numeric,
    vigencia varchar(1),
    clave_cuota smallint,
    descripcion varchar(30),
    renta numeric,
    leyenda varchar(60),
    adeudo integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id_local,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque,
        l.nombre,
        l.descripcion_local,
        l.superficie,
        l.vigencia,
        l.clave_cuota,
        m.descripcion,
        -- Cálculo de renta
        CASE 
            WHEN l.seccion = 'PS' AND l.clave_cuota = 4 THEN l.superficie * c.importe_cuota
            WHEN l.seccion = 'PS' THEN (c.importe_cuota * l.superficie) * 30
            WHEN l.num_mercado = 214 THEN (l.superficie * c.importe_cuota) * fd.sabadosacum
            ELSE l.superficie * c.importe_cuota
        END AS renta,
        -- Leyenda y adeudo
        CASE WHEN (SELECT COUNT(1) FROM ta_11_adeudo_local al WHERE al.id_local = l.id_local AND ((al.axo = p_axo AND al.periodo <= p_mes) OR (al.axo < p_axo))) >= 1 THEN 'Local con Adeudo' ELSE 'Local al Corriente de Pagos' END AS leyenda,
        CASE WHEN (SELECT COUNT(1) FROM ta_11_adeudo_local al WHERE al.id_local = l.id_local AND ((al.axo = p_axo AND al.periodo <= p_mes) OR (al.axo < p_axo))) >= 1 THEN 1 ELSE 0 END AS adeudo
    FROM ta_11_locales l
    JOIN ta_11_mercados m ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
    LEFT JOIN ta_11_cuo_locales c ON c.axo = p_axo AND c.categoria = l.categoria AND c.seccion = l.seccion AND c.clave_cuota = l.clave_cuota
    LEFT JOIN ta_11_fecha_desc fd ON fd.mes = p_mes
    WHERE l.num_mercado <> 99
      AND l.vigencia = p_vig
    ORDER BY l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque;
END;
$$ LANGUAGE plpgsql;