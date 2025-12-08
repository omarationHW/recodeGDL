-- =====================================================
-- DEPLOY BATCH 8 - MULTAS Y REGLAMENTOS
-- Componentes: consmulpagos, consobsmulfrm, dderechosLic, descmultampalfrm, descpredfrm
-- Fecha: 2025-11-24
-- =====================================================

-- 1. CONSMULPAGOS
CREATE OR REPLACE FUNCTION consmulpagos_sp_buscar(
    p_fecha VARCHAR(20), p_recaud INTEGER, p_caja VARCHAR(5),
    p_folio INTEGER, p_nombre VARCHAR(200), p_num_acta INTEGER
) RETURNS TABLE (
    cvepago INTEGER, fecha DATE, recaud INTEGER, caja VARCHAR(5),
    folio INTEGER, importe NUMERIC(12,2), contribuyente VARCHAR(200),
    domicilio VARCHAR(300), num_acta INTEGER, axo_acta INTEGER
) AS $$
BEGIN
    RETURN QUERY SELECT p.id_pago, p.fecha_pago, p.recaudadora, p.caja,
        p.folio, p.importe, p.contribuyente, p.domicilio, p.num_acta, p.axo_acta
    FROM pagos_multas p
    WHERE (p_fecha = '' OR p.fecha_pago = p_fecha::DATE)
      AND (p_recaud = 0 OR p.recaudadora = p_recaud)
      AND (p_caja = '' OR p.caja = p_caja)
      AND (p_folio = 0 OR p.folio = p_folio)
      AND (p_nombre = '' OR p.contribuyente ILIKE '%' || p_nombre || '%')
      AND (p_num_acta = 0 OR p.num_acta = p_num_acta)
    ORDER BY p.fecha_pago DESC, p.folio;
END; $$ LANGUAGE plpgsql;

-- 2. CONSOBSMULFRM
CREATE OR REPLACE FUNCTION consobsmulfrm_sp_get_dependencias()
RETURNS TABLE (id INTEGER, abrevia VARCHAR(50)) AS $$
BEGIN
    RETURN QUERY SELECT d.id_dependencia, d.abrevia FROM dependencias d WHERE d.activo = true ORDER BY d.abrevia;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION consobsmulfrm_sp_list(
    p_q VARCHAR(200), p_num_acta INTEGER, p_axo_acta INTEGER, p_id_dependencia INTEGER
) RETURNS TABLE (
    id_observacion INTEGER, num_acta INTEGER, axo_acta INTEGER, dependencia VARCHAR(50),
    fecha DATE, usuario VARCHAR(50), observacion TEXT
) AS $$
BEGIN
    RETURN QUERY SELECT o.id_obs, o.num_acta, o.axo_acta, d.abrevia,
        o.fecha, o.usuario, o.observacion
    FROM observaciones_multas o LEFT JOIN dependencias d ON o.id_dependencia = d.id_dependencia
    WHERE (p_q = '' OR o.observacion ILIKE '%' || p_q || '%')
      AND (p_num_acta = 0 OR o.num_acta = p_num_acta)
      AND (p_axo_acta = 0 OR o.axo_acta = p_axo_acta)
      AND (p_id_dependencia = 0 OR o.id_dependencia = p_id_dependencia)
    ORDER BY o.fecha DESC;
END; $$ LANGUAGE plpgsql;

-- 3. DDERECHOSLIC
CREATE OR REPLACE FUNCTION dderechoslic_sp_buscar_licencia(p_folio INTEGER)
RETURNS TABLE (id_licencia INTEGER, licencia VARCHAR(20), propietario VARCHAR(200), min INTEGER, max INTEGER) AS $$
BEGIN
    RETURN QUERY SELECT l.id_licencia, l.num_licencia, l.propietario,
        EXTRACT(YEAR FROM l.fecha_inicio)::INTEGER, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER
    FROM licencias l WHERE l.id_licencia = p_folio OR l.num_licencia::INTEGER = p_folio;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dderechoslic_sp_buscar_anuncio(p_folio INTEGER)
RETURNS TABLE (id_anuncio INTEGER, anuncio VARCHAR(20), propietario VARCHAR(200), min INTEGER, max INTEGER) AS $$
BEGIN
    RETURN QUERY SELECT a.id_anuncio, a.num_anuncio, a.propietario,
        EXTRACT(YEAR FROM a.fecha_inicio)::INTEGER, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER
    FROM anuncios a WHERE a.id_anuncio = p_folio OR a.num_anuncio::INTEGER = p_folio;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dderechoslic_sp_get_descuentos(p_tipo VARCHAR(1), p_folio INTEGER)
