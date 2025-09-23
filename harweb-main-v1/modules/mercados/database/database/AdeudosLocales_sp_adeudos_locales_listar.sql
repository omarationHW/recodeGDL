-- Stored Procedure: sp_adeudos_locales_listar
-- Tipo: Report
-- Descripción: Lista los adeudos de locales para un año, oficina y periodo dados.
-- Generado para formulario: AdeudosLocales
-- Fecha: 2025-08-26 19:35:38

CREATE OR REPLACE FUNCTION sp_adeudos_locales_listar(p_axo INTEGER, p_oficina INTEGER, p_periodo INTEGER)
RETURNS TABLE(
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    nombre VARCHAR(30),
    superficie NUMERIC(10,2),
    clave_cuota SMALLINT,
    adeudo NUMERIC(14,2),
    recaudadora VARCHAR(50),
    descripcion VARCHAR(30),
    meses TEXT,
    local INTEGER,
    RentaCalc NUMERIC(14,2)
) AS $$
DECLARE
    r RECORD;
    meses_str TEXT;
    renta NUMERIC(14,2);
BEGIN
    FOR r IN
        SELECT c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.letra_local, c.bloque, c.nombre, c.superficie, c.clave_cuota,
               SUM(a.importe) AS adeudo, d.recaudadora, e.descripcion, c.local
        FROM ta_11_adeudo_local a
        JOIN ta_11_locales c ON a.id_local = c.id_local
        JOIN ta_12_recaudadoras d ON c.oficina = d.id_rec
        JOIN ta_11_mercados e ON c.oficina = e.oficina AND c.num_mercado = e.num_mercado_nvo
        WHERE a.axo = p_axo AND c.oficina = p_oficina AND a.periodo <= p_periodo AND c.vigencia = 'A'
        GROUP BY c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.letra_local, c.bloque, c.nombre, c.superficie, c.clave_cuota, d.recaudadora, e.descripcion, c.local
        ORDER BY c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque
    LOOP
        -- Obtener meses de adeudo
        SELECT string_agg(CAST(periodo AS TEXT), ',') INTO meses_str
        FROM ta_11_adeudo_local
        WHERE id_local = r.id_local AND axo = p_axo AND periodo <= p_periodo;
        -- Calcular renta
        SELECT CASE
            WHEN r.seccion = 'PS' AND r.clave_cuota = 4 THEN r.superficie * cu.importe_cuota
            WHEN r.seccion = 'PS' THEN (cu.importe_cuota * r.superficie) * 30
            WHEN r.num_mercado = 214 THEN (r.superficie * cu.importe_cuota) * COALESCE(fd.sabadosacum,1)
            ELSE r.superficie * cu.importe_cuota
        END INTO renta
        FROM ta_11_cuo_locales cu
        LEFT JOIN ta_11_fecha_desc fd ON fd.mes = p_periodo
        WHERE cu.axo = p_axo AND cu.categoria = r.categoria AND cu.seccion = r.seccion AND cu.clave_cuota = r.clave_cuota
        LIMIT 1;
        RETURN NEXT (
            r.id_local, r.oficina, r.num_mercado, r.categoria, r.seccion, r.letra_local, r.bloque, r.nombre, r.superficie, r.clave_cuota,
            r.adeudo, r.recaudadora, r.descripcion, meses_str, r.local, renta
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;