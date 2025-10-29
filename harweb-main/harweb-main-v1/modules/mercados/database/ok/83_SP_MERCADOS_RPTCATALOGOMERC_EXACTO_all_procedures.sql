-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptCatalogoMerc
-- Generado: 2025-08-27 00:48:02
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_get_catalogo_mercados
-- Tipo: Catalog
-- Descripción: Obtiene el listado de mercados municipales con zona y public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_catalogo_mercados()
RETURNS TABLE (
    oficina SMALLINT,
    num_mercado_nvo SMALLINT,
    categoria SMALLINT,
    descripcion VARCHAR,
    cuenta_ingreso INTEGER,
    cuenta_energia INTEGER,
    id_zona SMALLINT,
    zona VARCHAR,
    tipo_emision VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.oficina, a.num_mercado_nvo, a.categoria, a.descripcion, a.cuenta_ingreso, a.cuenta_energia, a.id_zona, b.zona, a.tipo_emision
    FROM public.ta_11_mercados a
    JOIN public.ta_12_zonas b ON a.id_zona = b.id_zona
    WHERE a.num_mercado_nvo < 99
    ORDER BY a.oficina ASC, a.num_mercado_nvo ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_create_catalogo_mercado
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro en el catálogo de public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_create_catalogo_mercado(
    p_oficina SMALLINT,
    p_num_mercado_nvo SMALLINT,
    p_categoria SMALLINT,
    p_descripcion VARCHAR,
    p_cuenta_ingreso INTEGER,
    p_cuenta_energia INTEGER,
    p_id_zona SMALLINT,
    p_tipo_emision VARCHAR,
    p_usuario_id INTEGER
) RETURNS VOID AS $$
BEGIN
    INSERT INTO public.ta_11_mercados (
        oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision, id_usuario, fecha_alta
    ) VALUES (
        p_oficina, p_num_mercado_nvo, p_categoria, UPPER(p_descripcion), p_cuenta_ingreso, p_cuenta_energia, p_id_zona, p_tipo_emision, p_usuario_id, NOW()
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_update_catalogo_mercado
-- Tipo: CRUD
-- Descripción: Actualiza un registro existente en el catálogo de public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_catalogo_mercado(
    p_oficina SMALLINT,
    p_num_mercado_nvo SMALLINT,
    p_categoria SMALLINT,
    p_descripcion VARCHAR,
    p_cuenta_ingreso INTEGER,
    p_cuenta_energia INTEGER,
    p_id_zona SMALLINT,
    p_tipo_emision VARCHAR,
    p_usuario_id INTEGER
) RETURNS VOID AS $$
BEGIN
    UPDATE public.ta_11_mercados SET
        categoria = p_categoria,
        descripcion = UPPER(p_descripcion),
        cuenta_ingreso = p_cuenta_ingreso,
        cuenta_energia = p_cuenta_energia,
        id_zona = p_id_zona,
        tipo_emision = p_tipo_emision,
        id_usuario = p_usuario_id,
        fecha_modificacion = NOW()
    WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_delete_catalogo_mercado
-- Tipo: CRUD
-- Descripción: Elimina un registro del catálogo de public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_delete_catalogo_mercado(
    p_oficina SMALLINT,
    p_num_mercado_nvo SMALLINT
) RETURNS VOID AS $$
BEGIN
    DELETE FROM public.ta_11_mercados WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_reporte_catalogo_mercados
-- Tipo: Report
-- Descripción: Genera el reporte PDF del catálogo de mercados y retorna la URL del archivo generado.
-- --------------------------------------------

-- Este SP asume integración con una función de generación de PDF y almacenamiento en disco
CREATE OR REPLACE FUNCTION sp_reporte_catalogo_mercados()
RETURNS TABLE(pdf_url TEXT) AS $$
DECLARE
    v_pdf_url TEXT;
BEGIN
    -- Aquí se debe integrar con la lógica de generación de PDF (por ejemplo, llamando a una función de extensión)
    -- Para ejemplo, se retorna una URL dummy
    v_pdf_url := '/storage/reportes/catalogo_public.pdf';
    RETURN QUERY SELECT v_pdf_url;
END;
$$ LANGUAGE plpgsql;

-- ============================================