RETURNS TABLE (id_descto INTEGER, licencia INTEGER, porcentaje INTEGER, axoini INTEGER, axofin INTEGER, estado VARCHAR(20)) AS $$
BEGIN
    RETURN QUERY SELECT d.id_descto, d.id_licencia, d.porcentaje, d.axo_ini, d.axo_fin,
        CASE WHEN d.activo THEN 'Vigente'::VARCHAR(20) ELSE 'Cancelado'::VARCHAR(20) END
    FROM descuentos_licencias d WHERE d.id_licencia = p_folio AND d.tipo = p_tipo ORDER BY d.fecha_alta DESC;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dderechoslic_sp_get_funcionarios()
RETURNS TABLE (cveautoriza INTEGER, descripcion VARCHAR(100), porcentajetope INTEGER) AS $$
BEGIN
    RETURN QUERY SELECT f.id_funcionario, f.nombre, f.porcentaje_tope FROM funcionarios_autorizadores f WHERE f.activo = true;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dderechoslic_sp_alta_descuento(
    p_tipo VARCHAR(1), p_licencia INTEGER, p_porcentaje INTEGER, p_axoini INTEGER, p_axofin INTEGER, p_autoriza INTEGER
) RETURNS JSON AS $$
BEGIN
    INSERT INTO descuentos_licencias (tipo, id_licencia, porcentaje, axo_ini, axo_fin, id_autorizador, activo, fecha_alta)
    VALUES (p_tipo, p_licencia, p_porcentaje, p_axoini, p_axofin, p_autoriza, true, CURRENT_DATE);
    RETURN json_build_object('ok', true);
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dderechoslic_sp_cancelar_descuento(p_id_descto INTEGER, p_licencia INTEGER)
RETURNS JSON AS $$
BEGIN
    UPDATE descuentos_licencias SET activo = false, fecha_cancelacion = CURRENT_DATE WHERE id_descto = p_id_descto;
    RETURN json_build_object('ok', true);
END; $$ LANGUAGE plpgsql;

-- 4. DESCMULTAMPALFRM
CREATE OR REPLACE FUNCTION descmultampalfrm_sp_get_dependencias()
RETURNS TABLE (id INTEGER, abrevia VARCHAR(50)) AS $$
BEGIN RETURN QUERY SELECT d.id_dependencia, d.abrevia FROM dependencias d WHERE d.activo = true; END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION descmultampalfrm_sp_get_funcionarios()
RETURNS TABLE (id INTEGER, nombre VARCHAR(100), tope INTEGER) AS $$
BEGIN RETURN QUERY SELECT f.id_funcionario, f.nombre, f.porcentaje_tope FROM funcionarios_autorizadores f WHERE f.activo = true; END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION descmultampalfrm_sp_buscar(p_num_acta INTEGER, p_axo_acta INTEGER, p_id_dependencia INTEGER)
RETURNS TABLE (num_acta INTEGER, axo_acta INTEGER, dependencia VARCHAR(50), importe NUMERIC(12,2), recargos NUMERIC(12,2), contribuyente VARCHAR(200), tiene_descuento BOOLEAN) AS $$
BEGIN
    RETURN QUERY SELECT m.num_acta, m.axo_acta, d.abrevia, m.importe, m.recargos, m.contribuyente,
        EXISTS(SELECT 1 FROM descuentos_multas dm WHERE dm.num_acta = m.num_acta AND dm.axo_acta = m.axo_acta AND dm.activo)
    FROM multas m LEFT JOIN dependencias d ON m.id_dependencia = d.id_dependencia
    WHERE (p_num_acta = 0 OR m.num_acta = p_num_acta) AND (p_axo_acta = 0 OR m.axo_acta = p_axo_acta)
      AND (p_id_dependencia = 0 OR m.id_dependencia = p_id_dependencia) LIMIT 1;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION descmultampalfrm_sp_get_descuentos(p_num_acta INTEGER, p_axo_acta INTEGER)
