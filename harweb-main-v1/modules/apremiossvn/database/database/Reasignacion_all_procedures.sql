-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Reasignacion
-- Generado: 2025-08-27 14:23:03
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_reasignar_folio
-- Tipo: CRUD
-- Descripción: Reasigna un folio a un nuevo ejecutor y actualiza la fecha de entrega y usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_reasignar_folio(
    p_id_control INTEGER,
    p_nuevo_ejecutor INTEGER,
    p_fecha_entrega2 DATE,
    p_usuario INTEGER,
    p_fecha_actualiz DATE
) RETURNS TEXT AS $$
DECLARE
BEGIN
    UPDATE ta_15_apremios
    SET ejecutor = p_nuevo_ejecutor,
        fecha_entrega2 = p_fecha_entrega2,
        usuario = p_usuario,
        fecha_actualiz = p_fecha_actualiz
    WHERE id_control = p_id_control;
    RETURN 'OK';
EXCEPTION WHEN OTHERS THEN
    RETURN 'ERROR: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_listar_ejecutores
-- Tipo: Catalog
-- Descripción: Devuelve la lista de ejecutores activos entre dos recaudadoras.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_listar_ejecutores(
    p_id_rec_min INTEGER,
    p_id_rec_max INTEGER
) RETURNS TABLE (
    id_ejecutor INTEGER,
    cve_eje INTEGER,
    ini_rfc VARCHAR,
    fec_rfc DATE,
    hom_rfc VARCHAR,
    nombre VARCHAR,
    id_rec INTEGER,
    categoria VARCHAR,
    observacion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_ejecutor, cve_eje, ini_rfc, fec_rfc, hom_rfc, nombre, id_rec, categoria, observacion
    FROM ta_15_ejecutores
    WHERE id_rec >= p_id_rec_min AND id_rec <= p_id_rec_max AND oficio <> ''
    ORDER BY id_rec, cve_eje;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_buscar_folios
-- Tipo: Report
-- Descripción: Busca folios por zona, módulo y rango de folios, solo los que tienen ejecutor asignado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_folios(
    p_zona INTEGER,
    p_modulo INTEGER,
    p_folio1 INTEGER,
    p_folio2 INTEGER,
    p_vigencia VARCHAR
) RETURNS TABLE (
    id_control INTEGER,
    zona INTEGER,
    modulo INTEGER,
    control_otr INTEGER,
    folio INTEGER,
    ejecutor INTEGER,
    fecha_entrega1 DATE,
    fecha_pago DATE,
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    fecha_actualiz DATE,
    usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_control, zona, modulo, control_otr, folio, ejecutor, fecha_entrega1, fecha_pago, importe_global, importe_multa, importe_recargo, importe_gastos, fecha_actualiz, usuario
    FROM ta_15_apremios
    WHERE zona = p_zona AND modulo = p_modulo AND folio >= p_folio1 AND folio <= p_folio2 AND vigencia = p_vigencia AND ejecutor > 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================

