-- ============================================================
-- DEPLOYMENT SQL - MULTAS Y REGLAMENTOS - BATCHES 4, 5 Y 6
-- Generado: 2025-11-24
-- Componentes: 10 componentes Vue
-- SPs estimados: 35+ stored procedures
-- ============================================================

-- ============================================================
-- BATCH 4: drecgoLic, drecgoOtrasObligaciones, CapturaDif, CartaInvitacion
-- ============================================================

-- drecgoLic - Descuentos en recargos/multas para licencias (6 SPs)
CREATE OR REPLACE FUNCTION multas_reglamentos.drecgolic_sp_busca_licencia(p_folio VARCHAR)
RETURNS TABLE(id_licencia INT, licencia VARCHAR, propietario VARCHAR, min INT, max INT) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_licencia, l.licencia, l.propietario,
           EXTRACT(YEAR FROM MIN(a.periodo))::INT as min,
           EXTRACT(YEAR FROM MAX(a.periodo))::INT as max
    FROM licencias l
    LEFT JOIN adeudos_licencias a ON l.id_licencia = a.id_licencia
    WHERE l.licencia ILIKE '%' || p_folio || '%' OR l.id_licencia::VARCHAR = p_folio
    GROUP BY l.id_licencia, l.licencia, l.propietario
    LIMIT 50;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION multas_reglamentos.drecgolic_sp_busca_anuncio(p_folio VARCHAR)
RETURNS TABLE(id_anuncio INT, anuncio VARCHAR, propietario VARCHAR, min INT, max INT) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_anuncio, a.anuncio, a.propietario,
           EXTRACT(YEAR FROM MIN(ad.periodo))::INT as min,
           EXTRACT(YEAR FROM MAX(ad.periodo))::INT as max
    FROM anuncios a
    LEFT JOIN adeudos_anuncios ad ON a.id_anuncio = ad.id_anuncio
    WHERE a.anuncio ILIKE '%' || p_folio || '%' OR a.id_anuncio::VARCHAR = p_folio
    GROUP BY a.id_anuncio, a.anuncio, a.propietario
    LIMIT 50;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION multas_reglamentos.drecgolic_sp_consulta_funcionarios()
RETURNS TABLE(cveautoriza INT, descripcion VARCHAR, porcentajetope INT) AS $$
BEGIN
    RETURN QUERY
    SELECT f.cveautoriza, f.descripcion, COALESCE(f.porcentaje_tope, 100) as porcentajetope
    FROM funcionarios_autorizadores f
    WHERE f.activo = 1
    ORDER BY f.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION multas_reglamentos.drecgolic_sp_alta_desc_recargo(
    p_tipo CHAR, p_licencia INT, p_porcentaje INT, p_axoini INT, p_axofin INT,
    p_autoriza INT, p_observaciones TEXT, p_user VARCHAR
) RETURNS TABLE(success BOOLEAN, message VARCHAR, id_descto INT) AS $$
DECLARE
    v_id INT;
BEGIN
    INSERT INTO descuentos_recargos_licencias (tipo, id_licencia, porcentaje, axo_ini, axo_fin, cveautoriza, observaciones, usuario, fecha)
    VALUES (p_tipo, p_licencia, p_porcentaje, p_axoini, p_axofin, p_autoriza, p_observaciones, p_user, NOW())
    RETURNING id INTO v_id;
    RETURN QUERY SELECT TRUE, 'Descuento registrado'::VARCHAR, v_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION multas_reglamentos.drecgolic_sp_alta_desc_multa(
    p_tipo CHAR, p_licencia INT, p_porcentaje INT, p_axoini INT, p_axofin INT,
    p_autoriza INT, p_observaciones TEXT, p_user VARCHAR
) RETURNS TABLE(success BOOLEAN, message VARCHAR, id_descto INT) AS $$
DECLARE
    v_id INT;
BEGIN
    INSERT INTO descuentos_multas_licencias (tipo, id_licencia, porcentaje, axo_ini, axo_fin, cveautoriza, observaciones, usuario, fecha)
    VALUES (p_tipo, p_licencia, p_porcentaje, p_axoini, p_axofin, p_autoriza, p_observaciones, p_user, NOW())
    RETURNING id INTO v_id;
    RETURN QUERY SELECT TRUE, 'Descuento de multa registrado'::VARCHAR, v_id;
