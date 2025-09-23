-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: empresasfrm
-- Generado: 2025-08-26 16:14:20
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_empresas_create
-- Tipo: CRUD
-- Descripción: Crea una nueva empresa y retorna el registro insertado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_empresas_create(
    p_propietario TEXT,
    p_rfc TEXT,
    p_curp TEXT,
    p_domicilio TEXT,
    p_numext_prop INTEGER,
    p_numint_prop TEXT,
    p_colonia_prop TEXT,
    p_telefono_prop TEXT,
    p_email TEXT,
    p_cvecalle INTEGER,
    p_ubicacion TEXT,
    p_numext_ubic INTEGER,
    p_letraext_ubic TEXT,
    p_numint_ubic TEXT,
    p_letraint_ubic TEXT,
    p_colonia_ubic TEXT,
    p_sup_construida NUMERIC,
    p_sup_autorizada NUMERIC,
    p_num_cajones INTEGER,
    p_num_empleados INTEGER,
    p_aforo INTEGER,
    p_inversion NUMERIC,
    p_rhorario TEXT,
    p_fecha_consejo DATE,
    p_bloqueado INTEGER,
    p_asiento INTEGER,
    p_vigente TEXT,
    p_fecha_baja DATE,
    p_axo_baja INTEGER,
    p_folio_baja INTEGER,
    p_espubic TEXT,
    p_base_impuesto NUMERIC,
    p_zona INTEGER,
    p_subzona INTEGER,
    p_recaud INTEGER,
    p_fecha_otorgamiento DATE,
    p_empresa INTEGER DEFAULT NULL,
    p_id_giro INTEGER DEFAULT NULL,
    p_x NUMERIC DEFAULT NULL,
    p_y NUMERIC DEFAULT NULL,
    p_cvecuenta INTEGER DEFAULT NULL,
    p_cp INTEGER DEFAULT NULL
) RETURNS TABLE (empresa INTEGER, propietario TEXT, rfc TEXT, ubicacion TEXT, numext_ubic INTEGER, colonia_ubic TEXT, zona INTEGER, subzona INTEGER, vigente TEXT) AS $$
DECLARE
    v_empresa INTEGER;
BEGIN
    SELECT COALESCE(MAX(empresa),0)+1 INTO v_empresa FROM empresas;
    INSERT INTO empresas (
        empresa, propietario, rfc, curp, domicilio, numext_prop, numint_prop, colonia_prop, telefono_prop, email, cvecalle, ubicacion, numext_ubic, letraext_ubic, numint_ubic, letrainT_ubic, colonia_ubic, sup_construida, sup_autorizada, num_cajones, num_empleados, aforo, inversion, rhorario, fecha_consejo, bloqueado, asiento, vigente, fecha_baja, axo_baja, folio_baja, espubic, base_impuesto, zona, subzona, recaud, fecha_otorgamiento, id_giro, x, y, cvecuenta, cp
    ) VALUES (
        v_empresa, p_propietario, p_rfc, p_curp, p_domicilio, p_numext_prop, p_numint_prop, p_colonia_prop, p_telefono_prop, p_email, p_cvecalle, p_ubicacion, p_numext_ubic, p_letraext_ubic, p_numint_ubic, p_letraint_ubic, p_colonia_ubic, p_sup_construida, p_sup_autorizada, p_num_cajones, p_num_empleados, p_aforo, p_inversion, p_rhorario, p_fecha_consejo, p_bloqueado, p_asiento, p_vigente, p_fecha_baja, p_axo_baja, p_folio_baja, p_espubic, p_base_impuesto, p_zona, p_subzona, p_recaud, p_fecha_otorgamiento, p_id_giro, p_x, p_y, p_cvecuenta, p_cp
    );
    RETURN QUERY SELECT v_empresa, p_propietario, p_rfc, p_ubicacion, p_numext_ubic, p_colonia_ubic, p_zona, p_subzona, p_vigente;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_empresas_update
