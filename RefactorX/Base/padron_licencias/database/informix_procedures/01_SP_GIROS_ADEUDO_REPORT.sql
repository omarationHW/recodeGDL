-- ============================================
-- STORED PROCEDURE FOR INFORMIX COMPATIBILITY
-- Component: GirosDconAdeudofrm.vue
-- Base: padron_licencias
-- Description: Report of restricted activities with debts from a specific year
-- ============================================

DROP PROCEDURE IF EXISTS sp_giros_adeudo_report;

CREATE PROCEDURE sp_giros_adeudo_report(p_anio INTEGER)
RETURNING
    VARCHAR(50) AS licencia,
    VARCHAR(255) AS propietarionvo,
    VARCHAR(500) AS domcompleto,
    VARCHAR(255) AS descripcion,
    INTEGER AS axo;

    DEFINE v_licencia VARCHAR(50);
    DEFINE v_propietario VARCHAR(255);
    DEFINE v_primer_ap VARCHAR(100);
    DEFINE v_segundo_ap VARCHAR(100);
    DEFINE v_ubicacion VARCHAR(255);
    DEFINE v_numext_ubic VARCHAR(10);
    DEFINE v_letraext_ubic VARCHAR(5);
    DEFINE v_numint_ubic VARCHAR(10);
    DEFINE v_letraint_ubic VARCHAR(5);
    DEFINE v_descripcion VARCHAR(255);
    DEFINE v_axo INTEGER;
    DEFINE v_propietarionvo VARCHAR(255);
    DEFINE v_domcompleto VARCHAR(500);

    -- Cursor para obtener licencias con adeudos del año específico
    FOREACH SELECT
        l.licencia,
        l.propietario,
        NVL(TRIM(l.primer_ap), '') as primer_ap,
        NVL(TRIM(l.segundo_ap), '') as segundo_ap,
        NVL(TRIM(l.ubicacion), '') as ubicacion,
        NVL(l.numext_ubic, '') as numext_ubic,
        NVL(l.letraext_ubic, '') as letraext_ubic,
        NVL(l.numint_ubic, '') as numint_ubic,
        NVL(l.letraint_ubic, '') as letraint_ubic,
        g.descripcion,
        MIN(d.axo) as axo
    INTO
        v_licencia,
        v_propietario,
        v_primer_ap,
        v_segundo_ap,
        v_ubicacion,
        v_numext_ubic,
        v_letraext_ubic,
        v_numint_ubic,
        v_letraint_ubic,
        v_descripcion,
        v_axo
    FROM licencias l
    INNER JOIN detsal_lic d ON l.id_licencia = d.id_licencia
    INNER JOIN c_giros g ON g.id_giro = l.id_giro
    WHERE d.cvepago = 0
      AND d.id_anuncio = 0
      AND g.clasificacion = 'D'
      AND d.axo >= p_anio
    GROUP BY
        l.licencia, l.propietario, l.primer_ap, l.segundo_ap,
        l.ubicacion, l.numext_ubic, l.letraext_ubic,
        l.numint_ubic, l.letraint_ubic, g.descripcion
    HAVING MIN(d.axo) = p_anio
    ORDER BY l.licencia

        -- Concatenar nombre completo del propietario
        LET v_propietarionvo = TRIM(v_primer_ap) || ' ' || TRIM(v_segundo_ap) || ' ' || TRIM(v_propietario);
        LET v_propietarionvo = TRIM(v_propietarionvo);

        -- Concatenar domicilio completo
        LET v_domcompleto = TRIM(v_ubicacion) || ' No. ext.: ' || v_numext_ubic ||
                           ' Letra ext. ' || v_letraext_ubic || ' No. int.: ' || v_numint_ubic ||
                           ' Letra int. ' || v_letraint_ubic;

        RETURN v_licencia, v_propietarionvo, v_domcompleto, v_descripcion, v_axo
        WITH RESUME;

    END FOREACH;

END PROCEDURE;