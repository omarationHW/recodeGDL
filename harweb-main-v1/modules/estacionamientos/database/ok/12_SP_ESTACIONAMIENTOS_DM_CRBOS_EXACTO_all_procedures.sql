-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: DM_CRBOS (EXACTO del archivo original)
-- Archivo: 12_SP_ESTACIONAMIENTOS_DM_CRBOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
        INSERT INTO public.ta_contrarecibos (
            ejercicio, procedencia, contrarecibo, fecha_contrarecibo, dias_venc, importe, concepto, id_proveedor, numero_documentos, fecha_ingreso, fecha_vencimiento, fecha_codificacion, fecha_verificacion, fecha_programacion, fecha_tramite_caja, fecha_cancenlacion, clave_exped_cheque, benef_cheque, forma_pago, notas, num_ctrol_cheque, clave_movimiento
        ) VALUES (
            p_ejercicio, p_procedencia, p_crbo, p_feccrbo, p_diasven, p_importe, p_concepto, p_proveedor, p_doctos, p_fecingre, p_fecvenci, p_feccodi, p_fecveri, p_fecprog, p_fecaja, p_feccancel, p_cvecheq, p_benef_cheque, p_formapago, p_notas, p_num_ctrol_cheque, p_clave_movimiento
        );
        RETURN QUERY SELECT 'inserted'::TEXT;
    ELSIF p_param = 2 THEN -- Update
        UPDATE public.ta_contrarecibos SET
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
        DELETE FROM public.ta_contrarecibos WHERE ejercicio = p_ejercicio AND procedencia = p_procedencia AND contrarecibo = p_crbo;
        RETURN QUERY SELECT 'deleted'::TEXT;
    ELSE
        RETURN QUERY SELECT 'no_action'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: DM_CRBOS (EXACTO del archivo original)
-- Archivo: 12_SP_ESTACIONAMIENTOS_DM_CRBOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
    SELECT COALESCE(SUM(importe),0) INTO total FROM public.ta_contrarecibos WHERE fecha_ingreso = p_fecha;
    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: DM_CRBOS (EXACTO del archivo original)
-- Archivo: 12_SP_ESTACIONAMIENTOS_DM_CRBOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

