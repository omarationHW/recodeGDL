-- =============================================
-- Stored Procedure: spget_lic_grales
-- Descripción: Obtiene información general de una licencia de estacionamiento
-- Basado en: Sp_licgrales del archivo sfrm_consultapublicos.dfm (Delphi)
-- Uso: ConsultaPublicos.vue (línea 328)
-- Parámetros:
--   NumLicencia: Número de licencia a consultar
--   cero: Parámetro auxiliar (siempre 0)
--   reca: Tipo de recarga/consulta (valores: 0-4)
-- =============================================

CREATE OR REPLACE FUNCTION public.spget_lic_grales(
    p_numlicencia INTEGER,
    p_cero INTEGER DEFAULT 0,
    p_reca INTEGER DEFAULT 4
)
RETURNS TABLE(
    clave INTEGER,
    msg VARCHAR(100),
    id INTEGER,
    bloq INTEGER,
    vigente VARCHAR(1),
    id_giro INTEGER,
    desc_giro VARCHAR(96),
    actividad VARCHAR(130),
    reglamentada VARCHAR(1),
    propietario VARCHAR(80),
    ubicacion VARCHAR(50),
    numext INTEGER,
    letext VARCHAR(3),
    numint VARCHAR(5),
    letint VARCHAR(3),
    colonia VARCHAR(25),
    zona INTEGER,
    subzona INTEGER,
    espubic VARCHAR(100),
    asiento INTEGER,
    curp VARCHAR(18),
    sup_autorizada NUMERIC(10,2),
    num_cajones INTEGER,
    aforo INTEGER,
    rhorario VARCHAR(70),
    fecha_consejo DATE,
    cvecatnva VARCHAR(11),
    subpredio INTEGER,
    mensaje1 VARCHAR(85),
    v_mensaje2 VARCHAR(85),
    mensaje3 VARCHAR(200),
    mensaje4 VARCHAR(250),
    mensaje4_1 VARCHAR(250),
    tipotramite VARCHAR(50),
    desc_reglam VARCHAR(50),
    rfc VARCHAR(13),
    licencia INTEGER,
    mensaje5 VARCHAR(250),
    mensaje6 VARCHAR(250),
    mensaje7 VARCHAR(250),
    mensaje8 VARCHAR(250)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_clave INTEGER := 0;
    v_msg VARCHAR(100) := '';
    v_id INTEGER;
    v_bloq INTEGER := 0;
    v_vigente VARCHAR(1);
    v_id_giro INTEGER;
    v_desc_giro VARCHAR(96);
    v_actividad VARCHAR(130);
    v_reglamentada VARCHAR(1);
    v_propietario VARCHAR(80);
    v_ubicacion VARCHAR(50);
    v_numext INTEGER;
    v_letext VARCHAR(3);
    v_numint VARCHAR(5);
    v_letint VARCHAR(3);
    v_colonia VARCHAR(25);
    v_zona INTEGER;
    v_subzona INTEGER;
    v_espubic VARCHAR(100);
    v_asiento INTEGER;
    v_curp VARCHAR(18);
    v_sup_autorizada NUMERIC(10,2);
    v_num_cajones INTEGER;
    v_aforo INTEGER;
    v_rhorario VARCHAR(70);
    v_fecha_consejo DATE;
    v_cvecatnva VARCHAR(11);
    v_subpredio INTEGER;
    v_rfc VARCHAR(13);
BEGIN
    -- Buscar la licencia en la tabla de estacionamientos públicos
    -- Asumiendo estructura similar a pubmain del sistema original
    SELECT
        pm.id,
        CASE WHEN pm.movto_cve = 'C' THEN 1 ELSE 0 END, -- bloqueado si está cancelado
        CASE WHEN pm.fecha_vencimiento >= CURRENT_DATE THEN 'S' ELSE 'N' END, -- vigente
        pm.pubcategoria_id,
        pc.descripcion,
        '',  -- actividad (vacío por ahora)
        'N', -- reglamentada
        pm.nombre, -- propietario
        pm.calle, -- ubicacion
        CAST(pm.numext AS INTEGER),
        '', -- letext
        '', -- numint
        '', -- letint
        '', -- colonia
        pm.zona,
        pm.subzona,
        '', -- espubic
        0, -- asiento
        '', -- curp
        0.00, -- sup_autorizada
        pm.cupo, -- num_cajones
        0, -- aforo
        '', -- rhorario
        NULL, -- fecha_consejo
        CAST(pm.cvecuenta AS VARCHAR(11)), -- cvecatnva
        0, -- subpredio
        pm.rfc
    INTO
        v_id,
        v_bloq,
        v_vigente,
        v_id_giro,
        v_desc_giro,
        v_actividad,
        v_reglamentada,
        v_propietario,
        v_ubicacion,
        v_numext,
        v_letext,
        v_numint,
        v_letint,
        v_colonia,
        v_zona,
        v_subzona,
        v_espubic,
        v_asiento,
        v_curp,
        v_sup_autorizada,
        v_num_cajones,
        v_aforo,
        v_rhorario,
        v_fecha_consejo,
        v_cvecatnva,
        v_subpredio,
        v_rfc
    FROM pubmain pm
    LEFT JOIN pubcategoria pc ON pc.id = pm.pubcategoria_id
    WHERE pm.numlicencia = p_numlicencia
    LIMIT 1;

    IF v_id IS NULL THEN
        v_clave := -1;
        v_msg := 'Licencia no encontrada';
        v_id := 0;
    ELSE
        v_clave := 0;
        v_msg := 'OK';
    END IF;

    -- Retornar el resultado
    RETURN QUERY SELECT
        v_clave,
        v_msg,
        v_id,
        v_bloq,
        v_vigente,
        v_id_giro,
        v_desc_giro,
        v_actividad,
        v_reglamentada,
        v_propietario,
        v_ubicacion,
        v_numext,
        v_letext,
        v_numint,
        v_letint,
        v_colonia,
        v_zona,
        v_subzona,
        v_espubic,
        v_asiento,
        v_curp,
        v_sup_autorizada,
        v_num_cajones,
        v_aforo,
        v_rhorario,
        v_fecha_consejo,
        v_cvecatnva,
        v_subpredio,
        ''::VARCHAR(85) AS mensaje1,
        ''::VARCHAR(85) AS v_mensaje2,
        ''::VARCHAR(200) AS mensaje3,
        ''::VARCHAR(250) AS mensaje4,
        ''::VARCHAR(250) AS mensaje4_1,
        ''::VARCHAR(50) AS tipotramite,
        ''::VARCHAR(50) AS desc_reglam,
        v_rfc,
        p_numlicencia AS licencia,
        ''::VARCHAR(250) AS mensaje5,
        ''::VARCHAR(250) AS mensaje6,
        ''::VARCHAR(250) AS mensaje7,
        ''::VARCHAR(250) AS mensaje8;
END;
$$;

-- Comentarios y metadatos
COMMENT ON FUNCTION public.spget_lic_grales(INTEGER, INTEGER, INTEGER) IS
'SP que obtiene información general de una licencia de estacionamiento público.
Basado en Sp_licgrales del sistema Delphi original.
Usado por: ConsultaPublicos.vue';
