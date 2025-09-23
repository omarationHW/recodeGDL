-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptLista_mercados
-- Generado: 2025-08-27 14:55:43
-- Total SPs: 4
-- ============================================

-- SP 1/4: rpt_lista_mercados
-- Tipo: Report
-- Descripción: Obtiene el listado de adeudos de mercados con cálculo de recargos y gastos, según filtros.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_lista_mercados(
    vofna integer,
    vmerc1 integer,
    vmerc2 integer,
    vlocal1 integer,
    vlocal2 integer,
    vsecc text
)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    local smallint,
    letra_local varchar,
    bloque varchar,
    id_contribuy_prop integer,
    id_contribuy_renta integer,
    nombre varchar,
    arrendatario varchar,
    domicilio varchar,
    sector varchar,
    zona smallint,
    descripcion_local varchar,
    superficie float,
    giro smallint,
    fecha_alta date,
    fecha_baja date,
    fecha_modificacion timestamp,
    vigencia varchar,
    id_usuario integer,
    clave_cuota smallint,
    id_adeudo_local integer,
    id_local_1 integer,
    axo smallint,
    periodo smallint,
    importe numeric,
    fecha_alta_1 timestamp,
    id_usuario_1 integer,
    descripcion varchar,
    renta numeric,
    total_gasto numeric,
    recargos numeric
) AS $$
DECLARE
    vaxo integer;
    vmes integer;
    vdia integer;
    sql text;
BEGIN
    -- Obtener fecha de corte del sistema (simulación, usar current_date)
    SELECT EXTRACT(YEAR FROM current_date)::integer, EXTRACT(MONTH FROM current_date)::integer, EXTRACT(DAY FROM current_date)::integer
      INTO vaxo, vmes, vdia;

    RETURN QUERY
    WITH base AS (
      SELECT a.*, b.*, c.descripcion, b.importe AS renta,
        (
          SELECT COALESCE(SUM(importe_gastos),0)
          FROM ta_15_apremios
          WHERE modulo=11 AND control_otr=a.id_local AND clave_practicado='P' AND vigencia='1'
        ) AS total_gasto
      FROM ta_11_locales a
      JOIN ta_11_adeudo_local b ON a.id_local = b.id_local
      JOIN ta_11_mercados c ON a.oficina = c.oficina AND a.num_mercado = c.num_mercado_nvo
      WHERE a.oficina = vofna
        AND a.num_mercado BETWEEN vmerc1 AND vmerc2
        AND (
          (b.axo < vaxo) OR
          (b.axo = vaxo AND (
            CASE WHEN vdia > 12 THEN b.periodo <= vmes ELSE b.periodo <= vmes-1 END
          ))
        )
        AND (
          vsecc = 'todas' OR (a.seccion = vsecc AND a.local BETWEEN vlocal1 AND vlocal2)
        )
    )
    SELECT *,
      (
        SELECT COALESCE(SUM(porcentaje_mes),0)
        FROM ta_12_recargos
        WHERE (
          (axo = base.axo AND mes >= base.periodo)
          OR (axo = vaxo AND mes <= (CASE WHEN vdia <= 12 THEN vmes-1 ELSE vmes END))
          OR (axo > base.axo AND axo < vaxo)
        )
      ) AS recargos_porc,
      0.0::numeric AS recargos
    FROM base;
END;
$$ LANGUAGE plpgsql;


-- ============================================

-- SP 2/4: rpt_lista_mercados_resumen
-- Tipo: Report
-- Descripción: Resumen de totales por mercado (importe, recargos, multas, gastos, total).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_lista_mercados_resumen(
    vofna integer,
    vmerc1 integer,
    vmerc2 integer,
    vlocal1 integer,
    vlocal2 integer,
    vsecc text
)
RETURNS TABLE (
    num_mercado smallint,
    total_importe numeric,
    total_recargos numeric,
    total_multas numeric,
    total_gastos numeric,
    total numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT
      t.num_mercado,
      SUM(t.importe) AS total_importe,
      SUM(t.recargos) AS total_recargos,
      SUM(t.importe)*0.5 AS total_multas,
      SUM(t.total_gasto) AS total_gastos,
      SUM(t.importe) + SUM(t.recargos) + SUM(t.importe)*0.5 + SUM(t.total_gasto) AS total
    FROM rpt_lista_mercados(vofna, vmerc1, vmerc2, vlocal1, vlocal2, vsecc) t
    GROUP BY t.num_mercado;
END;
$$ LANGUAGE plpgsql;


-- ============================================

-- SP 3/4: rpt_lista_mercados_gastos
-- Tipo: Report
-- Descripción: Obtiene los gastos de notificación, requerimiento, embargo, etc. para un año y mes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_lista_mercados_gastos(
    axo integer,
    mes integer
)
RETURNS TABLE (
    fecha_axo integer,
    fecha_mes smallint,
    gtos_notif numeric,
    gtos_requer numeric,
    gtos_requer_anual numeric,
    gtos_secue numeric,
    gtos_secue_anual numeric,
    gtos_embar numeric,
    gtos_embar_anual numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta_15_gastos WHERE fecha_axo = axo AND fecha_mes = mes;
END;
$$ LANGUAGE plpgsql;


-- ============================================

-- SP 4/4: rpt_lista_mercados_recargos
-- Tipo: CRUD
-- Descripción: Calcula el porcentaje de recargos para un adeudo dado el año, periodo y fecha de corte.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_lista_mercados_recargos(
    axo integer,
    periodo integer,
    vaxo integer,
    vmes integer,
    vdia integer
) RETURNS numeric AS $$
DECLARE
    vporcentaje numeric := 0;
BEGIN
    SELECT COALESCE(SUM(porcentaje_mes),0) INTO vporcentaje
    FROM ta_12_recargos
    WHERE (
        (axo = axo AND mes >= periodo)
        OR (axo = vaxo AND mes <= (CASE WHEN vdia <= 12 THEN vmes-1 ELSE vmes END))
        OR (axo > axo AND axo < vaxo)
    );
    IF vporcentaje > 250 THEN
        vporcentaje := 250;
    END IF;
    RETURN vporcentaje;
END;
$$ LANGUAGE plpgsql;


-- ============================================

