-- ============================================
-- DEPLOY CONSOLIDADO: cargadatosfrm
-- Componente 93/95 - BATCH 19
-- Generado: 2025-11-20
-- Total SPs: 3 (básicos para carga de datos)
-- ============================================

-- SP 1/3: sp_cargadatos_list
CREATE OR REPLACE FUNCTION public.sp_cargadatos_list()
RETURNS TABLE(
    id INTEGER,
    nombre VARCHAR,
    archivo VARCHAR,
    fecha_carga TIMESTAMP,
    usuario VARCHAR,
    registros INTEGER,
    estado VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.id, c.nombre, c.archivo, c.fecha_carga, c.usuario, c.registros, c.estado
    FROM carga_datos c
    ORDER BY c.fecha_carga DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- SP 2/3: sp_cargadatos_create
CREATE OR REPLACE FUNCTION public.sp_cargadatos_create(
    p_nombre VARCHAR,
    p_archivo VARCHAR,
    p_usuario VARCHAR
) RETURNS JSON AS $$
DECLARE
    v_id INTEGER;
BEGIN
    INSERT INTO carga_datos (nombre, archivo, fecha_carga, usuario, registros, estado)
    VALUES (p_nombre, p_archivo, NOW(), p_usuario, 0, 'P')
    RETURNING id INTO v_id;

    RETURN json_build_object('success', true, 'id', v_id, 'message', 'Carga iniciada correctamente');
END;
$$ LANGUAGE plpgsql;

-- SP 3/3: sp_cargadatos_update_status
CREATE OR REPLACE FUNCTION public.sp_cargadatos_update_status(
    p_id INTEGER,
    p_estado VARCHAR,
    p_registros INTEGER
) RETURNS JSON AS $$
BEGIN
    UPDATE carga_datos SET estado = p_estado, registros = p_registros WHERE id = p_id;

    RETURN json_build_object('success', true, 'message', 'Estado actualizado correctamente');
END;
$$ LANGUAGE plpgsql;
