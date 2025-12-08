-- Stored Procedure: sp_cem_reporte_bonificaciones
-- Migrado de padron_licencias.comun a cementerio.public
-- Fecha: 2025-11-26

CREATE OR REPLACE FUNCTION public.sp_cem_reporte_bonificaciones(
    p_fecha_inicio date,
    p_fecha_fin date,
    p_cementerio character varying DEFAULT NULL::character varying
)
RETURNS TABLE(
    id_bonificacion integer,
    fecha_aplicacion date,
    control_rcm character varying,
    nombre character varying,
    cementerio character varying,
    porcentaje numeric,
    importe_bonificado numeric,
    usuario character varying,
    nombre_usuario character varying,
    motivo text
)
LANGUAGE plpgsql
AS $function$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'bonificaciones' AND table_schema = 'public') THEN
        RETURN QUERY
        SELECT
            b.id_bonificacion::INTEGER,
            b.fecha_aplicacion::DATE,
            b.control_rcm::VARCHAR,
            d.nombre::VARCHAR,
            d.cementerio::VARCHAR,
            COALESCE(b.porcentaje, 0)::DECIMAL,
            COALESCE(b.importe_bonificado, 0)::DECIMAL,
            b.usuario::VARCHAR,
            COALESCE(u.nombre, b.usuario)::VARCHAR as nombre_usuario,
            COALESCE(b.motivo, '')::TEXT
        FROM bonificaciones b
        LEFT JOIN datosrcm d ON b.control_rcm::INTEGER = d.control_rcm
        LEFT JOIN public.usuarios u ON b.usuario = u.usuario
        WHERE b.fecha_aplicacion BETWEEN p_fecha_inicio AND p_fecha_fin
          AND (p_cementerio IS NULL OR d.cementerio = p_cementerio)
        ORDER BY b.fecha_aplicacion DESC;
    END IF;
END;
$function$;
