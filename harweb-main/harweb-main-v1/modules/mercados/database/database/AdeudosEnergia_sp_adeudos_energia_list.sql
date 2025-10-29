-- Stored Procedure: sp_adeudos_energia_list
-- Tipo: Report
-- Descripción: Obtiene el listado de adeudos de energía eléctrica por año y oficina.
-- Generado para formulario: AdeudosEnergia
-- Fecha: 2025-08-26 19:34:16

CREATE OR REPLACE FUNCTION sp_adeudos_energia_list(p_axo INTEGER, p_oficina INTEGER)
RETURNS TABLE (
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    cve_consumo VARCHAR(1),
    local_adicional VARCHAR(50),
    adeudo NUMERIC(12,2),
    id_energia INTEGER,
    meses TEXT,
    nombre VARCHAR(30),
    axo SMALLINT,
    cuota NUMERIC(12,2),
    local INTEGER
) AS $$
DECLARE
    r RECORD;
    meses_str TEXT;
    cuota_val NUMERIC(12,2);
BEGIN
    FOR r IN
        SELECT c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.letra_local, c.bloque,
               f.cve_consumo, f.local_adicional, SUM(a.importe) AS adeudo, f.id_energia, c.nombre, a.axo, c.local
        FROM ta_11_adeudo_energ a
        JOIN ta_11_locales c ON a.id_energia = f.id_energia AND c.id_local = f.id_local
        JOIN ta_11_energia f ON a.id_energia = f.id_energia
        WHERE a.axo = p_axo AND c.oficina = p_oficina AND f.vigencia <> 'B'
        GROUP BY c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.letra_local, c.bloque, f.cve_consumo, f.id_energia, c.nombre, a.axo, f.local_adicional, c.local
        ORDER BY c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque
    LOOP
        -- Obtener meses y cuota
        meses_str := '';
        cuota_val := 0;
        FOR m IN SELECT periodo, importe FROM ta_11_adeudo_energ WHERE id_energia = r.id_energia AND axo = p_axo ORDER BY periodo LOOP
            meses_str := meses_str || m.periodo::TEXT || '-';
            cuota_val := m.importe;
        END LOOP;
        meses_str := LEFT(meses_str, LENGTH(meses_str)-1);
        RETURN NEXT (
            r.id_local, r.oficina, r.num_mercado, r.categoria, r.seccion, r.letra_local, r.bloque,
            r.cve_consumo, r.local_adicional, r.adeudo, r.id_energia, meses_str, r.nombre, r.axo, cuota_val, r.local
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;