-- Stored Procedure: sp_adeudos_energia_listar
-- Tipo: Report
-- Descripción: Lista los adeudos de energía eléctrica por año y oficina, incluyendo periodos y cuotas.
-- Generado para formulario: AdeudosEnergia
-- Fecha: 2025-08-26 18:44:05

CREATE OR REPLACE FUNCTION sp_adeudos_energia_listar(p_axo INTEGER, p_oficina INTEGER)
RETURNS TABLE (
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    local INTEGER,
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    cve_consumo VARCHAR(1),
    local_adicional VARCHAR(50),
    adeudo NUMERIC(14,2),
    id_energia INTEGER,
    nombre VARCHAR(30),
    axo SMALLINT,
    cuota NUMERIC(14,2),
    meses TEXT
) AS $$
DECLARE
    r RECORD;
    meses_str TEXT;
    cuota_val NUMERIC(14,2);
BEGIN
    FOR r IN
        SELECT c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque,
               f.cve_consumo, f.local_adicional, f.id_energia, c.nombre, a.axo, SUM(a.importe) AS adeudo
        FROM ta_11_adeudo_energ a
        JOIN ta_11_energia f ON a.id_energia = f.id_energia AND f.vigencia <> 'B'
        JOIN ta_11_locales c ON c.id_local = f.id_local
        WHERE a.axo = p_axo AND c.oficina = p_oficina
        GROUP BY c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque,
                 f.cve_consumo, f.local_adicional, f.id_energia, c.nombre, a.axo
        ORDER BY c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque
    LOOP
        -- Obtener meses y cuota
        meses_str := '';
        cuota_val := 0;
        FOR m IN SELECT periodo, importe FROM ta_11_adeudo_energ WHERE id_energia = r.id_energia AND axo = p_axo ORDER BY periodo ASC
        LOOP
            meses_str := meses_str || m.periodo::TEXT || '-';
            cuota_val := m.importe;
        END LOOP;
        meses_str := LEFT(meses_str, GREATEST(LENGTH(meses_str)-1,0));
        RETURN NEXT (
            r.id_local, r.oficina, r.num_mercado, r.categoria, r.seccion, r.local, r.letra_local, r.bloque,
            r.cve_consumo, r.local_adicional, r.adeudo, r.id_energia, r.nombre, r.axo, cuota_val, meses_str
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;