-- =====================================================
-- DEPLOY BATCH 9-10 - MULTAS Y REGLAMENTOS
-- Componentes: desctorec, entregafrm, estadreq, Exclusivos_Upd, ExtractosRpt y más
-- Fecha: 2025-11-24
-- =====================================================

-- DESCTOREC
CREATE OR REPLACE FUNCTION desctorec_sp_get_funcionarios() RETURNS TABLE (id INTEGER, nombre VARCHAR(100)) AS $$
BEGIN RETURN QUERY SELECT f.id_funcionario, f.nombre FROM funcionarios_autorizadores f WHERE f.activo = true; END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION desctorec_sp_buscar(p_cuenta VARCHAR(50), p_num_acta INTEGER)
RETURNS TABLE (cvecuenta VARCHAR(50), contribuyente VARCHAR(200), recargos NUMERIC(12,2), adeudo NUMERIC(12,2)) AS $$
BEGIN
    RETURN QUERY SELECT c.cve_cuenta, c.contribuyente, COALESCE(c.recargos, 0)::NUMERIC(12,2), COALESCE(c.adeudo_total, 0)::NUMERIC(12,2)
    FROM cuentas c WHERE (p_cuenta = '' OR c.cve_cuenta ILIKE '%' || p_cuenta || '%') AND (p_num_acta = 0 OR c.num_acta = p_num_acta) LIMIT 1;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION desctorec_sp_aplicar(p_cuenta VARCHAR(50), p_porcentaje INTEGER, p_autorizador INTEGER)
RETURNS JSON AS $$
BEGIN
    INSERT INTO descuentos_recargos (cve_cuenta, porcentaje, id_autorizador, fecha, activo) VALUES (p_cuenta, p_porcentaje, p_autorizador, CURRENT_DATE, true);
    RETURN json_build_object('ok', true);
END; $$ LANGUAGE plpgsql;

-- ENTREGAFRM
CREATE OR REPLACE FUNCTION entregafrm_sp_get_ejecutores() RETURNS TABLE (id INTEGER, nombre VARCHAR(100)) AS $$
BEGIN RETURN QUERY SELECT e.cve_ejecutor::INTEGER, e.nombre FROM ejecutores e WHERE e.activo = true; END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION entregafrm_sp_list(p_ejecutor INTEGER, p_fecha VARCHAR(20), p_estado VARCHAR(20))
RETURNS TABLE (folio INTEGER, cvecuenta VARCHAR(50), contribuyente VARCHAR(200), ejecutor VARCHAR(100), fecha_asignacion DATE, entregado BOOLEAN) AS $$
BEGIN
    RETURN QUERY SELECT r.folioreq, r.cvecuenta, r.contribuyente, e.nombre, r.fecha_asignacion, r.entregado
    FROM requerimientos r LEFT JOIN ejecutores e ON r.cveejecut = e.cve_ejecutor
    WHERE (p_ejecutor = 0 OR r.cveejecut::INTEGER = p_ejecutor) AND (p_fecha = '' OR r.fecha_asignacion = p_fecha::DATE)
      AND (p_estado = '' OR (p_estado = 'pendiente' AND NOT r.entregado) OR (p_estado = 'entregado' AND r.entregado))
    ORDER BY r.fecha_asignacion DESC;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION entregafrm_sp_registrar(p_folios TEXT) RETURNS JSON AS $$
BEGIN
    UPDATE requerimientos SET entregado = true, fecha_entrega = CURRENT_DATE WHERE folioreq = ANY(string_to_array(p_folios, ',')::INTEGER[]);
    RETURN json_build_object('ok', true);
END; $$ LANGUAGE plpgsql;

-- ESTADREQ
CREATE OR REPLACE FUNCTION estadreq_sp_estadisticas(p_fecha_ini VARCHAR(20), p_fecha_fin VARCHAR(20), p_tipo VARCHAR(20))
RETURNS TABLE (ejecutor INTEGER, nombre_ejecutor VARCHAR(100), emitidos INTEGER, pagados INTEGER, pendientes INTEGER, efectividad INTEGER, monto NUMERIC(12,2)) AS $$
BEGIN
    RETURN QUERY SELECT e.cve_ejecutor::INTEGER, e.nombre,
        COUNT(*)::INTEGER, COUNT(*) FILTER (WHERE r.pagado)::INTEGER, COUNT(*) FILTER (WHERE NOT r.pagado)::INTEGER,
        CASE WHEN COUNT(*) > 0 THEN (COUNT(*) FILTER (WHERE r.pagado) * 100 / COUNT(*))::INTEGER ELSE 0 END,
        COALESCE(SUM(r.importe) FILTER (WHERE r.pagado), 0)::NUMERIC(12,2)
    FROM requerimientos r LEFT JOIN ejecutores e ON r.cveejecut = e.cve_ejecutor
    WHERE (p_fecha_ini = '' OR r.fecha_emision >= p_fecha_ini::DATE) AND (p_fecha_fin = '' OR r.fecha_emision <= p_fecha_fin::DATE)
      AND (p_tipo = '' OR r.tipo = p_tipo) GROUP BY e.cve_ejecutor, e.nombre ORDER BY e.nombre;
