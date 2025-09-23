-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptAdeudosAbastos1998
-- Generado: 2025-08-27 00:37:50
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_get_adeudos_abastos_1998
-- Tipo: Report
-- Descripción: Obtiene el listado de adeudos de mercados del año 1998 para una oficina y periodo dados, incluyendo datos de renta E/A y S/D.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_adeudos_abastos_1998(p_axo integer, p_oficina integer, p_periodo integer)
RETURNS TABLE(
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar(2),
    local smallint,
    letra_local varchar(1),
    bloque varchar(1),
    nombre varchar,
    superficie numeric,
    clave_cuota smallint,
    adeudo numeric,
    recaudadora varchar,
    descripcion varchar,
    meses varchar,
    datoslocal varchar,
    totmeses integer,
    renta_ea numeric,
    renta_sd numeric
) AS $$
DECLARE
    r RECORD;
    meses_str TEXT;
    totmeses INT;
    renta_ea NUMERIC;
    renta_sd NUMERIC;
    renta NUMERIC;
    mesesade INT;
    mesrec RECORD;
    qmes CURSOR FOR SELECT periodo, importe FROM ta_11_adeudo_local WHERE id_local = r.id_local AND axo = p_axo ORDER BY periodo;
BEGIN
    FOR r IN
        SELECT c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque, c.nombre, c.superficie, c.clave_cuota,
               SUM(a.importe) AS adeudo, UPPER(d.recaudadora) AS recaudadora, e.descripcion, d.id_rec
        FROM ta_11_adeudo_local a
        JOIN ta_11_locales c ON a.id_local = c.id_local
        JOIN ta_12_recaudadoras d ON c.oficina = d.id_rec
        JOIN ta_11_mercados e ON e.oficina = c.oficina AND e.num_mercado_nvo = c.num_mercado
        WHERE a.axo = p_axo AND c.oficina = p_oficina AND a.periodo <= p_periodo AND c.vigencia = 'A'
        GROUP BY c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque, c.nombre, c.superficie, c.clave_cuota, d.recaudadora, e.descripcion, d.id_rec
        ORDER BY c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque
    LOOP
        -- Calcular meses y totmeses
        meses_str := '';
        totmeses := 0;
        renta_ea := 0;
        renta_sd := 0;
        renta := 0;
        mesesade := 0;
        FOR mesrec IN SELECT periodo, importe FROM ta_11_adeudo_local WHERE id_local = r.id_local AND axo = p_axo AND periodo <= p_periodo ORDER BY periodo LOOP
            meses_str := meses_str || mesrec.periodo || ',';
            renta := mesrec.importe;
            IF mesrec.periodo <= 8 THEN
                renta_ea := renta_ea + mesrec.importe;
            ELSE
                renta_sd := renta_sd + mesrec.importe;
            END IF;
            mesesade := mesesade + 1;
        END LOOP;
        IF length(meses_str) > 0 THEN
            meses_str := left(meses_str, length(meses_str)-1);
        END IF;
        totmeses := mesesade;
        RETURN NEXT (
            r.id_local, r.oficina, r.num_mercado, r.categoria, r.seccion, r.local, r.letra_local, r.bloque, r.nombre, r.superficie, r.clave_cuota,
            r.adeudo, r.recaudadora, r.descripcion, meses_str,
            CONCAT(r.oficina, ' ', r.num_mercado, ' ', r.categoria, ' ', r.seccion, ' ', r.local, ' ', COALESCE(r.letra_local, ''), ' ', COALESCE(r.bloque, '')),
            totmeses, renta_ea, renta_sd
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_get_renta_1998
-- Tipo: Report
-- Descripción: Obtiene la renta para un local en 1998 según categoría, sección y clave de cuota.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_renta_1998(p_vaxo integer, p_vcat smallint, p_vsec varchar, p_vcve smallint)
RETURNS TABLE(
    id_cuotas integer,
    axo smallint,
    categoria smallint,
    seccion varchar,
    clave_cuota smallint,
    importe_cuota numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_cuotas, axo, categoria, seccion, clave_cuota, importe_cuota, fecha_alta, id_usuario
    FROM ta_11_cuo_locales
    WHERE axo = p_vaxo AND categoria = p_vcat AND seccion = p_vsec AND clave_cuota = p_vcve;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_get_meses_adeudo_1998
-- Tipo: Report
-- Descripción: Obtiene los meses de adeudo para un local en 1998.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_meses_adeudo_1998(p_vid_local integer, p_vaxo integer)
RETURNS TABLE(
    id_local integer,
    axo smallint,
    periodo smallint,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, axo, periodo, importe
    FROM ta_11_adeudo_local
    WHERE id_local = p_vid_local AND axo = p_vaxo
    ORDER BY periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

