-- =============================================
-- Stored Procedure: sp_admin_update_config
-- Modulo: estacionamiento_publico
-- Componente: AdminPublicos.vue
-- Descripcion: Actualiza la configuracion del sistema de estacionamientos publicos
-- Fecha: 2025-11-26
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
    -- Actualizar prefijo_folio si se proporciona
    IF p_prefijo_folio IS NOT NULL THEN
        INSERT INTO pub_config_sistema (clave, valor, fecha_mod)
        VALUES ('PREFIJO_FOLIO', p_prefijo_folio, CURRENT_TIMESTAMP)
        ON CONFLICT (clave) DO UPDATE SET valor = p_prefijo_folio, fecha_mod = CURRENT_TIMESTAMP;
    END IF;

    -- Actualizar siguiente_folio si se proporciona
    IF p_siguiente_folio IS NOT NULL THEN
        INSERT INTO pub_config_sistema (clave, valor, fecha_mod)
        VALUES ('SIGUIENTE_FOLIO', p_siguiente_folio::VARCHAR, CURRENT_TIMESTAMP)
        ON CONFLICT (clave) DO UPDATE SET valor = p_siguiente_folio::VARCHAR, fecha_mod = CURRENT_TIMESTAMP;
    END IF;

    -- Actualizar permite_duplicados si se proporciona
    IF p_permite_duplicados IS NOT NULL THEN
        INSERT INTO pub_config_sistema (clave, valor, fecha_mod)
        VALUES ('PERMITE_DUPLICADOS', p_permite_duplicados::VARCHAR, CURRENT_TIMESTAMP)
        ON CONFLICT (clave) DO UPDATE SET valor = p_permite_duplicados::VARCHAR, fecha_mod = CURRENT_TIMESTAMP;
    END IF;

    -- Actualizar validar_rfc si se proporciona
    IF p_validar_rfc IS NOT NULL THEN
        INSERT INTO pub_config_sistema (clave, valor, fecha_mod)
        VALUES ('VALIDAR_RFC', p_validar_rfc::VARCHAR, CURRENT_TIMESTAMP)
        ON CONFLICT (clave) DO UPDATE SET valor = p_validar_rfc::VARCHAR, fecha_mod = CURRENT_TIMESTAMP;
    END IF;

    -- Actualizar generar_recibos si se proporciona
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

-- Comentario de documentacion
COMMENT ON FUNCTION public.sp_admin_update_config(VARCHAR, INTEGER, BOOLEAN, BOOLEAN, BOOLEAN) IS 'Actualiza la configuracion del sistema de estacionamientos publicos para AdminPublicos.vue';
