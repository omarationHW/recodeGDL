-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptRecup_Merc
-- Generado: 2025-08-27 15:03:18
-- Total SPs: 3
-- ============================================

-- SP 1/3: rptrecup_merc_report
-- Tipo: Report
-- Descripción: Obtiene el reporte de requerimiento de pago y embargo para mercados, filtrando por zona (ofna) y rango de folios.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rptrecup_merc_report(
    p_ofna SMALLINT,
    p_folio1 INTEGER,
    p_folio2 INTEGER
)
RETURNS TABLE (
    -- Campos principales del reporte
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    local SMALLINT,
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    id_contribuy_prop INTEGER,
    id_contribuy_renta INTEGER,
    nombre VARCHAR(60),
    arrendatario VARCHAR(60),
    domicilio VARCHAR(80),
    sector VARCHAR(1),
    zona SMALLINT,
    descripcion_local VARCHAR(80),
    superficie FLOAT,
    giro SMALLINT,
    fecha_alta DATE,
    fecha_baja DATE,
    fecha_modificacion TIMESTAMP,
    vigencia VARCHAR(1),
    id_usuario INTEGER,
    clave_cuota SMALLINT,
    descripcion VARCHAR(60),
    id_control INTEGER,
    zona_1 SMALLINT,
    modulo SMALLINT,
    control_otr INTEGER,
    folio INTEGER,
    diligencia VARCHAR(1),
    importe_global NUMERIC(18,2),
    importe_multa NUMERIC(18,2),
    importe_recargo NUMERIC(18,2),
    importe_gastos NUMERIC(18,2),
    zona_apremio SMALLINT,
    fecha_emision DATE,
    clave_practicado VARCHAR(1),
    fecha_practicado DATE,
    fecha_entrega1 DATE,
    fecha_entrega2 DATE,
    fecha_citatorio DATE,
    hora TIMESTAMP,
    ejecutor SMALLINT,
    clave_secuestro SMALLINT,
    clave_remate VARCHAR(1),
    fecha_remate DATE,
    porcentaje_multa SMALLINT,
    observaciones VARCHAR(255),
    fecha_pago DATE,
    recaudadora SMALLINT,
    caja VARCHAR(1),
    operacion INTEGER,
    importe_pago NUMERIC(18,2),
    vigencia_1 VARCHAR(1),
    fecha_actualiz DATE,
    usuario INTEGER,
    clave_mov VARCHAR(2),
    hora_practicado TIMESTAMP,
    id_control_1 INTEGER,
    control_otr_1 INTEGER,
    ayo SMALLINT,
    periodo SMALLINT,
    importe NUMERIC(18,2),
    recargos NUMERIC(18,2),
    cantidad NUMERIC(18,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque,
           a.id_contribuy_prop, a.id_contribuy_renta, a.nombre, a.arrendatario, a.domicilio, a.sector, a.zona,
           a.descripcion_local, a.superficie, a.giro, a.fecha_alta, a.fecha_baja, a.fecha_modificacion, a.vigencia,
           a.id_usuario, a.clave_cuota, b.descripcion, c.id_control, c.zona as zona_1, c.modulo, c.control_otr, c.folio,
           c.diligencia, c.importe_global, c.importe_multa, c.importe_recargo, c.importe_gastos, c.zona_apremio,
           c.fecha_emision, c.clave_practicado, c.fecha_practicado, c.fecha_entrega1, c.fecha_entrega2, c.fecha_citatorio,
           c.hora, c.ejecutor, c.clave_secuestro, c.clave_remate, c.fecha_remate, c.porcentaje_multa, c.observaciones,
           c.fecha_pago, c.recaudadora, c.caja, c.operacion, c.importe_pago, c.vigencia as vigencia_1, c.fecha_actualiz,
           c.usuario, c.clave_mov, c.hora_practicado, d.id_control as id_control_1, d.control_otr as control_otr_1,
           d.ayo, d.periodo, d.importe, d.recargos, b.cantidad
    FROM ta_11_locales a
    JOIN ta_11_mercados b ON a.num_mercado = b.num_mercado_nvo AND a.oficina = b.oficina
    JOIN ta_15_apremios c ON c.control_otr = a.id_local
    JOIN ta_15_periodos d ON c.id_control = d.control_otr
    WHERE c.modulo = 11
      AND c.zona = p_ofna
      AND c.folio >= p_folio1 AND c.folio <= p_folio2
    ORDER BY c.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: rptrecup_merc_recaudadora
-- Tipo: Catalog
-- Descripción: Obtiene los datos de la recaudadora, nombre y zona para la cabecera del reporte.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rptrecup_merc_recaudadora(
    p_reca SMALLINT
)
RETURNS TABLE (
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora VARCHAR(32),
    domicilio VARCHAR(32),
    tel VARCHAR(15),
    recaudador VARCHAR(32),
    sector VARCHAR(1),
    recing SMALLINT,
    nomre VARCHAR(60),
    id_zona_1 INTEGER,
    zona VARCHAR(2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_rec, a.id_zona, a.recaudadora, a.domicilio, a.tel, a.recaudador, a.sector, b.recing, b.nomre, c.id_zona as id_zona_1, c.zona
    FROM padron_licencias.comun.ta_12_recaudadoras a
    JOIN padron_licencias.comun.ta_12_nombrerec b ON a.id_rec = b.recing
    JOIN padron_licencias.comun.ta_12_zonas c ON a.id_zona = c.id_zona
    WHERE a.id_rec = p_reca;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: fecha_aletras
-- Tipo: CRUD
-- Descripción: Convierte una fecha a formato de letras en español (ejemplo: '5 de Junio de 2024').
-- --------------------------------------------

CREATE OR REPLACE FUNCTION fecha_aletras(p_fecha DATE)
RETURNS TEXT AS $$
DECLARE
    meses TEXT[] := ARRAY['', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    y INT;
    m INT;
    d INT;
BEGIN
    y := EXTRACT(YEAR FROM p_fecha)::INT;
    m := EXTRACT(MONTH FROM p_fecha)::INT;
    d := EXTRACT(DAY FROM p_fecha)::INT;
    RETURN d::TEXT || ' de ' || meses[m] || ' de ' || y::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

