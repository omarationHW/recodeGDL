-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sfrm_aspecto
-- Generado: 2025-08-27 14:09:01
-- Total SPs: 3
-- ============================================

-- SP 1/3: get_aspectos
-- Tipo: Catalog
-- Descripción: Devuelve la lista de aspectos visuales disponibles.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_aspectos()
RETURNS TABLE(nombre TEXT) AS $$
BEGIN
    -- Simulación: en producción, leer de tabla o directorio
    RETURN QUERY SELECT unnest(ARRAY['Directorio de Aspectos...', 'SkinBlue', 'SkinDark', 'SkinClassic']) AS nombre;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: set_aspecto
-- Tipo: CRUD
-- Descripción: Establece el aspecto visual actual para el usuario/sistema.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION set_aspecto(p_nombre TEXT)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    -- Aquí se podría guardar en una tabla de configuración por usuario
    -- Para demo, solo simula éxito
    -- UPDATE configuracion SET aspecto = p_nombre WHERE usuario_id = current_user_id;
    RETURN QUERY SELECT TRUE, 'Aspecto cambiado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: get_current_aspecto
-- Tipo: Catalog
-- Descripción: Devuelve el aspecto visual actualmente seleccionado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_current_aspecto()
RETURNS TABLE(nombre TEXT) AS $$
BEGIN
    -- Simulación: en producción, leer de tabla de configuración
    RETURN QUERY SELECT 'SkinBlue'::TEXT AS nombre;
END;
$$ LANGUAGE plpgsql;

-- ============================================

