-- =====================================================
-- CREACIÓN DE ÍNDICES - comun.dictamenes
-- Componente: dictamenfrm.vue
-- Fecha: 2025-11-05
-- =====================================================
-- Tabla con 17,470 registros SIN índices
-- CRÍTICO para performance de búsquedas
-- =====================================================

-- Índice 1: Búsqueda por propietario (6,938 únicos)
CREATE INDEX IF NOT EXISTS idx_dictamenes_propietario
ON comun.dictamenes USING btree (propietario);

-- Índice 2: Búsqueda por domicilio (1,841 únicos)
CREATE INDEX IF NOT EXISTS idx_dictamenes_domicilio
ON comun.dictamenes USING btree (domicilio);

-- Índice 3: Búsqueda por actividad (3,558 únicos)
CREATE INDEX IF NOT EXISTS idx_dictamenes_actividad
ON comun.dictamenes USING btree (actividad);

-- Índice 4: Ordenamiento por fecha
CREATE INDEX IF NOT EXISTS idx_dictamenes_fecha
ON comun.dictamenes USING btree (fecha DESC NULLS LAST);

-- Índice 5: Filtrado por estado del dictamen
CREATE INDEX IF NOT EXISTS idx_dictamenes_dictamen
ON comun.dictamenes USING btree (dictamen);

-- Índice 6: Foreign key a tabla de giros
CREATE INDEX IF NOT EXISTS idx_dictamenes_id_giro
ON comun.dictamenes USING btree (id_giro);

-- Índice 7: Búsqueda por capturista
CREATE INDEX IF NOT EXISTS idx_dictamenes_capturista
ON comun.dictamenes USING btree (capturista);

-- Índice 8: Compuesto para búsquedas combinadas más frecuentes
-- (propietario + domicilio + actividad)
CREATE INDEX IF NOT EXISTS idx_dictamenes_busqueda_combinada
ON comun.dictamenes USING btree (propietario, domicilio, actividad);

-- Índice 9: Compuesto para filtros de fecha y estado
CREATE INDEX IF NOT EXISTS idx_dictamenes_fecha_estado
ON comun.dictamenes USING btree (fecha DESC NULLS LAST, dictamen);

-- Verificar índices creados
SELECT
    i.relname as index_name,
    string_agg(a.attname, ', ' ORDER BY a.attnum) as columns,
    pg_size_pretty(pg_relation_size(i.oid)) as index_size
FROM pg_class t
JOIN pg_index ix ON t.oid = ix.indrelid
JOIN pg_class i ON i.oid = ix.indexrelid
JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(ix.indkey)
JOIN pg_namespace n ON t.relnamespace = n.oid
WHERE n.nspname = 'comun'
    AND t.relname = 'dictamenes'
GROUP BY i.relname, i.oid
ORDER BY i.relname;
