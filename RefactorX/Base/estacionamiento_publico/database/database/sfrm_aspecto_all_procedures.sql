-- =============================================================================
-- STORED PROCEDURES: Aspecto del Sistema
-- Base: estacionamiento_publico
-- Esquema: public
-- Formulario: sfrm_aspecto / AspectoPublicos.vue
-- Descripcion: Gestion de temas visuales del sistema
-- =============================================================================

-- -----------------------------------------------------------------------------
-- SP 1/3: sp_get_aspectos
-- Retorna lista de aspectos disponibles con estado activo
-- -----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.sp_get_aspectos();

CREATE OR REPLACE FUNCTION public.sp_get_aspectos()
RETURNS TABLE (
    id integer,
    nombre varchar,
    descripcion varchar,
    color varchar,
    activo boolean
) AS $func$
DECLARE
    v_aspecto_actual varchar;
BEGIN
    -- Obtener aspecto actual de configuracion
    SELECT valor INTO v_aspecto_actual
    FROM public.pub_config_sistema
    WHERE clave = 'ASPECTO_SISTEMA';

    IF v_aspecto_actual IS NULL THEN
        v_aspecto_actual := 'Municipal';
    END IF;

    -- Retornar lista de aspectos disponibles
    RETURN QUERY
    SELECT * FROM (VALUES
        (1, 'Municipal'::varchar, 'Tema oficial municipal naranja'::varchar, '#ea8215'::varchar, (v_aspecto_actual = 'Municipal')),
        (2, 'Clasico'::varchar, 'Tema clasico azul'::varchar, '#0d6efd'::varchar, (v_aspecto_actual = 'Clasico')),
        (3, 'Oscuro'::varchar, 'Tema oscuro moderno'::varchar, '#212529'::varchar, (v_aspecto_actual = 'Oscuro')),
        (4, 'Verde'::varchar, 'Tema verde institucional'::varchar, '#198754'::varchar, (v_aspecto_actual = 'Verde'))
    ) AS t(id, nombre, descripcion, color, activo);
END;
$func$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- SP 2/3: sp_get_current_aspecto
-- Retorna el aspecto actualmente activo
-- -----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.sp_get_current_aspecto();

CREATE OR REPLACE FUNCTION public.sp_get_current_aspecto()
RETURNS TABLE (
    id integer,
    nombre varchar,
    descripcion varchar,
    color varchar
) AS $func$
DECLARE
    v_aspecto varchar;
BEGIN
    SELECT valor INTO v_aspecto
    FROM public.pub_config_sistema
    WHERE clave = 'ASPECTO_SISTEMA';

    IF v_aspecto IS NULL OR v_aspecto = 'Municipal' THEN
        RETURN QUERY SELECT 1, 'Municipal'::varchar, 'Tema oficial municipal naranja'::varchar, '#ea8215'::varchar;
    ELSIF v_aspecto = 'Clasico' THEN
        RETURN QUERY SELECT 2, 'Clasico'::varchar, 'Tema clasico azul'::varchar, '#0d6efd'::varchar;
    ELSIF v_aspecto = 'Oscuro' THEN
        RETURN QUERY SELECT 3, 'Oscuro'::varchar, 'Tema oscuro moderno'::varchar, '#212529'::varchar;
    ELSIF v_aspecto = 'Verde' THEN
        RETURN QUERY SELECT 4, 'Verde'::varchar, 'Tema verde institucional'::varchar, '#198754'::varchar;
    ELSE
        RETURN QUERY SELECT 1, 'Municipal'::varchar, 'Tema oficial municipal naranja'::varchar, '#ea8215'::varchar;
    END IF;
END;
$func$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- SP 3/3: sp_set_aspecto
-- Establece el aspecto activo por ID
-- -----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.sp_set_aspecto(integer);

CREATE OR REPLACE FUNCTION public.sp_set_aspecto(
    p_aspecto_id INTEGER
) RETURNS TABLE(success boolean, message text) AS $func$
DECLARE
    v_nombre varchar;
    v_exists boolean;
BEGIN
    -- Mapear ID a nombre
    v_nombre := CASE p_aspecto_id
        WHEN 1 THEN 'Municipal'
        WHEN 2 THEN 'Clasico'
        WHEN 3 THEN 'Oscuro'
        WHEN 4 THEN 'Verde'
        ELSE NULL
    END;

    IF v_nombre IS NULL THEN
        RETURN QUERY SELECT false::boolean, 'Aspecto no valido';
        RETURN;
    END IF;

    -- Verificar si existe la configuracion
    SELECT EXISTS(SELECT 1 FROM public.pub_config_sistema WHERE clave = 'ASPECTO_SISTEMA') INTO v_exists;

    IF v_exists THEN
        UPDATE public.pub_config_sistema
        SET valor = v_nombre, fecha_mod = CURRENT_TIMESTAMP
        WHERE clave = 'ASPECTO_SISTEMA';
    ELSE
        INSERT INTO public.pub_config_sistema (clave, valor, descripcion, fecha_mod)
        VALUES ('ASPECTO_SISTEMA', v_nombre, 'Aspecto visual del sistema', CURRENT_TIMESTAMP);
    END IF;

    RETURN QUERY SELECT true::boolean, 'Aspecto cambiado a ' || v_nombre || ' correctamente';
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT false::boolean, 'Error: ' || SQLERRM;
END;
$func$ LANGUAGE plpgsql;

-- =============================================================================
-- FIN STORED PROCEDURES
-- =============================================================================
