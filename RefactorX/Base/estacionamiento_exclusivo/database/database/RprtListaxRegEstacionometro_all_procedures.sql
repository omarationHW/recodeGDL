-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RprtListaxRegEstacionometro
-- Generado: 2025-08-27 14:43:30
-- Total SPs: 2
-- ============================================

-- SP 1/2: rpt_listaxreg_estacionometro
-- Tipo: Report
-- Descripción: Obtiene el listado de registros de estacionómetros con requerimientos, filtrando por vigencia, clave_practicado, colonia y oficina.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_listaxreg_estacionometro(
    p_vigencia VARCHAR,
    p_clave_practicado VARCHAR,
    p_colonia VARCHAR,
    p_oficina SMALLINT
)
RETURNS TABLE (
    id INTEGER,
    placa VARCHAR,
    colonia VARCHAR,
    id_control INTEGER,
    zona SMALLINT,
    modulo SMALLINT,
    control_otr INTEGER,
    folio INTEGER,
    diligencia VARCHAR,
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    zona_apremio SMALLINT,
    fecha_emision DATE,
    clave_practicado VARCHAR,
    fecha_practicado DATE,
    fecha_entrega1 DATE,
    fecha_entrega2 DATE,
    fecha_citatorio DATE,
    hora TIMESTAMP,
    ejecutor SMALLINT,
    clave_secuestro SMALLINT,
    clave_remate VARCHAR,
    fecha_remate DATE,
    porcentaje_multa SMALLINT,
    observaciones VARCHAR,
    fecha_pago DATE,
    recaudadora SMALLINT,
    caja VARCHAR,
    operacion INTEGER,
    importe_pago NUMERIC,
    vigencia VARCHAR,
    fecha_actualiz DATE,
    usuario INTEGER,
    clave_mov VARCHAR,
    hora_practicado TIMESTAMP,
    fea_secuencia INTEGER,
    id_ejecutor INTEGER,
    cve_eje INTEGER,
    ini_rfc VARCHAR,
    fec_rfc DATE,
    hom_rfc VARCHAR,
    nombre VARCHAR,
    id_rec SMALLINT,
    categoria VARCHAR,
    observacion VARCHAR,
    oficio VARCHAR,
    fecinic DATE,
    fecterm DATE,
    vigencia_1 VARCHAR
) AS $$
DECLARE
    sql TEXT;
BEGIN
    sql := 'SELECT a.id, a.placa, a.colonia, b.id_control, b.zona, b.modulo, b.control_otr, b.folio, b.diligencia, b.importe_global, b.importe_multa, b.importe_recargo, b.importe_gastos, b.zona_apremio, b.fecha_emision, b.clave_practicado, b.fecha_practicado, b.fecha_entrega1, b.fecha_entrega2, b.fecha_citatorio, b.hora, b.ejecutor, b.clave_secuestro, b.clave_remate, b.fecha_remate, b.porcentaje_multa, b.observaciones, b.fecha_pago, b.recaudadora, b.caja, b.operacion, b.importe_pago, b.vigencia, b.fecha_actualiz, b.usuario, b.clave_mov, b.hora_practicado, b.fea_secuencia, b.id_ejecutor, b.cve_eje, b.ini_rfc, b.fec_rfc, b.hom_rfc, b.nombre, b.id_rec, b.categoria, b.observacion, b.oficio, b.fecinic, b.fecterm, b.vigencia_1 FROM ta_padron a JOIN db_ingresos.ta_15_apremios b ON b.control_otr = a.id JOIN db_ingresos.ta_15_ejecutores c ON b.ejecutor = c.cve_eje WHERE a.id > 0 AND TRIM(a.municipio) = ''GUADALAJARA'' AND TRIM(a.colonia) = $1 AND a.modulo = 14 AND b.vigencia = ''1'' AND b.zona = 2 AND c.id_rec = b.zona';

    IF p_clave_practicado IS NOT NULL AND p_clave_practicado <> 'todas' THEN
        sql := sql || ' AND b.clave_practicado = ' || quote_literal(p_clave_practicado);
    END IF;
    IF p_vigencia IS NOT NULL AND p_vigencia <> 'todas' THEN
        IF p_vigencia = '2' THEN
            sql := sql || ' AND (b.vigencia = ' || quote_literal(p_vigencia) || ' OR b.vigencia = ''P'')';
        ELSE
            sql := sql || ' AND b.vigencia = ' || quote_literal(p_vigencia);
        END IF;
    END IF;
    IF p_oficina IS NOT NULL THEN
        sql := sql || ' AND c.id_rec = ' || p_oficina;
    END IF;
    -- sql := sql || ' ORDER BY b.num_mercado, b.local'; -- Uncomment if needed
    RETURN QUERY EXECUTE sql USING p_colonia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: get_recaudadora_zona
-- Tipo: Catalog
-- Descripción: Obtiene información de la recaudadora y zona por id_rec.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_recaudadora_zona(p_rec SMALLINT)
RETURNS TABLE (
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora VARCHAR,
    domicilio VARCHAR,
    tel VARCHAR,
    recaudador VARCHAR,
    sector VARCHAR,
    zona VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_rec, a.id_zona, a.recaudadora, a.domicilio, a.tel, a.recaudador, a.sector, b.zona
    FROM padron_licencias.comun.ta_12_recaudadoras a
    JOIN padron_licencias.comun.ta_12_zonas b ON a.id_zona = b.id_zona
    WHERE a.id_rec = p_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

