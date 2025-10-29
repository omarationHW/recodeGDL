-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: LICENCIAMICROGENERADORECOLOGIA (EXACTO del archivo original)
-- Archivo: 60_SP_RECAUDADORA_LICENCIAMICROGENERADORECOLOGIA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_licencia_microgenerador_ecologia
-- Tipo: CRUD
-- Descripción: Alta, consulta y cancelación de microgenerador para licencias y trámites de ecología.
-- --------------------------------------------

-- PostgreSQL stored procedure for microgenerador ecología
CREATE OR REPLACE FUNCTION sp_licencia_microgenerador_ecologia(
    p_opc integer, -- 1=consulta, 2=alta, 3=cancela
    p_id integer,  -- id_licencia o id_tramite
    p_tipo varchar, -- 'L'=licencia, 'T'=tramite
    p_anio smallint,
    p_usuario varchar
)
RETURNS TABLE(estatus integer, mensaje varchar) AS $$
DECLARE
    v_existe integer;
    v_msg varchar;
BEGIN
    IF p_opc = 1 THEN -- Consulta
        IF p_tipo = 'L' THEN
            SELECT COUNT(*) INTO v_existe FROM lic_microgenerador_ecologia WHERE id_licencia = p_id AND anio = p_anio AND vigente = 'V';
            IF v_existe > 0 THEN
                RETURN QUERY SELECT 1, 'Licencia ya es microgenerador vigente.';
            ELSE
                RETURN QUERY SELECT 2, 'Licencia no es microgenerador.';
            END IF;
        ELSIF p_tipo = 'T' THEN
            SELECT COUNT(*) INTO v_existe FROM lic_microgenerador_ecologia WHERE id_tramite = p_id AND anio = p_anio AND vigente = 'V';
            IF v_existe > 0 THEN
                RETURN QUERY SELECT 1, 'Trámite ya es microgenerador vigente.';
            ELSE
                RETURN QUERY SELECT 2, 'Trámite no es microgenerador.';
            END IF;
        ELSE
            RETURN QUERY SELECT 0, 'Tipo inválido.';
        END IF;
    ELSIF p_opc = 2 THEN -- Alta
        IF p_tipo = 'L' THEN
            SELECT COUNT(*) INTO v_existe FROM lic_microgenerador_ecologia WHERE id_licencia = p_id AND anio = p_anio AND vigente = 'V';
            IF v_existe > 0 THEN
                RETURN QUERY SELECT 1, 'Licencia ya es microgenerador vigente.';
            ELSE
                INSERT INTO lic_microgenerador_ecologia(id_licencia, anio, usuario_alta, fecha_alta, vigente)
                VALUES (p_id, p_anio, p_usuario, now(), 'V');
                RETURN QUERY SELECT 1, 'Alta exitosa, Licencia registrada como microgenerador.';
            END IF;
        ELSIF p_tipo = 'T' THEN
            SELECT COUNT(*) INTO v_existe FROM lic_microgenerador_ecologia WHERE id_tramite = p_id AND anio = p_anio AND vigente = 'V';
            IF v_existe > 0 THEN
                RETURN QUERY SELECT 1, 'Trámite ya es microgenerador vigente.';
            ELSE
                INSERT INTO lic_microgenerador_ecologia(id_tramite, anio, usuario_alta, fecha_alta, vigente)
                VALUES (p_id, p_anio, p_usuario, now(), 'V');
                RETURN QUERY SELECT 1, 'Alta exitosa, Trámite registrado como microgenerador.';
            END IF;
        ELSE
            RETURN QUERY SELECT 0, 'Tipo inválido.';
        END IF;
    ELSIF p_opc = 3 THEN -- Cancela
        IF p_tipo = 'L' THEN
            UPDATE lic_microgenerador_ecologia SET vigente = 'C', usuario_baja = p_usuario, fecha_baja = now()
            WHERE id_licencia = p_id AND anio = p_anio AND vigente = 'V';
            IF FOUND THEN
                RETURN QUERY SELECT 1, 'Cancelación exitosa, Licencia cancelada como microgenerador.';
            ELSE
                RETURN QUERY SELECT 0, 'No se encontró registro vigente para cancelar.';
            END IF;
        ELSIF p_tipo = 'T' THEN
            UPDATE lic_microgenerador_ecologia SET vigente = 'C', usuario_baja = p_usuario, fecha_baja = now()
            WHERE id_tramite = p_id AND anio = p_anio AND vigente = 'V';
            IF FOUND THEN
                RETURN QUERY SELECT 1, 'Cancelación exitosa, Trámite cancelado como microgenerador.';
            ELSE
                RETURN QUERY SELECT 0, 'No se encontró registro vigente para cancelar.';
            END IF;
        ELSE
            RETURN QUERY SELECT 0, 'Tipo inválido.';
        END IF;
    ELSE
        RETURN QUERY SELECT 0, 'Operación inválida.';
    END IF;
END;
$$ LANGUAGE plpgsql;


-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: LICENCIAMICROGENERADORECOLOGIA (EXACTO del archivo original)
-- Archivo: 60_SP_RECAUDADORA_LICENCIAMICROGENERADORECOLOGIA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: vw_licencia_microgenerador
-- Tipo: Catalog
-- Descripción: Vista para consulta de datos de licencia para microgenerador.
-- --------------------------------------------

-- Vista para consulta de licencia
CREATE OR REPLACE VIEW vw_licencia_microgenerador AS
SELECT id_licencia, licencia, trim(coalesce(propietario, '')) || ' ' || trim(coalesce(primer_ap, '')) || ' ' || trim(coalesce(segundo_ap, '')) AS nombre,
       trim(coalesce(ubicacion, '')) || ' ' || trim(coalesce(numext_ubic, '')) || ' ' || trim(coalesce(letraext_ubic, '')) || ' ' || trim(coalesce(numint_ubic, '')) || ' ' || trim(coalesce(letraint_ubic, '')) AS ubicacion,
       actividad
FROM public WHERE vigente = 'V';


-- ============================================

