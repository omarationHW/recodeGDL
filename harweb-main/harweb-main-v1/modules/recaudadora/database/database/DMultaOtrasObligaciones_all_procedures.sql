-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: DMultaOtrasObligaciones
-- Generado: 2025-08-27 00:31:21
-- Total SPs: 4
-- ============================================

-- SP 1/4: cob34_gdatosg_02
-- Tipo: CRUD
-- Descripción: Obtiene encabezado de control para Otras Obligaciones
-- --------------------------------------------

CREATE OR REPLACE FUNCTION cob34_gdatosg_02(par_tabla TEXT, par_control TEXT)
RETURNS TABLE (
    status INTEGER,
    concepto_status TEXT,
    id_datos INTEGER,
    control TEXT,
    concesionario TEXT,
    ubicacion TEXT,
    nomcomercial TEXT,
    lugar TEXT,
    obs TEXT,
    adicionales TEXT,
    statusregistro TEXT,
    unidades TEXT,
    categoria TEXT,
    seccion TEXT,
    bloque TEXT,
    sector TEXT,
    superficie FLOAT,
    fechainicio DATE,
    fechafin DATE,
    recaudadora INTEGER,
    zona INTEGER,
    licencia INTEGER,
    giro INTEGER,
    tipoobligacion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.status,
        o.concepto_status,
        o.id_datos,
        o.control,
        o.concesionario,
        o.ubicacion,
        o.nomcomercial,
        o.lugar,
        o.obs,
        o.adicionales,
        o.statusregistro,
        o.unidades,
        o.categoria,
        o.seccion,
        o.bloque,
        o.sector,
        o.superficie,
        o.fechainicio,
        o.fechafin,
        o.recaudadora,
        o.zona,
        o.licencia,
        o.giro,
        o.tipoobligacion
    FROM t34_control o
    WHERE o.tabla = par_tabla AND o.control = par_control;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: admin_adeudos_detalle_25odoo
-- Tipo: CRUD
-- Descripción: Obtiene detalle de adeudos para Otras Obligaciones
-- --------------------------------------------

CREATE OR REPLACE FUNCTION admin_adeudos_detalle_25odoo(par_tabla TEXT, par_control TEXT, pref TEXT)
RETURNS TABLE (
    rubro INTEGER,
    concepto INTEGER,
    cuenta_aplicacion INTEGER,
    referencia TEXT,
    descripcion TEXT,
    monto NUMERIC,
    acumulado NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.rubro,
        d.concepto,
        d.cuenta_aplicacion,
        d.referencia,
        d.descripcion,
        d.monto,
        d.acumulado
    FROM t34_detalle d
    WHERE d.tabla = par_tabla AND d.control = par_control;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_alta_descuento_otras_obligaciones
-- Tipo: CRUD
-- Descripción: Da de alta un descuento en t34_descmul para Otras Obligaciones
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_alta_descuento_otras_obligaciones(
    p_id_datos INTEGER,
    p_axoi INTEGER,
    p_mesi INTEGER,
    p_axof INTEGER,
    p_mesf INTEGER,
    p_usuario TEXT,
    p_porc INTEGER,
    p_autoriza INTEGER
) RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_id INTEGER;
BEGIN
    INSERT INTO t34_descmul (
        id_descto, id_contrato, axoinicio, mesinicio, axofin, mesfin, fecha_alta, usuario_alta, vigencia, porcentaje, autoriza
    ) VALUES (
        DEFAULT, p_id_datos, p_axoi, p_mesi, p_axof, p_mesf, NOW(), p_usuario, 'V', p_porc, p_autoriza
    ) RETURNING id_descto INTO v_id;
    RETURN QUERY SELECT TRUE, 'Descuento registrado correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_cancelar_descuento_otras_obligaciones
-- Tipo: CRUD
-- Descripción: Cancela un descuento vigente en t34_descmul para Otras Obligaciones
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cancelar_descuento_otras_obligaciones(
    p_id_datos INTEGER,
    p_minimo TEXT,
    p_maximo TEXT,
    p_usuario TEXT,
    p_porc INTEGER
) RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_id INTEGER;
BEGIN
    UPDATE t34_descmul
    SET vigencia = 'C', fecha_baja = NOW(), usuario_baja = p_usuario
    WHERE id_contrato = p_id_datos
      AND (axoinicio::text || LPAD(mesinicio::text,2,'0')) = p_minimo
      AND (axofin::text || LPAD(mesfin::text,2,'0')) = p_maximo
      AND porcentaje = p_porc
      AND vigencia = 'V'
    RETURNING id_descto INTO v_id;
    IF v_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'No se encontró descuento vigente para cancelar';
    ELSE
        RETURN QUERY SELECT TRUE, 'Descuento cancelado correctamente';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

