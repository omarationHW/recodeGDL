-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Gen_ArcDiario
-- Generado: 2025-08-27 20:40:42
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp14_remesa
-- Tipo: CRUD
-- Descripción: Genera la remesa diaria, actualiza/crea registros en ta14_datos_mpio y retorna status, obs y remesa.
-- --------------------------------------------

-- PostgreSQL stored procedure equivalent for sp14_remesa
-- Asume que la lógica de negocio original está implementada aquí
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
    v_obs text;
    v_status integer := 0;
BEGIN
    -- Ejemplo de lógica (ajustar según reglas de negocio reales)
    v_remesa := 'R' || to_char(now(), 'YYYYMMDDHH24MISS');
    v_obs := 'Remesa generada para el periodo ' || p_Fec_Ini || ' a ' || p_Fec_Fin;
    -- Aquí iría la lógica de inserción/actualización de ta14_datos_mpio
    -- Si ocurre error, setear v_status := 1 y v_obs := mensaje de error
    RETURN QUERY SELECT v_status, v_obs, v_remesa;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: get_periodo_diario
-- Tipo: Catalog
-- Descripción: Obtiene el periodo de la última generación diaria (tipo 'C')
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_periodo_diario()
RETURNS TABLE(fecha_inicio date, fecha_fin date) AS $$
BEGIN
    RETURN QUERY SELECT fecha_inicio, fecha_fin FROM ta14_bitacora WHERE tipo = 'C' ORDER BY fecha_fin DESC LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: get_periodo_altas
-- Tipo: Catalog
-- Descripción: Obtiene el periodo de la última generación de altas (tipo 'B')
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_periodo_altas()
RETURNS TABLE(fecha_inicio date, fecha_fin date) AS $$
BEGIN
    RETURN QUERY SELECT fecha_inicio, fecha_fin FROM ta14_bitacora WHERE tipo = 'B' ORDER BY fecha_fin DESC LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: buscar_folios_remesa
-- Tipo: Report
-- Descripción: Cuenta los folios de una remesa por tipoact
-- --------------------------------------------

CREATE OR REPLACE FUNCTION buscar_folios_remesa(p_remesa text, p_tipoact text)
RETURNS integer AS $$
DECLARE
    v_count integer;
BEGIN
    SELECT COUNT(*) INTO v_count FROM ta14_datos_mpio WHERE remesa = p_remesa AND tipoact = p_tipoact;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: generar_archivo_remesa
-- Tipo: Report
-- Descripción: Devuelve los registros de la remesa para generar el archivo de texto
-- --------------------------------------------

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
        idrmunicipio, tipoact, folio, 
        TO_CHAR(fechagenreq, 'MM/DD/YYYY'), 
        placa, TRIM(folionot), TO_CHAR(fechanot, 'MM/DD/YYYY'), 
        TO_CHAR(fechapago, 'MM/DD/YYYY'), 
        TO_CHAR(fechacancelado, 'MM/DD/YYYY'), 
        importe, clave, 
        TO_CHAR(fechaalta, 'MM/DD/YYYY'), 
        TO_CHAR(fechavenc, 'MM/DD/YYYY'), 
        folioec, TRIM(folioecmpio), gastos, remesa, 
        TO_CHAR(fecharemesa, 'MM/DD/YYYY')
    FROM ta14_datos_mpio WHERE remesa = p_remesa;
END;
$$ LANGUAGE plpgsql;

-- ============================================

