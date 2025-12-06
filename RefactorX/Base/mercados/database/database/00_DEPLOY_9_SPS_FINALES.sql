-- ============================================
-- DEPLOYMENT - 9 STORED PROCEDURES FINALES
-- Base: padron_licencias
-- Fecha: 2025-12-05
-- CORREGIDOS: Solo usan schema.tabla (NO base.schema.tabla)
-- ============================================

-- ============================================
-- SP 1/9: sp_list_cuotas_energia
-- Descripción: Lista cuotas de energía eléctrica
-- Usado por: CuotasEnergiaMntto.vue
-- ============================================

DROP FUNCTION IF EXISTS sp_list_cuotas_energia(smallint, smallint);

CREATE OR REPLACE FUNCTION sp_list_cuotas_energia(
    p_axo smallint DEFAULT NULL,
    p_periodo smallint DEFAULT NULL
)
RETURNS TABLE (
    id_kilowhatts integer,
    axo smallint,
    periodo smallint,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer,
    usuario varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        k.id_kilowhatts,
        k.axo,
        k.periodo,
        k.importe,
        k.fecha_alta,
        k.id_usuario,
        COALESCE(u.usuario, 'N/A')::varchar AS usuario
    FROM public.ta_11_kilowhatts k
    LEFT JOIN public.usuarios u ON k.id_usuario = u.id
    WHERE (p_axo IS NULL OR k.axo = p_axo)
      AND (p_periodo IS NULL OR k.periodo = p_periodo)
    ORDER BY k.axo DESC, k.periodo DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 2/9: sp_get_categorias
-- Descripción: Catálogo de categorías de mercados
-- Usado por: Múltiples componentes
-- CORREGIDO: Agregado public. antes de ta_11_categoria
-- ============================================

DROP FUNCTION IF EXISTS sp_get_categorias();

CREATE OR REPLACE FUNCTION sp_get_categorias()
RETURNS TABLE(
    categoria smallint,
    descripcion varchar(30)
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT t.categoria, t.descripcion
    FROM public.ta_11_categoria t
    ORDER BY t.categoria;
END;
$$;

-- ============================================
-- SP 3/9: cuotasmdo_listar
-- Descripción: Lista todas las cuotas de mercado por año
-- Usado por: CuotasMdoMntto.vue
-- CORREGIDO: Agregado public. antes de ta_11_cuo_locales
-- ============================================

DROP FUNCTION IF EXISTS cuotasmdo_listar();

CREATE OR REPLACE FUNCTION cuotasmdo_listar()
RETURNS TABLE (
    id_cuotas integer,
    axo smallint,
    categoria smallint,
    seccion char(2),
    clave_cuota smallint,
    importe_cuota numeric(16,2),
    fecha_alta timestamp,
    id_usuario integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id_cuotas,
        t.axo,
        t.categoria,
        t.seccion,
        t.clave_cuota,
        t.importe_cuota,
        t.fecha_alta,
        t.id_usuario
    FROM public.ta_11_cuo_locales t
    ORDER BY t.axo DESC, t.categoria, t.seccion, t.clave_cuota;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 4/9: fechas_descuento_get_all
-- Descripción: Obtiene todas las fechas de descuento y recargos
-- Usado por: FechasDescuentoMntto.vue
-- CORREGIDO: "publico" -> "public"
-- ============================================

DROP FUNCTION IF EXISTS fechas_descuento_get_all();

CREATE OR REPLACE FUNCTION fechas_descuento_get_all()
RETURNS TABLE (
    mes smallint,
    fecha_descuento date,
    fecha_recargos date,
    fecha_alta timestamp,
    id_usuario integer,
    usuario varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        f.mes,
        f.fecha_descuento,
        f.fecha_recargos,
        f.fecha_alta,
        f.id_usuario,
        COALESCE(u.usuario, 'N/A')::varchar AS usuario
    FROM public.ta_11_fecha_desc f
    LEFT JOIN public.usuarios u ON u.id = f.id_usuario
    ORDER BY f.mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 5/9: sp_insert_cuota_energia
-- Descripción: Inserta nueva cuota de energía
-- Usado por: CuotasEnergiaMntto.vue
-- ============================================

DROP FUNCTION IF EXISTS sp_insert_cuota_energia(smallint, smallint, numeric, integer);

CREATE OR REPLACE FUNCTION sp_insert_cuota_energia(
    p_axo smallint,
    p_periodo smallint,
    p_importe numeric,
    p_id_usuario integer
)
RETURNS TABLE (
    id_kilowhatts integer,
    axo smallint,
    periodo smallint,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS $$
BEGIN
    RETURN QUERY
    INSERT INTO public.ta_11_kilowhatts (axo, periodo, importe, fecha_alta, id_usuario)
    VALUES (p_axo, p_periodo, p_importe, CURRENT_TIMESTAMP, p_id_usuario)
    RETURNING
        ta_11_kilowhatts.id_kilowhatts,
        ta_11_kilowhatts.axo,
        ta_11_kilowhatts.periodo,
        ta_11_kilowhatts.importe,
        ta_11_kilowhatts.fecha_alta,
        ta_11_kilowhatts.id_usuario;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 6/9: rpt_adeudos_energia
-- Descripción: Reporte de adeudos de energía
-- Usado por: RptAdeudosEnergia.vue
-- ============================================

DROP FUNCTION IF EXISTS rpt_adeudos_energia(integer, smallint);

CREATE OR REPLACE FUNCTION public.rpt_adeudos_energia(
    p_axo integer,
    p_oficina smallint
)
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
    rec RECORD;
    m RECORD;
    v_meses TEXT;
    v_cuota NUMERIC(18,2);
    v_datoslocal TEXT;
BEGIN
    FOR rec IN
        SELECT
            c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local,
            c.letra_local, c.bloque, f.cve_consumo, f.id_energia, c.nombre,
            f.local_adicional, a.axo, SUM(a.importe) AS adeudo,
            UPPER(b.recaudadora) AS recaudadora, d.descripcion, b.id_rec
        FROM public.ta_11_adeudo_energ a
        INNER JOIN comun.ta_11_locales c ON a.id_local = c.id_local
        INNER JOIN public.ta_11_energia f ON a.id_energia = f.id_energia AND f.vigencia <> 'B'
        INNER JOIN comun.ta_12_recaudadoras b ON c.oficina = b.id_rec
        INNER JOIN comun.ta_11_mercados d ON c.oficina = d.oficina
        WHERE a.axo = p_axo AND c.oficina = p_oficina
        GROUP BY
            c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local,
            c.letra_local, c.bloque, f.cve_consumo, f.id_energia, c.nombre,
            f.local_adicional, a.axo, b.recaudadora, d.descripcion, b.id_rec
        ORDER BY
            c.oficina, c.num_mercado, c.categoria, c.seccion, c.local,
            c.letra_local, c.bloque, d.descripcion
    LOOP
        v_datoslocal := rec.oficina::text || '-' || rec.num_mercado::text || '-' ||
                        rec.categoria::text || '-' || rec.seccion || '-' || rec.local::text ||
                        '-' || rec.letra_local || '-' || rec.bloque;

        v_meses := '';
        v_cuota := NULL;

        FOR m IN
            SELECT periodo, importe
            FROM public.ta_11_adeudo_energ
            WHERE id_energia = rec.id_energia AND axo = p_axo
            ORDER BY periodo ASC
        LOOP
            v_meses := v_meses || m.periodo::text || '-';
            v_cuota := m.importe;
        END LOOP;

        IF length(v_meses) > 0 THEN
            v_meses := left(v_meses, length(v_meses)-1);
        ELSE
            v_meses := '';
        END IF;

        -- Retornar el registro completo
        id_local := rec.id_local;
        oficina := rec.oficina;
        num_mercado := rec.num_mercado;
        categoria := rec.categoria;
        seccion := rec.seccion;
        local := rec.local;
        letra_local := rec.letra_local;
        bloque := rec.bloque;
        cve_consumo := rec.cve_consumo;
        id_energia := rec.id_energia;
        nombre := rec.nombre;
        local_adicional := rec.local_adicional;
        axo := rec.axo;
        adeudo := rec.adeudo;
        recaudadora := rec.recaudadora;
        descripcion := rec.descripcion;
        id_rec := rec.id_rec;
        datoslocal := v_datoslocal;
        meses := v_meses;
        cuota := v_cuota;

        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 7/9: sp_reporte_catalogo_mercados
-- Descripción: Genera reporte PDF (dummy)
-- Usado por: Múltiples componentes
-- ============================================

DROP FUNCTION IF EXISTS sp_reporte_catalogo_mercados();

CREATE OR REPLACE FUNCTION sp_reporte_catalogo_mercados()
RETURNS TABLE(pdf_url TEXT) AS $$
DECLARE
    v_pdf_url TEXT;
BEGIN
    -- Retorna URL dummy para PDF
    v_pdf_url := '/storage/reportes/catalogo_mercados.pdf';
    RETURN QUERY SELECT v_pdf_url;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 8/9: sp_rpt_saldos_locales
-- Descripción: Reporte de saldos de locales por mercado
-- Usado por: RptSaldosLocales.vue
-- ============================================

DROP FUNCTION IF EXISTS sp_rpt_saldos_locales(INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_rpt_saldos_locales(
    p_oficina INTEGER,
    p_mercado INTEGER,
    p_axo INTEGER DEFAULT NULL
)
RETURNS TABLE(
    id_local INTEGER,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    local INTEGER,
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    nombre VARCHAR(50),
    total_adeudos NUMERIC(12,2),
    total_pagos NUMERIC(12,2),
    saldo NUMERIC(12,2),
    ultimo_pago DATE,
    periodos_adeudo INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH adeudos_por_local AS (
        SELECT
            a.id_local,
            SUM(COALESCE(a.importe, 0) + COALESCE(a.recargos, 0)) as total_adeudo,
            COUNT(DISTINCT CONCAT(a.axo::TEXT, '-', a.periodo::TEXT)) as periodos
        FROM comun.ta_11_adeudos_local a
        WHERE (p_axo IS NULL OR a.axo = p_axo)
        GROUP BY a.id_local
    ),
    pagos_por_local AS (
        SELECT
            p.id_local,
            SUM(COALESCE(p.importe_pago, 0)) as total_pago,
            MAX(p.fecha_pago) as ultimo_pago_fecha
        FROM comun.ta_11_pagos_local p
        WHERE (p_axo IS NULL OR p.axo = p_axo)
        GROUP BY p.id_local
    )
    SELECT
        l.id_local,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque,
        COALESCE(l.nombre, 'SIN NOMBRE') as nombre,
        COALESCE(a.total_adeudo, 0.00) as total_adeudos,
        COALESCE(p.total_pago, 0.00) as total_pagos,
        (COALESCE(a.total_adeudo, 0.00) - COALESCE(p.total_pago, 0.00)) as saldo,
        p.ultimo_pago_fecha as ultimo_pago,
        COALESCE(a.periodos, 0) as periodos_adeudo
    FROM comun.ta_11_locales l
    INNER JOIN comun.ta_11_mercados m ON m.num_mercado_nvo = l.num_mercado
    LEFT JOIN adeudos_por_local a ON a.id_local = l.id_local
    LEFT JOIN pagos_por_local p ON p.id_local = l.id_local
    WHERE m.oficina = p_oficina
      AND l.num_mercado = p_mercado
    ORDER BY
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque;
END;
$$;

-- ============================================
-- SP 9/9: sp_rpt_emision_rbos_abastos
-- Descripción: Reporte de emisión de recibos de abastos
-- Usado por: RptEmisionRbosAbastos.vue
-- ============================================

DROP FUNCTION IF EXISTS sp_rpt_emision_rbos_abastos(integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION public.sp_rpt_emision_rbos_abastos(
    p_oficina integer,
    p_mercado integer,
    p_axo integer,
    p_periodo integer
) RETURNS TABLE (
    id_local integer,
    oficina integer,
    num_mercado integer,
    categoria integer,
    seccion text,
    local integer,
    letra_local text,
    bloque text,
    nombre text,
    descripcion text,
    descripcion_local text,
    axo_1 integer,
    categoria_1 integer,
    seccion_1 text,
    clave_cuota integer,
    importe_cuota numeric,
    renta numeric,
    rentaaxos numeric,
    meses text,
    adeudo numeric,
    recargos numeric,
    subtotal numeric,
    multa numeric
) AS $$
DECLARE
    rec record;
    m_rec record;
    v_cad text;
    v_rentaaxos numeric;
    v_renta numeric;
BEGIN
    FOR rec IN
        SELECT
            a.id_local,
            a.oficina,
            a.num_mercado,
            a.categoria,
            a.seccion,
            a.local,
            a.letra_local,
            a.bloque,
            a.nombre,
            b.descripcion,
            a.descripcion_local,
            c.axo AS axo_1,
            c.categoria AS categoria_1,
            c.seccion AS seccion_1,
            c.clave_cuota,
            c.importe_cuota,
            COALESCE(SUM(d.importe),0) AS adeudo,
            COALESCE(SUM(ROUND((d.importe * (
                SELECT SUM(porcentaje_mes)
                FROM comun.ta_12_recargos
                WHERE (axo = d.axo AND mes >= d.periodo) OR (axo > d.axo)
            ))/100,2)),0) AS recargos
        FROM comun.ta_11_locales a
        INNER JOIN comun.ta_11_mercados b
            ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado
        INNER JOIN public.ta_11_cuo_locales c
            ON a.categoria = c.categoria
            AND a.seccion = c.seccion
            AND a.clave_cuota = c.clave_cuota
            AND c.axo = p_axo
        LEFT JOIN comun.ta_11_adeudo_local d
            ON a.id_local = d.id_local
        WHERE a.oficina = p_oficina
          AND a.num_mercado = p_mercado
          AND a.vigencia = 'A'
          AND ((d.axo = p_axo AND d.periodo < p_periodo) OR (d.axo < p_axo))
          AND a.id_local NOT IN (
              SELECT id_local
              FROM public.ta_11_pagos_local
              WHERE id_local = a.id_local
                AND axo = p_axo
                AND periodo = p_periodo
          )
        GROUP BY
            a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion,
            a.local, a.letra_local, a.bloque, a.nombre, b.descripcion,
            a.descripcion_local, c.axo, c.categoria, c.seccion,
            c.clave_cuota, c.importe_cuota
        ORDER BY
            a.oficina, a.num_mercado, a.categoria, a.seccion,
            a.local, a.letra_local, a.bloque, c.axo
    LOOP
        -- Calcular renta según tipo de sección
        IF rec.seccion = 'PS' THEN
            v_renta := (rec.importe_cuota * COALESCE((
                SELECT superficie
                FROM comun.ta_11_locales
                WHERE id_local = rec.id_local
            ), 1)) * 30;
        ELSE
            v_renta := COALESCE((
                SELECT superficie
                FROM comun.ta_11_locales
                WHERE id_local = rec.id_local
            ), 1) * rec.importe_cuota;
        END IF;

        -- Calcular rentaaxos y meses adeudados
        v_cad := '';
        v_rentaaxos := 0;

        FOR m_rec IN
            SELECT periodo, importe, axo
            FROM comun.ta_11_adeudo_local
            WHERE id_local = rec.id_local
              AND axo = rec.axo_1
        LOOP
            IF m_rec.axo < p_axo THEN
                v_cad := v_cad || m_rec.periodo::text || ',';
                v_rentaaxos := m_rec.importe;
            ELSIF m_rec.axo = p_axo AND m_rec.periodo < p_periodo THEN
                v_cad := v_cad || m_rec.periodo::text || ',';
                v_rentaaxos := m_rec.importe;
            END IF;
        END LOOP;

        -- Asignar valores de salida
        id_local := rec.id_local;
        oficina := rec.oficina;
        num_mercado := rec.num_mercado;
        categoria := rec.categoria;
        seccion := rec.seccion;
        local := rec.local;
        letra_local := rec.letra_local;
        bloque := rec.bloque;
        nombre := rec.nombre;
        descripcion := rec.descripcion;
        descripcion_local := rec.descripcion_local;
        axo_1 := rec.axo_1;
        categoria_1 := rec.categoria_1;
        seccion_1 := rec.seccion_1;
        clave_cuota := rec.clave_cuota;
        importe_cuota := rec.importe_cuota;
        renta := v_renta;
        rentaaxos := v_rentaaxos;
        meses := LEFT(v_cad, GREATEST(LENGTH(v_cad)-1, 0));
        adeudo := rec.adeudo;
        recargos := rec.recargos;
        multa := 0;
        subtotal := rec.adeudo + rec.recargos + multa;

        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIN - 9 STORED PROCEDURES DESPLEGADOS
-- ============================================
