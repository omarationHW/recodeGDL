-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ListadosSinAdereq
-- Generado: 2025-08-27 13:58:36
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_listados_sin_adereq
-- Tipo: Report
-- Descripción: Obtiene listado de locales sin adeudo para requerimientos, filtrando por tipo, recaudadora, mercado, sección y rango de locales.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_listados_sin_adereq(
    p_tipo TEXT,
    p_id_rec INTEGER,
    p_num_mercado INTEGER,
    p_seccion TEXT,
    p_local1 INTEGER,
    p_local2 INTEGER
) RETURNS TABLE (
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion TEXT,
    local SMALLINT,
    letra_local TEXT,
    bloque TEXT,
    id_contribuy_prop INTEGER,
    id_contribuy_renta INTEGER,
    nombre TEXT,
    arrendatario TEXT,
    domicilio TEXT,
    sector TEXT,
    zona SMALLINT,
    descripcion_local TEXT,
    superficie FLOAT,
    giro SMALLINT,
    fecha_alta DATE,
    fecha_baja DATE,
    fecha_modificacion TIMESTAMP,
    vigencia TEXT,
    id_usuario INTEGER,
    clave_cuota SMALLINT,
    id_adeudo_local INTEGER,
    id_local_1 INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    importe NUMERIC,
    descripcion TEXT,
    renta NUMERIC,
    total_gasto NUMERIC,
    recargos NUMERIC
) AS $$
DECLARE
    v_sql TEXT;
BEGIN
    v_sql := 'SELECT a.*, b.*, c.descripcion, (b.importe) AS renta, '
        || '(SELECT COALESCE(SUM(importe_gastos),0) FROM ta_15_apremios WHERE modulo=11 AND control_otr=a.id_local AND clave_practicado=''P'' AND vigencia=''1'') AS total_gasto, '
        || '0 AS recargos '
        || 'FROM ta_11_locales a '
        || 'JOIN ta_11_adeudo_local b ON a.id_local = b.id_local '
        || 'JOIN ta_11_mercados c ON a.oficina = c.oficina AND a.num_mercado = c.num_mercado_nvo '
        || 'WHERE a.vigencia <> ''B'' ';
    IF p_id_rec IS NOT NULL THEN
        v_sql := v_sql || ' AND a.oficina = ' || p_id_rec;
    END IF;
    IF p_num_mercado IS NOT NULL THEN
        v_sql := v_sql || ' AND a.num_mercado = ' || p_num_mercado;
    END IF;
    IF p_seccion IS NOT NULL AND p_seccion <> ''todas'' THEN
        v_sql := v_sql || ' AND a.seccion = ''' || p_seccion || '''';
    END IF;
    v_sql := v_sql || ' AND a.local BETWEEN ' || p_local1 || ' AND ' || p_local2;
    v_sql := v_sql || ' ORDER BY a.id_local, b.axo, b.periodo';
    RETURN QUERY EXECUTE v_sql;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_ultimo_movimiento_local
-- Tipo: Report
-- Descripción: Devuelve el último movimiento (folio) de un local.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_ultimo_movimiento_local(
    p_id_local INTEGER
) RETURNS TABLE (
    id_control INTEGER,
    zona SMALLINT,
    modulo SMALLINT,
    control_otr INTEGER,
    folio INTEGER,
    diligencia TEXT,
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    zona_apremio SMALLINT,
    fecha_emision DATE,
    clave_practicado TEXT,
    fecha_practicado DATE,
    fecha_entrega1 DATE,
    fecha_entrega2 DATE,
    fecha_citatorio DATE,
    hora TIMESTAMP,
    ejecutor SMALLINT,
    clave_secuestro SMALLINT,
    clave_remate TEXT,
    fecha_remate DATE,
    porcentaje_multa SMALLINT,
    observaciones TEXT,
    fecha_pago DATE,
    recaudadora SMALLINT,
    caja TEXT,
    operacion INTEGER,
    importe_pago NUMERIC,
    vigencia TEXT,
    fecha_actualiz DATE,
    usuario INTEGER,
    clave_mov TEXT,
    hora_practicado TIMESTAMP,
    vigen TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT *,
        CASE WHEN vigencia='1' THEN 'Vigente' WHEN vigencia='2' THEN 'Pagado' WHEN vigencia='P' THEN 'Pagado' ELSE 'Cancelado' END AS vigen
    FROM ta_15_apremios
    WHERE control_otr = p_id_local AND modulo = 11
    ORDER BY id_control DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

