-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Titulos
-- Generado: 2025-08-27 14:55:53
-- Total SPs: 6
-- ============================================

-- SP 1/6: sp_titulos_search
-- Tipo: CRUD
-- Descripción: Busca un título por fecha, folio y operación, devuelve todos los datos relevantes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_titulos_search(p_fecha DATE, p_folio INTEGER, p_operacion INTEGER)
RETURNS TABLE(
    control_rcm INTEGER,
    titulo INTEGER,
    libro INTEGER,
    axo INTEGER,
    folio_libro INTEGER,
    nombre_beneficiario TEXT,
    domicilio_beneficiario TEXT,
    colonia_beneficiario TEXT,
    telefono_beneficiario TEXT,
    partida TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.control_rcm, t.titulo, t.libro, t.axo, t.folio, t.nombre_beneficiario, t.domicilio_beneficiario, t.colonia_beneficiario, t.telefono_beneficiario, t.partida
    FROM ta_13_titulos t
    WHERE t.fecha = p_fecha AND t.control_rcm = p_folio AND t.operacion = p_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/6: sp_titulos_update
-- Tipo: CRUD
-- Descripción: Actualiza los datos del beneficiario de un título.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_titulos_update(
    p_control_rcm INTEGER,
    p_titulo INTEGER,
    p_fecha DATE,
    p_libro INTEGER,
    p_axo INTEGER,
    p_folio INTEGER,
    p_nombre TEXT,
    p_domicilio TEXT,
    p_colonia TEXT,
    p_telefono TEXT,
    p_partida TEXT
) RETURNS TABLE(status TEXT, observacion TEXT) AS $$
BEGIN
    UPDATE ta_13_titulos
    SET libro = p_libro,
        axo = p_axo,
        folio = p_folio,
        nombre_beneficiario = p_nombre,
        domicilio_beneficiario = p_domicilio,
        colonia_beneficiario = p_colonia,
        telefono_beneficiario = p_telefono,
        partida = p_partida
    WHERE control_rcm = p_control_rcm AND titulo = p_titulo AND fecha = p_fecha;
    RETURN QUERY SELECT 'OK', 'Actualización exitosa';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/6: sp_titulos_print
-- Tipo: Report
-- Descripción: Devuelve los datos necesarios para la impresión del título.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_titulos_print(p_fecha DATE, p_folio INTEGER, p_operacion INTEGER)
RETURNS TABLE(
    control_rcm INTEGER,
    titulo INTEGER,
    libro INTEGER,
    axo INTEGER,
    folio_libro INTEGER,
    nombre_beneficiario TEXT,
    domicilio_beneficiario TEXT,
    colonia_beneficiario TEXT,
    telefono_beneficiario TEXT,
    partida TEXT,
    datos_json JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.control_rcm, t.titulo, t.libro, t.axo, t.folio, t.nombre_beneficiario, t.domicilio_beneficiario, t.colonia_beneficiario, t.telefono_beneficiario, t.partida,
           to_jsonb(t) as datos_json
    FROM ta_13_titulos t
    WHERE t.fecha = p_fecha AND t.control_rcm = p_folio AND t.operacion = p_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/6: sp_titulos_view
-- Tipo: Catalog
-- Descripción: Devuelve la vista previa de los datos de beneficiario para un título.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_titulos_view(p_fecha DATE, p_folio INTEGER, p_operacion INTEGER)
RETURNS TABLE(
    nombre_beneficiario TEXT,
    domicilio_beneficiario TEXT,
    colonia_beneficiario TEXT,
    telefono_beneficiario TEXT,
    libro INTEGER,
    axo INTEGER,
    folio_libro INTEGER,
    partida TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.nombre_beneficiario, t.domicilio_beneficiario, t.colonia_beneficiario, t.telefono_beneficiario, t.libro, t.axo, t.folio, t.partida
    FROM ta_13_titulos t
    WHERE t.fecha = p_fecha AND t.control_rcm = p_folio AND t.operacion = p_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/6: sp_titulos_validate
-- Tipo: CRUD
-- Descripción: Valida la existencia de un título.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_titulos_validate(p_fecha DATE, p_folio INTEGER, p_operacion INTEGER)
RETURNS TABLE(exists BOOLEAN) AS $$
BEGIN
    RETURN QUERY
    SELECT EXISTS(
        SELECT 1 FROM ta_13_titulos t
        WHERE t.fecha = p_fecha AND t.control_rcm = p_folio AND t.operacion = p_operacion
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/6: sp_titulos_extra
-- Tipo: Catalog
-- Descripción: Devuelve datos extendidos de la vista v_titulos_cem para impresión avanzada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_titulos_extra(p_fecha DATE, p_folio INTEGER, p_operacion INTEGER)
RETURNS TABLE(
    scontrol_rcm INTEGER,
    snombre TEXT,
    sdomicilio TEXT,
    scolonia TEXT,
    stelefono TEXT,
    slibro INTEGER,
    saxo INTEGER,
    sfoliot INTEGER,
    snombreben TEXT,
    sdomben TEXT,
    scolben TEXT,
    stelben TEXT,
    spartida TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT scontrol_rcm, snombre, sdomicilio, scolonia, stelefono, slibro, saxo, sfoliot, snombreben, sdomben, scolben, stelben, spartida
    FROM v_titulos_cem
    WHERE sfecha = p_fecha AND scontrol_rcm = p_folio AND soperacion = p_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