RETURNS TABLE (id_descuento INTEGER, tipo_descuento VARCHAR(20), porcentaje INTEGER, importe_descuento NUMERIC(12,2), fecha DATE, estado VARCHAR(20)) AS $$
BEGIN
    RETURN QUERY SELECT d.id_descuento, d.tipo, d.porcentaje, d.importe_descuento, d.fecha,
        CASE WHEN d.activo THEN 'Vigente'::VARCHAR(20) ELSE 'Cancelado'::VARCHAR(20) END
    FROM descuentos_multas d WHERE d.num_acta = p_num_acta AND d.axo_acta = p_axo_acta ORDER BY d.fecha DESC;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION descmultampalfrm_sp_aplicar_descuento(
    p_num_acta INTEGER, p_axo_acta INTEGER, p_tipo VARCHAR(20), p_porcentaje INTEGER, p_autoriza INTEGER, p_observaciones TEXT
) RETURNS JSON AS $$
BEGIN
    INSERT INTO descuentos_multas (num_acta, axo_acta, tipo, porcentaje, id_autorizador, observaciones, activo, fecha)
    VALUES (p_num_acta, p_axo_acta, p_tipo, p_porcentaje, p_autoriza, p_observaciones, true, CURRENT_DATE);
    RETURN json_build_object('ok', true);
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION descmultampalfrm_sp_cancelar_descuento(p_id_descuento INTEGER)
RETURNS JSON AS $$
BEGIN UPDATE descuentos_multas SET activo = false WHERE id_descuento = p_id_descuento; RETURN json_build_object('ok', true); END; $$ LANGUAGE plpgsql;

-- 5. DESCPREDFRM
CREATE OR REPLACE FUNCTION descpredfrm_sp_get_catalogos()
RETURNS JSON AS $$
BEGIN
    RETURN json_build_object(
        'tipos', (SELECT json_agg(json_build_object('id', t.id_tipo, 'descripcion', t.descripcion)) FROM tipos_descuento t),
        'instituciones', (SELECT json_agg(json_build_object('cveinst', i.id_institucion, 'institucion', i.nombre)) FROM instituciones i)
    );
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION descpredfrm_sp_list(p_cvecat VARCHAR(50), p_folio INTEGER, p_estado VARCHAR(1))
RETURNS TABLE (id INTEGER, foliodesc INTEGER, cvecuenta VARCHAR(50), descripcion VARCHAR(100), bimini INTEGER, bimfin INTEGER,
    solicitante VARCHAR(200), identificacion VARCHAR(50), institucion_nombre VARCHAR(100), porcentaje INTEGER, status VARCHAR(1)) AS $$
BEGIN
    RETURN QUERY SELECT d.id_descuento, d.folio, d.cve_cuenta, t.descripcion, d.bim_ini, d.bim_fin,
        d.solicitante, d.identificacion, i.nombre, d.porcentaje, d.estado
    FROM descuentos_predial d LEFT JOIN tipos_descuento t ON d.id_tipo = t.id_tipo LEFT JOIN instituciones i ON d.id_institucion = i.id_institucion
    WHERE (p_cvecat = '' OR d.cve_cuenta ILIKE '%' || p_cvecat || '%') AND (p_folio = 0 OR d.folio = p_folio)
      AND (p_estado = '' OR d.estado = p_estado) ORDER BY d.fecha_alta DESC;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION descpredfrm_sp_create(
    p_id INTEGER, p_cvecuenta VARCHAR(50), p_tipo INTEGER, p_bimini INTEGER, p_bimfin INTEGER,
    p_porcentaje INTEGER, p_solicitante VARCHAR(200), p_identificacion VARCHAR(50), p_institucion INTEGER
) RETURNS JSON AS $$
BEGIN
    INSERT INTO descuentos_predial (cve_cuenta, id_tipo, bim_ini, bim_fin, porcentaje, solicitante, identificacion, id_institucion, estado, fecha_alta)
    VALUES (p_cvecuenta, p_tipo, p_bimini, p_bimfin, p_porcentaje, p_solicitante, p_identificacion, NULLIF(p_institucion, 0), 'V', CURRENT_DATE);
    RETURN json_build_object('ok', true);
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION descpredfrm_sp_update(
    p_id INTEGER, p_cvecuenta VARCHAR(50), p_tipo INTEGER, p_bimini INTEGER, p_bimfin INTEGER,
    p_porcentaje INTEGER, p_solicitante VARCHAR(200), p_identificacion VARCHAR(50), p_institucion INTEGER
) RETURNS JSON AS $$
BEGIN
    UPDATE descuentos_predial SET id_tipo = p_tipo, bim_ini = p_bimini, bim_fin = p_bimfin, porcentaje = p_porcentaje,
        solicitante = p_solicitante, identificacion = p_identificacion, id_institucion = NULLIF(p_institucion, 0)
    WHERE id_descuento = p_id;
    RETURN json_build_object('ok', true);
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION descpredfrm_sp_baja(p_id INTEGER) RETURNS JSON AS $$
BEGIN UPDATE descuentos_predial SET estado = 'C' WHERE id_descuento = p_id; RETURN json_build_object('ok', true); END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION descpredfrm_sp_reactivar(p_id INTEGER) RETURNS JSON AS $$
BEGIN UPDATE descuentos_predial SET estado = 'V' WHERE id_descuento = p_id; RETURN json_build_object('ok', true); END; $$ LANGUAGE plpgsql;
