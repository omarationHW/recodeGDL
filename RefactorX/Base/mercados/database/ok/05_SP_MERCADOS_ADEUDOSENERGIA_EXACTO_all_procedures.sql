-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: mercados
-- ESQUEMA: public
-- NOTA: Usa tablas cross-database de padron_licencias.comun
-- ============================================
\c mercados;
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
    m RECORD;
    meses_str TEXT;
    cuota_val NUMERIC(12,2);
BEGIN
    FOR r IN
        SELECT l.id_local, l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque,
               f.cve_consumo, f.id_energia, l.nombre, f.local_adicional, a.axo, SUM(a.importe) AS adeudo
        FROM public.ta_11_adeudo_energ a
        JOIN public.ta_11_energia f ON a.id_energia = f.id_energia AND f.vigencia <> 'B'
        JOIN public.ta_11_localpaso l ON l.id_local = f.id_local
        WHERE a.axo = p_axo AND l.oficina = p_oficina
        GROUP BY l.id_local, l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque,
                 f.cve_consumo, f.id_energia, l.nombre, f.local_adicional, a.axo
        ORDER BY l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque
    LOOP
        -- Obtener meses y cuota
        meses_str := '';
        cuota_val := 0;
        FOR m IN SELECT ae.periodo, ae.importe
                 FROM public.ta_11_adeudo_energ ae
                 WHERE ae.id_energia = r.id_energia AND ae.axo = p_axo
                 ORDER BY ae.periodo LOOP
            meses_str := meses_str || m.periodo::TEXT || '-';
            cuota_val := m.importe;
        END LOOP;
        IF LENGTH(meses_str) > 0 THEN
            meses_str := LEFT(meses_str, LENGTH(meses_str)-1);
        END IF;

        id_local := r.id_local;
        oficina := r.oficina;
        num_mercado := r.num_mercado;
        categoria := r.categoria;
        seccion := r.seccion;
        local := r.local;
        letra_local := r.letra_local;
        bloque := r.bloque;
        cve_consumo := r.cve_consumo;
        id_energia := r.id_energia;
        nombre := r.nombre;
        local_adicional := r.local_adicional;
        axo := r.axo;
        adeudo := r.adeudo;
        cuota := cuota_val;
        meses := meses_str;

        RETURN NEXT;
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