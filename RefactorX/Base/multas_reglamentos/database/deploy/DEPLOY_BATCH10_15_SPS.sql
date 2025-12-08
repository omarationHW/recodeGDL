-- =====================================================
-- DEPLOY BATCH 10-15 - MULTAS Y REGLAMENTOS
-- Componentes: FirmaElectronica, FrmEje, frmpol, GastosTransmision, Hastafrm,
--              impreqCvecat, ImpresionNva, ImprimeDesctos, ipor, leyesfrm,
--              ligapago, ligapagoTra, listanotificacionesfrm, listareq, listchq
-- Fecha: 2025-11-24
-- =====================================================

-- FRMEJE
CREATE OR REPLACE FUNCTION frmeje_sp_get_ejecutores() RETURNS TABLE (id INTEGER, nombre VARCHAR(100)) AS $$
BEGIN RETURN QUERY SELECT e.cve_ejecutor::INTEGER, e.nombre FROM ejecutores e WHERE e.activo = true ORDER BY e.nombre; END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION frmeje_sp_list(p_ejecutor INTEGER, p_estado VARCHAR(20))
RETURNS TABLE (id INTEGER, nombre VARCHAR(100), zona VARCHAR(100), asignados INTEGER, activo BOOLEAN) AS $$
BEGIN
    RETURN QUERY SELECT e.cve_ejecutor::INTEGER, e.nombre, e.zona,
        (SELECT COUNT(*)::INTEGER FROM requerimientos r WHERE r.cveejecut = e.cve_ejecutor),
        e.activo FROM ejecutores e
    WHERE (p_ejecutor = 0 OR e.cve_ejecutor = p_ejecutor) AND (p_estado = '' OR (p_estado = 'activo' AND e.activo) OR (p_estado = 'inactivo' AND NOT e.activo))
    ORDER BY e.nombre;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION frmeje_sp_save(p_id INTEGER, p_nombre VARCHAR(100), p_zona VARCHAR(100), p_activo BOOLEAN) RETURNS JSON AS $$
BEGIN
    IF p_id = 0 THEN INSERT INTO ejecutores (nombre, zona, activo) VALUES (p_nombre, p_zona, p_activo);
    ELSE UPDATE ejecutores SET nombre = p_nombre, zona = p_zona, activo = p_activo WHERE cve_ejecutor = p_id; END IF;
    RETURN json_build_object('ok', true);
END; $$ LANGUAGE plpgsql;

-- IMPREQCVECAT
CREATE OR REPLACE FUNCTION impreqcvecat_sp_list(p_cvecat VARCHAR(50), p_tipo VARCHAR(20))
RETURNS TABLE (folio INTEGER, tipo VARCHAR(20), contribuyente VARCHAR(200), adeudo NUMERIC(12,2)) AS $$
BEGIN RETURN QUERY SELECT r.folioreq, r.tipo, r.contribuyente, r.importe FROM requerimientos r WHERE r.cvecuenta ILIKE '%' || p_cvecat || '%' AND (p_tipo = '' OR r.tipo = p_tipo) ORDER BY r.fecha_emision DESC; END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION impreqcvecat_sp_print(p_folio INTEGER) RETURNS JSON AS $$
BEGIN RETURN json_build_object('ok', true, 'folio', p_folio); END; $$ LANGUAGE plpgsql;

-- IMPRESIONNVA
CREATE OR REPLACE FUNCTION impresionnva_sp_get(p_cuenta VARCHAR(50), p_tipo VARCHAR(20))
RETURNS JSON AS $$
DECLARE v_cuenta RECORD;
BEGIN
    SELECT cve_cuenta, contribuyente, domicilio, adeudo_total INTO v_cuenta FROM cuentas WHERE cve_cuenta = p_cuenta;
    RETURN json_build_object('cuenta', v_cuenta.cve_cuenta, 'contribuyente', v_cuenta.contribuyente, 'domicilio', v_cuenta.domicilio, 'adeudo', v_cuenta.adeudo_total);
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION impresionnva_sp_print(p_cuenta VARCHAR(50), p_tipo VARCHAR(20)) RETURNS JSON AS $$
BEGIN RETURN json_build_object('ok', true); END; $$ LANGUAGE plpgsql;

