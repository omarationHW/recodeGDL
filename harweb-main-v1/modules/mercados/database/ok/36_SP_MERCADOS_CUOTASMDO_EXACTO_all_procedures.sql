-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CuotasMdo
-- Generado: 2025-08-26 23:34:39
-- Total SPs: 7
-- ============================================

-- SP 1/7: sp_cuotasmdo_list
-- Tipo: Catalog
-- Descripción: Lista todas las cuotas de mercados para un año dado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cuotasmdo_list(p_axo INTEGER)
RETURNS TABLE (
    id_cuotas INTEGER,
    axo INTEGER,
    categoria INTEGER,
    seccion VARCHAR(10),
    clave_cuota INTEGER,
    importe_cuota NUMERIC(12,2),
    fecha_alta TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR(50),
    descripcion VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_cuotas, a.axo, a.categoria, a.seccion, a.clave_cuota, a.importe_cuota, a.fecha_alta, a.id_usuario, b.usuario, c.descripcion
    FROM public.ta_11_cuo_locales a
    JOIN public.ta_12_passwords b ON a.id_usuario = b.id_usuario
    JOIN public.ta_11_cve_cuota c ON a.clave_cuota = c.clave_cuota
    WHERE a.axo >= p_axo
    ORDER BY a.axo DESC, a.categoria DESC, a.seccion DESC, a.clave_cuota DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/7: sp_cuotasmdo_create
-- Tipo: CRUD
-- Descripción: Crea una nueva cuota de mercado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cuotasmdo_create(
    p_axo INTEGER,
    p_categoria INTEGER,
    p_seccion VARCHAR(10),
    p_clave_cuota INTEGER,
    p_importe_cuota NUMERIC(12,2),
    p_id_usuario INTEGER
) RETURNS TABLE (id_cuotas INTEGER) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO public.ta_11_cuo_locales(axo, categoria, seccion, clave_cuota, importe_cuota, fecha_alta, id_usuario)
    VALUES (p_axo, p_categoria, p_seccion, p_clave_cuota, p_importe_cuota, NOW(), p_id_usuario)
    RETURNING id_cuotas INTO new_id;
    RETURN QUERY SELECT new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/7: sp_cuotasmdo_update
-- Tipo: CRUD
-- Descripción: Actualiza una cuota de mercado existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cuotasmdo_update(
    p_id_cuotas INTEGER,
    p_axo INTEGER,
    p_categoria INTEGER,
    p_seccion VARCHAR(10),
    p_clave_cuota INTEGER,
    p_importe_cuota NUMERIC(12,2),
    p_id_usuario INTEGER
) RETURNS VOID AS $$
BEGIN
    UPDATE public.ta_11_cuo_locales
    SET axo = p_axo,
        categoria = p_categoria,
        seccion = p_seccion,
        clave_cuota = p_clave_cuota,
        importe_cuota = p_importe_cuota,
        fecha_alta = NOW(),
        id_usuario = p_id_usuario
    WHERE id_cuotas = p_id_cuotas;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/7: sp_cuotasmdo_delete
-- Tipo: CRUD
-- Descripción: Elimina una cuota de mercado por ID
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cuotasmdo_delete(p_id_cuotas INTEGER)
RETURNS VOID AS $$
BEGIN
    DELETE FROM public.ta_11_cuo_locales WHERE id_cuotas = p_id_cuotas;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/7: sp_categorias_list
-- Tipo: Catalog
-- Descripción: Lista todas las categorías de mercado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_categorias_list()
RETURNS TABLE (categoria INTEGER, descripcion VARCHAR(100)) AS $$
BEGIN
    RETURN QUERY SELECT categoria, descripcion FROM public.ta_11_categoria ORDER BY categoria;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/7: sp_secciones_list
-- Tipo: Catalog
-- Descripción: Lista todas las secciones de mercado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_secciones_list()
RETURNS TABLE (seccion VARCHAR(10), descripcion VARCHAR(100)) AS $$
BEGIN
    RETURN QUERY SELECT seccion, descripcion FROM public.ta_11_secciones ORDER BY seccion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/7: sp_clavescuota_list
-- Tipo: Catalog
-- Descripción: Lista todas las claves de cuota
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_clavescuota_list()
RETURNS TABLE (clave_cuota INTEGER, descripcion VARCHAR(100)) AS $$
BEGIN
    RETURN QUERY SELECT clave_cuota, descripcion FROM public.ta_11_cve_cuota ORDER BY clave_cuota;
END;
$$ LANGUAGE plpgsql;

-- ============================================

