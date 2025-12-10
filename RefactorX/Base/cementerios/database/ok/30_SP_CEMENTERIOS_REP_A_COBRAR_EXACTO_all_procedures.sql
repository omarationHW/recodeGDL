-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: REP_A_COBRAR (EXACTO del archivo original)
-- Archivo: 30_SP_CEMENTERIOS_REP_A_COBRAR_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================
--
-- CORRECCIONES POSTGRESQL - AGENTE CATALIZADOR
-- Fecha: 2025-12-04
-- Total Correcciones: 8
--
-- Correcciones aplicadas:
-- SP 1: sp_rep_a_cobrar
-- 1. mantenimiento: NUMERIC → NUMERIC(16,2)
-- 2. recargos: NUMERIC → NUMERIC(16,2)
--
-- SP 2: sp_rep_a_cobrar_cuentas_cobrar
-- 3. p_cementerio: VARCHAR → CHAR(1)
-- 4. cementerio: VARCHAR → CHAR(1)
-- 5. nombre: VARCHAR → VARCHAR(60)
-- 6. domicilio: VARCHAR → VARCHAR(60)
-- 7. colonia: VARCHAR → VARCHAR(30)
-- 8. ubicacion: VARCHAR → VARCHAR(100)
-- ============================================

-- SP 1/2: sp_rep_a_cobrar
-- Tipo: Report
-- Descripción: Genera el reporte de cementerios a cobrar para una recaudadora y mes dados.
-- --------------------------------------------

-- PostgreSQL stored procedure for report


CREATE OR REPLACE FUNCTION sp_rep_a_cobrar(
    par_mes     integer,
    par_id_rec  integer
)
RETURNS TABLE (
    ano            integer,
    mantenimiento  numeric(16,2),
    recargos       numeric(16,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
	-- t.metros,
        t.axo_cuota                               AS ano,
        SUM(t.cuota1 /* * t.metros*/)                             AS mantenimiento,
        SUM(t.cuota1 /* * t.metros */ * r.porcentaje_global / 100) AS recargos
    FROM public.ta_13_rcmcuotas   t
    JOIN public.ta_13_datosrcm    d  ON d.cementerio = t.cementerio
    JOIN public.ta_12_recaudadoras rca ON rca.id_rec = par_id_rec
    JOIN public.ta_13_recargosrcm r  ON r.axo = t.axo_cuota
                                     AND r.mes = par_mes
    /* Nota: a petición tuya, NO se filtra por d.id_rec = par_id_rec */
    GROUP BY t.axo_cuota
    ORDER BY t.axo_cuota;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_rep_a_cobrar_info_recaudadora
-- Tipo: Query
-- Descripción: Obtiene información de la recaudadora para el reporte (FormShow del Pascal)
-- Query Pascal: SELECT a.*,b.*,upper(c.zona) d_zona FROM TA_12_nombrerec a,ta_12_recaudadoras b,ta_12_zonas c
--               WHERE a.RECing=:REC and a.recing=b.id_rec and b.id_zona=c.id_zona
-- --------------------------------------------
CREATE OR REPLACE FUNCTION sp_rep_a_cobrar_info_recaudadora(
    p_id_rec integer
)
RETURNS TABLE (
    recing SMALLINT,
    nomre VARCHAR(60),
    titulo VARCHAR(25),
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora VARCHAR(50),
    domicilio VARCHAR(50),
    tel VARCHAR(15),
    recaudador VARCHAR(50),
    sector CHAR(1),
    d_zona VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.recing,
        a.nomre,
        a.titulo,
        b.id_rec,
        b.id_zona,
        b.recaudadora::VARCHAR(50),
        b.domicilio::VARCHAR(50),
        b.tel::VARCHAR(15),
        b.recaudador::VARCHAR(50),
        b.sector::CHAR(1),
        UPPER(c.zona)::VARCHAR(50) AS d_zona
    FROM public.ta_12_nombrerec a
    JOIN public.ta_12_recaudadoras b ON a.recing = b.id_rec
    JOIN public.ta_12_zonas c ON b.id_zona = c.id_zona
    WHERE a.recing = p_id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_rep_a_cobrar_cuentas_cobrar
-- Tipo: Report
-- Descripción: Lista folios con adeudos vigentes por cementerio y año de referencia
-- NUEVO 2025-12-01
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rep_a_cobrar_cuentas_cobrar(
    p_cementerio CHAR(1) DEFAULT NULL,
    p_anio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    control_rcm INTEGER,
    cementerio CHAR(1),
    nombre VARCHAR(60),
    domicilio VARCHAR(60),
    colonia VARCHAR(30),
    axo_pagado INTEGER,
    anios_adeudo INTEGER,
    ubicacion VARCHAR(100)
) AS $$
DECLARE
    v_anio_ref INTEGER;
BEGIN
    -- Si no se proporciona año, usar el año actual
    v_anio_ref := COALESCE(p_anio, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER);

    RETURN QUERY
    SELECT
        d.control_rcm,
        d.cementerio,
        d.nombre,
        COALESCE(d.domicilio, '') AS domicilio,
        COALESCE(d.colonia, '') AS colonia,
        COALESCE(d.axo_pagado, 0) AS axo_pagado,
        (v_anio_ref - COALESCE(d.axo_pagado, v_anio_ref - 10)) AS anios_adeudo,
        CONCAT(
            'Cl:', d.clase, COALESCE(d.clase_alfa, ''),
            ' Sec:', d.seccion, COALESCE(d.seccion_alfa, ''),
            ' Lin:', d.linea, COALESCE(d.linea_alfa, ''),
            ' Fosa:', d.fosa, COALESCE(d.fosa_alfa, '')
        ) AS ubicacion
    FROM comun.ta_13_datosrcm d
    WHERE d.vigencia = 'A'
      AND (p_cementerio IS NULL OR d.cementerio = p_cementerio)
      AND (v_anio_ref - COALESCE(d.axo_pagado, 0)) > 0
    ORDER BY anios_adeudo DESC, d.cementerio, d.control_rcm;
END;
$$ LANGUAGE plpgsql;

-- ============================================

