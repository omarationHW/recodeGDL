-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RprtListaxFec
-- Generado: 2025-08-27 14:37:49
-- Total SPs: 1
-- ============================================

-- SP 1/1: rprt_listaxfec
-- Tipo: Report
-- Descripción: Genera el listado de requerimientos por fecha y módulo, con lógica equivalente a la función 'inicio' de Delphi. Incluye lógica de joins y filtros dinámicos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rprt_listaxfec(
    vrec integer,
    vmod integer,
    vcve integer,
    vfec1 date,
    vfec2 date,
    vvig character varying,
    veje character varying
)
RETURNS TABLE (
    id_control integer,
    zona smallint,
    modulo smallint,
    control_otr integer,
    folio integer,
    diligencia varchar,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_gastos numeric,
    zona_apremio smallint,
    fecha_emision date,
    clave_practicado varchar,
    fecha_practicado date,
    fecha_entrega1 date,
    fecha_entrega2 date,
    fecha_citatorio date,
    hora timestamp,
    ejecutor smallint,
    clave_secuestro smallint,
    clave_remate varchar,
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar,
    fecha_pago date,
    recaudadora smallint,
    caja varchar,
    operacion integer,
    importe_pago numeric,
    vigencia varchar,
    fecha_actualiz date,
    usuario integer,
    clave_mov varchar,
    hora_practicado timestamp,
    nombre varchar,
    datos varchar,
    recaudadora_1 varchar,
    zona_1 varchar
) AS $$
DECLARE
    sql text;
BEGIN
    sql := 'SELECT a.*, b.nombre, c.recaudadora AS recaudadora_1, d.zona AS zona_1, '''' AS datos FROM ta_15_apremios a '
        || 'LEFT JOIN ta_15_ejecutores b ON a.zona = b.id_rec '
        || 'LEFT JOIN padron_licencias.comun.ta_12_recaudadoras c ON a.zona = c.id_rec '
        || 'LEFT JOIN padron_licencias.comun.ta_12_zonas d ON c.id_zona = d.id_zona '
        || 'WHERE a.zona = $1';

    IF vmod IS NOT NULL AND vmod <> 99 THEN
        sql := sql || ' AND a.modulo = ' || vmod;
    END IF;

    IF vvig IS NOT NULL AND vvig <> 'todas' THEN
        IF vvig = '2' THEN
            sql := sql || ' AND (a.vigencia = ''2'' OR a.vigencia = ''P'')';
        ELSE
            sql := sql || ' AND a.vigencia = ''' || vvig || '''';
        END IF;
    END IF;

    IF veje IS NOT NULL AND veje <> 'todos' THEN
        IF veje <> 'ninguno' THEN
            sql := sql || ' AND a.ejecutor = ' || quote_literal(veje);
        END IF;
    END IF;

    IF vcve = 1 THEN
        sql := sql || ' AND (a.fecha_actualiz >= ' || quote_literal(vfec1) || ' AND a.fecha_actualiz <= ' || quote_literal(vfec2) || ')';
        sql := sql || ' ORDER BY a.folio, a.fecha_actualiz';
    ELSIF vcve = 2 THEN
        sql := sql || ' AND (a.fecha_practicado >= ' || quote_literal(vfec1) || ' AND a.fecha_practicado <= ' || quote_literal(vfec2) || ')';
        sql := sql || ' ORDER BY a.ejecutor, a.folio';
    ELSIF vcve = 3 THEN
        sql := sql || ' AND (a.fecha_citatorio >= ' || quote_literal(vfec1) || ' AND a.fecha_citatorio <= ' || quote_literal(vfec2) || ')';
        sql := sql || ' ORDER BY a.folio, a.fecha_citatorio';
    ELSIF vcve = 4 THEN
        sql := sql || ' AND (a.fecha_pago >= ' || quote_literal(vfec1) || ' AND a.fecha_pago <= ' || quote_literal(vfec2) || ')';
        sql := sql || ' ORDER BY a.folio, a.fecha_pago';
    ELSIF vcve = 5 THEN
        sql := sql || ' AND (a.fecha_emision >= ' || quote_literal(vfec1) || ' AND a.fecha_emision <= ' || quote_literal(vfec2) || ')';
        sql := sql || ' ORDER BY a.folio, a.fecha_emision';
    ELSIF vcve = 6 THEN
        sql := sql || ' AND (a.fecha_entrega1 >= ' || quote_literal(vfec1) || ' AND a.fecha_entrega1 <= ' || quote_literal(vfec2) || ')';
        sql := sql || ' ORDER BY a.ejecutor, a.folio, a.fecha_entrega1';
    END IF;

    RETURN QUERY EXECUTE sql USING vrec;
END;
$$ LANGUAGE plpgsql;


-- ============================================

