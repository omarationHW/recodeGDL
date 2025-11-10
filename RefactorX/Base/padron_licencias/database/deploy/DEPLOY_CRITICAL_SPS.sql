-- ============================================================
-- DEPLOY DE STORED PROCEDURES CRÍTICOS
-- Base de datos: padron_licencias
-- Fecha: 2025-11-09
-- ============================================================
--
-- Este script crea los 3 Stored Procedures CRÍTICOS identificados
-- en el análisis de prioridades:
--
-- 1. sp_get_tramite_by_id (Priority: 120)
-- 2. sp_verifica_firma (Priority: 100)
--
-- ============================================================

-- ============================================================
-- SP #1: sp_get_tramite_by_id
-- ============================================================
-- Descripción: Obtiene la información completa de un trámite por ID
-- Usado en: modtramitefrm, formatosEcologiafrm, ReactivaTramite
-- Frecuencia: 4 veces
-- ============================================================

CREATE OR REPLACE FUNCTION sp_get_tramite_by_id(
    p_id_tramite INTEGER
)
RETURNS TABLE (
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite CHARACTER(2),
    id_giro INTEGER,
    x NUMERIC,
    y NUMERIC,
    zona SMALLINT,
    subzona SMALLINT,
    actividad CHARACTER(130),
    cvecuenta INTEGER,
    recaud SMALLINT,
    licencia_ref INTEGER,
    tramita_apoderado CHARACTER VARYING(100),
    propietario CHARACTER(80),
    primer_ap CHARACTER VARYING(80),
    segundo_ap CHARACTER VARYING(80),
    rfc CHARACTER(13),
    curp CHARACTER(18),
    domicilio CHARACTER(50),
    numext_prop INTEGER,
    numint_prop CHARACTER(5),
    colonia_prop CHARACTER(25),
    telefono_prop CHARACTER(30),
    email CHARACTER(50),
    cvecalle INTEGER,
    ubicacion CHARACTER(50),
    numext_ubic INTEGER,
    letraext_ubic CHARACTER(3),
    letraint_ubic CHARACTER(3),
    colonia_ubic CHARACTER(25),
    espubic CHARACTER(60),
    documentos TEXT,
    sup_construida NUMERIC,
    sup_autorizada NUMERIC,
    num_cajones SMALLINT,
    num_empleados SMALLINT,
    aforo SMALLINT,
    inversion NUMERIC,
    costo NUMERIC,
    fecha_consejo DATE,
    id_fabricante INTEGER,
    texto_anuncio CHARACTER(50),
    medidas1 NUMERIC,
    medidas2 NUMERIC,
    area_anuncio NUMERIC,
    num_caras SMALLINT,
    calificacion NUMERIC,
    usr_califica CHARACTER(10),
    estatus CHARACTER(1),
    id_licencia INTEGER,
    id_anuncio INTEGER,
    feccap DATE,
    capturista CHARACTER(10),
    numint_ubic CHARACTER(5),
    bloqueado SMALLINT,
    dictamen SMALLINT,
    observaciones TEXT,
    rhorario CHARACTER(50),
    cp INTEGER,
    fecmov TIMESTAMP WITHOUT TIME ZONE,
    usuariomov CHARACTER(10)
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id_tramite,
        t.folio,
        t.tipo_tramite,
        t.id_giro,
        t.x,
        t.y,
        t.zona,
        t.subzona,
        t.actividad,
        t.cvecuenta,
        t.recaud,
        t.licencia_ref,
        t.tramita_apoderado,
        t.propietario,
        t.primer_ap,
        t.segundo_ap,
        t.rfc,
        t.curp,
        t.domicilio,
        t.numext_prop,
        t.numint_prop,
        t.colonia_prop,
        t.telefono_prop,
        t.email,
        t.cvecalle,
        t.ubicacion,
        t.numext_ubic,
        t.letraext_ubic,
        t.letraint_ubic,
        t.colonia_ubic,
        t.espubic,
        t.documentos,
        t.sup_construida,
        t.sup_autorizada,
        t.num_cajones,
        t.num_empleados,
        t.aforo,
        t.inversion,
        t.costo,
        t.fecha_consejo,
        t.id_fabricante,
        t.texto_anuncio,
        t.medidas1,
        t.medidas2,
        t.area_anuncio,
        t.num_caras,
        t.calificacion,
        t.usr_califica,
        t.estatus,
        t.id_licencia,
        t.id_anuncio,
        t.feccap,
        t.capturista,
        t.numint_ubic,
        t.bloqueado,
        t.dictamen,
        t.observaciones,
        t.rhorario,
        t.cp,
        t.fecmov,
        t.usuariomov
    FROM h_tramites t
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION sp_get_tramite_by_id(INTEGER) IS
'Obtiene la información completa de un trámite por su ID.
Usado en modtramitefrm, formatosEcologiafrm, ReactivaTramite.';


-- ============================================================
-- SP #2: sp_verifica_firma
-- ============================================================
-- Descripción: Verifica si la firma/contraseña de un usuario es correcta
-- Usado en: bajaAnunciofrm, bajaLicenciafrm, modlicfrm
-- Frecuencia: 4 veces
-- ============================================================

CREATE OR REPLACE FUNCTION sp_verifica_firma(
    p_usuario CHARACTER VARYING,
    p_firma CHARACTER VARYING
)
RETURNS TABLE (
    firma_valida BOOLEAN,
    usuario CHARACTER(8),
    nombres CHARACTER(30),
    nivel SMALLINT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        CASE
            WHEN u.clave = p_firma::CHARACTER(8) THEN TRUE
            ELSE FALSE
        END AS firma_valida,
        u.usuario,
        u.nombres,
        u.nivel
    FROM comun.usuarios u
    WHERE u.usuario = p_usuario::CHARACTER(8)
      AND u.fecbaj IS NULL;  -- Usuario activo (no dado de baja)

    -- Si el usuario no existe, retornar firma_valida = FALSE
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            FALSE AS firma_valida,
            NULL::CHARACTER(8) AS usuario,
            NULL::CHARACTER(30) AS nombres,
            NULL::SMALLINT AS nivel;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION sp_verifica_firma(CHARACTER VARYING, CHARACTER VARYING) IS
'Verifica si la firma/contraseña de un usuario es correcta.
Usado en bajaAnunciofrm, bajaLicenciafrm, modlicfrm.
Retorna firma_valida=TRUE si el usuario existe, está activo y la contraseña coincide.';


-- ============================================================
-- VERIFICACIÓN DE CREACIÓN
-- ============================================================

SELECT
    routine_schema,
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_name IN ('sp_get_tramite_by_id', 'sp_verifica_firma')
  AND routine_schema = 'public'
ORDER BY routine_name;

-- ============================================================
-- PRUEBAS BÁSICAS
-- ============================================================

-- Prueba 1: sp_get_tramite_by_id
-- SELECT * FROM sp_get_tramite_by_id(1);  -- Ajustar con un ID válido

-- Prueba 2: sp_verifica_firma
-- SELECT * FROM sp_verifica_firma('usuario', 'clave');  -- Ajustar con datos válidos

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
