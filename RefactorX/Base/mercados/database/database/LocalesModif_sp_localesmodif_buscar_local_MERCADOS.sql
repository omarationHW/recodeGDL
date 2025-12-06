-- Stored Procedure: sp_localesmodif_buscar_local
-- Tipo: CRUD
-- Descripción: Busca un local por criterios únicos (oficina, mercado, categoria, seccion, local, letra, bloque)
-- Formulario: LocalesModif / Prescripcion
-- Base de datos: mercados
-- Fecha corrección: 2025-12-05

CREATE OR REPLACE FUNCTION sp_localesmodif_buscar_local(
    p_oficina INTEGER,
    p_num_mercado INTEGER,
    p_categoria INTEGER,
    p_seccion VARCHAR,
    p_local INTEGER,
    p_letra_local VARCHAR DEFAULT NULL,
    p_bloque VARCHAR DEFAULT NULL
) RETURNS TABLE (
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR,
    local INTEGER,
    letra_local VARCHAR,
    bloque VARCHAR,
    nombre VARCHAR,
    domicilio VARCHAR,
    sector VARCHAR,
    zona SMALLINT,
    descripcion_local VARCHAR,
    superficie NUMERIC,
    giro SMALLINT,
    fecha_alta DATE,
    fecha_baja DATE,
    vigencia VARCHAR,
    clave_cuota SMALLINT,
    bloqueo SMALLINT,
    id_usuario INTEGER,
    -- Campos adicionales para prescripción de energía
    id_energia INTEGER,
    arrendatario VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_local,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion::VARCHAR,
        l.local,
        l.letra_local::VARCHAR,
        l.bloque::VARCHAR,
        l.nombre::VARCHAR,
        COALESCE(l.domicilio, '')::VARCHAR AS domicilio,
        COALESCE(l.sector, '')::VARCHAR AS sector,
        l.zona,
        COALESCE(l.descripcion_local, '')::VARCHAR AS descripcion_local,
        l.superficie,
        l.giro,
        l.fecha_alta,
        l.fecha_baja,
        l.vigencia::VARCHAR,
        l.clave_cuota,
        l.bloqueo,
        l.id_usuario,
        -- Campos adicionales (de ta_11_energia)
        e.id_energia,
        COALESCE(l.arrendatario, '')::VARCHAR AS arrendatario
    FROM publico.ta_11_locales l
    LEFT JOIN public.ta_11_energia e ON l.id_local = e.id_local
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_num_mercado
      AND l.categoria = p_categoria
      AND l.seccion::VARCHAR = p_seccion
      AND l.local = p_local
      AND (p_letra_local IS NULL OR l.letra_local::VARCHAR = p_letra_local OR (l.letra_local IS NULL AND p_letra_local = ''))
      AND (p_bloque IS NULL OR l.bloque::VARCHAR = p_bloque OR (l.bloque IS NULL AND p_bloque = ''))
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Comentarios:
-- 1. Adaptado para la base de datos 'mercados'
-- 2. Usa tabla 'publico.ta_11_locales' (esquema 'publico' en base mercados)
-- 3. LEFT JOIN con 'public.ta_11_energia' para obtener id_energia
-- 4. Los parámetros p_letra_local y p_bloque son opcionales (DEFAULT NULL)
-- 5. Se agregaron campos id_energia y arrendatario para prescripción
-- 6. Todos los campos CHAR se convierten a VARCHAR para compatibilidad
-- 7. Manejo de valores NULL con COALESCE
