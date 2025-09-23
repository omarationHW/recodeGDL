-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ipor
-- Generado: 2025-08-27 12:29:04
-- Total SPs: 5
-- ============================================

-- SP 1/5: requerimientos.get_requerimientos
-- Tipo: Report
-- Descripción: Obtiene los requerimientos de predial según parámetros de año, recaudadora y rango de folios.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION requerimientos.get_requerimientos(axoreq integer, recaud integer, folioini integer, foliofin integer)
RETURNS TABLE(
    cvereq integer,
    cveejecut integer,
    folioreq integer,
    axoreq integer,
    cvecuenta integer,
    recaud integer,
    cvepago integer,
    impuesto numeric,
    recargos numeric,
    gastos numeric,
    multas numeric,
    total numeric,
    gasto_req numeric,
    fecemi date,
    fecent date,
    cvecancr varchar,
    axoini integer,
    bimini integer,
    axofin integer,
    bimfin integer,
    secuencia integer,
    vigencia varchar,
    feccap date,
    capturista varchar,
    fecejec date,
    feccit date,
    horacit varchar,
    horaprac varchar,
    recibereq varchar,
    recibecit varchar,
    obs text,
    feccan date,
    nodiligenciado varchar,
    zona_subzona varchar,
    impreso varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM reqpredial
    WHERE axoreq = $1 AND recaud = $2 AND folioreq BETWEEN $3 AND $4;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: requerimientos.assign_requerimientos
-- Tipo: CRUD
-- Descripción: Asigna requerimientos a ejecutores según tipo, ejecutor, fecha, recaudadora y rango de folios.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION requerimientos.assign_requerimientos(tipo text, ejecutor_id integer, fecha date, recaud integer, folioini integer, foliofin integer)
RETURNS TABLE(
    asignados integer,
    mensaje text
) AS $$
DECLARE
    n_asignados integer := 0;
BEGIN
    IF tipo = 'predial' THEN
        UPDATE reqpredial
        SET cveejecut = ejecutor_id, fecejec = fecha
        WHERE recaud = recaud AND folioreq BETWEEN folioini AND foliofin AND cveejecut IS NULL;
        GET DIAGNOSTICS n_asignados = ROW_COUNT;
        RETURN QUERY SELECT n_asignados, 'Asignados a ejecutor ' || ejecutor_id;
    ELSIF tipo = 'multas' THEN
        UPDATE reqmultas
        SET cveejecut = ejecutor_id, fecejec = fecha
        WHERE recaud = recaud AND folioreq BETWEEN folioini AND foliofin AND cveejecut IS NULL;
        GET DIAGNOSTICS n_asignados = ROW_COUNT;
        RETURN QUERY SELECT n_asignados, 'Asignados a ejecutor ' || ejecutor_id;
    -- Agregar lógica para licencias, anuncios, diferencias si aplica
    ELSE
        RETURN QUERY SELECT 0, 'Tipo no soportado';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: requerimientos.print_requerimientos
-- Tipo: Report
-- Descripción: Genera los datos para impresión de requerimientos según fecha, recaudadora, tipo de impresión y ejecutor.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION requerimientos.print_requerimientos(fecha date, recaud integer, tipo_impresion text, ejecutor_id integer)
RETURNS TABLE(
    folioreq integer,
    cveejecut integer,
    datos jsonb
) AS $$
BEGIN
    IF tipo_impresion = 'notificacion' THEN
        RETURN QUERY
        SELECT folioreq, cveejecut, to_jsonb(reqpredial.*)
        FROM reqpredial
        WHERE fecejec = fecha AND recaud = recaud AND cveejecut = ejecutor_id AND secuencia = 3;
    ELSIF tipo_impresion = 'requerimiento' THEN
        RETURN QUERY
        SELECT folioreq, cveejecut, to_jsonb(reqpredial.*)
        FROM reqpredial
        WHERE fecejec = fecha AND recaud = recaud AND cveejecut = ejecutor_id AND secuencia = 0;
    ELSE
        RETURN QUERY SELECT NULL, NULL, NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: requerimientos.get_ejecutores
-- Tipo: Catalog
-- Descripción: Obtiene la lista de ejecutores disponibles para una recaudadora y fecha.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION requerimientos.get_ejecutores(fecha date, recaud integer)
RETURNS TABLE(
    cveejecutor integer,
    ncompleto varchar,
    asignar integer,
    ultfec_entrega date
) AS $$
BEGIN
    RETURN QUERY
    SELECT cveejecutor, (paterno || ' ' || materno || ' ' || nombres) as ncompleto, asignados as asignar, ultfec_entrega
    FROM ejecutor
    WHERE recaud = $2 AND (vigencia = 'V' OR vigencia IS NULL);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: requerimientos.get_multas_grid
-- Tipo: Report
-- Descripción: Obtiene el grid de multas agrupadas por zona/subzona para asignación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION requerimientos.get_multas_grid(tipo text, recaud integer, folioini integer, foliofin integer)
RETURNS TABLE(
    zona_sub varchar,
    cantidad integer,
    ejecutor_id integer,
    asignar integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT zona || '/' || subzona as zona_sub, count(*) as cantidad, NULL::integer as ejecutor_id, NULL::integer as asignar
    FROM reqmultas
    WHERE recaud = recaud AND folioreq BETWEEN folioini AND foliofin AND tipo = tipo AND vigencia = 'V'
    GROUP BY zona, subzona;
END;
$$ LANGUAGE plpgsql;

-- ============================================

