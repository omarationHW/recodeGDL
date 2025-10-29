-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: DM_Crbos
-- Generado: 2025-08-27 13:33:33
-- Total SPs: 4
-- ============================================

-- SP 1/4: spd_crbo_abc
-- Tipo: CRUD
-- Descripción: Alta, modificación y baja de contrarecibos
-- --------------------------------------------

-- PostgreSQL stored procedure for CRUD on contrarecibos
CREATE OR REPLACE FUNCTION spd_crbo_abc(
    p_ejercicio SMALLINT,
    p_procedencia SMALLINT,
    p_crbo INTEGER,
    p_feccrbo DATE,
    p_diasven SMALLINT,
    p_importe NUMERIC(18,2),
    p_concepto TEXT,
    p_proveedor INTEGER,
    p_doctos SMALLINT,
    p_fecingre DATE,
    p_fecvenci DATE,
    p_feccodi DATE,
    p_fecveri DATE,
    p_fecprog DATE,
    p_fecaja DATE,
    p_feccancel DATE,
    p_cvecheq VARCHAR(1),
    p_benef TEXT,
    p_formapago VARCHAR(1),
    p_notas TEXT,
    p_param SMALLINT,
    p_num_ctrol_cheque INTEGER,
    p_clave_movimiento VARCHAR(1),
    p_benef_cheque TEXT
) RETURNS TABLE(result TEXT) AS $$
BEGIN
    -- Insert or update logic
    IF p_param = 1 THEN -- Insert
        INSERT INTO ta_contrarecibos (
            ejercicio, procedencia, contrarecibo, fecha_contrarecibo, dias_venc, importe, concepto, id_proveedor, numero_documentos, fecha_ingreso, fecha_vencimiento, fecha_codificacion, fecha_verificacion, fecha_programacion, fecha_tramite_caja, fecha_cancenlacion, clave_exped_cheque, benef_cheque, forma_pago, notas, num_ctrol_cheque, clave_movimiento
        ) VALUES (
            p_ejercicio, p_procedencia, p_crbo, p_feccrbo, p_diasven, p_importe, p_concepto, p_proveedor, p_doctos, p_fecingre, p_fecvenci, p_feccodi, p_fecveri, p_fecprog, p_fecaja, p_feccancel, p_cvecheq, p_benef_cheque, p_formapago, p_notas, p_num_ctrol_cheque, p_clave_movimiento
        );
        RETURN QUERY SELECT 'inserted'::TEXT;
    ELSIF p_param = 2 THEN -- Update
        UPDATE ta_contrarecibos SET
            fecha_contrarecibo = p_feccrbo,
            dias_venc = p_diasven,
            importe = p_importe,
            concepto = p_concepto,
            id_proveedor = p_proveedor,
            numero_documentos = p_doctos,
            fecha_ingreso = p_fecingre,
            fecha_vencimiento = p_fecvenci,
            fecha_codificacion = p_feccodi,
            fecha_verificacion = p_fecveri,
            fecha_programacion = p_fecprog,
            fecha_tramite_caja = p_fecaja,
            fecha_cancenlacion = p_feccancel,
            clave_exped_cheque = p_cvecheq,
            benef_cheque = p_benef_cheque,
            forma_pago = p_formapago,
            notas = p_notas,
            num_ctrol_cheque = p_num_ctrol_cheque,
            clave_movimiento = p_clave_movimiento
        WHERE ejercicio = p_ejercicio AND procedencia = p_procedencia AND contrarecibo = p_crbo;
        RETURN QUERY SELECT 'updated'::TEXT;
    ELSIF p_param = 3 THEN -- Delete
        DELETE FROM ta_contrarecibos WHERE ejercicio = p_ejercicio AND procedencia = p_procedencia AND contrarecibo = p_crbo;
        RETURN QUERY SELECT 'deleted'::TEXT;
    ELSE
        RETURN QUERY SELECT 'no_action'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: spd_proveedor_abc
-- Tipo: CRUD
-- Descripción: Alta, modificación y baja de proveedores
-- --------------------------------------------

