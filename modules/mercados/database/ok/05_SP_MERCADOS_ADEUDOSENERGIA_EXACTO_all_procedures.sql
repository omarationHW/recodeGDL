-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: AdeudosEnergia
-- Generado: 2025-08-26 20:50:21
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_get_adeudos_energia
-- Tipo: Report
-- Descripción: Obtiene el listado de adeudos de energía eléctrica por año y oficina.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_adeudos_energia(p_axo INTEGER, p_oficina INTEGER)
RETURNS TABLE(
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    local INTEGER,
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    cve_consumo VARCHAR(1),
    id_energia INTEGER,
    nombre VARCHAR(30),
    local_adicional VARCHAR(50),
    axo SMALLINT,
    adeudo NUMERIC(12,2),
    cuota NUMERIC(12,2),
    meses TEXT
) AS $$
DECLARE
    r RECORD;
    meses_str TEXT;
    cuota_val NUMERIC(12,2);
BEGIN
    FOR r IN
        SELECT c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque,
               f.cve_consumo, f.id_energia, c.nombre, f.local_adicional, a.axo, SUM(a.importe) AS adeudo
        FROM public.ta_11_adeudo_energ a
        JOIN public.ta_11_energia f ON a.id_energia = f.id_energia AND f.vigencia <> 'B'
        JOIN public.ta_11_locales c ON c.id_local = f.id_local
        WHERE a.axo = p_axo AND c.oficina = p_oficina
        GROUP BY c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque,
                 f.cve_consumo, f.id_energia, c.nombre, f.local_adicional, a.axo
        ORDER BY c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque
    LOOP
        -- Obtener meses y cuota
        meses_str := '';
        cuota_val := 0;
        FOR m IN SELECT periodo, importe FROM public.ta_11_adeudo_energ WHERE id_energia = r.id_energia AND axo = p_axo ORDER BY periodo LOOP
            meses_str := meses_str || m.periodo::TEXT || '-';
            cuota_val := m.importe;
        END LOOP;
        meses_str := LEFT(meses_str, LENGTH(meses_str)-1);
        RETURN NEXT (
            r.id_local, r.oficina, r.num_mercado, r.categoria, r.seccion, r.local, r.letra_local, r.bloque,
            r.cve_consumo, r.id_energia, r.nombre, r.local_adicional, r.axo, r.adeudo, cuota_val, meses_str
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_get_meses_adeudo_energia
-- Tipo: Report
-- Descripción: Obtiene los meses y cuotas de adeudo de energía para un id_energia y año.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_meses_adeudo_energia(p_id_energia INTEGER, p_axo INTEGER)
RETURNS TABLE(
    periodo SMALLINT,
    importe NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT periodo, importe
    FROM public.ta_11_adeudo_energ
    WHERE id_energia = p_id_energia AND axo = p_axo
    ORDER BY periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================