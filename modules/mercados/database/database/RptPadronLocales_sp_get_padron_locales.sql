-- Stored Procedure: sp_get_padron_locales
-- Tipo: Report
-- Descripción: Obtiene el padrón de locales para una recaudadora y mercado, incluyendo datos calculados de vigencia y renta.
-- Generado para formulario: RptPadronLocales
-- Fecha: 2025-08-27 01:27:45

CREATE OR REPLACE FUNCTION sp_get_padron_locales(p_oficina INTEGER, p_mercado INTEGER)
RETURNS TABLE (
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    id_contribuy_prop INTEGER,
    id_contribuy_renta INTEGER,
    nombre VARCHAR(60),
    arrendatario VARCHAR(60),
    domicilio VARCHAR(80),
    sector VARCHAR(1),
    zona SMALLINT,
    descripcion_local VARCHAR(80),
    superficie NUMERIC(12,2),
    giro SMALLINT,
    fecha_alta DATE,
    fecha_baja DATE,
    fecha_modificacion TIMESTAMP,
    vigencia VARCHAR(1),
    id_usuario INTEGER,
    clave_cuota SMALLINT,
    descripcion VARCHAR(60),
    datosmercado VARCHAR(60),
    vigdescripcion VARCHAR(30),
    renta NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.letra_local, a.bloque,
        a.id_contribuy_prop, a.id_contribuy_renta, a.nombre, a.arrendatario, a.domicilio, a.sector, a.zona,
        a.descripcion_local, a.superficie, a.giro, a.fecha_alta, a.fecha_baja, a.fecha_modificacion, a.vigencia, a.id_usuario, a.clave_cuota,
        b.descripcion,
        (a.seccion || ' ' || a.local::text || ' ' || COALESCE(a.letra_local,'') || ' ' || COALESCE(a.bloque,'')) AS datosmercado,
        CASE a.vigencia
            WHEN 'B' THEN 'BAJA'
            WHEN 'C' THEN 'BAJA POR ACUERDO'
            WHEN 'D' THEN 'BAJA ADMINISTRATIVA'
            ELSE 'VIGENTE'
        END AS vigdescripcion,
        CASE 
            WHEN a.seccion = 'PS' AND a.clave_cuota = 4 THEN a.superficie * c.importe_cuota
            WHEN a.seccion = 'PS' THEN (c.importe_cuota * a.superficie) * 30
            WHEN a.num_mercado = 214 THEN (a.superficie * c.importe_cuota) * COALESCE(d.sabadosacum, 1)
            ELSE a.superficie * c.importe_cuota
        END AS renta
    FROM ta_11_locales a
    JOIN ta_11_categoria b ON a.categoria = b.categoria
    LEFT JOIN ta_11_cuo_locales c ON c.axo = EXTRACT(YEAR FROM CURRENT_DATE) AND c.categoria = a.categoria AND c.seccion = a.seccion AND c.clave_cuota = a.clave_cuota
    LEFT JOIN ta_11_fecha_desc d ON d.mes = EXTRACT(MONTH FROM CURRENT_DATE)
    WHERE a.oficina = p_oficina AND a.num_mercado = p_mercado
    ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque;
END;
$$ LANGUAGE plpgsql;