-- PostgreSQL stored procedure for CRUD on proveedores
CREATE OR REPLACE FUNCTION spd_proveedor_abc(
    p_idproveedor INTEGER,
    p_denominacion TEXT,
    p_origen VARCHAR(1),
    p_domicilio TEXT,
    p_colonia TEXT,
    p_cod_postal VARCHAR(6),
    p_ciudad TEXT,
    p_tel01 TEXT,
    p_tel02 TEXT,
    p_fax TEXT,
    p_radio TEXT,
    p_rfc VARCHAR(15),
    p_notas TEXT,
    p_fechaingreso DATE,
    p_fechatermino DATE,
    p_parametro SMALLINT,
    p_cuenta TEXT,
    p_banco SMALLINT,
    p_plaza_nom TEXT,
    p_plaza_num SMALLINT
) RETURNS TABLE(result TEXT) AS $$
BEGIN
    IF p_parametro = 1 THEN -- Insert
        INSERT INTO ta_proveedores (
            id_proveedor, denominacion, origen, domicilio_fiscal, colonia, codigo_postal, ciudad, telefono_01, telefono_02, fax, radio_clave, reg_fed_causante, notas, fecha_ingreso, fecha_termino, cuenta, banco, plaza_nom, plaza_num
        ) VALUES (
            p_idproveedor, p_denominacion, p_origen, p_domicilio, p_colonia, p_cod_postal, p_ciudad, p_tel01, p_tel02, p_fax, p_radio, p_rfc, p_notas, p_fechaingreso, p_fechatermino, p_cuenta, p_banco, p_plaza_nom, p_plaza_num
        );
        RETURN QUERY SELECT 'inserted'::TEXT;
    ELSIF p_parametro = 2 THEN -- Update
        UPDATE ta_proveedores SET
            denominacion = p_denominacion,
            origen = p_origen,
            domicilio_fiscal = p_domicilio,
            colonia = p_colonia,
            codigo_postal = p_cod_postal,
            ciudad = p_ciudad,
            telefono_01 = p_tel01,
            telefono_02 = p_tel02,
            fax = p_fax,
            radio_clave = p_radio,
            reg_fed_causante = p_rfc,
            notas = p_notas,
            fecha_ingreso = p_fechaingreso,
            fecha_termino = p_fechatermino,
            cuenta = p_cuenta,
            banco = p_banco,
            plaza_nom = p_plaza_nom,
            plaza_num = p_plaza_num
        WHERE id_proveedor = p_idproveedor;
        RETURN QUERY SELECT 'updated'::TEXT;
    ELSIF p_parametro = 3 THEN -- Delete
        DELETE FROM ta_proveedores WHERE id_proveedor = p_idproveedor;
        RETURN QUERY SELECT 'deleted'::TEXT;
    ELSE
        RETURN QUERY SELECT 'no_action'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sum_contrarecibos_by_date
-- Tipo: Report
-- Descripción: Suma de importes de contrarecibos por fecha de ingreso
-- --------------------------------------------

-- PostgreSQL function for sum by date
CREATE OR REPLACE FUNCTION sum_contrarecibos_by_date(p_fecha DATE)
RETURNS NUMERIC(18,2) AS $$
DECLARE
    total NUMERIC(18,2);
BEGIN
    SELECT COALESCE(SUM(importe),0) INTO total FROM ta_contrarecibos WHERE fecha_ingreso = p_fecha;
    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: get_contrarecibos_by_date
-- Tipo: Report
-- Descripción: Obtiene listado de contrarecibos por fecha de ingreso
-- --------------------------------------------

-- PostgreSQL function for contrarecibos by date
CREATE OR REPLACE FUNCTION get_contrarecibos_by_date(p_fecha DATE)
RETURNS TABLE (
    ejercicio SMALLINT,
    procedencia SMALLINT,
    contrarecibo INTEGER,
    denominacion TEXT,
    importe NUMERIC(18,2),
    fecha_contrarecibo DATE,
    concepto TEXT,
    notas TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.ejercicio, a.procedencia, a.contrarecibo, b.denominacion, a.importe, a.fecha_contrarecibo, a.concepto, a.notas
    FROM ta_contrarecibos a
    JOIN ta_proveedores b ON a.id_proveedor = b.id_proveedor
    WHERE a.fecha_ingreso = p_fecha
    ORDER BY a.ejercicio, a.procedencia, a.contrarecibo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

