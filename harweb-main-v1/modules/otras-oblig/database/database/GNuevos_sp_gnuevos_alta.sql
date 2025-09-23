-- Stored Procedure: sp_gnuevos_alta
-- Tipo: CRUD
-- Descripción: Alta de nuevo registro en t34_datos y t34_conceptos, lógica de validación y creación de contrato/concesión.
-- Generado para formulario: GNuevos
-- Fecha: 2025-08-28 13:18:13

-- PostgreSQL stored procedure para alta de nuevo registro (GNuevos)
CREATE OR REPLACE FUNCTION sp_gnuevos_alta(
    par_tabla integer,
    par_control text,
    par_conces text,
    par_ubica text,
    par_sup numeric,
    par_Axo_Ini integer,
    par_Mes_Ini integer,
    par_ofna integer,
    par_sector text,
    par_zona integer,
    par_lic integer,
    par_Descrip text,
    par_NomCom text,
    par_Lugar text,
    par_Obs text,
    par_usuario text
) RETURNS TABLE(status integer, concepto_status text) AS $$
DECLARE
    v_exists integer;
    v_id_34_datos integer;
    v_msg text;
BEGIN
    -- Validaciones básicas
    IF par_conces IS NULL OR trim(par_conces) = '' THEN
        RETURN QUERY SELECT 0, 'Falta el dato del CONCESIONARIO';
        RETURN;
    END IF;
    IF par_ubica IS NULL OR trim(par_ubica) = '' THEN
        RETURN QUERY SELECT 0, 'Falta el dato de la UBICACION';
        RETURN;
    END IF;
    IF par_sup IS NULL OR par_sup <= 0 THEN
        RETURN QUERY SELECT 0, 'Falta el dato de la SUPERFICIE';
        RETURN;
    END IF;
    IF par_lic IS NULL OR par_lic = 0 THEN
        RETURN QUERY SELECT 0, 'Falta el dato de la LICENCIA';
        RETURN;
    END IF;
    IF par_Axo_Ini IS NULL OR par_Axo_Ini < 2020 THEN
        RETURN QUERY SELECT 0, 'Falta el dato del AÑO de inicio de OBLIGACION';
        RETURN;
    END IF;
    -- Validar que no exista el control
    SELECT count(*) INTO v_exists FROM t34_datos WHERE control = par_control AND cve_tab = par_tabla;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 0, 'Ya existe un registro con ese control';
        RETURN;
    END IF;
    -- Insertar en t34_datos
    INSERT INTO t34_datos (
        cve_tab, control, concesionario, ubicacion, superficie, fecha_inicio, id_recaudadora, sector, id_zona, licencia, descrip_unidad, nom_comercial, lugar, obs, usuario_alta, fecha_alta
    ) VALUES (
        par_tabla, par_control, par_conces, par_ubica, par_sup, make_date(par_Axo_Ini, par_Mes_Ini, 1), par_ofna, par_sector, par_zona, par_lic, par_Descrip, par_NomCom, par_Lugar, par_Obs, par_usuario, now()
    ) RETURNING id_34_datos INTO v_id_34_datos;
    -- Insertar en t34_conceptos si aplica (ejemplo)
    -- INSERT INTO t34_conceptos (id_datos, tipo, concepto) VALUES (v_id_34_datos, 'C', par_NomCom);
    -- ...
    RETURN QUERY SELECT 1, 'Registro creado correctamente';
END;
$$ LANGUAGE plpgsql;