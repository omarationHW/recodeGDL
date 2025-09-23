-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DMULTAOTRASOBLIGACIONES (EXACTO del archivo original)
-- Archivo: 46_SP_RECAUDADORA_DMULTAOTRASOBLIGACIONES_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DMULTAOTRASOBLIGACIONES (EXACTO del archivo original)
-- Archivo: 46_SP_RECAUDADORA_DMULTAOTRASOBLIGACIONES_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DMULTAOTRASOBLIGACIONES (EXACTO del archivo original)
-- Archivo: 46_SP_RECAUDADORA_DMULTAOTRASOBLIGACIONES_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

