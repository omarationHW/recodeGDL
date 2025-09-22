-- Stored Procedure genérico para CRUD de empleados
-- Ejemplo de implementación para el parámetro "tipo":
-- tipo = 0: Consulta (SELECT)
-- tipo = 1: Insert/Update/Delete (según parámetro accion)

CREATE OR REPLACE FUNCTION pavimentacion.sp_empleados_crud(
    p_tipo INTEGER DEFAULT 0,
    p_nombre VARCHAR DEFAULT NULL,
    p_correo VARCHAR DEFAULT NULL,
    p_id INTEGER DEFAULT NULL,
    p_accion VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id INTEGER,
    nombre VARCHAR,
    correo VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    -- tipo = 0: CONSULTA
    IF p_tipo = 0 THEN
        RETURN QUERY 
        SELECT e.id, e.nombre, e.correo, e.created_at, e.updated_at
        FROM pavimentacion.empleados e
        ORDER BY e.id;
    
    -- tipo = 1: INSERT/UPDATE/DELETE
    ELSIF p_tipo = 1 THEN
        
        -- INSERT
        IF p_accion = 'insert' THEN
            INSERT INTO pavimentacion.empleados (nombre, correo, created_at, updated_at)
            VALUES (p_nombre, p_correo, NOW(), NOW());
            
            RETURN QUERY
            SELECT e.id, e.nombre, e.correo, e.created_at, e.updated_at
            FROM pavimentacion.empleados e
            WHERE e.nombre = p_nombre AND e.correo = p_correo
            ORDER BY e.id DESC
            LIMIT 1;
        
        -- UPDATE
        ELSIF p_accion = 'update' THEN
            UPDATE pavimentacion.empleados e
            SET nombre = p_nombre, 
                correo = p_correo, 
                updated_at = NOW()
            WHERE e.id = p_id;
            
            RETURN QUERY
            SELECT e.id, e.nombre, e.correo, e.created_at, e.updated_at
            FROM pavimentacion.empleados e
            WHERE e.id = p_id;
        
        -- DELETE
        ELSIF p_accion = 'delete' THEN
            -- Primero guardamos el registro que vamos a eliminar para devolverlo
            RETURN QUERY
            SELECT e.id, e.nombre, e.correo, e.created_at, e.updated_at
            FROM pavimentacion.empleados e
            WHERE e.id = p_id;
            
            -- Luego eliminamos
            DELETE FROM pavimentacion.empleados e WHERE e.id = p_id;
            
        END IF;
        
    END IF;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;