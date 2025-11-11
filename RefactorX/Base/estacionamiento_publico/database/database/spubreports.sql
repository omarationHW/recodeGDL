-- =============================================
-- Stored Procedure: spubreports
-- Descripción: Wrapper/alias para spubreports_list
-- Uso: PagosPublicos.vue (línea 56), ReportesPublicos.vue (línea 100)
-- Nota: Este SP es un wrapper que llama a spubreports_list con opción por defecto
-- =============================================

CREATE OR REPLACE FUNCTION public.spubreports(
    p_opc INTEGER DEFAULT 1
)
RETURNS TABLE (
    id INTEGER,
    pubcategoria_id INTEGER,
    categoria VARCHAR(10),
    descripcion VARCHAR(100),
    numesta INTEGER,
    sector VARCHAR(10),
    nomsector VARCHAR(20),
    zona INTEGER,
    subzona INTEGER,
    numlicencia INTEGER,
    axolicencias INTEGER,
    cvecuenta INTEGER,
    nombre VARCHAR(100),
    calle VARCHAR(100),
    numext VARCHAR(10),
    telefono VARCHAR(20),
    cupo INTEGER,
    fecha_at DATE,
    fecha_inicial DATE,
    fecha_vencimiento DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Simplemente redirige la llamada a spubreports_list
    -- Si no se proporciona opción, usa 1 (ordenar por categoría)
    RETURN QUERY SELECT * FROM spubreports_list(COALESCE(p_opc, 1));
END;
$$;

-- Comentarios y metadatos
COMMENT ON FUNCTION public.spubreports(INTEGER) IS
'SP wrapper que redirige a spubreports_list.
Proporciona compatibilidad con componentes que llaman a spubreports sin parámetros.
Opciones:
  1 = Por categoría
  2 = Por sector
  3 = Por número
  4 = Por nombre
  5 = Por calle
  7 = Por zona/subzona
Usado por: PagosPublicos.vue, ReportesPublicos.vue';
