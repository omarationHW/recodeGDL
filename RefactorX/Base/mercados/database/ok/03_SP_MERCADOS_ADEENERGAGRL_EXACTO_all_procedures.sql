-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: mercados
-- ESQUEMA: public
-- NOTA: Usa tablas cross-database de padron_licencias.comun
-- ============================================
\c mercados;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: AdeEnergiaGrl
-- Generado: 2025-08-26 20:47:30
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_ade_energia_grl
-- Tipo: Report
-- Descripción: Obtiene el listado de adeudos generales de energía eléctrica por recaudadora, mercado, año y mes, incluyendo cálculo de cuotas y periodos de adeudo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_ade_energia_grl(
    p_id_rec INTEGER,
    p_num_mercado_nvo INTEGER,
    p_axo INTEGER,
    p_mes INTEGER
)
RETURNS TABLE (
    id_local INTEGER,
    id_energia INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    local INTEGER,
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    nombre VARCHAR(30),
    local_adicional VARCHAR(50),
    descripcion VARCHAR(30),
    axo SMALLINT,
    adeudo NUMERIC(18,2),
    mesesadeudos TEXT,
    cuota NUMERIC(18,2)
) AS $$
DECLARE
    r RECORD;
    meses TEXT;
    cuota_val NUMERIC(18,2);
BEGIN
    FOR r IN
        SELECT a.id_local, b.id_energia, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre, b.local_adicional, d.descripcion, c.axo, SUM(c.importe) AS adeudo
        FROM padron_licencias.comun.ta_11_locales a
        JOIN public.ta_11_energia b ON a.id_local = b.id_local
        JOIN public.ta_11_adeudo_energ c ON b.id_energia = c.id_energia
        JOIN padron_licencias.comun.ta_11_mercados d ON a.oficina = d.oficina AND a.num_mercado = d.num_mercado_nvo
        WHERE a.oficina = p_id_rec
          AND a.num_mercado = p_num_mercado_nvo
          AND ((c.axo = p_axo AND c.periodo <= p_mes) OR (c.axo < p_axo))
        GROUP BY a.id_local, b.id_energia, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre, b.local_adicional, d.descripcion, c.axo
        ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, c.axo
    LOOP
        -- Calcular mesesadeudos y cuota
        meses := '';
        cuota_val := 0;
        FOR m IN SELECT periodo, importe FROM public.ta_11_adeudo_energ WHERE id_energia = r.id_energia AND axo = p_axo AND periodo <= p_mes ORDER BY periodo LOOP
            meses := meses || m.periodo::TEXT || '-';
            cuota_val := m.importe;
        END LOOP;
        IF LENGTH(meses) > 0 THEN
            meses := LEFT(meses, LENGTH(meses)-1);
        END IF;
        RETURN NEXT (
            r.id_local, r.id_energia, r.oficina, r.num_mercado, r.categoria, r.seccion, r.local, r.letra_local, r.bloque, r.nombre, r.local_adicional, r.descripcion, r.axo, r.adeudo, meses, cuota_val
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================
