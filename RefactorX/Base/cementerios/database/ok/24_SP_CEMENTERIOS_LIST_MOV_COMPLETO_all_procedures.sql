-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public (cementerio)
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: List_Mov (Listado de Movimientos)
-- Archivo: 24_SP_CEMENTERIOS_LIST_MOV_COMPLETO_all_procedures.sql
-- Generado: 2025-11-30
-- Total SPs: 2
-- ============================================
--
-- CORRECCIONES POSTGRESQL - AGENTE CATALIZADOR
-- Fecha: 2025-12-04
-- Total Correcciones: 15
--
-- Correcciones aplicadas:
-- 1. cementerio: VARCHAR(2) → CHAR(1) (3 ocurrencias)
-- 2. nombre: VARCHAR(255) → VARCHAR(60) (2 ocurrencias)
-- 3. domicilio: VARCHAR(255) → VARCHAR(60) (2 ocurrencias)
-- 4. linea_alfa: VARCHAR(10) → VARCHAR(20) (2 ocurrencias)
-- 5. fosa_alfa: VARCHAR(10) → VARCHAR(20) (2 ocurrencias)
-- 6. exterior: VARCHAR(20) → CHAR(6)
-- 7. interior: VARCHAR(20) → CHAR(6)
-- 8. colonia: VARCHAR(100) → VARCHAR(30)
-- 9. observaciones: TEXT → VARCHAR(60)
-- 10. nombre_usuario: VARCHAR(255) → VARCHAR(50)
-- 11. tipo: VARCHAR(1) → CHAR(1)
-- ============================================

-- =============================================
-- SP 1/2: sp_listmov_listar_cementerios
-- Descripción: Lista catálogo de cementerios para filtro
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_listmov_listar_cementerios()
RETURNS TABLE(
    cementerio CHAR(1),
    nombre VARCHAR(60),
    domicilio VARCHAR(60)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.cementerio,
        c.nombre,
        c.domicilio
    FROM padron_licencias.comun.tc_13_cementerios c
    ORDER BY c.cementerio;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.sp_listmov_listar_cementerios IS 'Lista catálogo de cementerios para filtro de búsqueda';

-- =============================================
-- SP 2/2: sp_listmov_buscar_movimientos
-- Descripción: Lista movimientos de folios por rango de fechas y cementerio
-- =============================================


CREATE OR REPLACE FUNCTION public.sp_listmov_buscar_movimientos(
    p_fecha_inicio DATE,
    p_fecha_fin DATE,
    p_cementerio CHAR(1) DEFAULT NULL
)
RETURNS TABLE(
    control_rcm INTEGER,
    cementerio CHAR(1),
    nombre_cementerio VARCHAR(60),
    clase SMALLINT,
    clase_alfa VARCHAR(10),
    seccion SMALLINT,
    seccion_alfa VARCHAR(10),
    linea SMALLINT,
    linea_alfa VARCHAR(20),
    fosa SMALLINT,
    fosa_alfa VARCHAR(20),
    nombre VARCHAR(60),
    domicilio VARCHAR(60),
    exterior CHAR(6),
    interior CHAR(6),
    colonia VARCHAR(30),
    axo_pagado INTEGER,
    metros NUMERIC(10,2),
    tipo CHAR(1),
    observaciones VARCHAR(60),
    usuario INTEGER,
   -- nombre_usuario VARCHAR(50),
    fecha_mov DATE,
    ubicacion VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.control_rcm,
        a.cementerio,
        COALESCE(c.nombre, a.cementerio) as nombre_cementerio,
        a.clase,
        a.clase_alfa,
        a.seccion,
        a.seccion_alfa,
        a.linea,
        a.linea_alfa,
        a.fosa,
        a.fosa_alfa,
        a.nombre,
        a.domicilio,
        a.exterior,
        a.interior,
        a.colonia,
        a.axo_pagado,
        a.metros,
        a.tipo,
        a.observaciones,
        a.usuario,
       -- COALESCE(b.nombre, 'Sistema') as nombre_usuario,
        a.fecha_mov,
		 CONCAT_WS('-',
            a.clase_alfa,
            a.seccion_alfa,
            a.linea_alfa,
            a.fosa_alfa
        )::varchar(100) AS ubicacion

    FROM public.ta_13_datosrcm a
    --LEFT JOIN padron_licencias.comun.ta_12_passwords b
      --  ON a.usuario = b.id_usuario
    LEFT JOIN public.tc_13_cementerios c
        ON a.cementerio = c.cementerio
    WHERE a.fecha_mov BETWEEN p_fecha_inicio AND p_fecha_fin
      AND (p_cementerio IS NULL OR a.cementerio = p_cementerio)
    ORDER BY a.fecha_mov DESC, a.control_rcm;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.sp_listmov_buscar_movimientos IS 'Lista movimientos de folios por rango de fechas y cementerio opcional';

-- ============================================
-- FIN DE STORED PROCEDURES - LIST_MOV
-- ============================================