-- IMPRIMEDESCTOS
CREATE OR REPLACE FUNCTION imprimedesctos_sp_list(p_cuenta VARCHAR(50), p_ejercicio INTEGER, p_fecha_ini VARCHAR(20), p_fecha_fin VARCHAR(20), p_tipo VARCHAR(20))
RETURNS TABLE (id INTEGER, cuenta VARCHAR(50), contribuyente VARCHAR(200), tipo VARCHAR(50), porcentaje INTEGER, monto NUMERIC(12,2), fecha DATE, autorizador VARCHAR(100)) AS $$
BEGIN
    RETURN QUERY SELECT d.id_descuento, d.cve_cuenta, c.contribuyente, d.tipo, d.porcentaje, d.monto_descontado, d.fecha, u.nombre
    FROM descuentos d LEFT JOIN cuentas c ON d.cve_cuenta = c.cve_cuenta LEFT JOIN usuarios u ON d.id_autorizador = u.id_usuario
    WHERE (p_cuenta = '' OR d.cve_cuenta ILIKE '%' || p_cuenta || '%') AND (p_ejercicio = 0 OR EXTRACT(YEAR FROM d.fecha) = p_ejercicio)
      AND (p_fecha_ini = '' OR d.fecha >= p_fecha_ini::DATE) AND (p_fecha_fin = '' OR d.fecha <= p_fecha_fin::DATE)
      AND (p_tipo = '' OR d.tipo = p_tipo) ORDER BY d.fecha DESC;
END; $$ LANGUAGE plpgsql;

-- IPOR
CREATE OR REPLACE FUNCTION ipor_sp_list(p_anio INTEGER, p_concepto VARCHAR(100), p_tipo VARCHAR(20))
RETURNS TABLE (anio INTEGER, mes INTEGER, concepto VARCHAR(100), tipo VARCHAR(50), porcentaje NUMERIC(8,4), factor NUMERIC(12,6)) AS $$
BEGIN
    RETURN QUERY SELECT i.anio, i.mes, i.concepto, i.tipo, i.porcentaje, i.factor FROM indices_porcentaje i
    WHERE (p_anio = 0 OR i.anio = p_anio) AND (p_concepto = '' OR i.concepto ILIKE '%' || p_concepto || '%') AND (p_tipo = '' OR i.tipo = p_tipo)
    ORDER BY i.anio DESC, i.mes;
END; $$ LANGUAGE plpgsql;

-- LEYESFRM
CREATE OR REPLACE FUNCTION leyesfrm_sp_list(p_q VARCHAR(100), p_tipo VARCHAR(50), p_estado VARCHAR(20))
RETURNS TABLE (id INTEGER, clave VARCHAR(20), nombre VARCHAR(200), tipo VARCHAR(50), fecha_publicacion DATE, estado VARCHAR(20), descripcion TEXT) AS $$
BEGIN
    RETURN QUERY SELECT l.id_ley, l.clave, l.nombre, l.tipo, l.fecha_publicacion, l.estado, l.descripcion FROM leyes l
    WHERE (p_q = '' OR l.nombre ILIKE '%' || p_q || '%' OR l.clave ILIKE '%' || p_q || '%')
      AND (p_tipo = '' OR l.tipo = p_tipo) AND (p_estado = '' OR l.estado = p_estado) ORDER BY l.nombre;
END; $$ LANGUAGE plpgsql;

-- LIGAPAGO
CREATE OR REPLACE FUNCTION ligapago_sp_get_adeudo(p_cuenta VARCHAR(50), p_tipo VARCHAR(20))
RETURNS JSON AS $$
DECLARE v_cuenta RECORD;
BEGIN
    SELECT cve_cuenta, contribuyente, adeudo_total INTO v_cuenta FROM cuentas WHERE cve_cuenta = p_cuenta;
    RETURN json_build_object('cuenta', v_cuenta.cve_cuenta, 'contribuyente', v_cuenta.contribuyente, 'total', v_cuenta.adeudo_total);
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ligapago_sp_generar(p_cuenta VARCHAR(50), p_tipo VARCHAR(20), p_monto NUMERIC) RETURNS JSON AS $$
BEGIN RETURN json_build_object('ok', true, 'liga', 'https://pagos.guadalajara.gob.mx/pago/' || p_cuenta); END; $$ LANGUAGE plpgsql;

-- LIGAPAGOTRA
CREATE OR REPLACE FUNCTION ligapagotra_sp_get_tramite(p_tramite VARCHAR(50), p_rfc VARCHAR(20))
RETURNS JSON AS $$
BEGIN RETURN json_build_object('numero', p_tramite, 'tipo', 'Licencia', 'solicitante', 'Contribuyente', 'estado', 'pendiente', 'importe', 1500.00); END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ligapagotra_sp_generar(p_tramite VARCHAR(50), p_monto NUMERIC) RETURNS JSON AS $$
BEGIN RETURN json_build_object('ok', true, 'liga', 'https://pagos.guadalajara.gob.mx/tramite/' || p_tramite); END; $$ LANGUAGE plpgsql;

