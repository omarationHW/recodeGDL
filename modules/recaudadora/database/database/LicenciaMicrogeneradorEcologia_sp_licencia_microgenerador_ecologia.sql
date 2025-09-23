-- Stored Procedure: sp_licencia_microgenerador_ecologia
-- Tipo: CRUD
-- Descripción: Alta, consulta y cancelación de microgenerador para licencias y trámites de ecología.
-- Generado para formulario: LicenciaMicrogeneradorEcologia
-- Fecha: 2025-08-27 12:38:05

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
