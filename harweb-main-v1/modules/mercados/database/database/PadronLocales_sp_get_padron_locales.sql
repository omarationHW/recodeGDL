-- Stored Procedure: sp_get_padron_locales
-- Tipo: Report
-- Descripción: Obtiene el padrón de locales filtrado por recaudadora, incluyendo cálculo de renta.
-- Generado para formulario: PadronLocales
-- Fecha: 2025-08-27 00:20:10

CREATE OR REPLACE FUNCTION sp_get_padron_locales(p_recaudadora INTEGER)
RETURNS TABLE (
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    local SMALLINT,
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    nombre VARCHAR(30),
    superficie NUMERIC,
    clave_cuota SMALLINT,
    descripcion VARCHAR(30),
    renta NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_local,
        a.oficina,
        a.num_mercado,
        a.categoria,
        a.seccion,
        a.local,
        a.letra_local,
        a.bloque,
        a.nombre,
        a.superficie,
        a.clave_cuota,
        b.descripcion,
        CASE 
            WHEN a.seccion = 'PS' THEN a.superficie * c.importe_cuota * 30
            ELSE a.superficie * c.importe_cuota
        END AS renta
    FROM ta_11_locales a
    JOIN ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
    LEFT JOIN ta_11_cuo_locales c ON c.axo = EXTRACT(YEAR FROM CURRENT_DATE) AND c.categoria = a.categoria AND c.seccion = a.seccion AND c.clave_cuota = a.clave_cuota
    WHERE a.oficina = p_recaudadora
      AND a.vigencia = 'A'
    ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque;
END;
$$ LANGUAGE plpgsql;