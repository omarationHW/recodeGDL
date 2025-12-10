-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: REP_BON (EXACTO del archivo original)
-- Archivo: 29_SP_CEMENTERIOS_REP_BON_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================
--
-- CORRECCIONES POSTGRESQL - AGENTE CATALIZADOR
-- Fecha: 2025-12-04
-- Total Correcciones: 18
--
-- Correcciones aplicadas:
-- SP 1: sp_rep_bon_listar
-- 1. p_tipo: VARCHAR → VARCHAR(20)
-- 2. doble: VARCHAR → CHAR(1) (2 ocurrencias)
-- 3. cementerio: VARCHAR → CHAR(1) (2 ocurrencias)
-- 4. clase_alfa: VARCHAR → VARCHAR(10)
-- 5. seccion_alfa: VARCHAR → VARCHAR(10)
-- 6. linea_alfa: VARCHAR → VARCHAR(20)
-- 7. fosa_alfa: VARCHAR → VARCHAR(20)
-- 8. importe_bonificar: NUMERIC → NUMERIC(16,2)
-- 9. importe_bonificado: NUMERIC → NUMERIC(16,2) (2 ocurrencias)
-- 10. importe_resto: NUMERIC → NUMERIC(16,2)
-- 11. nombre: VARCHAR → VARCHAR(50)
--
-- SP 2: sp_rep_bon_reporte_bonificaciones
-- 12. nombre: VARCHAR → VARCHAR(60)
-- 13. nombre_usuario: VARCHAR → VARCHAR(50)
-- 14. porcentaje: NUMERIC → NUMERIC(5,2)
-- 15. motivo: TEXT → VARCHAR(255)
-- 16. ubicacion: VARCHAR → VARCHAR(100)
-- ============================================

-- SP 1/1: sp_rep_bon_listar
-- Tipo: Report
-- Descripción: Obtiene la lista de oficios de bonificación de la recaudadora indicada, filtrando por pendientes o todos.
-- --------------------------------------------

-- PostgreSQL stored procedure para reporte de bonificaciones
CREATE OR REPLACE FUNCTION sp_rep_bon_listar(
    p_recaudadora INTEGER,
    p_tipo VARCHAR(20) -- 'pendientes' o 'todos'
)
RETURNS TABLE (
    control_bon INTEGER,
    oficio INTEGER,
    axo SMALLINT,
    doble CHAR(1),
    control_rcm INTEGER,
    cementerio CHAR(1),
    clase SMALLINT,
    clase_alfa VARCHAR(10),
    seccion SMALLINT,
    seccion_alfa VARCHAR(10),
    linea SMALLINT,
    linea_alfa VARCHAR(20),
    fosa SMALLINT,
    fosa_alfa VARCHAR(20),
    fecha_ofic DATE,
    importe_bonificar NUMERIC(16,2),
    importe_bonificado NUMERIC(16,2),
    importe_resto NUMERIC(16,2),
    usuario INTEGER,
    fecha_mov DATE,
    nombre VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.control_bon,
        a.oficio,
        a.axo,
        a.doble,
        a.control_rcm,
        a.cementerio,
        a.clase,
        a.clase_alfa,
        a.seccion,
        a.seccion_alfa,
        a.linea,
        a.linea_alfa,
        a.fosa,
        a.fosa_alfa,
        a.fecha_ofic,
        a.importe_bonificar,
        a.importe_bonificado,
        a.importe_resto,
        a.usuario,
        a.fecha_mov,
        (SELECT nombre FROM public.ta_12_passwords WHERE id_usuario = a.usuario) AS nombre
    FROM public.ta_13_bonifrcm a
    WHERE a.doble = p_recaudadora::CHAR(1)
      AND (
        (p_tipo = 'pendientes' AND a.importe_resto > 0)
        OR (p_tipo = 'todos')
      )
    ORDER BY a.oficio DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_rep_bon_info_recaudadora
-- Tipo: Query
-- Descripción: Obtiene información de la recaudadora (Qryrec del Pascal)
-- Query Pascal: SELECT recing, upper(nomre) nomre, titulo FROM TA_12_nombrerec WHERE recing=:rec
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rep_bon_info_recaudadora(
    p_rec SMALLINT
)
RETURNS TABLE (
    recing SMALLINT,
    nomre VARCHAR(60),
    titulo VARCHAR(25)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        n.recing,
        UPPER(n.nomre)::VARCHAR(60) AS nomre,
        n.titulo
    FROM public.ta_12_nombrerec n
    WHERE n.recing = p_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_rep_bon_reporte_bonificaciones
-- Tipo: Report
-- Descripción: Genera reporte de bonificaciones por rango de fechas y cementerio opcional, NO UTILIZADO EN EL PASCAL
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rep_bon_reporte_bonificaciones(
    p_fecha_inicio DATE,
    p_fecha_fin DATE,
    p_cementerio CHAR(1) DEFAULT NULL
)
RETURNS TABLE (
    id_bonificacion INTEGER,
    control_rcm INTEGER,
    nombre VARCHAR(60),
    cementerio CHAR(1),
    ubicacion VARCHAR(100),
    fecha_aplicacion DATE,
    porcentaje NUMERIC(5,2),
    importe_bonificado NUMERIC(16,2),
    motivo VARCHAR(255),
    usuario INTEGER,
    nombre_usuario VARCHAR(50),
    oficio INTEGER,
    axo SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.control_bon AS id_bonificacion,
        b.control_rcm,
        d.nombre,
        b.cementerio,
        CONCAT(
            'Cl:', b.clase, COALESCE(b.clase_alfa, ''),
            ' Sec:', b.seccion, COALESCE(b.seccion_alfa, ''),
            ' Lin:', b.linea, COALESCE(b.linea_alfa, ''),
            ' Fosa:', b.fosa, COALESCE(b.fosa_alfa, '')
        ) AS ubicacion,
        b.fecha_ofic AS fecha_aplicacion,
        CASE
            WHEN b.importe_bonificar > 0 THEN
                ROUND((b.importe_bonificado / b.importe_bonificar) * 100, 2)
            ELSE 0
        END AS porcentaje,
        b.importe_bonificado,
        CONCAT('Oficio: ', b.oficio, '/', b.axo) AS motivo,
        b.usuario,
        p.nombre AS nombre_usuario,
        b.oficio,
        b.axo
    FROM cementerio.ta_13_bonifrcm b
    LEFT JOIN comun.ta_13_datosrcm d ON b.control_rcm = d.control_rcm
    LEFT JOIN padron_licencias.comun.ta_12_passwords p ON b.usuario = p.id_usuario
    WHERE b.fecha_ofic BETWEEN p_fecha_inicio AND p_fecha_fin
      AND (p_cementerio IS NULL OR b.cementerio = p_cementerio)
      AND b.importe_bonificado > 0
    ORDER BY b.fecha_ofic DESC, b.oficio DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

