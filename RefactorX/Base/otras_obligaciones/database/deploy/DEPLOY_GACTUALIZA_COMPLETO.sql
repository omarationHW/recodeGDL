-- ================================================================
-- DEPLOY COMPLETO: GActualiza y RActualiza - Otras Obligaciones
-- Fecha: 2025-11-26
-- Autor: Sistema RefactorX - QA Agent
-- Descripción: Script completo de despliegue para módulos de actualización
-- ================================================================

-- ================================================================
-- TABLA DE AUDITORÍA (si no existe)
-- ================================================================
CREATE TABLE IF NOT EXISTS t_34_auditoria (
    id_auditoria SERIAL PRIMARY KEY,
    id_34_datos INTEGER NOT NULL,
    accion VARCHAR(50) NOT NULL,
    usuario VARCHAR(50) NOT NULL,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    descripcion TEXT,
    FOREIGN KEY (id_34_datos) REFERENCES t_34_datos(id_34_datos) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_t34_auditoria_id_datos ON t_34_auditoria(id_34_datos);
CREATE INDEX IF NOT EXISTS idx_t34_auditoria_fecha ON t_34_auditoria(fecha DESC);

COMMENT ON TABLE t_34_auditoria IS 'Registro de auditoría de cambios en contratos/concesiones de otras obligaciones';

-- ================================================================
-- SP 1: sp_gactualiza_grales_update
-- ================================================================
\i '../generated/sp_gactualiza_grales_update.sql'

-- ================================================================
-- SP 2: sp_gactualiza_sup_update
-- ================================================================
\i '../generated/sp_gactualiza_sup_update.sql'

-- ================================================================
-- SP 3: sp_gactualiza_unidades_update
-- ================================================================
\i '../generated/sp_gactualiza_unidades_update.sql'

-- ================================================================
-- SP 4: sp_gactualiza_oblig_update
-- ================================================================
\i '../generated/sp_gactualiza_oblig_update.sql'

-- ================================================================
-- VERIFICACIÓN DE INSTALACIÓN
-- ================================================================
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Verificar SPs instalados
    SELECT COUNT(*) INTO v_count
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
      AND p.proname IN (
        'sp_gactualiza_grales_update',
        'sp_gactualiza_sup_update',
        'sp_gactualiza_unidades_update',
        'sp_gactualiza_oblig_update'
      );

    IF v_count = 4 THEN
        RAISE NOTICE '✓ DEPLOY EXITOSO: 4/4 stored procedures instalados correctamente';
    ELSE
        RAISE WARNING '⚠ ADVERTENCIA: Solo se instalaron %/4 stored procedures', v_count;
    END IF;

    -- Verificar tabla de auditoría
    SELECT COUNT(*) INTO v_count
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 't_34_auditoria';

    IF v_count = 1 THEN
        RAISE NOTICE '✓ Tabla de auditoría verificada: t_34_auditoria';
    ELSE
        RAISE WARNING '⚠ Tabla de auditoría no encontrada: t_34_auditoria';
    END IF;
END $$;

-- ================================================================
-- RESUMEN DE FUNCIONALIDADES DESPLEGADAS
-- ================================================================
--
-- COMPONENTES AFECTADOS:
-- - GActualiza.vue (Actualización General - Todos los tipos)
-- - RActualiza.vue (Actualización Rubros - Mercados)
--
-- STORED PROCEDURES:
-- 1. sp_gactualiza_grales_update   - Actualiza datos generales
-- 2. sp_gactualiza_sup_update      - Actualiza superficie
-- 3. sp_gactualiza_unidades_update - Actualiza tipo de local/unidades
-- 4. sp_gactualiza_oblig_update    - Actualiza inicio de obligación
--
-- FUNCIONALIDADES:
-- ✓ Búsqueda por control (número-letra para mercados, expediente para otros)
-- ✓ Validación de estado VIGENTE
-- ✓ Actualización de datos generales (concesionario, ubicación, licencia)
-- ✓ Actualización de superficie con fecha de inicio
-- ✓ Actualización de tipo de local/unidades con fecha de inicio
-- ✓ Actualización de inicio de obligación
-- ✓ Registro de auditoría automático
-- ✓ Histórico de cambios en t_34_unidades
-- ✓ Gestión de multas relacionadas (SP ya existentes)
-- ✓ Gestión de suspensiones (SP ya existentes)
--
-- VALIDACIONES IMPLEMENTADAS:
-- ✓ Solo permite actualizar registros VIGENTES
-- ✓ Validación de campos numéricos (superficie > 0)
-- ✓ Validación de rangos (año 2000-2099, mes 1-12)
-- ✓ Verificación de existencia de registro
-- ✓ Manejo de errores con rollback automático
--
-- ================================================================
