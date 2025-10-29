-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptReq_pba
-- Generado: 2025-08-27 15:11:39
-- Total SPs: 5
-- ============================================

-- SP 1/5: rptreq_pba_get_report_data
-- Tipo: Report
-- Descripción: Obtiene los datos principales del reporte de requerimiento de pago y embargo, incluyendo cálculo de recargos y total de gastos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rptreq_pba_get_report_data(
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
    -- Obtener fecha actual del sistema
    SELECT EXTRACT(YEAR FROM CURRENT_DATE), EXTRACT(MONTH FROM CURRENT_DATE), EXTRACT(DAY FROM CURRENT_DATE)
      INTO vaxo, vmes, vdia;

    RETURN QUERY
    SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque,
           a.id_contribuy_prop, a.id_contribuy_renta, a.nombre, a.arrendatario, a.domicilio, a.sector, a.zona,
           a.descripcion_local, a.superficie, a.giro, a.fecha_alta, a.fecha_baja, a.fecha_modificacion, a.vigencia,
           a.id_usuario, a.clave_cuota, b.id_adeudo_local, b.id_local as id_local_1, b.axo, b.periodo, b.importe,
           b.fecha_alta as fecha_alta_1, b.id_usuario as id_usuario_1, c.descripcion,
           b.importe as renta,
           COALESCE((SELECT SUM(importe_gastos) FROM ta_15_apremios WHERE modulo=11 AND control_otr=a.id_local AND clave_practicado='P' AND vigencia='1'), 0) as total_gasto,
           rptreq_pba_calc_recargos(b.axo, b.periodo, b.importe, vaxo, vmes, vdia) as recargos
    FROM ta_11_locales a
    JOIN ta_11_adeudo_local b ON a.id_local = b.id_local
    JOIN ta_11_mercados c ON a.oficina = c.oficina AND a.num_mercado = c.num_mercado_nvo
    WHERE a.num_mercado >= vmerc1 AND a.num_mercado <= vmerc2
      AND (
        (b.axo < vaxo)
        OR (b.axo = vaxo AND (
            CASE WHEN vdia > 12 THEN b.periodo <= vmes ELSE b.periodo <= vmes - 1 END
        ))
      )
      AND (
        vsecc = 'todas' OR (
          a.seccion = vsecc AND a.local >= vlocal1 AND a.local <= vlocal2
        )
      );
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: rptreq_pba_calc_recargos
-- Tipo: CRUD
-- Descripción: Calcula el monto de recargos para un adeudo local según la lógica del reporte.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rptreq_pba_calc_recargos(
    varaxoper integer,
    varperiodo integer,
    importe numeric,
    vaxo integer,
    vmes integer,
    vdia integer
) RETURNS numeric AS $$
DECLARE
    vporcentaje float := 0;
    recargos numeric := 0;
BEGIN
    -- Suma de porcentaje de recargos
    SELECT COALESCE(SUM(porcentaje_mes), 0)
      INTO vporcentaje
      FROM ta_12_recargos
     WHERE (axo = varaxoper AND mes >= varperiodo)
        OR (axo = vaxo AND mes <= (CASE WHEN vdia <= 12 THEN vmes - 1 ELSE vmes END))
        OR (axo > varaxoper AND axo < vaxo);

    IF vporcentaje > 250 THEN
        vporcentaje := 250;
    END IF;

    IF varaxoper = vaxo THEN
        IF varperiodo = vmes THEN
            IF vdia > 12 THEN
                recargos := (importe * vporcentaje) / 100;
            ELSE
                recargos := 0;
            END IF;
        ELSE
            recargos := (importe * vporcentaje) / 100;
        END IF;
    ELSE
        recargos := (importe * vporcentaje) / 100;
    END IF;

    IF recargos > 0 THEN
        recargos := trunc(recargos::numeric, 2);
    END IF;

    RETURN recargos;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: rptreq_pba_get_gastos
-- Tipo: Report
-- Descripción: Obtiene los gastos de requerimiento para un año y mes dados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rptreq_pba_get_gastos(
    axo integer,
    mes integer
) RETURNS TABLE (
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
    SELECT fecha_axo, fecha_mes, gtos_notif, gtos_requer, gtos_requer_anual, gtos_secue, gtos_secue_anual, gtos_embar, gtos_embar_anual
    FROM ta_15_gastos
    WHERE fecha_axo = axo AND fecha_mes = mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: rptreq_pba_get_recargos
-- Tipo: Report
-- Descripción: Obtiene el porcentaje de recargos acumulado para un periodo de adeudo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rptreq_pba_get_recargos(
    axo integer,
    periodo integer,
    vaxo integer,
    vmes integer,
    vdia integer
) RETURNS TABLE (
    porcentaje float
) AS $$
BEGIN
    RETURN QUERY
    SELECT COALESCE(SUM(porcentaje_mes), 0) as porcentaje
    FROM ta_12_recargos
    WHERE (axo = axo AND mes >= periodo)
       OR (axo = vaxo AND mes <= (CASE WHEN vdia <= 12 THEN vmes - 1 ELSE vmes END))
       OR (axo > axo AND axo < vaxo);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: rptreq_pba_get_recaudadora
-- Tipo: Catalog
-- Descripción: Obtiene los datos de la recaudadora y zona para el reporte.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rptreq_pba_get_recaudadora(
    reca integer
) RETURNS TABLE (
    id_rec smallint,
    id_zona integer,
    recaudadora varchar,
    domicilio varchar,
    tel varchar,
    recaudador varchar,
    sector varchar,
    recing smallint,
    nomre varchar,
    id_zona_1 integer,
    zona varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_rec, a.id_zona, a.recaudadora, a.domicilio, a.tel, a.recaudador, a.sector, b.recing, b.nomre, c.id_zona, c.zona
    FROM ta_12_recaudadoras a
    JOIN ta_12_nombrerec b ON a.id_rec = b.recing
    JOIN ta_12_zonas c ON a.id_zona = c.id_zona
    WHERE a.id_rec = reca;
END;
$$ LANGUAGE plpgsql;

-- ============================================

