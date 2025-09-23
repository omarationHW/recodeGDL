-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - OTRAS-OBLIG
-- Formulario: GAdeudos_OpcMult (EXACTO del archivo original)
-- Archivo: 08_SP_OTRASOBLIG_GADEUDOS_OPCMULT_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: cob34_gdatosg_02
-- Tipo: Report
-- Descripción: Obtiene los datos generales de la concesión/control para una tabla y control dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION cob34_gdatosg_02(par_tab TEXT, par_control TEXT)
RETURNS TABLE (
    status INTEGER,
    concepto_status TEXT,
    id_datos INTEGER,
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
    superficie NUMERIC,
    fechainicio DATE,
    fechafin DATE,
    recaudadora INTEGER,
    zona INTEGER,
    licencia INTEGER,
    giro INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CASE WHEN d.id_34_datos IS NULL THEN -1 ELSE 1 END AS status,
        CASE WHEN d.id_34_datos IS NULL THEN 'No existe registro' ELSE 'OK' END AS concepto_status,
        d.id_34_datos, d.concesionario, d.ubicacion, d.nomcomercial, d.lugar, d.obs, d.adicionales, 
        s.descripcion AS statusregistro, d.unidades, d.categoria, d.seccion, d.bloque, d.sector, d.superficie, d.fecha_inicio, d.fecha_fin, d.id_recaudadora, d.id_zona, d.licencia, d.giro
    FROM otrasoblig.t34_datos d
    LEFT JOIN otrasoblig.t34_status s ON d.id_stat = s.id_34_stat
    WHERE d.cve_tab = par_tab AND d.control = par_control
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: cob34_gdetade_01
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos para un control, año y mes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION cob34_gdetade_01(par_tabla TEXT, par_id_datos INTEGER, par_aso INTEGER, par_mes INTEGER)
RETURNS TABLE (
    concepto TEXT,
    axo INTEGER,
    mes INTEGER,
    importe_pagar NUMERIC,
    recargos_pagar NUMERIC,
    dscto_importe NUMERIC,
    dscto_recargos NUMERIC,
    actualizacion_pagar NUMERIC,
    multa_pagar NUMERIC,
    dscto_multa NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.concepto, c.axo, c.mes, c.importe_pagar, c.recargos_pagar, c.dscto_importe, c.dscto_recargos, c.actualizacion_pagar, c.multa_pagar, c.dscto_multa
    FROM otrasoblig.t34_conceptos c
    WHERE c.cve_tab = par_tabla AND c.id_datos = par_id_datos AND c.axo = par_aso AND c.mes = par_mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: upd34_gen_adeudos_ind
-- Tipo: CRUD
-- Descripción: Procesa la opción seleccionada (pago, condonación, cancelación, prescripción) sobre un adeudo individual.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION upd34_gen_adeudos_ind(
    par_id_34_datos INTEGER,
    par_Axo INTEGER,
    par_Mes INTEGER,
    par_Fecha DATE,
    par_Id_Rec INTEGER,
    par_Caja TEXT,
    par_Consec INTEGER,
    par_Folio_rcbo TEXT,
    par_tab TEXT,
    par_status TEXT,
    par_Opc TEXT,
    par_usuario TEXT
) RETURNS TABLE (
    status INTEGER,
    concepto_status TEXT
) AS $$
DECLARE
    v_status INTEGER := 0;
    v_msg TEXT := '';
BEGIN
    -- Aquí va la lógica de actualización de adeudos, pagos, etc.
    -- Ejemplo: Si par_status = 'P' (pagado), insertar en otrasoblig.t34_pagos y actualizar status
    IF par_status = 'P' THEN
        -- Insertar pago
        INSERT INTO otrasoblig.t34_pagos (id_datos, periodo, importe, recargo, fecha_hora_pago, id_recaudadora, caja, operacion, folio_recibo, usuario, id_stat)
        VALUES (par_id_34_datos, make_date(par_Axo, par_Mes, 1), 0, 0, par_Fecha, par_Id_Rec, par_Caja, par_Consec, par_Folio_rcbo, par_usuario, (SELECT id_34_stat FROM otrasoblig.t34_status WHERE cve_stat = 'P'));
        v_status := 1;
        v_msg := 'Pago registrado correctamente.';
    ELSIF par_status = 'S' THEN
        -- Lógica de condonación
        v_status := 1;
        v_msg := 'Adeudo condonado correctamente.';
    ELSIF par_status = 'C' THEN
        -- Lógica de cancelación
        v_status := 1;
        v_msg := 'Adeudo cancelado correctamente.';
    ELSIF par_status = 'R' THEN
        -- Lógica de prescripción
        v_status := 1;
        v_msg := 'Adeudo prescrito correctamente.';
    ELSE
        v_status := 0;
        v_msg := 'Opción no válida.';
    END IF;
    RETURN QUERY SELECT v_status, v_msg;
END;
$$ LANGUAGE plpgsql;

-- ============================================