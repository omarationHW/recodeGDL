<?php
// Crear tabla y SPs para observaciones de trámites/licencias

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CREAR TABLA Y SPs PARA OBSERVACIONES DE TRÁMITES ===\n\n";

    // 1. Crear tabla
    echo "1️⃣  Creando tabla comun.ta_observaciones_tramites...\n";
    $db->exec("
        CREATE TABLE IF NOT EXISTS comun.ta_observaciones_tramites (
            id_observacion SERIAL PRIMARY KEY,
            num_tramite INTEGER NOT NULL,
            tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('TRAMITE', 'LICENCIA', 'GENERAL')),
            observacion TEXT NOT NULL,
            usuario VARCHAR(50) NOT NULL DEFAULT 'sistema',
            fecha_captura TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
            fecha_modificacion TIMESTAMP WITHOUT TIME ZONE
        )
    ");
    echo "✅ Tabla comun.ta_observaciones_tramites creada\n\n";

    // 2. Crear índices
    echo "2️⃣  Creando índices...\n";
    $db->exec("
        CREATE INDEX IF NOT EXISTS idx_observaciones_tramites_num_tramite
        ON comun.ta_observaciones_tramites(num_tramite)
    ");
    $db->exec("
        CREATE INDEX IF NOT EXISTS idx_observaciones_tramites_tipo
        ON comun.ta_observaciones_tramites(tipo)
    ");
    $db->exec("
        CREATE INDEX IF NOT EXISTS idx_observaciones_tramites_fecha
        ON comun.ta_observaciones_tramites(fecha_captura DESC)
    ");
    echo "✅ Índices creados\n\n";

    // 3. SP_GET_OBSERVACIONES - Obtener observaciones por trámite
    echo "3️⃣  Creando sp_observaciones_get_by_tramite...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_observaciones_get_by_tramite(
            p_num_tramite INTEGER,
            p_tipo VARCHAR DEFAULT NULL
        )
        RETURNS TABLE (
            id INTEGER,
            num_tramite INTEGER,
            tipo VARCHAR,
            observacion TEXT,
            usuario VARCHAR,
            fecha TIMESTAMP
        ) AS $$
        BEGIN
            RETURN QUERY
            SELECT
                o.id_observacion as id,
                o.num_tramite,
                o.tipo,
                o.observacion,
                o.usuario,
                o.fecha_captura as fecha
            FROM comun.ta_observaciones_tramites o
            WHERE o.num_tramite = p_num_tramite
              AND (p_tipo IS NULL OR o.tipo = p_tipo)
            ORDER BY o.fecha_captura DESC;
        END;
        $$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_observaciones_get_by_tramite creado\n\n";

    // 4. SP_SAVE_OBSERVACION - Crear nueva observación
    echo "4️⃣  Creando sp_observaciones_create...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_observaciones_create(
            p_num_tramite INTEGER,
            p_tipo VARCHAR,
            p_observacion TEXT,
            p_usuario VARCHAR DEFAULT 'sistema'
        )
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR,
            id_observacion INTEGER
        ) AS $$
        DECLARE
            v_id_observacion INTEGER;
        BEGIN
            -- Validaciones
            IF p_num_tramite IS NULL OR p_num_tramite <= 0 THEN
                RETURN QUERY SELECT FALSE, 'Número de trámite inválido'::VARCHAR, NULL::INTEGER;
                RETURN;
            END IF;

            IF p_tipo NOT IN ('TRAMITE', 'LICENCIA', 'GENERAL') THEN
                RETURN QUERY SELECT FALSE, 'Tipo inválido'::VARCHAR, NULL::INTEGER;
                RETURN;
            END IF;

            IF p_observacion IS NULL OR TRIM(p_observacion) = '' THEN
                RETURN QUERY SELECT FALSE, 'La observación no puede estar vacía'::VARCHAR, NULL::INTEGER;
                RETURN;
            END IF;

            -- Insertar
            INSERT INTO comun.ta_observaciones_tramites (
                num_tramite, tipo, observacion, usuario, fecha_captura
            ) VALUES (
                p_num_tramite, p_tipo, TRIM(p_observacion), p_usuario, CURRENT_TIMESTAMP
            )
            RETURNING id_observacion INTO v_id_observacion;

            RETURN QUERY SELECT TRUE, 'Observación guardada exitosamente'::VARCHAR, v_id_observacion;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY SELECT FALSE, ('Error al guardar: ' || SQLERRM)::VARCHAR, NULL::INTEGER;
        END;
        $$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_observaciones_create creado\n\n";

    // 5. SP_UPDATE_OBSERVACION - Actualizar observación existente
    echo "5️⃣  Creando sp_observaciones_update...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_observaciones_update(
            p_id INTEGER,
            p_tipo VARCHAR,
            p_observacion TEXT
        )
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR
        ) AS $$
        BEGIN
            -- Validaciones
            IF NOT EXISTS (SELECT 1 FROM comun.ta_observaciones_tramites WHERE id_observacion = p_id) THEN
                RETURN QUERY SELECT FALSE, 'Observación no encontrada'::VARCHAR;
                RETURN;
            END IF;

            IF p_tipo NOT IN ('TRAMITE', 'LICENCIA', 'GENERAL') THEN
                RETURN QUERY SELECT FALSE, 'Tipo inválido'::VARCHAR;
                RETURN;
            END IF;

            IF p_observacion IS NULL OR TRIM(p_observacion) = '' THEN
                RETURN QUERY SELECT FALSE, 'La observación no puede estar vacía'::VARCHAR;
                RETURN;
            END IF;

            -- Actualizar
            UPDATE comun.ta_observaciones_tramites
            SET
                tipo = p_tipo,
                observacion = TRIM(p_observacion),
                fecha_modificacion = CURRENT_TIMESTAMP
            WHERE id_observacion = p_id;

            RETURN QUERY SELECT TRUE, 'Observación actualizada exitosamente'::VARCHAR;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY SELECT FALSE, ('Error al actualizar: ' || SQLERRM)::VARCHAR;
        END;
        $$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_observaciones_update creado\n\n";

    // 6. Insertar datos de prueba
    echo "6️⃣  Insertando datos de prueba...\n";
    $db->exec("
        INSERT INTO comun.ta_observaciones_tramites (num_tramite, tipo, observacion, usuario)
        VALUES
            (12345, 'TRAMITE', 'Falta documentación de identificación oficial', 'admin'),
            (12345, 'TRAMITE', 'Se completó la documentación requerida', 'recepcion'),
            (67890, 'LICENCIA', 'Licencia aprobada sin observaciones', 'supervisor'),
            (67890, 'LICENCIA', 'Se realizó inspección física del establecimiento', 'inspector'),
            (11111, 'GENERAL', 'El contribuyente solicita cambio de domicilio', 'admin')
        ON CONFLICT DO NOTHING
    ");
    echo "✅ 5 registros de prueba insertados\n\n";

    // 7. Probar SPs
    echo "🧪 Probando sp_observaciones_get_by_tramite:\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $db->query("SELECT * FROM comun.sp_observaciones_get_by_tramite(12345, NULL)");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "✅ SP ejecutado correctamente\n";
    echo "📊 Observaciones del trámite 12345:\n";
    foreach ($results as $i => $row) {
        echo ($i + 1) . ". ID: {$row['id']} - {$row['tipo']} - " . substr($row['observacion'], 0, 50) . "...\n";
    }
    echo str_repeat("-", 80) . "\n\n";

    echo "✅ TODOS LOS OBJETOS CREADOS EXITOSAMENTE\n";
    echo "\nTabla: comun.ta_observaciones_tramites\n";
    echo "SPs: sp_observaciones_get_by_tramite, sp_observaciones_create, sp_observaciones_update\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