-- Tipo: CRUD
-- Descripción: Actualiza una empresa existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_empresas_update(
    p_empresa INTEGER,
    p_propietario TEXT,
    p_rfc TEXT,
    p_curp TEXT,
    p_domicilio TEXT,
    p_numext_prop INTEGER,
    p_numint_prop TEXT,
    p_colonia_prop TEXT,
    p_telefono_prop TEXT,
    p_email TEXT,
    p_cvecalle INTEGER,
    p_ubicacion TEXT,
    p_numext_ubic INTEGER,
    p_letraext_ubic TEXT,
    p_numint_ubic TEXT,
    p_letraint_ubic TEXT,
    p_colonia_ubic TEXT,
    p_sup_construida NUMERIC,
    p_sup_autorizada NUMERIC,
    p_num_cajones INTEGER,
    p_num_empleados INTEGER,
    p_aforo INTEGER,
    p_inversion NUMERIC,
    p_rhorario TEXT,
    p_fecha_consejo DATE,
    p_bloqueado INTEGER,
    p_asiento INTEGER,
    p_vigente TEXT,
    p_fecha_baja DATE,
    p_axo_baja INTEGER,
    p_folio_baja INTEGER,
    p_espubic TEXT,
    p_base_impuesto NUMERIC,
    p_zona INTEGER,
    p_subzona INTEGER,
    p_recaud INTEGER,
    p_fecha_otorgamiento DATE,
    p_id_giro INTEGER DEFAULT NULL,
    p_x NUMERIC DEFAULT NULL,
    p_y NUMERIC DEFAULT NULL,
    p_cvecuenta INTEGER DEFAULT NULL,
    p_cp INTEGER DEFAULT NULL
) RETURNS TABLE (empresa INTEGER, propietario TEXT, rfc TEXT, ubicacion TEXT, numext_ubic INTEGER, colonia_ubic TEXT, zona INTEGER, subzona INTEGER, vigente TEXT) AS $$
BEGIN
    UPDATE empresas SET
        propietario = p_propietario,
        rfc = p_rfc,
        curp = p_curp,
        domicilio = p_domicilio,
        numext_prop = p_numext_prop,
        numint_prop = p_numint_prop,
        colonia_prop = p_colonia_prop,
        telefono_prop = p_telefono_prop,
        email = p_email,
        cvecalle = p_cvecalle,
        ubicacion = p_ubicacion,
        numext_ubic = p_numext_ubic,
        letraext_ubic = p_letraext_ubic,
        numint_ubic = p_numint_ubic,
        letrainT_ubic = p_letraint_ubic,
        colonia_ubic = p_colonia_ubic,
        sup_construida = p_sup_construida,
        sup_autorizada = p_sup_autorizada,
        num_cajones = p_num_cajones,
        num_empleados = p_num_empleados,
        aforo = p_aforo,
        inversion = p_inversion,
        rhorario = p_rhorario,
        fecha_consejo = p_fecha_consejo,
        bloqueado = p_bloqueado,
        asiento = p_asiento,
        vigente = p_vigente,
        fecha_baja = p_fecha_baja,
        axo_baja = p_axo_baja,
        folio_baja = p_folio_baja,
        espubic = p_espubic,
        base_impuesto = p_base_impuesto,
        zona = p_zona,
        subzona = p_subzona,
        recaud = p_recaud,
        fecha_otorgamiento = p_fecha_otorgamiento,
        id_giro = p_id_giro,
        x = p_x,
        y = p_y,
        cvecuenta = p_cvecuenta,
        cp = p_cp
    WHERE empresa = p_empresa;
    RETURN QUERY SELECT empresa, propietario, rfc, ubicacion, numext_ubic, colonia_ubic, zona, subzona, vigente FROM empresas WHERE empresa = p_empresa;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_empresas_delete
-- Tipo: CRUD
-- Descripción: Elimina una empresa por su clave primaria.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_empresas_delete(p_empresa INTEGER)
RETURNS TABLE (empresa INTEGER) AS $$
BEGIN
    DELETE FROM empresas WHERE empresa = p_empresa RETURNING empresa;
END;
$$ LANGUAGE plpgsql;

-- ============================================

