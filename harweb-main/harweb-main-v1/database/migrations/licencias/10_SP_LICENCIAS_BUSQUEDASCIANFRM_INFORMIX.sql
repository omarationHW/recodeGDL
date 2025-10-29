-- ============================================
-- STORED PROCEDURES MIGRADOS - INFORMIX
-- Formulario: BUSQUEDASCIANFRM
-- Archivo: 10_SP_LICENCIAS_BUSQUEDASCIANFRM_INFORMIX.sql
-- Migración desde PostgreSQL a INFORMIX
-- Fecha: 2025-09-23
-- Total SPs: 1
-- ============================================

-- SP 1/1: catalogo_scian_busqueda
-- Tipo: Catalog
-- Descripción: Devuelve los registros de c_scian vigentes filtrados por descripción o código_scian. Si el parámetro es vacío, devuelve todos los vigentes.
-- Parámetros entrada: p_descripcion (LVARCHAR)
-- Parámetros salida: codigo_scian, descripcion, vigente, es_microgenerador, microgenerador_a, microgenerador_b, microgenerador_c, microgenerador_d, fecha_alta, usuario_alta, fecha_baja, usuario_baja, tipo
-- --------------------------------------------

CREATE PROCEDURE catalogo_scian_busqueda(p_descripcion LVARCHAR(255))
RETURNING INTEGER AS codigo_scian,
          LVARCHAR(200) AS descripcion,
          CHAR(1) AS vigente,
          CHAR(1) AS es_microgenerador,
          CHAR(1) AS microgenerador_a,
          CHAR(1) AS microgenerador_b,
          CHAR(1) AS microgenerador_c,
          CHAR(1) AS microgenerador_d,
          DATETIME YEAR TO SECOND AS fecha_alta,
          LVARCHAR(50) AS usuario_alta,
          DATETIME YEAR TO SECOND AS fecha_baja,
          LVARCHAR(50) AS usuario_baja,
          CHAR(1) AS tipo;

    RETURN
        codigo_scian,
        descripcion,
        vigente,
        es_microgenerador,
        microgenerador_a,
        microgenerador_b,
        microgenerador_c,
        microgenerador_d,
        fecha_alta,
        usuario_alta,
        fecha_baja,
        usuario_baja,
        tipo
    FROM c_scian
    WHERE vigente = 'V'
      AND (
        p_descripcion IS NULL OR
        p_descripcion = '' OR
        UPPER(descripcion) LIKE '%' || UPPER(p_descripcion) || '%' OR
        codigo_scian::LVARCHAR LIKE '%' || p_descripcion || '%'
      )
    ORDER BY descripcion ASC;

END PROCEDURE;