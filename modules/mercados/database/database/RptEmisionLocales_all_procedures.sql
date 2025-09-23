-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptEmisionLocales
-- Generado: 2025-08-27 00:57:07
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_rpt_emision_locales_get
-- Tipo: Report
-- Descripción: Obtiene la previsualización de la emisión de recibos de locales para una oficina, año, periodo y mercado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rpt_emision_locales_get(
    p_oficina integer,
    p_axo integer,
    p_periodo integer,
    p_mercado integer
) RETURNS TABLE(
    id_local integer,
    oficina integer,
    num_mercado integer,
    categoria integer,
    seccion text,
    local integer,
    letra_local text,
    bloque text,
    nombre text,
    descripcion_local text,
    superficie numeric,
    renta numeric,
    adeudo numeric,
    recargos numeric,
    subtotal numeric,
    meses text
) AS $$
DECLARE
    per integer;
    axo1 integer;
BEGIN
    IF p_periodo = 1 THEN
        per := 12;
        axo1 := p_axo - 1;
    ELSE
        per := p_periodo - 1;
        axo1 := p_axo;
    END IF;
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
        -- Cálculo de renta
        CASE WHEN l.seccion = 'PS' AND c.clave_cuota = 4 THEN l.superficie * c.importe_cuota
             WHEN l.seccion = 'PS' THEN (c.importe_cuota * l.superficie) * 30
             ELSE l.superficie * c.importe_cuota END AS renta,
        COALESCE(SUM(a.importe), 0) AS adeudo,
        -- Recargos: sumar porcentaje según lógica de recargos
        (
            SELECT COALESCE(SUM((a2.importe * r.porcentaje_mes) / 100), 0)
            FROM ta_11_adeudo_local a2
            JOIN ta_12_recargos r ON (r.axo = a2.axo AND r.mes >= a2.periodo)
            WHERE a2.id_local = l.id_local
              AND ((a2.axo = p_axo AND a2.periodo < p_periodo) OR (a2.axo < p_axo))
        ) AS recargos,
        -- Subtotal
        COALESCE(SUM(a.importe), 0) + (
            SELECT COALESCE(SUM((a2.importe * r.porcentaje_mes) / 100), 0)
            FROM ta_11_adeudo_local a2
            JOIN ta_12_recargos r ON (r.axo = a2.axo AND r.mes >= a2.periodo)
            WHERE a2.id_local = l.id_local
              AND ((a2.axo = p_axo AND a2.periodo < p_periodo) OR (a2.axo < p_axo))
        ) AS subtotal,
        -- Meses adeudados
        (
            SELECT string_agg(a3.periodo::text, ',' ORDER BY a3.axo, a3.periodo)
            FROM ta_11_adeudo_local a3
            WHERE a3.id_local = l.id_local
              AND ((a3.axo = p_axo AND a3.periodo < p_periodo) OR (a3.axo < p_axo))
        ) AS meses
    FROM ta_11_locales l
    JOIN ta_11_cuo_locales c ON c.axo = p_axo AND l.categoria = c.categoria AND l.seccion = c.seccion AND l.clave_cuota = c.clave_cuota
    LEFT JOIN ta_11_adeudo_local a ON a.id_local = l.id_local AND ((a.axo = p_axo AND a.periodo < p_periodo) OR (a.axo < p_axo))
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_mercado
      AND l.vigencia = 'A'
      AND l.bloqueo < 4
    GROUP BY l.id_local, l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque, l.nombre, l.descripcion_local, l.superficie, c.clave_cuota, c.importe_cuota;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_rpt_emision_locales_emit
-- Tipo: CRUD
-- Descripción: Graba la emisión de recibos de locales para una oficina, año, periodo y mercado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rpt_emision_locales_emit(
    p_oficina integer,
    p_axo integer,
    p_periodo integer,
    p_mercado integer,
    p_usuario_id integer
) RETURNS TABLE(
    id_local integer,
    status text
) AS $$
DECLARE
    rec RECORD;
    per integer;
    axo1 integer;
    existe integer;
BEGIN
    IF p_periodo = 1 THEN
        per := 12;
        axo1 := p_axo - 1;
    ELSE
        per := p_periodo - 1;
        axo1 := p_axo;
    END IF;
    FOR rec IN SELECT id_local FROM ta_11_locales WHERE oficina = p_oficina AND num_mercado = p_mercado AND vigencia = 'A' AND bloqueo < 4
    LOOP
        SELECT COUNT(*) INTO existe FROM ta_11_adeudo_local WHERE id_local = rec.id_local AND axo = p_axo AND periodo = p_periodo;
        IF existe = 0 THEN
            -- Calcular renta
            INSERT INTO ta_11_adeudo_local (id_adeudo_local, id_local, axo, periodo, importe, fecha_alta, id_usuario)
            VALUES (DEFAULT, rec.id_local, p_axo, p_periodo,
                (
                    SELECT CASE WHEN l.seccion = 'PS' AND c.clave_cuota = 4 THEN l.superficie * c.importe_cuota
                                WHEN l.seccion = 'PS' THEN (c.importe_cuota * l.superficie) * 30
                                ELSE l.superficie * c.importe_cuota END
                    FROM ta_11_locales l
                    JOIN ta_11_cuo_locales c ON c.axo = p_axo AND l.categoria = c.categoria AND l.seccion = c.seccion AND l.clave_cuota = c.clave_cuota
                    WHERE l.id_local = rec.id_local
                ),
                NOW(), p_usuario_id
            );
            RETURN NEXT (rec.id_local, 'inserted');
        ELSE
            RETURN NEXT (rec.id_local, 'exists');
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================

