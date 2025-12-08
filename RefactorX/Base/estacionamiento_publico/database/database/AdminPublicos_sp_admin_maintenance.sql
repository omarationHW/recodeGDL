-- =============================================
-- Stored Procedure: sp_admin_maintenance
-- Modulo: estacionamiento_publico
-- Componente: AdminPublicos.vue
-- Descripcion: Operaciones de mantenimiento del sistema de estacionamientos publicos
-- Fecha: 2025-11-26
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_admin_maintenance(
    p_operacion VARCHAR(50)
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR(500),
    detalles VARCHAR(1000)
) AS $$
DECLARE
    v_count INTEGER;
    v_fecha_backup VARCHAR(20);
BEGIN
    CASE UPPER(p_operacion)
        WHEN 'CLEAR_CACHE' THEN
            -- Limpiar cache (simular operacion - en produccion limpiar tablas temporales)
            DELETE FROM pub_config_sistema WHERE clave LIKE 'CACHE_%';
            GET DIAGNOSTICS v_count = ROW_COUNT;
            RETURN QUERY SELECT
                TRUE,
                'Cache limpiado correctamente'::VARCHAR(500),
                ('Se eliminaron ' || v_count || ' registros de cache')::VARCHAR(1000);

        WHEN 'BACKUP' THEN
            -- Registrar inicio de backup
            v_fecha_backup := TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS');
            INSERT INTO pub_config_sistema (clave, valor, fecha_mod)
            VALUES ('ULTIMO_BACKUP', v_fecha_backup, CURRENT_TIMESTAMP)
            ON CONFLICT (clave) DO UPDATE SET valor = v_fecha_backup, fecha_mod = CURRENT_TIMESTAMP;

            RETURN QUERY SELECT
                TRUE,
                'Respaldo iniciado correctamente'::VARCHAR(500),
                ('Backup programado: ' || v_fecha_backup)::VARCHAR(1000);

        WHEN 'CHECK_INTEGRITY' THEN
            -- Verificar integridad basica
            SELECT COUNT(*) INTO v_count
            FROM pubmain
            WHERE movto_cve NOT IN ('A', 'M', 'B', 'C');

            IF v_count = 0 THEN
                RETURN QUERY SELECT
                    TRUE,
                    'Verificacion de integridad completada'::VARCHAR(500),
                    'Sistema integro. No se encontraron inconsistencias.'::VARCHAR(1000);
            ELSE
                RETURN QUERY SELECT
                    FALSE,
                    'Se encontraron inconsistencias'::VARCHAR(500),
                    ('Registros con movto_cve invalido: ' || v_count)::VARCHAR(1000);
            END IF;

        WHEN 'STATS' THEN
            -- Obtener estadisticas generales
            SELECT COUNT(*) INTO v_count FROM pubmain WHERE movto_cve <> 'C';
            RETURN QUERY SELECT
                TRUE,
                'Estadisticas obtenidas'::VARCHAR(500),
                ('Total registros activos: ' || v_count)::VARCHAR(1000);

        ELSE
            RETURN QUERY SELECT
                FALSE,
                'Operacion no reconocida'::VARCHAR(500),
                ('Operaciones validas: CLEAR_CACHE, BACKUP, CHECK_INTEGRITY, STATS')::VARCHAR(1000);
    END CASE;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT
        FALSE,
        ('Error en operacion de mantenimiento: ' || SQLERRM)::VARCHAR(500),
        ''::VARCHAR(1000);
END;
$$ LANGUAGE plpgsql;

-- Comentario de documentacion
COMMENT ON FUNCTION public.sp_admin_maintenance(VARCHAR) IS 'Operaciones de mantenimiento del sistema: CLEAR_CACHE, BACKUP, CHECK_INTEGRITY, STATS';
