-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptAdeEnergiaGrl
-- Generado: 2025-08-27 00:36:29
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_get_ade_energia_grl
-- Tipo: Report
-- Descripción: Obtiene el listado global de adeudos de energía eléctrica por mercado, oficina, año y mes, incluyendo meses de adeudo y cuota.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_ade_energia_grl(
    p_oficina integer,
    p_mercado integer,
    p_axo integer,
    p_mes integer
)
RETURNS TABLE (
    id_local integer,
    id_energia integer,
    oficina integer,
    num_mercado integer,
    categoria integer,
    seccion varchar,
    local integer,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    local_adicional varchar,
    descripcion varchar,
    axo integer,
    adeudo numeric,
    mesesadeudos varchar,
    cuota numeric
) AS $$
DECLARE
    r RECORD;
    cad TEXT;
    cuota_val NUMERIC;
BEGIN
    FOR r IN
        SELECT a.id_local, b.id_energia, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque,
               a.nombre, b.local_adicional, d.descripcion, c.axo, SUM(c.importe) AS adeudo
        FROM public.ta_11_locales a
        JOIN public.ta_11_energia b ON a.id_local = b.id_local
        JOIN public.ta_11_adeudo_energ c ON b.id_energia = c.id_energia
        JOIN public.ta_11_mercados d ON a.oficina = d.oficina AND a.num_mercado = d.num_mercado_nvo
        WHERE a.oficina = p_oficina
          AND a.num_mercado = p_mercado
          AND ((c.axo = p_axo AND c.periodo <= p_mes) OR (c.axo < p_axo))
        GROUP BY a.id_local, b.id_energia, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque,
                 a.nombre, b.local_adicional, d.descripcion, c.axo
        ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, c.axo
    LOOP
        -- Obtener meses de adeudo y cuota
        cad := '';
        cuota_val := 0;
        FOR m IN SELECT periodo, importe FROM public.ta_11_adeudo_energ WHERE id_energia = r.id_energia AND axo = r.axo AND periodo <= p_mes ORDER BY periodo LOOP
            cad := cad || m.periodo || '-';
            cuota_val := m.importe;
        END LOOP;
        mesesadeudos := CASE WHEN length(cad) > 0 THEN left(cad, length(cad)-1) ELSE '' END;
        cuota := cuota_val;
        RETURN NEXT (
            r.id_local, r.id_energia, r.oficina, r.num_mercado, r.categoria, r.seccion, r.local, r.letra_local, r.bloque,
            r.nombre, r.local_adicional, r.descripcion, r.axo, r.adeudo, mesesadeudos, cuota
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================