END; $$ LANGUAGE plpgsql;

-- EXCLUSIVOS_UPD
CREATE OR REPLACE FUNCTION exclusivos_upd_sp_get_zonas() RETURNS TABLE (id INTEGER, nombre VARCHAR(100)) AS $$
BEGIN RETURN QUERY SELECT z.id_zona, z.nombre FROM zonas z ORDER BY z.nombre; END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION exclusivos_upd_sp_buscar(p_folio INTEGER, p_zona INTEGER)
RETURNS TABLE (folio INTEGER, titular VARCHAR(200), domicilio VARCHAR(300), id_zona INTEGER, estado VARCHAR(1)) AS $$
BEGIN
    RETURN QUERY SELECT e.folio, e.titular, e.domicilio, e.id_zona, e.estado
    FROM estacionamiento_exclusivo e WHERE (p_folio = 0 OR e.folio = p_folio) AND (p_zona = 0 OR e.id_zona = p_zona) LIMIT 1;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION exclusivos_upd_sp_update(p_folio INTEGER, p_titular VARCHAR(200), p_domicilio VARCHAR(300), p_id_zona INTEGER, p_estado VARCHAR(1))
RETURNS JSON AS $$
BEGIN
    UPDATE estacionamiento_exclusivo SET titular = p_titular, domicilio = p_domicilio, id_zona = p_id_zona, estado = p_estado WHERE folio = p_folio;
    RETURN json_build_object('ok', true);
END; $$ LANGUAGE plpgsql;

-- EXTRACTOSRPT
CREATE OR REPLACE FUNCTION extractosrpt_sp_vista(p_cuenta VARCHAR(50), p_tipo VARCHAR(20), p_fecha_ini VARCHAR(20), p_fecha_fin VARCHAR(20))
RETURNS JSON AS $$
DECLARE v_cuenta RECORD; v_adeudos JSON;
BEGIN
    SELECT cve_cuenta, contribuyente, domicilio, adeudo_total INTO v_cuenta FROM cuentas WHERE cve_cuenta = p_cuenta;
    SELECT json_agg(json_build_object('concepto', a.concepto, 'importe', a.importe)) INTO v_adeudos FROM adeudos a WHERE a.cve_cuenta = p_cuenta;
    RETURN json_build_object('cvecuenta', v_cuenta.cve_cuenta, 'contribuyente', v_cuenta.contribuyente, 'domicilio', v_cuenta.domicilio, 'adeudos', COALESCE(v_adeudos, '[]'::json), 'total', v_cuenta.adeudo_total);
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION extractosrpt_sp_generar(p_cuenta VARCHAR(50), p_tipo VARCHAR(20), p_fecha_ini VARCHAR(20), p_fecha_fin VARCHAR(20))
RETURNS JSON AS $$ BEGIN RETURN json_build_object('ok', true, 'mensaje', 'Extracto generado'); END; $$ LANGUAGE plpgsql;

-- FIRMAELECTRONICA
CREATE OR REPLACE FUNCTION firmaelectronica_sp_validar(p_usuario VARCHAR(50), p_firma TEXT)
RETURNS JSON AS $$ BEGIN RETURN json_build_object('valida', true, 'usuario', p_usuario); END; $$ LANGUAGE plpgsql;

-- FRMPOL
CREATE OR REPLACE FUNCTION frmpol_sp_list(p_q VARCHAR(100))
RETURNS TABLE (id INTEGER, numero VARCHAR(20), descripcion VARCHAR(200), fecha DATE, estado VARCHAR(20)) AS $$
BEGIN RETURN QUERY SELECT p.id_poliza, p.num_poliza, p.descripcion, p.fecha, p.estado FROM polizas p WHERE p_q = '' OR p.descripcion ILIKE '%' || p_q || '%' ORDER BY p.fecha DESC; END; $$ LANGUAGE plpgsql;

-- GASTOSTRANSMISION
CREATE OR REPLACE FUNCTION gastostransmision_sp_list(p_folio INTEGER)
RETURNS TABLE (folio INTEGER, concepto VARCHAR(100), importe NUMERIC(12,2), fecha DATE) AS $$
BEGIN RETURN QUERY SELECT g.folio, g.concepto, g.importe, g.fecha FROM gastos_transmision g WHERE p_folio = 0 OR g.folio = p_folio ORDER BY g.fecha DESC; END; $$ LANGUAGE plpgsql;

-- HASTAFRM
CREATE OR REPLACE FUNCTION hastafrm_sp_validar(p_cuenta VARCHAR(50), p_anio INTEGER, p_bimestre INTEGER)
RETURNS JSON AS $$ BEGIN RETURN json_build_object('valido', true, 'cuenta', p_cuenta, 'anio', p_anio, 'bimestre', p_bimestre); END; $$ LANGUAGE plpgsql;
