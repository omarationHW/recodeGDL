-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptAdeudosEnergia
-- Generado: 2025-08-27 00:41:19
-- Total SPs: 2
-- ============================================

-- SP 1/2: rpt_adeudos_energia
-- Tipo: Report
-- Descripción: Obtiene el listado de adeudos de energía eléctrica por año y oficina, incluyendo datos del local, nombre, locales adicionales, meses y adeudo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_adeudos_energia(p_axo integer, p_oficina smallint)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar(2),
    local smallint,
    letra_local varchar(1),
    bloque varchar(1),
    cve_consumo varchar(1),
    id_energia integer,
    nombre varchar(100),
    local_adicional varchar(50),
    axo smallint,
    adeudo numeric(18,2),
    recaudadora varchar(50),
    descripcion varchar(100),
    id_rec smallint,
    datoslocal varchar(100),
    meses varchar(100),
    cuota numeric(18,2)
) AS $$
DECLARE
    r RECORD;
    meses_str TEXT;
    cuota_val NUMERIC(18,2);
BEGIN
    FOR r IN
        SELECT c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque,
               f.cve_consumo, f.id_energia, c.nombre, f.local_adicional, a.axo,
               SUM(a.importe) AS adeudo, UPPER(b.recaudadora) AS recaudadora, d.descripcion, b.id_rec
        FROM public.ta_11_adeudo_energ a
        JOIN public.ta_11_locales c ON a.id_local = c.id_local
        JOIN public.ta_11_energia f ON a.id_energia = f.id_energia AND f.vigencia <> 'B'
        JOIN public.ta_12_recaudadoras b ON c.oficina = b.id_rec
        JOIN public.ta_11_mercados d ON c.oficina = d.oficina
        WHERE a.axo = p_axo AND c.oficina = p_oficina
        GROUP BY c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque,
                 f.cve_consumo, f.id_energia, c.nombre, f.local_adicional, a.axo, b.recaudadora, d.descripcion, b.id_rec
        ORDER BY c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque, d.descripcion
    LOOP
        -- Construir datoslocal
        r.datoslocal := r.oficina::text || '-' || r.num_mercado::text || '-' || r.categoria::text || '-' || r.seccion || '-' || r.local::text || '-' || r.letra_local || '-' || r.bloque;
        -- Obtener meses y cuota
        meses_str := '';
        cuota_val := NULL;
        FOR m IN SELECT periodo, importe FROM public.ta_11_adeudo_energ WHERE id_energia = r.id_energia AND axo = p_axo ORDER BY periodo ASC
        LOOP
            meses_str := meses_str || m.periodo::text || '-';
            cuota_val := m.importe;
        END LOOP;
        IF length(meses_str) > 0 THEN
            r.meses := left(meses_str, length(meses_str)-1);
        ELSE
            r.meses := '';
        END IF;
        r.cuota := cuota_val;
        RETURN NEXT r;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: rpt_adeudos_energia_meses
-- Tipo: Report
-- Descripción: Obtiene los periodos (meses/bimestres) y el importe de adeudo para un id_energia y año específico.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_adeudos_energia_meses(p_id_energia integer, p_axo smallint)
RETURNS TABLE (
    id_energia integer,
    axo smallint,
    periodo smallint,
    importe numeric(18,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_energia, axo, periodo, importe
    FROM public.ta_11_adeudo_energ
    WHERE id_energia = p_id_energia AND axo = p_axo
    ORDER BY id_energia ASC, axo ASC, periodo ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