END;
$$ LANGUAGE plpgsql;

-- drecgoOtrasObligaciones - Descuentos otras obligaciones (4 SPs)
CREATE OR REPLACE FUNCTION multas_reglamentos.drecgootrasoblig_sp_buscar(p_cuenta VARCHAR)
RETURNS TABLE(folio INT, concepto VARCHAR, importe NUMERIC, recargos NUMERIC, total NUMERIC, estado CHAR, id_descto INT) AS $$
BEGIN
    RETURN QUERY
    SELECT o.folio, o.concepto, o.importe, o.recargos, (o.importe + o.recargos) as total, o.estado, d.id_descto
    FROM otras_obligaciones o
    LEFT JOIN descuentos_otras_oblig d ON o.folio = d.folio AND d.activo = 1
    WHERE o.cuenta = p_cuenta OR p_cuenta IS NULL
    ORDER BY o.fecha DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION multas_reglamentos.drecgootrasoblig_sp_get_autorizadores()
RETURNS TABLE(cveautoriza INT, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT f.cveautoriza, f.descripcion
    FROM funcionarios_autorizadores f
    WHERE f.activo = 1
    ORDER BY f.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION multas_reglamentos.drecgootrasoblig_sp_alta_descuento(
    p_folio INT, p_porcentaje INT, p_autoriza INT, p_observaciones TEXT, p_user VARCHAR
) RETURNS TABLE(success BOOLEAN, message VARCHAR) AS $$
BEGIN
    INSERT INTO descuentos_otras_oblig (folio, porcentaje, cveautoriza, observaciones, usuario, fecha, activo)
    VALUES (p_folio, p_porcentaje, p_autoriza, p_observaciones, p_user, NOW(), 1);
    RETURN QUERY SELECT TRUE, 'Descuento registrado correctamente'::VARCHAR;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION multas_reglamentos.drecgootrasoblig_sp_cancelar_descuento(
    p_folio INT, p_id_descto INT, p_user VARCHAR
) RETURNS TABLE(success BOOLEAN, message VARCHAR) AS $$
BEGIN
    UPDATE descuentos_otras_oblig SET activo = 0, usuario_baja = p_user, fecha_baja = NOW()
    WHERE folio = p_folio AND id_descto = p_id_descto;
    RETURN QUERY SELECT TRUE, 'Descuento cancelado'::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- CapturaDif - Captura de diferencias (2 SPs)
CREATE OR REPLACE FUNCTION multas_reglamentos.capturadif_sp_buscar(p_folio INT)
RETURNS TABLE(foliot INT, fecalta TIMESTAMP, baseimpuesto NUMERIC, diferencia NUMERIC, recargos NUMERIC, cvepago INT) AS $$
BEGIN
    RETURN QUERY
    SELECT d.foliot, d.fecalta, d.baseimpuesto, d.diferencia, d.recargos, d.cvepago
    FROM diferencias_impuestos d
    WHERE d.foliot = p_folio OR p_folio IS NULL
    ORDER BY d.fecalta DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION multas_reglamentos.capturadif_sp_crear(
    p_foliot INT, p_baseimpuesto NUMERIC, p_diferencia NUMERIC, p_observaciones TEXT, p_user VARCHAR
) RETURNS TABLE(success BOOLEAN, message VARCHAR) AS $$
BEGIN
    INSERT INTO diferencias_impuestos (foliot, baseimpuesto, diferencia, observaciones, usuario, fecalta)
    VALUES (p_foliot, p_baseimpuesto, p_diferencia, p_observaciones, p_user, NOW());
    RETURN QUERY SELECT TRUE, 'Diferencia registrada'::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- CartaInvitacion - Cartas de invitación (2 SPs)
CREATE OR REPLACE FUNCTION multas_reglamentos.cartainvitacion_sp_generar(
    p_cuenta VARCHAR, p_ejercicio INT, p_tipo CHAR, p_user VARCHAR
) RETURNS TABLE(folio VARCHAR, cuenta VARCHAR, ejercicio INT, fecha TIMESTAMP) AS $$
DECLARE
    v_folio VARCHAR;
BEGIN
    v_folio := 'CI' || TO_CHAR(NOW(), 'YYYYMMDD') || LPAD(nextval('seq_carta_invitacion')::TEXT, 6, '0');
    INSERT INTO cartas_invitacion (folio, cuenta, ejercicio, tipo, usuario, fecha)
    VALUES (v_folio, p_cuenta, p_ejercicio, p_tipo, p_user, NOW());
    RETURN QUERY SELECT v_folio, p_cuenta, p_ejercicio, NOW();
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION multas_reglamentos.cartainvitacion_sp_historial(p_cuenta VARCHAR)
RETURNS TABLE(folio VARCHAR, cuenta VARCHAR, tipo CHAR, fecha TIMESTAMP, usuario VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT c.folio, c.cuenta, c.tipo, c.fecha, c.usuario
    FROM cartas_invitacion c
    WHERE c.cuenta = p_cuenta OR p_cuenta IS NULL
    ORDER BY c.fecha DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- BATCH 5: Ejecutores, Empresas, FolMulta
-- ============================================================

-- Ejecutores (4 SPs)
CREATE OR REPLACE FUNCTION multas_reglamentos.ejecutores_sp_list(p_q VARCHAR DEFAULT NULL, p_activo INT DEFAULT NULL)
RETURNS TABLE(cve_ejecutor INT, nombre VARCHAR, rfc VARCHAR, zona VARCHAR, telefono VARCHAR, activo INT) AS $$
BEGIN
    RETURN QUERY
    SELECT e.cve_ejecutor, e.nombre, e.rfc, e.zona, e.telefono, e.activo
    FROM ejecutores e
    WHERE (p_q IS NULL OR e.nombre ILIKE '%' || p_q || '%' OR e.cve_ejecutor::VARCHAR = p_q)
      AND (p_activo IS NULL OR e.activo = p_activo)
    ORDER BY e.nombre
    LIMIT 200;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION multas_reglamentos.ejecutores_sp_create(
    p_nombre VARCHAR, p_rfc VARCHAR, p_zona VARCHAR, p_telefono VARCHAR, p_user VARCHAR
) RETURNS TABLE(success BOOLEAN, message VARCHAR, cve_ejecutor INT) AS $$
DECLARE
    v_id INT;
BEGIN
    INSERT INTO ejecutores (nombre, rfc, zona, telefono, activo, usuario, fecha)
    VALUES (p_nombre, p_rfc, p_zona, p_telefono, 1, p_user, NOW())
    RETURNING ejecutores.cve_ejecutor INTO v_id;
    RETURN QUERY SELECT TRUE, 'Ejecutor creado'::VARCHAR, v_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION multas_reglamentos.ejecutores_sp_update(
    p_cve_ejecutor INT, p_nombre VARCHAR, p_rfc VARCHAR, p_zona VARCHAR, p_telefono VARCHAR, p_user VARCHAR
) RETURNS TABLE(success BOOLEAN, message VARCHAR) AS $$
BEGIN
    UPDATE ejecutores SET nombre = p_nombre, rfc = p_rfc, zona = p_zona, telefono = p_telefono, usuario_mod = p_user, fecha_mod = NOW()
    WHERE cve_ejecutor = p_cve_ejecutor;
    RETURN QUERY SELECT TRUE, 'Ejecutor actualizado'::VARCHAR;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION multas_reglamentos.ejecutores_sp_desactivar(p_cve_ejecutor INT, p_user VARCHAR)
RETURNS TABLE(success BOOLEAN, message VARCHAR) AS $$
BEGIN
    UPDATE ejecutores SET activo = 0, usuario_mod = p_user, fecha_mod = NOW()
    WHERE cve_ejecutor = p_cve_ejecutor;
    RETURN QUERY SELECT TRUE, 'Ejecutor desactivado'::VARCHAR;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION multas_reglamentos.ejecutores_sp_activar(p_cve_ejecutor INT, p_user VARCHAR)
RETURNS TABLE(success BOOLEAN, message VARCHAR) AS $$
BEGIN
    UPDATE ejecutores SET activo = 1, usuario_mod = p_user, fecha_mod = NOW()
    WHERE cve_ejecutor = p_cve_ejecutor;
    RETURN QUERY SELECT TRUE, 'Ejecutor activado'::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- Empresas (3 SPs)
CREATE OR REPLACE FUNCTION multas_reglamentos.empresas_sp_list(p_q VARCHAR DEFAULT NULL, p_activo INT DEFAULT NULL)
RETURNS TABLE(cve_empresa INT, nombre VARCHAR, rfc VARCHAR, telefono VARCHAR, contacto VARCHAR, direccion VARCHAR, activo INT) AS $$
BEGIN
    RETURN QUERY
    SELECT e.cve_empresa, e.nombre, e.rfc, e.telefono, e.contacto, e.direccion, e.activo
    FROM empresas_recaudadoras e
    WHERE (p_q IS NULL OR e.nombre ILIKE '%' || p_q || '%' OR e.rfc ILIKE '%' || p_q || '%')
      AND (p_activo IS NULL OR e.activo = p_activo)
    ORDER BY e.nombre
    LIMIT 200;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION multas_reglamentos.empresas_sp_create(
    p_nombre VARCHAR, p_rfc VARCHAR, p_telefono VARCHAR, p_contacto VARCHAR, p_direccion VARCHAR, p_user VARCHAR
) RETURNS TABLE(success BOOLEAN, message VARCHAR, cve_empresa INT) AS $$
DECLARE
    v_id INT;
BEGIN
    INSERT INTO empresas_recaudadoras (nombre, rfc, telefono, contacto, direccion, activo, usuario, fecha)
    VALUES (p_nombre, p_rfc, p_telefono, p_contacto, p_direccion, 1, p_user, NOW())
    RETURNING empresas_recaudadoras.cve_empresa INTO v_id;
    RETURN QUERY SELECT TRUE, 'Empresa creada'::VARCHAR, v_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION multas_reglamentos.empresas_sp_update(
    p_cve_empresa INT, p_nombre VARCHAR, p_rfc VARCHAR, p_telefono VARCHAR, p_contacto VARCHAR, p_direccion VARCHAR, p_user VARCHAR
) RETURNS TABLE(success BOOLEAN, message VARCHAR) AS $$
BEGIN
    UPDATE empresas_recaudadoras SET nombre = p_nombre, rfc = p_rfc, telefono = p_telefono, contacto = p_contacto, direccion = p_direccion, usuario_mod = p_user, fecha_mod = NOW()
    WHERE cve_empresa = p_cve_empresa;
    RETURN QUERY SELECT TRUE, 'Empresa actualizada'::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- FolMulta - Generación de folios (2 SPs)
CREATE OR REPLACE FUNCTION multas_reglamentos.folmulta_sp_generar(
    p_clave_cuenta VARCHAR, p_ejercicio INT, p_tipo CHAR, p_motivo VARCHAR, p_user VARCHAR
) RETURNS TABLE(folio VARCHAR, clave_cuenta VARCHAR, ejercicio INT, fecha TIMESTAMP) AS $$
DECLARE
    v_folio VARCHAR;
BEGIN
    v_folio := 'MUL' || TO_CHAR(NOW(), 'YYYYMMDD') || LPAD(nextval('seq_folio_multa')::TEXT, 6, '0');
    INSERT INTO folios_multa (folio, clave_cuenta, ejercicio, tipo, motivo, usuario, fecha)
    VALUES (v_folio, p_clave_cuenta, p_ejercicio, p_tipo, p_motivo, p_user, NOW());
    RETURN QUERY SELECT v_folio, p_clave_cuenta, p_ejercicio, NOW();
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION multas_reglamentos.folmulta_sp_historial(p_clave_cuenta VARCHAR, p_ejercicio INT)
RETURNS TABLE(folio VARCHAR, clave_cuenta VARCHAR, ejercicio INT, tipo CHAR, fecha TIMESTAMP, usuario VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT f.folio, f.clave_cuenta, f.ejercicio, f.tipo, f.fecha, f.usuario
    FROM folios_multa f
    WHERE (p_clave_cuenta IS NULL OR f.clave_cuenta = p_clave_cuenta)
      AND f.ejercicio = p_ejercicio
    ORDER BY f.fecha DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- BATCH 6: MultasDM, RequerimientosDM
-- ============================================================

-- MultasDM (1 SP)
CREATE OR REPLACE FUNCTION multas_reglamentos.multasdm_sp_buscar(
    p_cuenta VARCHAR DEFAULT NULL, p_ejercicio INT DEFAULT NULL, p_estatus CHAR DEFAULT NULL
) RETURNS TABLE(folio VARCHAR, clave_cuenta VARCHAR, ejercicio INT, importe NUMERIC, recargos NUMERIC, total NUMERIC, estatus CHAR, fecha TIMESTAMP) AS $$
BEGIN
    RETURN QUERY
    SELECT m.folio, m.clave_cuenta, m.ejercicio, m.importe, m.recargos, (m.importe + m.recargos) as total, m.estatus, m.fecha
    FROM multas_dm m
    WHERE (p_cuenta IS NULL OR m.clave_cuenta ILIKE '%' || p_cuenta || '%')
      AND (p_ejercicio IS NULL OR m.ejercicio = p_ejercicio)
      AND (p_estatus IS NULL OR m.estatus = p_estatus)
    ORDER BY m.fecha DESC
    LIMIT 200;
END;
$$ LANGUAGE plpgsql;

-- RequerimientosDM (1 SP)
CREATE OR REPLACE FUNCTION multas_reglamentos.requerimientosdm_sp_buscar(
    p_cuenta VARCHAR DEFAULT NULL, p_ejercicio INT DEFAULT NULL, p_tipo CHAR DEFAULT NULL
) RETURNS TABLE(folio VARCHAR, clave_cuenta VARCHAR, tipo CHAR, ejercicio INT, importe NUMERIC, fecha TIMESTAMP, fecha_notif TIMESTAMP, estado CHAR, ejecutor VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT r.folio, r.clave_cuenta, r.tipo, r.ejercicio, r.importe, r.fecha, r.fecha_notif, r.estado, e.nombre as ejecutor
    FROM requerimientos_dm r
    LEFT JOIN ejecutores e ON r.cve_ejecutor = e.cve_ejecutor
    WHERE (p_cuenta IS NULL OR r.clave_cuenta ILIKE '%' || p_cuenta || '%')
      AND (p_ejercicio IS NULL OR r.ejercicio = p_ejercicio)
      AND (p_tipo IS NULL OR r.tipo = p_tipo)
    ORDER BY r.fecha DESC
    LIMIT 200;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- SECUENCIAS (si no existen)
-- ============================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_sequences WHERE schemaname = 'multas_reglamentos' AND sequencename = 'seq_carta_invitacion') THEN
        CREATE SEQUENCE multas_reglamentos.seq_carta_invitacion START 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_sequences WHERE schemaname = 'multas_reglamentos' AND sequencename = 'seq_folio_multa') THEN
        CREATE SEQUENCE multas_reglamentos.seq_folio_multa START 1;
    END IF;
END $$;

-- ============================================================
-- VERIFICACION
-- ============================================================
DO $$
DECLARE
    sp_count INT;
BEGIN
    SELECT COUNT(*) INTO sp_count
    FROM information_schema.routines
    WHERE routine_schema = 'multas_reglamentos'
      AND routine_name IN (
        'drecgolic_sp_busca_licencia', 'drecgolic_sp_busca_anuncio', 'drecgolic_sp_consulta_funcionarios',
        'drecgolic_sp_alta_desc_recargo', 'drecgolic_sp_alta_desc_multa',
        'drecgootrasoblig_sp_buscar', 'drecgootrasoblig_sp_get_autorizadores',
        'drecgootrasoblig_sp_alta_descuento', 'drecgootrasoblig_sp_cancelar_descuento',
        'capturadif_sp_buscar', 'capturadif_sp_crear',
        'cartainvitacion_sp_generar', 'cartainvitacion_sp_historial',
        'ejecutores_sp_list', 'ejecutores_sp_create', 'ejecutores_sp_update',
        'ejecutores_sp_desactivar', 'ejecutores_sp_activar',
        'empresas_sp_list', 'empresas_sp_create', 'empresas_sp_update',
        'folmulta_sp_generar', 'folmulta_sp_historial',
        'multasdm_sp_buscar', 'requerimientosdm_sp_buscar'
      );
    RAISE NOTICE 'BATCHES 4-5-6: % SPs instalados correctamente', sp_count;
END $$;

-- FIN DE DEPLOYMENT BATCHES 4, 5 Y 6
