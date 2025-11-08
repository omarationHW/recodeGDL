-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Rep_Bon
-- Generado: 2025-08-27 14:50:08
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_rep_bon_listar
-- Tipo: Report
-- Descripción: Obtiene la lista de oficios de bonificación de la recaudadora indicada, filtrando por pendientes o todos.
-- --------------------------------------------

-- PostgreSQL stored procedure para reporte de bonificaciones
CREATE OR REPLACE FUNCTION sp_rep_bon_listar(
    p_recaudadora INTEGER,
    p_tipo VARCHAR -- 'pendientes' o 'todos'
)
RETURNS TABLE (
    control_bon INTEGER,
    oficio INTEGER,
    axo SMALLINT,
    doble VARCHAR,
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase SMALLINT,
    clase_alfa VARCHAR,
    seccion SMALLINT,
    seccion_alfa VARCHAR,
    linea SMALLINT,
    linea_alfa VARCHAR,
    fosa SMALLINT,
    fosa_alfa VARCHAR,
    fecha_ofic DATE,
    importe_bonificar NUMERIC,
    importe_bonificado NUMERIC,
    importe_resto NUMERIC,
    usuario INTEGER,
    fecha_mov DATE,
    nombre VARCHAR
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
        (SELECT nombre FROM ta_12_passwords WHERE id_usuario = a.usuario) AS nombre
    FROM ta_13_bonifrcm a
    WHERE a.doble = p_recaudadora::VARCHAR
      AND (
        (p_tipo = 'pendientes' AND a.importe_resto > 0)
        OR (p_tipo = 'todos')
      )
    ORDER BY a.oficio DESC;
END;
$$ LANGUAGE plpgsql;


-- ============================================

