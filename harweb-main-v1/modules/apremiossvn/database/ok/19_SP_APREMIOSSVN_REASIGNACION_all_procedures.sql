-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - APREMIOSSVN
-- Módulo: Reasignación de Folios
-- Archivo: 19_SP_APREMIOSSVN_REASIGNACION_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 3
-- ============================================

-- SP 1/3: SP_APREMIOSSVN_REASIGNAR_FOLIO
-- Tipo: CRUD
-- Descripción: Reasigna un folio a un nuevo ejecutor y actualiza la fecha de entrega y usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_REASIGNAR_FOLIO(
    p_id_control INTEGER,
    p_nuevo_ejecutor INTEGER,
    p_fecha_entrega2 DATE,
    p_usuario INTEGER,
    p_fecha_actualiz DATE,
    p_observaciones TEXT DEFAULT NULL
) RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_folio INTEGER;
    v_ejecutor_anterior INTEGER;
BEGIN
    -- Obtener datos del folio antes de la reasignación
    SELECT folio, ejecutor INTO v_folio, v_ejecutor_anterior
    FROM public.ta_15_apremios
    WHERE id_control = p_id_control;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Folio no encontrado';
        RETURN;
    END IF;
    
    -- Insertar en histórico antes de la actualización
    INSERT INTO public.ta_15_historia (
        SELECT * FROM public.ta_15_apremios WHERE id_control = p_id_control
    );
    
    -- Actualizar el folio con el nuevo ejecutor
    UPDATE public.ta_15_apremios
    SET ejecutor = p_nuevo_ejecutor,
        fecha_entrega2 = p_fecha_entrega2,
        usuario = p_usuario,
        fecha_actualiz = p_fecha_actualiz,
        observaciones = COALESCE(observaciones, '') || 
                       CASE WHEN observaciones IS NOT NULL AND observaciones <> '' 
                            THEN ' | ' ELSE '' END ||
                       'Reasignado de ejecutor ' || v_ejecutor_anterior::text || 
                       ' a ejecutor ' || p_nuevo_ejecutor::text ||
                       CASE WHEN p_observaciones IS NOT NULL 
                            THEN ' - ' || p_observaciones ELSE '' END
    WHERE id_control = p_id_control;
    
    RETURN QUERY SELECT TRUE, 'Folio ' || v_folio::text || ' reasignado correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'ERROR: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: SP_APREMIOSSVN_LISTAR_EJECUTORES
-- Tipo: Catalog
-- Descripción: Devuelve la lista de ejecutores activos entre dos recaudadoras.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_LISTAR_EJECUTORES(
    p_id_rec_min INTEGER,
    p_id_rec_max INTEGER
) RETURNS TABLE (
    id_ejecutor INTEGER,
    cve_eje INTEGER,
    ini_rfc VARCHAR,
    fec_rfc DATE,
    hom_rfc VARCHAR,
    nombre VARCHAR,
    id_rec INTEGER,
    recaudadora VARCHAR,
    vigencia VARCHAR,
    comision NUMERIC,
    zona VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id_ejecutor,
        e.cve_eje,
        e.ini_rfc,
        e.fec_rfc,
        e.hom_rfc,
        e.nombre,
        e.id_rec,
        r.recaudadora,
        e.vigencia,
        e.comision,
        z.zona
    FROM public.ta_15_ejecutores e
    JOIN public.ta_12_recaudadoras r ON e.id_rec = r.id_rec
    LEFT JOIN public.ta_12_zonas z ON r.id_zona = z.id_zona
    WHERE e.id_rec BETWEEN p_id_rec_min AND p_id_rec_max
      AND e.vigencia = 'V'
    ORDER BY e.id_rec, e.nombre;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: SP_APREMIOSSVN_FOLIOS_PARA_REASIGNAR
-- Tipo: Report
-- Descripción: Obtiene la lista de folios que pueden ser reasignados (practicados pero no pagados).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_FOLIOS_PARA_REASIGNAR(
    p_modulo INTEGER,
    p_recaudadora INTEGER,
    p_ejecutor INTEGER DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
) RETURNS TABLE (
    id_control INTEGER,
    folio INTEGER,
    modulo INTEGER,
    zona INTEGER,
    ejecutor INTEGER,
    ejecutor_nombre VARCHAR,
    fecha_emision DATE,
    fecha_practicado DATE,
    importe_global NUMERIC,
    vigencia VARCHAR,
    clave_practicado VARCHAR,
    dias_sin_pago INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_control,
        a.folio,
        a.modulo,
        a.zona,
        a.ejecutor,
        COALESCE(e.nombre, 'Sin asignar') as ejecutor_nombre,
        a.fecha_emision,
        a.fecha_practicado,
        a.importe_global,
        a.vigencia,
        a.clave_practicado,
        CASE WHEN a.fecha_practicado IS NOT NULL 
             THEN EXTRACT(DAY FROM (CURRENT_DATE - a.fecha_practicado))::INTEGER
             ELSE NULL END as dias_sin_pago
    FROM public.ta_15_apremios a
    LEFT JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    WHERE a.modulo = p_modulo
      AND a.zona = p_recaudadora
      AND a.clave_practicado = 'P'  -- Practicado
      AND a.vigencia = '1'          -- Vigente (no pagado)
      AND (p_ejecutor IS NULL OR a.ejecutor = p_ejecutor)
      AND (p_fecha_desde IS NULL OR a.fecha_emision >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR a.fecha_emision <= p_fecha_hasta)
    ORDER BY a.fecha_practicado DESC, a.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================