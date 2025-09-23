-- Stored Procedure: sp_adeudos_loc_grl
-- Tipo: Report
-- Descripción: Obtiene el reporte de adeudos generales de locales de mercados por recaudadora, mercado, año y mes.
-- Generado para formulario: AdeudosLocGrl
-- Fecha: 2025-08-26 22:41:25

CREATE OR REPLACE FUNCTION sp_adeudos_loc_grl(
    p_id_rec INTEGER,
    p_num_mercado INTEGER DEFAULT NULL,
    p_axo INTEGER,
    p_mes INTEGER
)
RETURNS TABLE (
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    local INTEGER,
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    nombre VARCHAR(30),
    superficie NUMERIC,
    clave_cuota SMALLINT,
    adeudo NUMERIC,
    recaudadora VARCHAR(50),
    descripcion VARCHAR(30),
    meses VARCHAR(26),
    renta NUMERIC,
    axo SMALLINT,
    folios VARCHAR(150)
) AS $$
DECLARE
    r RECORD;
    meses_str TEXT;
    folios_str TEXT;
    renta_val NUMERIC;
BEGIN
    FOR r IN
        SELECT c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque,
               c.nombre, c.superficie, c.clave_cuota, SUM(a.importe) AS adeudo, d.recaudadora, e.descripcion, a.axo
        FROM ta_11_adeudo_local a
        JOIN ta_11_locales c ON a.id_local = c.id_local
        JOIN ta_12_recaudadoras d ON d.id_rec = c.oficina
        JOIN ta_11_mercados e ON e.oficina = c.oficina AND e.num_mercado_nvo = c.num_mercado
        WHERE c.oficina = p_id_rec
          AND (p_num_mercado IS NULL OR c.num_mercado = p_num_mercado)
          AND ((a.axo = p_axo AND a.periodo <= p_mes) OR (a.axo < p_axo))
          AND c.vigencia = 'A'
        GROUP BY c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque,
                 c.nombre, c.superficie, c.clave_cuota, d.recaudadora, e.descripcion, a.axo
        ORDER BY c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque, a.axo
    LOOP
        -- Calcular meses adeudados
        meses_str := '';
        FOR m IN SELECT periodo, importe FROM ta_11_adeudo_local WHERE id_local = r.id_local AND (
            (axo = r.axo AND periodo <= p_mes) OR (axo < r.axo)
        ) ORDER BY periodo LOOP
            meses_str := meses_str || m.periodo::TEXT || ' ';
            renta_val := m.importe;
        END LOOP;
        -- Calcular folios de requerimientos
        folios_str := '';
        FOR f IN SELECT folio, vigencia, clave_practicado FROM ta_15_apremios WHERE modulo = 11 AND control_otr = r.id_local LOOP
            IF f.vigencia = '1' AND f.clave_practicado = 'P' THEN
                folios_str := folios_str || f.folio::TEXT || ',';
            END IF;
        END LOOP;
        RETURN NEXT (
            r.id_local, r.oficina, r.num_mercado, r.categoria, r.seccion, r.local, r.letra_local, r.bloque,
            r.nombre, r.superficie, r.clave_cuota, r.adeudo, r.recaudadora, r.descripcion,
            TRIM(BOTH ' ' FROM SUBSTRING(meses_str FROM 1 FOR GREATEST(0, LENGTH(meses_str)-1))),
            renta_val, r.axo,
            TRIM(BOTH ',' FROM folios_str)
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;