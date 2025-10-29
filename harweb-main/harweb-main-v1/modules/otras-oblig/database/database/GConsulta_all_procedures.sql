-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: GConsulta
-- Generado: 2025-08-27 16:02:36
-- Total SPs: 8
-- ============================================

-- SP 1/8: sp_get_etiquetas
-- Tipo: Catalog
-- Descripción: Obtiene las etiquetas de la tabla t34_etiq para el tipo de contrato/tab seleccionado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_etiquetas(par_tab integer)
RETURNS TABLE (
    cve_tab varchar,
    abreviatura varchar,
    etiq_control varchar,
    concesionario varchar,
    ubicacion varchar,
    superficie varchar,
    fecha_inicio varchar,
    fecha_fin varchar,
    recaudadora varchar,
    sector varchar,
    zona varchar,
    licencia varchar,
    fecha_cancelacion varchar,
    unidad varchar,
    categoria varchar,
    seccion varchar,
    bloque varchar,
    nombre_comercial varchar,
    lugar varchar,
    obs varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM t34_etiq WHERE cve_tab = par_tab;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/8: sp_get_tablas
-- Tipo: Catalog
-- Descripción: Obtiene el nombre y descripción de la tabla de contratos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tablas(par_tab integer)
RETURNS TABLE (
    cve_tab varchar,
    nombre varchar,
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.cve_tab, a.nombre, b.descripcion
    FROM t34_tablas a
    JOIN t34_unidades b ON b.cve_tab = a.cve_tab
    WHERE a.cve_tab = par_tab
    GROUP BY a.cve_tab, a.nombre, b.descripcion
    ORDER BY a.cve_tab, a.nombre, b.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/8: sp_get_datos_generales
-- Tipo: Report
-- Descripción: Obtiene los datos generales del contrato/concesión para mostrar en la consulta.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_datos_generales(par_tab integer, par_control varchar)
RETURNS TABLE (
    status integer,
    concepto_status varchar,
    id_datos integer,
    concesionario varchar,
    ubicacion varchar,
    nomcomercial varchar,
    lugar varchar,
    obs varchar,
    adicionales varchar,
    statusregistro varchar,
    unidades varchar,
    categoria varchar,
    seccion varchar,
    bloque varchar,
    sector varchar,
    superficie numeric,
    fechainicio date,
    fechafin date,
    recaudadora integer,
    zona integer,
    licencia integer,
    giro integer,
    control varchar,
    tipoobligacion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CASE WHEN a.id_34_datos IS NULL THEN -1 ELSE 0 END AS status,
        CASE WHEN a.id_34_datos IS NULL THEN 'No existe registro' ELSE 'OK' END AS concepto_status,
        a.id_34_datos, a.concesionario, a.ubicacion, a.nomcomercial, a.lugar, a.obs, a.adicionales, a.statusregistro, a.unidades, a.categoria, a.seccion, a.bloque, a.sector, a.superficie, a.fechainicio, a.fechafin, a.recaudadora, a.zona, a.licencia, a.giro, a.control, a.tipoobligacion
    FROM t34_datos a
    WHERE a.cve_tab = par_tab AND a.control = par_control
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/8: sp_get_adeudos_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos para un contrato/concesión y periodo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_adeudos_detalle(par_tabla integer, par_id_datos integer, par_aso integer, par_mes integer)
RETURNS TABLE (
    concepto varchar,
    axo integer,
    mes integer,
    importe_pagar numeric,
    recargos_pagar numeric,
    dscto_importe numeric,
    dscto_recargos numeric,
    actualizacion_pagar numeric,
    multa_pagar numeric,
    dscto_multa numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT concepto, axo, mes, importe_pagar, recargos_pagar, dscto_importe, dscto_recargos, actualizacion_pagar, multa_pagar, dscto_multa
    FROM t34_adeudos_detalle
    WHERE cve_tab = par_tabla AND id_datos = par_id_datos AND axo = par_aso AND mes = par_mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/8: sp_get_adeudos_totales
-- Tipo: Report
-- Descripción: Obtiene los totales de adeudos para un contrato/concesión y periodo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_adeudos_totales(par_tabla integer, par_id_datos integer, par_aso integer, par_mes integer)
RETURNS TABLE (
    cuenta integer,
    obliga varchar,
    concepto varchar,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT cuenta, obliga, concepto, importe
    FROM t34_adeudos_totales
    WHERE cve_tab = par_tabla AND id_datos = par_id_datos AND axo = par_aso AND mes = par_mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/8: sp_get_pagados
-- Tipo: Report
-- Descripción: Obtiene los pagos realizados para un contrato/concesión.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_pagados(p_Control integer)
RETURNS TABLE (
    id_34_pagos integer,
    id_datos integer,
    periodo date,
    importe numeric,
    recargo numeric,
    fecha_hora_pago timestamp,
    id_recaudadora integer,
    caja varchar,
    operacion integer,
    folio_recibo varchar,
    usuario varchar,
    id_stat integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_pagos, a.id_datos, a.periodo, a.importe, a.recargo, a.fecha_hora_pago, a.id_recaudadora, a.caja, a.operacion, a.folio_recibo, a.usuario, a.id_stat
    FROM t34_pagos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = p_Control AND b.cve_stat = 'P'
    ORDER BY a.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/8: sp_get_admin_adeudos_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos administrativos para un contrato/concesión y periodo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_admin_adeudos_detalle(par_Tabla integer, par_Control varchar, pref varchar)
RETURNS TABLE (
    rubro integer,
    concepto integer,
    cuenta_aplicacion integer,
    referencia varchar,
    descripcion varchar,
    monto numeric,
    acumulado numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT rubro, concepto, cuenta_aplicacion, referencia, descripcion, monto, acumulado
    FROM admin_adeudos_detalle
    WHERE cve_tab = par_Tabla AND control = par_Control AND referencia = pref;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 8/8: sp_get_admin_adeudos_detalle_tot
-- Tipo: Report
-- Descripción: Obtiene los totales de adeudos administrativos para un contrato/concesión y periodo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_admin_adeudos_detalle_tot(par_Tabla integer, par_Control varchar, pref varchar)
RETURNS TABLE (
    cuenta_aplicacion integer,
    referencia varchar,
    monto numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT cuenta_aplicacion, referencia, monto
    FROM admin_adeudos_detalle_tot
    WHERE cve_tab = par_Tabla AND control = par_Control AND referencia = pref;
END;
$$ LANGUAGE plpgsql;

-- ============================================

