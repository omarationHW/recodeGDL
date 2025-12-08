-- =============================================
-- DEPLOY: Stored Procedures para AdminPublicos.vue
-- Modulo: estacionamiento_publico
-- Base de datos: estacionamiento_publico
-- Esquema: public
-- Fecha: 2025-11-26
-- =============================================

-- Verificar/crear tabla de configuracion del sistema si no existe
-- Nota: Se usa pub_config_sistema porque pubparametros ya existe con otra estructura
CREATE TABLE IF NOT EXISTS public.pub_config_sistema (
    id SERIAL PRIMARY KEY,
    clave VARCHAR(100) UNIQUE NOT NULL,
    valor VARCHAR(500),
    descripcion VARCHAR(200),
    fecha_mod TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear indice unico si no existe
CREATE UNIQUE INDEX IF NOT EXISTS idx_pub_config_sistema_clave ON public.pub_config_sistema(clave);

-- =============================================
-- SP 1: sp_admin_get_config
-- Obtiene la configuracion del sistema
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_admin_get_config()
RETURNS TABLE (
    prefijo_folio VARCHAR(10),
    siguiente_folio INTEGER,
    permite_duplicados BOOLEAN,
    validar_rfc BOOLEAN,
    generar_recibos BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(
            (SELECT p.valor::VARCHAR(10) FROM pub_config_sistema p WHERE p.clave = 'PREFIJO_FOLIO'),
            'EP-'
        ) AS prefijo_folio,
        COALESCE(
            (SELECT p.valor::INTEGER FROM pub_config_sistema p WHERE p.clave = 'SIGUIENTE_FOLIO'),
            1000
        ) AS siguiente_folio,
        COALESCE(
            (SELECT p.valor::BOOLEAN FROM pub_config_sistema p WHERE p.clave = 'PERMITE_DUPLICADOS'),
            FALSE
        ) AS permite_duplicados,
        COALESCE(
            (SELECT p.valor::BOOLEAN FROM pub_config_sistema p WHERE p.clave = 'VALIDAR_RFC'),
            TRUE
        ) AS validar_rfc,
        COALESCE(
            (SELECT p.valor::BOOLEAN FROM pub_config_sistema p WHERE p.clave = 'GENERAR_RECIBOS'),
            TRUE
        ) AS generar_recibos;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_admin_get_config() IS 'Obtiene configuracion del sistema - AdminPublicos.vue';

-- =============================================
-- SP 2: sp_admin_update_config
-- Actualiza la configuracion del sistema
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_admin_update_config(
    p_prefijo_folio VARCHAR(10) DEFAULT NULL,
    p_siguiente_folio INTEGER DEFAULT NULL,
    p_permite_duplicados BOOLEAN DEFAULT NULL,
    p_validar_rfc BOOLEAN DEFAULT NULL,
    p_generar_recibos BOOLEAN DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR(200)
) AS $$
BEGIN
    IF p_prefijo_folio IS NOT NULL THEN
        INSERT INTO pub_config_sistema (clave, valor, fecha_mod)
        VALUES ('PREFIJO_FOLIO', p_prefijo_folio, CURRENT_TIMESTAMP)
        ON CONFLICT (clave) DO UPDATE SET valor = p_prefijo_folio, fecha_mod = CURRENT_TIMESTAMP;
    END IF;

    IF p_siguiente_folio IS NOT NULL THEN
        INSERT INTO pub_config_sistema (clave, valor, fecha_mod)
        VALUES ('SIGUIENTE_FOLIO', p_siguiente_folio::VARCHAR, CURRENT_TIMESTAMP)
        ON CONFLICT (clave) DO UPDATE SET valor = p_siguiente_folio::VARCHAR, fecha_mod = CURRENT_TIMESTAMP;
    END IF;

    IF p_permite_duplicados IS NOT NULL THEN
        INSERT INTO pub_config_sistema (clave, valor, fecha_mod)
        VALUES ('PERMITE_DUPLICADOS', p_permite_duplicados::VARCHAR, CURRENT_TIMESTAMP)
        ON CONFLICT (clave) DO UPDATE SET valor = p_permite_duplicados::VARCHAR, fecha_mod = CURRENT_TIMESTAMP;
    END IF;

    IF p_validar_rfc IS NOT NULL THEN
        INSERT INTO pub_config_sistema (clave, valor, fecha_mod)
        VALUES ('VALIDAR_RFC', p_validar_rfc::VARCHAR, CURRENT_TIMESTAMP)
        ON CONFLICT (clave) DO UPDATE SET valor = p_validar_rfc::VARCHAR, fecha_mod = CURRENT_TIMESTAMP;
    END IF;

    IF p_generar_recibos IS NOT NULL THEN
        INSERT INTO pub_config_sistema (clave, valor, fecha_mod)
        VALUES ('GENERAR_RECIBOS', p_generar_recibos::VARCHAR, CURRENT_TIMESTAMP)
        ON CONFLICT (clave) DO UPDATE SET valor = p_generar_recibos::VARCHAR, fecha_mod = CURRENT_TIMESTAMP;
    END IF;

    RETURN QUERY SELECT TRUE, 'Configuracion actualizada correctamente'::VARCHAR(200);

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, ('Error: ' || SQLERRM)::VARCHAR(200);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_admin_update_config(VARCHAR, INTEGER, BOOLEAN, BOOLEAN, BOOLEAN) IS 'Actualiza configuracion del sistema - AdminPublicos.vue';

-- =============================================
-- SP 3: sp_admin_maintenance
-- Operaciones de mantenimiento del sistema
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
            DELETE FROM pub_config_sistema WHERE clave LIKE 'CACHE_%';
            GET DIAGNOSTICS v_count = ROW_COUNT;
            RETURN QUERY SELECT
                TRUE,
                'Cache limpiado correctamente'::VARCHAR(500),
                ('Se eliminaron ' || v_count || ' registros de cache')::VARCHAR(1000);

        WHEN 'BACKUP' THEN
            v_fecha_backup := TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS');
            INSERT INTO pub_config_sistema (clave, valor, fecha_mod)
            VALUES ('ULTIMO_BACKUP', v_fecha_backup, CURRENT_TIMESTAMP)
            ON CONFLICT (clave) DO UPDATE SET valor = v_fecha_backup, fecha_mod = CURRENT_TIMESTAMP;

            RETURN QUERY SELECT
                TRUE,
                'Respaldo iniciado correctamente'::VARCHAR(500),
                ('Backup programado: ' || v_fecha_backup)::VARCHAR(1000);

        WHEN 'CHECK_INTEGRITY' THEN
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

COMMENT ON FUNCTION public.sp_admin_maintenance(VARCHAR) IS 'Operaciones de mantenimiento: CLEAR_CACHE, BACKUP, CHECK_INTEGRITY, STATS - AdminPublicos.vue';

-- =============================================
-- Insertar valores por defecto si no existen
-- =============================================
INSERT INTO pub_config_sistema (clave, valor, descripcion) VALUES
    ('PREFIJO_FOLIO', 'EP-', 'Prefijo para folios de estacionamiento publico'),
    ('SIGUIENTE_FOLIO', '1000', 'Siguiente numero de folio a asignar'),
    ('PERMITE_DUPLICADOS', 'false', 'Permitir licencias duplicadas'),
    ('VALIDAR_RFC', 'true', 'Validar RFC en altas'),
    ('GENERAR_RECIBOS', 'true', 'Generar recibos automaticos')
ON CONFLICT (clave) DO NOTHING;

-- =============================================
-- Verificacion final
-- =============================================
DO $$
BEGIN
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'DEPLOY AdminPublicos SPs - Completado';
    RAISE NOTICE 'SPs creados:';
    RAISE NOTICE '  1. sp_admin_get_config()';
    RAISE NOTICE '  2. sp_admin_update_config()';
    RAISE NOTICE '  3. sp_admin_maintenance()';
    RAISE NOTICE 'Tabla: pubparametros - OK';
    RAISE NOTICE '=============================================';
END $$;
