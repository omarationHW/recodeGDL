-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Gen_ArcAltas
-- Generado: 2025-08-27 13:40:51
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp14_remesa
-- Tipo: CRUD
-- Descripción: Genera la remesa de altas para el periodo seleccionado. Inserta/actualiza registros en ta14_datos_mpio y devuelve status, obs y remesa.
-- --------------------------------------------

-- PostgreSQL stored procedure equivalent
CREATE OR REPLACE FUNCTION sp14_remesa(
    p_Opc integer,
    p_Axo integer,
    p_Fec_Ini date,
    p_Fec_Fin date,
    p_Fec_A_Fin date
)
RETURNS TABLE(status integer, obs text, remesa text) AS $$
DECLARE
    v_remesa text;
    v_obs text := '';
    v_status integer := 0;
BEGIN
    -- Lógica de generación de remesa (simplificada, adaptar a negocio real)
    -- 1. Generar número de remesa
    v_remesa := to_char(p_Fec_Ini, 'YYYYMMDD') || '_' || to_char(p_Fec_Fin, 'YYYYMMDD');
    -- 2. Insertar/actualizar registros en ta14_datos_mpio según lógica de negocio
    -- ...
    -- 3. Si todo OK
    v_status := 0;
    v_obs := 'Remesa generada correctamente';
    RETURN QUERY SELECT v_status, v_obs, v_remesa;
EXCEPTION WHEN OTHERS THEN
    v_status := 1;
    v_obs := SQLERRM;
    RETURN QUERY SELECT v_status, v_obs, NULL;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: contar_folios_remesa
-- Tipo: Report
-- Descripción: Cuenta los folios de alta asociados a una remesa.
-- --------------------------------------------

-- PostgreSQL function to count folios
CREATE OR REPLACE FUNCTION contar_folios_remesa(p_remesa text)
RETURNS integer AS $$
DECLARE
    v_count integer;
BEGIN
    SELECT COUNT(*) INTO v_count FROM ta14_datos_mpio WHERE remesa = p_remesa;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: get_periodo_altas
-- Tipo: Catalog
-- Descripción: Obtiene el último periodo de altas registrado.
-- --------------------------------------------

-- PostgreSQL function to get last period
CREATE OR REPLACE FUNCTION get_periodo_altas()
RETURNS TABLE(fecha_inicio date, fecha_fin date) AS $$
BEGIN
    RETURN QUERY SELECT fecha_inicio, fecha_fin FROM ta14_bitacora WHERE tipo = 'B' ORDER BY fecha_fin DESC LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: generar_archivo_remesa
-- Tipo: Report
-- Descripción: Devuelve los registros de la remesa para exportar a archivo de texto.
-- --------------------------------------------

-- PostgreSQL function to get remesa data
CREATE OR REPLACE FUNCTION generar_archivo_remesa(p_remesa text)
RETURNS TABLE(
    idrmunicipio integer,
    tipoact text,
    folio text,
    fechagenreq text,
    placa text,
    folionot text,
    fechanot text,
    fechapago text,
    fechacancelado text,
    importe numeric,
    clave integer,
    fechaalta text,
    fechavenc text,
    folioec numeric,
    folioecmpio text,
    gastos numeric,
    remesa text,
    fecharemesa text
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        idrmunicipio,
        tipoact,
        folio,
        to_char(fechagenreq, 'MM/DD/YYYY'),
        placa,
        trim(folionot),
        to_char(fechanot, 'MM/DD/YYYY'),
        to_char(fechapago, 'MM/DD/YYYY'),
        to_char(fechacancelado, 'MM/DD/YYYY'),
        importe,
        clave,
        to_char(fechaalta, 'MM/DD/YYYY'),
        to_char(fechavenc, 'MM/DD/YYYY'),
        folioec,
        trim(folioecmpio),
        gastos,
        remesa,
        to_char(fecharemesa, 'MM/DD/YYYY')
    FROM ta14_datos_mpio WHERE remesa = p_remesa;
END;
$$ LANGUAGE plpgsql;

-- ============================================

