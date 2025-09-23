-- Stored Procedure: lic_registro_microgenerador
-- Tipo: CRUD
-- Descripción: Alta, consulta y cancelación de registro de microgenerador para licencias o trámites
-- Generado para formulario: LicenciaMicrogenerador
-- Fecha: 2025-08-27 12:34:46

-- PostgreSQL stored procedure for microgenerador registration
CREATE OR REPLACE FUNCTION lic_registro_microgenerador(
    p_opc integer, -- 1=consulta, 2=alta, 3=cancelar
    p_id integer,  -- id_licencia o id_tramite
    p_anio smallint,
    p_usuario varchar
) RETURNS TABLE (estatus integer, mensaje varchar) AS $$
DECLARE
    v_existe integer;
BEGIN
    IF p_opc = 1 THEN -- Consulta
        SELECT COUNT(*) INTO v_existe FROM lic_microgenerador WHERE id_ref = p_id AND anio = p_anio AND vigente = 'V';
        IF v_existe > 0 THEN
            RETURN QUERY SELECT 1 AS estatus, 'Ya existe como microgenerador' AS mensaje;
        ELSE
            RETURN QUERY SELECT 2 AS estatus, 'No existe como microgenerador' AS mensaje;
        END IF;
    ELSIF p_opc = 2 THEN -- Alta
        SELECT COUNT(*) INTO v_existe FROM lic_microgenerador WHERE id_ref = p_id AND anio = p_anio AND vigente = 'V';
        IF v_existe > 0 THEN
            RETURN QUERY SELECT 0, 'Ya existe como microgenerador';
        ELSE
            INSERT INTO lic_microgenerador(id_ref, anio, usuario_alta, fecha_alta, vigente)
            VALUES (p_id, p_anio, p_usuario, NOW(), 'V');
            RETURN QUERY SELECT 1, 'Alta exitosa, Licencia registrada como microgenerador';
        END IF;
    ELSIF p_opc = 3 THEN -- Cancelar
        UPDATE lic_microgenerador SET vigente = 'C', usuario_baja = p_usuario, fecha_baja = NOW()
        WHERE id_ref = p_id AND anio = p_anio AND vigente = 'V';
        IF FOUND THEN
            RETURN QUERY SELECT 1, 'Cancelación exitosa, Licencia cancelada como microgenerador';
        ELSE
            RETURN QUERY SELECT 0, 'No se encontró registro vigente para cancelar';
        END IF;
    ELSE
        RETURN QUERY SELECT 0, 'Opción no válida';
    END IF;
END;
$$ LANGUAGE plpgsql;