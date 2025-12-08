-- =============================================
-- Stored Procedure: sp_admin_get_config
-- Modulo: estacionamiento_publico
-- Componente: AdminPublicos.vue
-- Descripcion: Obtiene la configuracion del sistema de estacionamientos publicos
-- Fecha: 2025-11-26
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
    -- Retorna configuracion desde tabla de parametros o valores por defecto
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

-- Comentario de documentacion
COMMENT ON FUNCTION public.sp_admin_get_config() IS 'Obtiene la configuracion del sistema de estacionamientos publicos para AdminPublicos.vue';
