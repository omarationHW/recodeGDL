-- ============================================
-- SCRIPT MAESTRO DE STORED PROCEDURES
-- Proyecto: cementerios
-- Generado: 2025-08-27 15:19:30
-- Total SPs: 45
-- ============================================

-- NOTA: Ejecutar este script en PostgreSQL para crear todos los stored procedures
-- del módulo. Se recomienda ejecutar en el siguiente orden:
-- 1. CATALOG procedures (consultas básicas)
-- 2. CRUD procedures (operaciones de datos)
-- 3. PROCESS procedures (procesos de negocio)
-- 4. REPORT procedures (reportes y análisis)

-- ============================================
-- STORED PROCEDURES TIPO: Catalog
-- ============================================

-- SP 1/10 del tipo Catalog
-- Nombre: rpt_titulos_get_recaudadora
-- Descripción: Obtiene los datos de la recaudadora por id_rec.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_titulos_get_recaudadora(rec smallint)
RETURNS TABLE (
    recing smallint,
    nomre varchar,
    titulo varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT recing, nomre, titulo
    FROM ta_12_nombrerec
    WHERE recing = rec;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 2/10 del tipo Catalog
-- Nombre: sp_cementerios_list
-- Descripción: Devuelve el catálogo de cementerios
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cementerios_list()
RETURNS TABLE (
    cementerio VARCHAR,
    nombre VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT cementerio, nombre FROM tc_13_cementerios ORDER BY cementerio;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 3/10 del tipo Catalog
-- Nombre: sp_consultar_sanandres
-- Descripción: Devuelve todos los registros de la tabla 'datos' del cementerio San Andrés.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consultar_sanandres()
RETURNS TABLE (
    id integer,
    clase text,
    seccion text,
    linea text,
    fosa text,
    ppago text,
    nombre text,
    fcompra timestamp,
    otros text,
    clave smallint,
    medida float,
    calle text,
    colonia text
) AS $$
BEGIN
    RETURN QUERY SELECT id, clase, seccion, linea, fosa, ppago, nombre, fcompra, otros, clave, medida, calle, colonia FROM datos;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 4/10 del tipo Catalog
-- Nombre: sp_consultar_sanandres_paginated
-- Descripción: Devuelve registros paginados de la tabla 'datos' del cementerio San Andrés.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consultar_sanandres_paginated(p_page integer, p_per_page integer)
RETURNS TABLE (
    id integer,
    clase text,
    seccion text,
    linea text,
    fosa text,
    ppago text,
    nombre text,
    fcompra timestamp,
    otros text,
    clave smallint,
    medida float,
    calle text,
    colonia text
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, clase, seccion, linea, fosa, ppago, nombre, fcompra, otros, clave, medida, calle, colonia
    FROM datos
    ORDER BY id
    OFFSET ((p_page - 1) * p_per_page)
    LIMIT p_per_page;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 5/10 del tipo Catalog
-- Nombre: sp_get_recaudadora
-- Descripción: Obtiene los datos de la recaudadora (nombre, zona, etc) por id_rec.
-- --------------------------------------------

-- PostgreSQL stored procedure for recaudadora info
CREATE OR REPLACE FUNCTION sp_get_recaudadora(par_id_rec integer)
RETURNS TABLE(
    id_rec integer,
    nomre text,
    titulo text,
    d_zona text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_rec, a.nomre, a.titulo, upper(c.zona) as d_zona
    FROM ta_12_nombrerec a
    JOIN ta_12_recaudadoras b ON a.recing = b.id_rec
    JOIN ta_12_zonas c ON b.id_zona = c.id_zona
    WHERE a.recing = par_id_rec;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 6/10 del tipo Catalog
-- Nombre: sp_get_usuario_detalle
-- Descripción: Obtiene detalles del usuario por nombre de usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_usuario_detalle(p_usuario VARCHAR)
RETURNS TABLE(
    id_usuario INTEGER,
    usuario VARCHAR,
    nombre VARCHAR,
    estado VARCHAR,
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora VARCHAR,
    domicilio VARCHAR,
    tel VARCHAR,
    recaudador VARCHAR,
    nivel SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_usuario,
        a.usuario,
        a.nombre,
        a.estado,
        a.id_rec,
        b.id_zona,
        b.recaudadora,
        b.domicilio,
        b.tel,
        b.recaudador,
        a.nivel
    FROM ta_12_passwords a
    JOIN ta_12_recaudadoras b ON a.id_rec = b.id_rec
    WHERE a.usuario = p_usuario
      AND a.estado = 'A';
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 7/10 del tipo Catalog
-- Nombre: sp_get_version_detalle
-- Descripción: Obtiene detalles de la versión de un proyecto.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_version_detalle(p_proyecto VARCHAR, p_version VARCHAR)
RETURNS TABLE(
    proyecto VARCHAR,
    version VARCHAR,
    fecha DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT proyecto, version, fecha
    FROM ta_versiones
    WHERE proyecto = p_proyecto AND version = p_version;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 8/10 del tipo Catalog
-- Nombre: sp_titulos_extra
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

-- --------------------------------------------

-- SP 9/10 del tipo Catalog
-- Nombre: sp_titulos_view
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

-- --------------------------------------------

-- SP 10/10 del tipo Catalog
-- Nombre: sp_titulosin_get_rec
-- Descripción: Obtiene los datos de la recaudadora.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_titulosin_get_rec(
    p_rec SMALLINT
) RETURNS TABLE(
    recing SMALLINT,
    nomre VARCHAR,
    titulo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT recing, UPPER(nomre), titulo
    FROM ta_12_nombrerec
    WHERE recing = p_rec;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- ============================================
-- STORED PROCEDURES TIPO: CRUD
-- ============================================

-- SP 1/23 del tipo CRUD
-- Nombre: rpt_titulos_fecha_aletras_corta
-- Descripción: Convierte una fecha a formato 'dd-Mes-aaaa' en español abreviado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_titulos_fecha_aletras_corta(fecha date)
RETURNS varchar AS $$
DECLARE
    meses text[] := ARRAY['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    d integer;
    m integer;
    y integer;
BEGIN
    d := EXTRACT(DAY FROM fecha);
    m := EXTRACT(MONTH FROM fecha);
    y := EXTRACT(YEAR FROM fecha);
    RETURN d::text || '-' || meses[m] || '-' || y::text;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 2/23 del tipo CRUD
-- Nombre: sp_abcf_baja_folio
-- Descripción: Da de baja lógica un folio (vigencia = 'B') y registra histórico.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_abcf_baja_folio(
    p_folio INTEGER,
    p_usuario INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ta_13_datosrcm SET
        vigencia = 'B',
        usuario = p_usuario,
        fecha_mov = CURRENT_DATE
    WHERE control_rcm = p_folio;
    CALL sp_13_historia(p_folio);
END;
$$;

-- --------------------------------------------

-- SP 3/23 del tipo CRUD
-- Nombre: sp_abcf_delete_adicional
-- Descripción: Elimina los datos adicionales de un folio.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_abcf_delete_adicional(p_folio INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM ta_13_datosrcmadic WHERE control_rcm = p_folio;
END;
$$;

-- --------------------------------------------

-- SP 4/23 del tipo CRUD
-- Nombre: sp_abcf_get_adicional
-- Descripción: Obtiene los datos adicionales de un folio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_abcf_get_adicional(p_folio INTEGER)
RETURNS TABLE (
    control_rcm INTEGER,
    rfc VARCHAR,
    curp VARCHAR,
    telefono VARCHAR,
    clave_ife VARCHAR
) AS $$
BEGIN
    RETURN QUERY SELECT control_rcm, rfc, curp, telefono, clave_ife FROM ta_13_datosrcmadic WHERE control_rcm = p_folio;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 5/23 del tipo CRUD
-- Nombre: sp_abcf_get_folio
-- Descripción: Obtiene todos los datos de un folio, incluyendo datos adicionales y adeudos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_abcf_get_folio(p_folio INTEGER)
RETURNS TABLE (
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase SMALLINT,
    clase_alfa VARCHAR,
    seccion SMALLINT,
    seccion_alfa VARCHAR,
    linea SMALLINT,
    linea_alfa VARCHAR,
    fosa SMALLINT,
    fosa_alfa VARCHAR,
    axo_pagado INTEGER,
    metros FLOAT,
    nombre VARCHAR,
    domicilio VARCHAR,
    exterior VARCHAR,
    interior VARCHAR,
    colonia VARCHAR,
    observaciones VARCHAR,
    usuario INTEGER,
    fecha_mov DATE,
    tipo VARCHAR,
    fecha_alta DATE,
    vigencia VARCHAR,
    usuario_nombre VARCHAR,
    id_rec SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_rcm, a.cementerio, a.clase, a.clase_alfa, a.seccion, a.seccion_alfa, a.linea, a.linea_alfa, a.fosa, a.fosa_alfa, a.axo_pagado, a.metros, a.nombre, a.domicilio, a.exterior, a.interior, a.colonia, a.observaciones, a.usuario, a.fecha_mov, a.tipo, a.fecha_alta, a.vigencia, c.nombre, c.id_rec
    FROM ta_13_datosrcm a
    LEFT JOIN ta_12_passwords c ON a.usuario = c.id_usuario
    WHERE a.control_rcm = p_folio;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 6/23 del tipo CRUD
-- Nombre: sp_abcf_update_adicional
-- Descripción: Actualiza o inserta los datos adicionales de un folio.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_abcf_update_adicional(
    p_folio INTEGER,
    p_rfc VARCHAR,
    p_curp VARCHAR,
    p_telefono VARCHAR,
    p_clave_ife VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_13_datosrcmadic WHERE control_rcm = p_folio) THEN
        UPDATE ta_13_datosrcmadic SET
            rfc = p_rfc,
            curp = p_curp,
            telefono = p_telefono,
            clave_ife = p_clave_ife
        WHERE control_rcm = p_folio;
    ELSE
        INSERT INTO ta_13_datosrcmadic (control_rcm, rfc, curp, telefono, clave_ife)
        VALUES (p_folio, p_rfc, p_curp, p_telefono, p_clave_ife);
    END IF;
END;
$$;

-- --------------------------------------------

-- SP 7/23 del tipo CRUD
-- Nombre: sp_abcf_update_folio
-- Descripción: Actualiza los datos principales de un folio.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_abcf_update_folio(
    p_folio INTEGER,
    p_cementerio VARCHAR,
    p_clase SMALLINT,
    p_clase_alfa VARCHAR,
    p_seccion SMALLINT,
    p_seccion_alfa VARCHAR,
    p_linea SMALLINT,
    p_linea_alfa VARCHAR,
    p_fosa SMALLINT,
    p_fosa_alfa VARCHAR,
    p_axo_pagado INTEGER,
    p_metros FLOAT,
    p_nombre VARCHAR,
    p_domicilio VARCHAR,
    p_exterior VARCHAR,
    p_interior VARCHAR,
    p_colonia VARCHAR,
    p_observaciones VARCHAR,
    p_tipo VARCHAR,
    p_usuario INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ta_13_datosrcm SET
        cementerio = p_cementerio,
        clase = p_clase,
        clase_alfa = p_clase_alfa,
        seccion = p_seccion,
        seccion_alfa = p_seccion_alfa,
        linea = p_linea,
        linea_alfa = p_linea_alfa,
        fosa = p_fosa,
        fosa_alfa = p_fosa_alfa,
        axo_pagado = p_axo_pagado,
        metros = p_metros,
        nombre = p_nombre,
        domicilio = p_domicilio,
        exterior = p_exterior,
        interior = p_interior,
        colonia = p_colonia,
        observaciones = p_observaciones,
        usuario = p_usuario,
        fecha_mov = CURRENT_DATE,
        tipo = p_tipo
    WHERE control_rcm = p_folio;
    -- Lógica de histórico
    CALL sp_13_historia(p_folio);
END;
$$;

-- --------------------------------------------

-- SP 8/23 del tipo CRUD
-- Nombre: sp_chgpass_change
-- Descripción: Cambia la clave del usuario autenticado, validando reglas de seguridad.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_chgpass_change(
    p_user_id integer,
    p_current_password text,
    p_new_password text,
    p_confirm_password text
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_user_record RECORD;
    v_valid boolean;
BEGIN
    -- Validar clave actual
    SELECT * INTO v_user_record FROM ta_12_passwords WHERE id_usuario = p_user_id AND estado = 'A';
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Usuario no encontrado o inactivo.';
        RETURN;
    END IF;
    v_valid := (v_user_record.password = crypt(p_current_password, v_user_record.password));
    IF NOT v_valid THEN
        RETURN QUERY SELECT false, 'La clave actual no es correcta.';
        RETURN;
    END IF;
    -- Validaciones de nueva clave
    IF p_new_password IS NULL OR length(p_new_password) < 6 THEN
        RETURN QUERY SELECT false, 'La clave debe ser mayor a 5 dígitos.';
        RETURN;
    END IF;
    IF p_new_password = p_current_password THEN
        RETURN QUERY SELECT false, 'La clave nueva no debe ser igual a la actual.';
        RETURN;
    END IF;
    IF substring(p_new_password, 1, 3) = substring(p_current_password, 1, 3) THEN
        RETURN QUERY SELECT false, 'Los tres primeros caracteres deben ser diferentes al actual.';
        RETURN;
    END IF;
    IF p_new_password <> p_confirm_password THEN
        RETURN QUERY SELECT false, 'La confirmación de la clave no es igual.';
        RETURN;
    END IF;
    IF p_new_password !~ '[a-z]' OR p_new_password !~ '[0-9]' THEN
        RETURN QUERY SELECT false, 'La clave debe contener números y letras.';
        RETURN;
    END IF;
    -- Actualizar clave
    UPDATE ta_12_passwords
    SET password = crypt(p_new_password, gen_salt('bf')),
        fecha_mov = now()
    WHERE id_usuario = p_user_id;
    RETURN QUERY SELECT true, 'Clave cambiada satisfactoriamente.';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- --------------------------------------------

-- SP 9/23 del tipo CRUD
-- Nombre: sp_chgpass_validate_current
-- Descripción: Valida si la clave actual ingresada corresponde al usuario autenticado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_chgpass_validate_current(p_user_id integer, p_current_password text)
RETURNS TABLE(is_valid boolean) AS $$
BEGIN
    RETURN QUERY
    SELECT (password = crypt(p_current_password, password)) AS is_valid
    FROM ta_12_passwords
    WHERE id_usuario = p_user_id AND estado = 'A';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- --------------------------------------------

-- SP 10/23 del tipo CRUD
-- Nombre: sp_hay_nueva_version
-- Descripción: Verifica si hay una nueva versión para el proyecto.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_hay_nueva_version(p_proyecto VARCHAR, p_version VARCHAR)
RETURNS TABLE(hay_nueva BOOLEAN) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM ta_versiones WHERE proyecto = p_proyecto AND version = p_version;
    IF v_count = 1 THEN
        RETURN QUERY SELECT FALSE;
    ELSE
        RETURN QUERY SELECT TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 11/23 del tipo CRUD
-- Nombre: sp_liquidaciones_calcular
-- Descripción: Calcula la liquidación de mantenimiento y recargos para un cementerio, años y metros dados.
-- --------------------------------------------

-- PostgreSQL stored procedure for liquidation calculation
CREATE OR REPLACE FUNCTION sp_liquidaciones_calcular(
    p_cementerio VARCHAR(1),
    p_anio_desde INTEGER,
    p_anio_hasta INTEGER,
    p_metros NUMERIC,
    p_tipo VARCHAR(1), -- 'F', 'U', 'G'
    p_nuevo BOOLEAN,
    p_mes INTEGER
)
RETURNS TABLE(
    axo_cuota INTEGER,
    manten NUMERIC,
    recargos NUMERIC
) AS $$
DECLARE
    v_cuota_col TEXT;
    v_axo INTEGER;
    v_mant NUMERIC;
    v_rec NUMERIC;
    v_porcentaje NUMERIC;
BEGIN
    -- Determinar columna de cuota
    IF p_tipo = 'F' THEN
        v_cuota_col := 'cuota1';
    ELSIF p_tipo = 'U' THEN
        v_cuota_col := 'cuota_urna';
    ELSIF p_tipo = 'G' THEN
        v_cuota_col := 'cuota_gaveta';
    ELSE
        v_cuota_col := 'cuota2';
    END IF;

    FOR v_axo IN p_anio_desde..p_anio_hasta LOOP
        -- Obtener cuota
        EXECUTE format('SELECT %I FROM ta_13_rcmcuotas WHERE cementerio = $1 AND axo_cuota = $2', v_cuota_col)
        INTO v_mant USING p_cementerio, v_axo;
        IF v_mant IS NULL THEN v_mant := 0; END IF;
        v_mant := round(v_mant * p_metros, 2);
        -- Calcular recargos
        IF p_nuevo THEN
            v_rec := 0;
        ELSE
            SELECT porcentaje_global FROM ta_13_recargosrcm WHERE axo = v_axo AND mes = p_mes INTO v_porcentaje;
            IF v_porcentaje IS NULL THEN v_porcentaje := 0; END IF;
            v_rec := round(v_mant * (v_porcentaje/100), 2);
        END IF;
        axo_cuota := v_axo;
        manten := v_mant;
        recargos := v_rec;
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 12/23 del tipo CRUD
-- Nombre: sp_titulos_search
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

-- --------------------------------------------

-- SP 13/23 del tipo CRUD
-- Nombre: sp_titulos_update
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

-- --------------------------------------------

-- SP 14/23 del tipo CRUD
-- Nombre: sp_titulos_validate
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

-- --------------------------------------------

-- SP 15/23 del tipo CRUD
-- Nombre: sp_titulosin_get_folio
-- Descripción: Obtiene los datos del folio para impresión de título sin referencias.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_titulosin_get_folio(
    p_folio INTEGER,
    p_fecha DATE,
    p_operacion INTEGER
) RETURNS TABLE(
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase SMALLINT,
    clase_alfa VARCHAR,
    seccion SMALLINT,
    seccion_alfa VARCHAR,
    linea SMALLINT,
    linea_alfa VARCHAR,
    fosa SMALLINT,
    fosa_alfa VARCHAR,
    axo_pagado INTEGER,
    metros FLOAT,
    nombre VARCHAR,
    domicilio VARCHAR,
    exterior VARCHAR,
    interior VARCHAR,
    colonia VARCHAR,
    observaciones VARCHAR,
    usuario INTEGER,
    fecha_mov DATE,
    tipo VARCHAR,
    nombre_1 VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.control_rcm, b.cementerio, b.clase, b.clase_alfa, b.seccion, b.seccion_alfa, b.linea, b.linea_alfa, b.fosa, b.fosa_alfa, b.axo_pagado, b.metros, b.nombre, b.domicilio, b.exterior, b.interior, b.colonia, b.observaciones, b.usuario, b.fecha_mov, b.tipo, c.nombre as nombre_1
    FROM ta_13_datosrcm b
    JOIN tc_13_cementerios c ON b.cementerio = c.cementerio
    WHERE b.control_rcm = p_folio;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 16/23 del tipo CRUD
-- Nombre: sp_titulosin_get_ingresos
-- Descripción: Obtiene los datos de ingresos para la impresión del título.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_titulosin_get_ingresos(
    p_fecha DATE,
    p_ofna SMALLINT,
    p_caja VARCHAR,
    p_operacion INTEGER
) RETURNS TABLE(
    fecha DATE,
    id_rec SMALLINT,
    caja VARCHAR,
    operacion INTEGER,
    importe NUMERIC,
    cvepago VARCHAR,
    id_modulo INTEGER,
    id_regmodulo INTEGER,
    id_rec_cta SMALLINT,
    regmunur VARCHAR,
    mesdesde SMALLINT,
    axodesde SMALLINT,
    meshasta SMALLINT,
    axohasta SMALLINT,
    nombre VARCHAR,
    domicilio VARCHAR,
    concepto VARCHAR,
    rfcini VARCHAR,
    rfcnumero INTEGER,
    rfccolonia SMALLINT,
    obra SMALLINT,
    axofolio INTEGER,
    id_usuario INTEGER,
    fecha_act TIMESTAMP,
    cajero VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.*, (SELECT nombre FROM ta_12_passwords WHERE id_usuario = a.id_usuario) as cajero
    FROM ta_12_recibos a
    WHERE a.fecha = p_fecha
      AND a.id_rec = p_ofna
      AND a.caja = p_caja
      AND a.operacion = p_operacion
      AND a.id_modulo = 12
      AND (
        SELECT COUNT(*) FROM ta_12_recibosdet
        WHERE fecha = a.fecha AND a.id_rec = id_rec AND a.caja = caja AND a.operacion = operacion
          AND cuenta IN (44304, 44301, 44307, 44314, 44311, 44310, 44450)
      ) > 0;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 17/23 del tipo CRUD
-- Nombre: sp_titulosin_print
-- Descripción: Prepara los datos para la impresión del título sin referencias. Puede devolver los datos en formato JSON o PDF.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_titulosin_print(
    p_folio INTEGER,
    p_fecha DATE,
    p_operacion INTEGER,
    p_rec SMALLINT,
    p_telefono VARCHAR
) RETURNS JSON AS $$
DECLARE
    folio_data RECORD;
    rec_data RECORD;
    result JSON;
BEGIN
    SELECT * INTO folio_data FROM sp_titulosin_get_folio(p_folio, p_fecha, p_operacion);
    SELECT * INTO rec_data FROM sp_titulosin_get_rec(p_rec);
    result := json_build_object(
        'folio', folio_data,
        'rec', rec_data,
        'telefono', p_telefono
    );
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 18/23 del tipo CRUD
-- Nombre: sp_traslado_folios_sin_adeudo
-- Descripción: Traslada pagos seleccionados de un folio a otro sin afectar adeudos. Actualiza los registros de pagos y los datos de axo_pagado según la lógica de negocio.
-- --------------------------------------------

--
-- sp_traslado_folios_sin_adeudo
-- Traslada pagos seleccionados de un folio a otro sin afectar adeudos
--
CREATE OR REPLACE FUNCTION sp_traslado_folios_sin_adeudo(
    p_folio_de integer,
    p_folio_a integer,
    p_pagos_ids jsonb,
    p_usuario integer
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_axo integer;
    v_mes integer;
    v_dia integer;
    v_suma integer := 0;
    v_pago_id integer;
    v_uap integer;
BEGIN
    -- Validaciones
    IF p_folio_de IS NULL OR p_folio_a IS NULL OR p_pagos_ids IS NULL OR p_usuario IS NULL THEN
        RETURN QUERY SELECT false, 'Parámetros incompletos';
        RETURN;
    END IF;
    IF p_folio_de = p_folio_a THEN
        RETURN QUERY SELECT false, 'Los folios no deben ser iguales';
        RETURN;
    END IF;
    -- Procesar cada pago seleccionado
    FOR v_pago_id IN SELECT jsonb_array_elements_text(p_pagos_ids)::integer LOOP
        -- Actualizar ta_13_adeudosrcm: poner id_pago=null, vigencia='V', fecha_mov=now()
        UPDATE ta_13_adeudosrcm
        SET id_pago = NULL, vigencia = 'V', fecha_mov = now()
        WHERE control_rcm = p_folio_de
          AND id_pago = v_pago_id;
        -- Actualizar ta_13_pagosrcm: cambiar datos al folio destino
        UPDATE ta_13_pagosrcm
        SET cementerio = (SELECT cementerio FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            clase = (SELECT clase FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            clase_alfa = (SELECT clase_alfa FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            seccion = (SELECT seccion FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            seccion_alfa = (SELECT seccion_alfa FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            linea = (SELECT linea FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            linea_alfa = (SELECT linea_alfa FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            fosa = (SELECT fosa FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            fosa_alfa = (SELECT fosa_alfa FROM ta_13_datosrcm WHERE control_rcm = p_folio_a),
            control_rcm = p_folio_a,
            usuario = p_usuario,
            fecha_mov = now()
        WHERE control_id = v_pago_id;
        v_suma := v_suma + 1;
    END LOOP;
    -- Actualizar axo_pagado en ta_13_datosrcm para folio destino
    SELECT EXTRACT(YEAR FROM now()) INTO v_axo;
    -- UAP para folio destino
    SELECT COALESCE(MAX(axo_pago_hasta), 0) INTO v_uap FROM ta_13_pagosrcm WHERE control_rcm = p_folio_a;
    IF v_uap = 0 THEN
        v_uap := v_axo - 5;
    END IF;
    UPDATE ta_13_datosrcm SET axo_pagado = v_uap WHERE control_rcm = p_folio_a;
    -- UAP para folio origen
    SELECT COALESCE(MAX(axo_pago_hasta), 0) INTO v_uap FROM ta_13_pagosrcm WHERE control_rcm = p_folio_de;
    IF v_uap = 0 THEN
        v_uap := v_axo - 5;
    END IF;
    UPDATE ta_13_datosrcm SET axo_pagado = v_uap WHERE control_rcm = p_folio_de;
    IF v_suma > 0 THEN
        RETURN QUERY SELECT true, 'Los registros se han trasladado';
    ELSE
        RETURN QUERY SELECT false, 'No se seleccionó ningún registro a trasladar';
    END IF;
END;
$$ LANGUAGE plpgsql;


-- --------------------------------------------

-- SP 19/23 del tipo CRUD
-- Nombre: sp_traslados_buscar_pagos_destino
-- Descripción: Busca los pagos en la ubicación destino según los parámetros de búsqueda.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_traslados_buscar_pagos_destino(
    p_cementerio VARCHAR,
    p_clase INTEGER,
    p_clase_alfa VARCHAR,
    p_seccion INTEGER,
    p_seccion_alfa VARCHAR,
    p_linea INTEGER,
    p_linea_alfa VARCHAR,
    p_fosa INTEGER,
    p_fosa_alfa VARCHAR
)
RETURNS TABLE (
    control_id INTEGER,
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase INTEGER,
    clase_alfa VARCHAR,
    seccion INTEGER,
    seccion_alfa VARCHAR,
    linea INTEGER,
    linea_alfa VARCHAR,
    fosa INTEGER,
    fosa_alfa VARCHAR,
    fecing DATE,
    importe_anual NUMERIC,
    vigencia VARCHAR,
    usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT control_id, control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, fecing, importe_anual, vigencia, usuario
    FROM ta_13_pagosrcm
    WHERE cementerio = p_cementerio
      AND clase = p_clase
      AND (clase_alfa = p_clase_alfa OR (p_clase_alfa IS NULL OR p_clase_alfa = ''))
      AND seccion = p_seccion
      AND (seccion_alfa = p_seccion_alfa OR (p_seccion_alfa IS NULL OR p_seccion_alfa = ''))
      AND linea = p_linea
      AND (linea_alfa = p_linea_alfa OR (p_linea_alfa IS NULL OR p_linea_alfa = ''))
      AND fosa = p_fosa
      AND (fosa_alfa = p_fosa_alfa OR (p_fosa_alfa IS NULL OR p_fosa_alfa = ''));
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 20/23 del tipo CRUD
-- Nombre: sp_traslados_buscar_pagos_origen
-- Descripción: Busca los pagos en la ubicación origen según los parámetros de búsqueda.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_traslados_buscar_pagos_origen(
    p_cementerio VARCHAR,
    p_clase INTEGER,
    p_clase_alfa VARCHAR,
    p_seccion INTEGER,
    p_seccion_alfa VARCHAR,
    p_linea INTEGER,
    p_linea_alfa VARCHAR,
    p_fosa INTEGER,
    p_fosa_alfa VARCHAR
)
RETURNS TABLE (
    control_id INTEGER,
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase INTEGER,
    clase_alfa VARCHAR,
    seccion INTEGER,
    seccion_alfa VARCHAR,
    linea INTEGER,
    linea_alfa VARCHAR,
    fosa INTEGER,
    fosa_alfa VARCHAR,
    fecing DATE,
    importe_anual NUMERIC,
    vigencia VARCHAR,
    usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT control_id, control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, fecing, importe_anual, vigencia, usuario
    FROM ta_13_pagosrcm
    WHERE cementerio = p_cementerio
      AND clase = p_clase
      AND (clase_alfa = p_clase_alfa OR (p_clase_alfa IS NULL OR p_clase_alfa = ''))
      AND seccion = p_seccion
      AND (seccion_alfa = p_seccion_alfa OR (p_seccion_alfa IS NULL OR p_seccion_alfa = ''))
      AND linea = p_linea
      AND (linea_alfa = p_linea_alfa OR (p_linea_alfa IS NULL OR p_linea_alfa = ''))
      AND fosa = p_fosa
      AND (fosa_alfa = p_fosa_alfa OR (p_fosa_alfa IS NULL OR p_fosa_alfa = ''));
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 21/23 del tipo CRUD
-- Nombre: sp_traslados_trasladar_pagos
-- Descripción: Realiza el traslado de pagos de una ubicación origen a una destino, actualizando los registros correspondientes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_traslados_trasladar_pagos(
    p_origen_control_id INTEGER,
    p_destino_cementerio VARCHAR,
    p_destino_clase INTEGER,
    p_destino_clase_alfa VARCHAR,
    p_destino_seccion INTEGER,
    p_destino_seccion_alfa VARCHAR,
    p_destino_linea INTEGER,
    p_destino_linea_alfa VARCHAR,
    p_destino_fosa INTEGER,
    p_destino_fosa_alfa VARCHAR,
    p_destino_control_rcm INTEGER,
    p_usuario INTEGER
) RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_axo INTEGER;
    v_uap INTEGER;
BEGIN
    -- Actualizar pagos
    UPDATE ta_13_pagosrcm
    SET cementerio = p_destino_cementerio,
        clase = p_destino_clase,
        clase_alfa = COALESCE(p_destino_clase_alfa, ''),
        seccion = p_destino_seccion,
        seccion_alfa = COALESCE(p_destino_seccion_alfa, ''),
        linea = p_destino_linea,
        linea_alfa = COALESCE(p_destino_linea_alfa, ''),
        fosa = p_destino_fosa,
        fosa_alfa = COALESCE(p_destino_fosa_alfa, ''),
        control_rcm = p_destino_control_rcm,
        usuario = p_usuario,
        fecha_mov = CURRENT_DATE
    WHERE control_id = p_origen_control_id;

    -- Actualizar axo_pagado en datosrcm destino
    SELECT EXTRACT(YEAR FROM CURRENT_DATE) INTO v_axo;
    SELECT MAX(axo_pago_hasta) INTO v_uap FROM ta_13_pagosrcm WHERE control_rcm = p_destino_control_rcm;
    IF v_uap IS NULL OR v_uap = 0 THEN
        v_uap := v_axo - 5;
    END IF;
    UPDATE ta_13_datosrcm SET axo_pagado = v_uap WHERE control_rcm = p_destino_control_rcm;

    -- Actualizar axo_pagado en datosrcm origen (opcional, según reglas)
    -- SELECT MAX(axo_pago_hasta) INTO v_uap FROM ta_13_pagosrcm WHERE control_rcm = (SELECT control_rcm FROM ta_13_pagosrcm WHERE control_id = p_origen_control_id);
    -- IF v_uap IS NULL OR v_uap = 0 THEN
    --     v_uap := v_axo - 5;
    -- END IF;
    -- UPDATE ta_13_datosrcm SET axo_pagado = v_uap WHERE control_rcm = (SELECT control_rcm FROM ta_13_pagosrcm WHERE control_id = p_origen_control_id);

    RETURN QUERY SELECT TRUE, 'Traslado realizado correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error al trasladar pagos: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 22/23 del tipo CRUD
-- Nombre: sp_valida_usuario
-- Descripción: Valida usuario y clave, retorna datos del usuario si es válido.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_valida_usuario(p_usuario VARCHAR, p_clave VARCHAR)
RETURNS TABLE(
    valido BOOLEAN,
    id_usuario INTEGER,
    usuario VARCHAR,
    nombre VARCHAR,
    estado VARCHAR,
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora VARCHAR,
    domicilio VARCHAR,
    tel VARCHAR,
    recaudador VARCHAR,
    nivel SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        TRUE AS valido,
        a.id_usuario,
        a.usuario,
        a.nombre,
        a.estado,
        a.id_rec,
        b.id_zona,
        b.recaudadora,
        b.domicilio,
        b.tel,
        b.recaudador,
        a.nivel
    FROM ta_12_passwords a
    JOIN ta_12_recaudadoras b ON a.id_rec = b.id_rec
    WHERE a.usuario = p_usuario
      AND a.clave = p_clave
      AND a.estado = 'A'
    LIMIT 1;
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 23/23 del tipo CRUD
-- Nombre: spd_13_abcdesctos
-- Descripción: Alta, baja, modificación y reactivación de descuentos para cementerios. OPC: 1=alta, 2=baja, 3=modifica, 4=reactivar.
-- --------------------------------------------

-- PostgreSQL version of spd_13_abcdesctos
CREATE OR REPLACE FUNCTION spd_13_abcdesctos(
    v_control integer,
    v_axo integer,
    v_porc integer,
    v_usu integer,
    v_reac varchar(1),
    v_tipo_descto varchar(1),
    v_opc integer
)
RETURNS TABLE(par_ok smallint, par_observ varchar) AS $$
DECLARE
    v_exists integer;
BEGIN
    IF v_opc = 1 THEN -- Alta
        SELECT COUNT(*) INTO v_exists FROM ta_13_descpens WHERE control_rcm = v_control AND axo_descto = v_axo AND vigencia = 'V';
        IF v_exists > 0 THEN
            par_ok := 1;
            par_observ := 'Ya tiene descuento para el adeudo del año seleccionado, verifique';
            RETURN NEXT;
        END IF;
        INSERT INTO ta_13_descpens (control_rcm, axo_descto, descuento, usuario, fecha_alta, vigencia, reactivar, tipo_descto)
        VALUES (v_control, v_axo, v_porc, v_usu, CURRENT_DATE, 'V', v_reac, v_tipo_descto);
        par_ok := 0;
        par_observ := 'Descuento dado de alta correctamente';
        RETURN NEXT;
    ELSIF v_opc = 2 THEN -- Baja
        UPDATE ta_13_descpens SET vigencia = 'B', usuario_mov = v_usu, fecha_mov = CURRENT_DATE
        WHERE control_rcm = v_control AND axo_descto = v_axo AND vigencia = 'V';
        par_ok := 0;
        par_observ := 'Descuento dado de baja correctamente';
        RETURN NEXT;
    ELSIF v_opc = 3 THEN -- Modifica
        UPDATE ta_13_descpens SET descuento = v_porc, usuario_mov = v_usu, fecha_mov = CURRENT_DATE
        WHERE control_rcm = v_control AND axo_descto = v_axo AND vigencia = 'V';
        par_ok := 0;
        par_observ := 'Descuento modificado correctamente';
        RETURN NEXT;
    ELSIF v_opc = 4 THEN -- Reactivar
        UPDATE ta_13_descpens SET reactivar = 'S', usuario_mov = v_usu, fecha_mov = CURRENT_DATE
        WHERE control_rcm = v_control AND axo_descto = v_axo;
        par_ok := 0;
        par_observ := 'Descuento reactivado correctamente';
        RETURN NEXT;
    ELSE
        par_ok := 1;
        par_observ := 'Operación no soportada';
        RETURN NEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- ============================================
-- STORED PROCEDURES TIPO: Report
-- ============================================

-- SP 1/12 del tipo Report
-- Nombre: rpt_titulos_get_report
-- Descripción: Obtiene el reporte de títulos con todos los datos requeridos para una fecha y folio dados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_titulos_get_report(fechapag date, fol integer)
RETURNS TABLE (
    titulo integer,
    control_rcm integer,
    fecha date,
    id_rec smallint,
    caja varchar,
    operacion integer,
    importe numeric,
    observaciones varchar,
    control_rcm_1 integer,
    cementerio varchar,
    clase smallint,
    clase_alfa varchar,
    seccion smallint,
    seccion_alfa varchar,
    linea smallint,
    linea_alfa varchar,
    fosa smallint,
    fosa_alfa varchar,
    axo_pagado integer,
    metros float,
    nombre varchar,
    domicilio varchar,
    exterior varchar,
    interior varchar,
    colonia varchar,
    observaciones_1 varchar,
    usuario integer,
    fecha_mov date,
    tipo varchar,
    nombre_1 varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.titulo, a.control_rcm, a.fecha, a.id_rec, a.caja, a.operacion, a.importe, a.observaciones,
           b.control_rcm as control_rcm_1, b.cementerio, b.clase, b.clase_alfa, b.seccion, b.seccion_alfa, b.linea, b.linea_alfa, b.fosa, b.fosa_alfa, b.axo_pagado, b.metros, b.nombre, b.domicilio, b.exterior, b.interior, b.colonia, b.observaciones as observaciones_1, b.usuario, b.fecha_mov, b.tipo,
           c.nombre as nombre_1
    FROM ta_13_titulos a
    JOIN ta_13_datosrcm b ON a.control_rcm = b.control_rcm
    JOIN tc_13_cementerios c ON b.cementerio = c.cementerio
    WHERE a.fecha = fechapag AND a.control_rcm = fol;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 2/12 del tipo Report
-- Nombre: sp_estad_adeudo_listado
-- Descripción: Devuelve el listado de registros con adeudos mayores o iguales al parámetro axop.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_estad_adeudo_listado(axop INTEGER)
RETURNS TABLE(
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase SMALLINT,
    clase_alfa VARCHAR,
    seccion SMALLINT,
    seccion_alfa VARCHAR,
    linea SMALLINT,
    linea_alfa VARCHAR,
    fosa SMALLINT,
    fosa_alfa VARCHAR,
    axo_pagado INTEGER,
    metros FLOAT,
    nombre VARCHAR,
    domicilio VARCHAR,
    exterior VARCHAR,
    interior VARCHAR,
    colonia VARCHAR,
    observaciones VARCHAR,
    usuario INTEGER,
    fecha_mov DATE,
    tipo VARCHAR,
    nombre_1 VARCHAR,
    nombre_2 VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_rcm, a.cementerio, a.clase, a.clase_alfa, a.seccion, a.seccion_alfa, a.linea, a.linea_alfa, a.fosa, a.fosa_alfa, a.axo_pagado, a.metros, a.nombre, a.domicilio, a.exterior, a.interior, a.colonia, a.observaciones, a.usuario, a.fecha_mov, a.tipo, c.nombre AS nombre_1, e.nombre AS nombre_2
    FROM ta_13_datosrcm a
    JOIN tc_13_cementerios c ON a.cementerio = c.cementerio
    JOIN ta_12_passwords e ON a.usuario = e.id_usuario
    WHERE a.axo_pagado <= axop;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 3/12 del tipo Report
-- Nombre: sp_estad_adeudo_resumen
-- Descripción: Devuelve el resumen de adeudos por cementerio y año (UAP, cuenta).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_estad_adeudo_resumen()
RETURNS TABLE(
    cementerio VARCHAR,
    uap INTEGER,
    cuenta INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT cementerio, (axo_pagado-5) AS uap, COUNT(*) AS cuenta
    FROM ta_13_datosrcm
    GROUP BY cementerio, (axo_pagado-5)
    ORDER BY cementerio, uap;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 4/12 del tipo Report
-- Nombre: sp_list_movements
-- Descripción: Obtiene el listado de movimientos de cementerios entre dos fechas y por recaudadora.
-- --------------------------------------------

-- PostgreSQL stored procedure for List_Mov
CREATE OR REPLACE FUNCTION sp_list_movements(
    p_fecha1 DATE,
    p_fecha2 DATE,
    p_reca INTEGER
)
RETURNS TABLE (
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase SMALLINT,
    clase_alfa VARCHAR,
    seccion SMALLINT,
    seccion_alfa VARCHAR,
    linea SMALLINT,
    linea_alfa VARCHAR,
    fosa SMALLINT,
    fosa_alfa VARCHAR,
    axo_pagado INTEGER,
    metros FLOAT,
    nombre VARCHAR,
    domicilio VARCHAR,
    exterior VARCHAR,
    interior VARCHAR,
    colonia VARCHAR,
    observaciones VARCHAR,
    usuario INTEGER,
    fecha_mov DATE,
    tipo VARCHAR,
    nombre_1 VARCHAR,
    llave VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.control_rcm,
        a.cementerio,
        a.clase,
        a.clase_alfa,
        a.seccion,
        a.seccion_alfa,
        a.linea,
        a.linea_alfa,
        a.fosa,
        a.fosa_alfa,
        a.axo_pagado,
        a.metros,
        a.nombre,
        a.domicilio,
        a.exterior,
        a.interior,
        a.colonia,
        a.observaciones,
        a.usuario,
        a.fecha_mov,
        a.tipo,
        b.nombre as nombre_1,
        CONCAT_WS('-', a.cementerio, a.clase, a.clase_alfa, a.seccion, a.seccion_alfa, a.linea, a.linea_alfa, a.fosa, a.fosa_alfa) as llave
    FROM ta_13_datosrcm a
    JOIN ta_12_passwords b ON a.usuario = b.id_usuario
    WHERE a.fecha_mov BETWEEN p_fecha1 AND p_fecha2
      AND b.id_rec = p_reca;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 5/12 del tipo Report
-- Nombre: sp_multiple_fecha
-- Descripción: Devuelve pagos y títulos por fecha, recaudadora y caja (consulta múltiple por fecha de pago)
-- --------------------------------------------

-- PostgreSQL stored procedure for MultipleFecha
CREATE OR REPLACE FUNCTION sp_multiple_fecha(
    p_fecha DATE,
    p_rec SMALLINT,
    p_caja VARCHAR(10)
)
RETURNS TABLE (
    tipopag VARCHAR(10),
    fecing DATE,
    recing SMALLINT,
    cajing VARCHAR(10),
    opcaja INTEGER,
    control_id INTEGER,
    control_rcm INTEGER,
    cementerio VARCHAR(10),
    clase INTEGER,
    clase_alfa VARCHAR(10),
    seccion INTEGER,
    seccion_alfa VARCHAR(10),
    linea INTEGER,
    linea_alfa VARCHAR(10),
    fosa INTEGER,
    fosa_alfa VARCHAR(10),
    axo_pago_desde INTEGER,
    axo_pago_hasta INTEGER,
    importe_anual NUMERIC,
    importe_recargos NUMERIC,
    vigencia VARCHAR(2),
    usuario INTEGER,
    fecha_mov DATE,
    obser VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 'Manten' AS tipopag,
           fecing, recing, cajing, opcaja, control_id, control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, axo_pago_desde, axo_pago_hasta, importe_anual, importe_recargos, vigencia, usuario, fecha_mov, '' AS obser
      FROM ta_13_pagosrcm
     WHERE fecing = p_fecha AND recing >= p_rec AND cajing >= p_caja
    UNION ALL
    SELECT 'Titulo' AS tipopag,
           fecha AS fecing, id_rec AS recing, caja AS cajing, operacion AS opcaja, 0 AS control_id, control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, tipo AS axo_pago_desde, titulo AS axo_pago_hasta, importe, 0, '', 0, CURRENT_DATE, observaciones
      FROM ta_13_titulos
     WHERE fecha = p_fecha AND id_rec >= p_rec AND caja >= p_caja
    ORDER BY fecing, recing, cajing, opcaja;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 6/12 del tipo Report
-- Nombre: sp_multiple_nombre_search
-- Descripción: Busca registros en ta_13_datosrcm por nombre, cementerio y control_rcm (paginado)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_multiple_nombre_search(
    p_nombre VARCHAR,
    p_cuenta INTEGER,
    p_cem1 VARCHAR,
    p_cem2 VARCHAR,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE (
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase SMALLINT,
    clase_alfa VARCHAR,
    seccion SMALLINT,
    seccion_alfa VARCHAR,
    linea SMALLINT,
    linea_alfa VARCHAR,
    fosa SMALLINT,
    fosa_alfa VARCHAR,
    axo_pagado INTEGER,
    metros FLOAT,
    nombre VARCHAR,
    domicilio VARCHAR,
    exterior VARCHAR,
    interior VARCHAR,
    colonia VARCHAR,
    observaciones VARCHAR,
    usuario INTEGER,
    fecha_mov DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, axo_pagado, metros, nombre, domicilio, exterior, interior, colonia, observaciones, usuario, fecha_mov
    FROM ta_13_datosrcm
    WHERE nombre ILIKE p_nombre
      AND control_rcm > p_cuenta
      AND cementerio >= p_cem1 AND cementerio <= p_cem2
    ORDER BY nombre
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 7/12 del tipo Report
-- Nombre: sp_multiple_rcm_search
-- Descripción: Busca hasta 100 registros en ta_13_datosrcm a partir de los parámetros de búsqueda, similar a la lógica Delphi.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_multiple_rcm_search(
    p_cementerio VARCHAR,
    p_clase INTEGER,
    p_clase_alfa VARCHAR,
    p_seccion INTEGER,
    p_seccion_alfa VARCHAR,
    p_linea INTEGER,
    p_linea_alfa VARCHAR,
    p_fosa INTEGER,
    p_fosa_alfa VARCHAR,
    p_cuenta INTEGER
)
RETURNS TABLE (
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase INTEGER,
    clase_alfa VARCHAR,
    seccion INTEGER,
    seccion_alfa VARCHAR,
    linea INTEGER,
    linea_alfa VARCHAR,
    fosa INTEGER,
    fosa_alfa VARCHAR,
    axo_pagado INTEGER,
    metros FLOAT,
    nombre VARCHAR,
    domicilio VARCHAR,
    exterior VARCHAR,
    interior VARCHAR,
    colonia VARCHAR,
    observaciones VARCHAR,
    usuario INTEGER,
    fecha_mov DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa,
        axo_pagado, metros, nombre, domicilio, exterior, interior, colonia, observaciones, usuario, fecha_mov
    FROM ta_13_datosrcm
    WHERE cementerio = p_cementerio
      AND clase >= p_clase
      AND clase_alfa >= p_clase_alfa
      AND seccion >= p_seccion
      AND seccion_alfa >= p_seccion_alfa
      AND linea >= p_linea
      AND linea_alfa >= p_linea_alfa
      AND fosa >= p_fosa
      AND fosa <= (p_fosa + 100)
      AND fosa_alfa >= p_fosa_alfa
      AND control_rcm > p_cuenta
    ORDER BY clase, seccion, linea, fosa
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 8/12 del tipo Report
-- Nombre: sp_pago_detalle
-- Descripción: Devuelve el detalle de un pago individual por control_rcm
-- --------------------------------------------

-- PostgreSQL stored procedure for detalle individual
CREATE OR REPLACE FUNCTION sp_pago_detalle(
    p_control_rcm INTEGER
)
RETURNS TABLE (
    control_rcm INTEGER,
    cementerio VARCHAR(10),
    clase INTEGER,
    clase_alfa VARCHAR(10),
    seccion INTEGER,
    seccion_alfa VARCHAR(10),
    linea INTEGER,
    linea_alfa VARCHAR(10),
    fosa INTEGER,
    fosa_alfa VARCHAR(10),
    axo_pagado INTEGER,
    metros NUMERIC,
    nombre VARCHAR(100),
    domicilio VARCHAR(100),
    exterior VARCHAR(20),
    interior VARCHAR(20),
    colonia VARCHAR(50),
    observaciones VARCHAR(255),
    usuario INTEGER,
    fecha_mov DATE,
    tipo VARCHAR(2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, axo_pagado, metros, nombre, domicilio, exterior, interior, colonia, observaciones, usuario, fecha_mov, tipo
      FROM ta_13_datosrcm
     WHERE control_rcm = p_control_rcm;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 9/12 del tipo Report
-- Nombre: sp_rep_a_cobrar
-- Descripción: Genera el reporte de cementerios a cobrar para una recaudadora y mes dados.
-- --------------------------------------------

-- PostgreSQL stored procedure for report
CREATE OR REPLACE FUNCTION sp_rep_a_cobrar(par_mes integer, par_id_rec integer)
RETURNS TABLE(
    ano integer,
    mantenimiento numeric,
    recargos numeric
) AS $$
BEGIN
    -- Simulación: Debe ajustarse a la lógica real de cálculo
    RETURN QUERY
    SELECT
        t.axo_cuota AS ano,
        SUM(t.cuota1 * t.metros) AS mantenimiento,
        SUM(t.cuota1 * t.metros * r.porcentaje_global / 100) AS recargos
    FROM ta_13_rcmcuotas t
    JOIN ta_13_datosrcm d ON d.cementerio = t.cementerio
    JOIN ta_12_recaudadoras rca ON rca.id_rec = par_id_rec
    JOIN ta_13_recargosrcm r ON r.axo = t.axo_cuota AND r.mes = par_mes
    WHERE d.id_rec = par_id_rec
    GROUP BY t.axo_cuota
    ORDER BY t.axo_cuota;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 10/12 del tipo Report
-- Nombre: sp_rep_bon_listar
-- Descripción: Obtiene la lista de oficios de bonificación de la recaudadora indicada, filtrando por pendientes o todos.
-- --------------------------------------------

-- PostgreSQL stored procedure para reporte de bonificaciones
CREATE OR REPLACE FUNCTION sp_rep_bon_listar(
    p_recaudadora INTEGER,
    p_tipo VARCHAR -- 'pendientes' o 'todos'
)
RETURNS TABLE (
    control_bon INTEGER,
    oficio INTEGER,
    axo SMALLINT,
    doble VARCHAR,
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase SMALLINT,
    clase_alfa VARCHAR,
    seccion SMALLINT,
    seccion_alfa VARCHAR,
    linea SMALLINT,
    linea_alfa VARCHAR,
    fosa SMALLINT,
    fosa_alfa VARCHAR,
    fecha_ofic DATE,
    importe_bonificar NUMERIC,
    importe_bonificado NUMERIC,
    importe_resto NUMERIC,
    usuario INTEGER,
    fecha_mov DATE,
    nombre VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.control_bon,
        a.oficio,
        a.axo,
        a.doble,
        a.control_rcm,
        a.cementerio,
        a.clase,
        a.clase_alfa,
        a.seccion,
        a.seccion_alfa,
        a.linea,
        a.linea_alfa,
        a.fosa,
        a.fosa_alfa,
        a.fecha_ofic,
        a.importe_bonificar,
        a.importe_bonificado,
        a.importe_resto,
        a.usuario,
        a.fecha_mov,
        (SELECT nombre FROM ta_12_passwords WHERE id_usuario = a.usuario) AS nombre
    FROM ta_13_bonifrcm a
    WHERE a.doble = p_recaudadora::VARCHAR
      AND (
        (p_tipo = 'pendientes' AND a.importe_resto > 0)
        OR (p_tipo = 'todos')
      )
    ORDER BY a.oficio DESC;
END;
$$ LANGUAGE plpgsql;


-- --------------------------------------------

-- SP 11/12 del tipo Report
-- Nombre: sp_titulos_print
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

-- --------------------------------------------

-- SP 12/12 del tipo Report
-- Nombre: sp_total_sanandres
-- Descripción: Devuelve el total de registros de la tabla 'datos' para paginación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_total_sanandres()
RETURNS integer AS $$
DECLARE
    total integer;
BEGIN
    SELECT COUNT(*) INTO total FROM datos;
    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- ============================================
-- FIN DEL SCRIPT MAESTRO
-- Total de 45 stored procedures incluidos
-- ============================================