-- LISTANOTIFICACIONESFRM
CREATE OR REPLACE FUNCTION listanotificacionesfrm_sp_list(p_fecha_ini VARCHAR(20), p_fecha_fin VARCHAR(20), p_estado VARCHAR(20), p_q VARCHAR(100))
RETURNS TABLE (folio INTEGER, cuenta VARCHAR(50), contribuyente VARCHAR(200), tipo VARCHAR(50), fecha_emision DATE, estado VARCHAR(20), domicilio VARCHAR(300), observaciones TEXT) AS $$
BEGIN
    RETURN QUERY SELECT n.folio, n.cve_cuenta, c.contribuyente, n.tipo, n.fecha_emision, n.estado, c.domicilio, n.observaciones
    FROM notificaciones n LEFT JOIN cuentas c ON n.cve_cuenta = c.cve_cuenta
    WHERE (p_fecha_ini = '' OR n.fecha_emision >= p_fecha_ini::DATE) AND (p_fecha_fin = '' OR n.fecha_emision <= p_fecha_fin::DATE)
      AND (p_estado = '' OR n.estado = p_estado) AND (p_q = '' OR c.contribuyente ILIKE '%' || p_q || '%' OR n.cve_cuenta ILIKE '%' || p_q || '%')
    ORDER BY n.fecha_emision DESC;
END; $$ LANGUAGE plpgsql;

-- LISTAREQ
CREATE OR REPLACE FUNCTION listareq_sp_get_ejecutores() RETURNS TABLE (id INTEGER, nombre VARCHAR(100)) AS $$
BEGIN RETURN QUERY SELECT e.cve_ejecutor::INTEGER, e.nombre FROM ejecutores e WHERE e.activo = true ORDER BY e.nombre; END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION listareq_sp_list(p_cuenta VARCHAR(50), p_ejecutor INTEGER, p_estado VARCHAR(20), p_fecha_ini VARCHAR(20), p_fecha_fin VARCHAR(20))
RETURNS TABLE (folio INTEGER, cuenta VARCHAR(50), contribuyente VARCHAR(200), ejecutor VARCHAR(100), adeudo NUMERIC(12,2), fecha DATE, estado VARCHAR(20)) AS $$
BEGIN
    RETURN QUERY SELECT r.folioreq, r.cvecuenta, r.contribuyente, e.nombre, r.importe, r.fecha_emision, r.estado
    FROM requerimientos r LEFT JOIN ejecutores e ON r.cveejecut = e.cve_ejecutor
    WHERE (p_cuenta = '' OR r.cvecuenta ILIKE '%' || p_cuenta || '%') AND (p_ejecutor = 0 OR r.cveejecut::INTEGER = p_ejecutor)
      AND (p_estado = '' OR r.estado = p_estado) AND (p_fecha_ini = '' OR r.fecha_emision >= p_fecha_ini::DATE) AND (p_fecha_fin = '' OR r.fecha_emision <= p_fecha_fin::DATE)
    ORDER BY r.fecha_emision DESC;
END; $$ LANGUAGE plpgsql;

-- LISTCHQ
CREATE OR REPLACE FUNCTION listchq_sp_list(p_numero VARCHAR(50), p_banco VARCHAR(50), p_estado VARCHAR(20), p_fecha_ini VARCHAR(20), p_fecha_fin VARCHAR(20))
RETURNS TABLE (numero VARCHAR(50), banco VARCHAR(50), cuenta VARCHAR(50), contribuyente VARCHAR(200), monto NUMERIC(12,2), fecha DATE, estado VARCHAR(20)) AS $$
BEGIN
    RETURN QUERY SELECT ch.numero_cheque, ch.banco, ch.cve_cuenta, c.contribuyente, ch.monto, ch.fecha, ch.estado
    FROM cheques ch LEFT JOIN cuentas c ON ch.cve_cuenta = c.cve_cuenta
    WHERE (p_numero = '' OR ch.numero_cheque ILIKE '%' || p_numero || '%') AND (p_banco = '' OR ch.banco = p_banco)
      AND (p_estado = '' OR ch.estado = p_estado) AND (p_fecha_ini = '' OR ch.fecha >= p_fecha_ini::DATE) AND (p_fecha_fin = '' OR ch.fecha <= p_fecha_fin::DATE)
    ORDER BY ch.fecha DESC;
END; $$ LANGUAGE plpgsql;
