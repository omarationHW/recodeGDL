-- SP: sp_otras_oblig_buscar_cont
-- Descripción: Obtiene datos principales del control especificado
-- Parámetros: par_tab INTEGER, par_control VARCHAR
-- Retorna: Datos completos del contrato/concesión
-- Prioridad: CRÍTICA
-- Componente: GConsulta2.vue

CREATE OR REPLACE FUNCTION sp_otras_oblig_buscar_cont(
    par_tab INTEGER,
    par_control VARCHAR
)
RETURNS TABLE (
    status INTEGER,
    id_datos INTEGER,
    control VARCHAR(20),
    concesionario VARCHAR(200),
    ubicacion VARCHAR(300),
    nomcomercial VARCHAR(200),
    lugar VARCHAR(200),
    obs VARCHAR(500),
    superficie NUMERIC(10,2),
    fechainicio DATE,
    recaudadora VARCHAR(100),
    sector VARCHAR(50),
    zona VARCHAR(50),
    licencia VARCHAR(50),
    unidades INTEGER,
    statusregistro VARCHAR(20),
    axo_ini INTEGER,
    mes_ini INTEGER,
    axo_fin INTEGER,
    mes_fin INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        0 AS status, -- 0: encontrado, 1: no encontrado
        d.id_34_datos AS id_datos,
        d.control::VARCHAR(20),
        COALESCE(d.concesionario, '')::VARCHAR(200),
        COALESCE(d.ubicacion, '')::VARCHAR(300),
        COALESCE(d.nomcomercial, '')::VARCHAR(200),
        COALESCE(d.lugar, '')::VARCHAR(200),
        COALESCE(d.obs, '')::VARCHAR(500),
        COALESCE(d.superficie, 0)::NUMERIC(10,2),
        d.fechainicio,
        COALESCE(r.nombre, '')::VARCHAR(100) AS recaudadora,
        COALESCE(d.sector, '')::VARCHAR(50),
        COALESCE(d.zona::TEXT, '')::VARCHAR(50),
        COALESCE(d.licencia, '')::VARCHAR(50),
        COALESCE(d.unidades, 0) AS unidades,
        CASE
            WHEN d.status = 'V' THEN 'VIGENTE'
            WHEN d.status = 'C' THEN 'CANCELADO'
            WHEN d.status = 'S' THEN 'SUSPENSION'
            ELSE 'DESCONOCIDO'
        END::VARCHAR(20) AS statusregistro,
        COALESCE(d.axo_ini, 0) AS axo_ini,
        COALESCE(d.mes_ini, 0) AS mes_ini,
        COALESCE(d.axo_fin, 0) AS axo_fin,
        COALESCE(d.mes_fin, 0) AS mes_fin
    FROM t_34_datos d
    LEFT JOIN t_recaudadoras r ON d.cve_ofna = r.cve_recaud
    WHERE d.cve_tab = par_tab
      AND d.control = par_control;

    -- Si no se encontró, retornar status 1
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            1 AS status,
            0 AS id_datos,
            ''::VARCHAR(20) AS control,
            ''::VARCHAR(200) AS concesionario,
            ''::VARCHAR(300) AS ubicacion,
            ''::VARCHAR(200) AS nomcomercial,
            ''::VARCHAR(200) AS lugar,
            ''::VARCHAR(500) AS obs,
            0::NUMERIC(10,2) AS superficie,
            NULL::DATE AS fechainicio,
            ''::VARCHAR(100) AS recaudadora,
            ''::VARCHAR(50) AS sector,
            ''::VARCHAR(50) AS zona,
            ''::VARCHAR(50) AS licencia,
            0 AS unidades,
            'NO EXISTE'::VARCHAR(20) AS statusregistro,
            0 AS axo_ini,
            0 AS mes_ini,
            0 AS axo_fin,
            0 AS mes_fin;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Comentarios
COMMENT ON FUNCTION sp_otras_oblig_buscar_cont(INTEGER, VARCHAR) IS
'Obtiene los datos completos de un control/concesión específico. Retorna status=0 si existe, status=1 si no existe';
