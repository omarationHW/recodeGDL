<?php
// Agregar SP para listar TODAS las observaciones (catálogo)

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CREAR SP PARA LISTAR TODAS LAS OBSERVACIONES ===\n\n";

    // SP_OBSERVACIONES_LIST - Listar todas las observaciones
    echo "1️⃣  Creando sp_observaciones_list...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_observaciones_list()
        RETURNS TABLE (
            id_observacion INTEGER,
            num_tramite INTEGER,
            tipo VARCHAR,
            observacion TEXT,
            usuario VARCHAR,
            fecha_captura TIMESTAMP,
            fecha_modificacion TIMESTAMP
        ) AS $$
        BEGIN
            RETURN QUERY
            SELECT
                o.id_observacion,
                o.num_tramite,
                o.tipo,
                o.observacion,
                o.usuario,
                o.fecha_captura,
                o.fecha_modificacion
            FROM comun.ta_observaciones_tramites o
            ORDER BY o.fecha_captura DESC;
        END;
        $$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_observaciones_list creado\n\n";

    // SP_OBSERVACIONES_GET - Obtener una observación por ID
    echo "2️⃣  Creando sp_observaciones_get...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_observaciones_get(p_id_observacion INTEGER)
        RETURNS TABLE (
            id_observacion INTEGER,
            num_tramite INTEGER,
            tipo VARCHAR,
            observacion TEXT,
            usuario VARCHAR,
            fecha_captura TIMESTAMP,
            fecha_modificacion TIMESTAMP
        ) AS $$
        BEGIN
            RETURN QUERY
            SELECT
                o.id_observacion,
                o.num_tramite,
                o.tipo,
                o.observacion,
                o.usuario,
                o.fecha_captura,
                o.fecha_modificacion
            FROM comun.ta_observaciones_tramites o
            WHERE o.id_observacion = p_id_observacion;
        END;
        $$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_observaciones_get creado\n\n";

    // SP_OBSERVACIONES_DELETE - Eliminar observación
    echo "3️⃣  Creando sp_observaciones_delete...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_observaciones_delete(p_id_observacion INTEGER)
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR
        ) AS $$
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM comun.ta_observaciones_tramites WHERE id_observacion = p_id_observacion) THEN
                RETURN QUERY SELECT FALSE, 'Observación no encontrada'::VARCHAR;
                RETURN;
            END IF;

            DELETE FROM comun.ta_observaciones_tramites WHERE id_observacion = p_id_observacion;

            RETURN QUERY SELECT TRUE, 'Observación eliminada exitosamente'::VARCHAR;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY SELECT FALSE, ('Error al eliminar: ' || SQLERRM)::VARCHAR;
        END;
        $$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_observaciones_delete creado\n\n";

    // Probar SP
    echo "🧪 Probando sp_observaciones_list:\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $db->query("SELECT * FROM comun.sp_observaciones_list()");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "✅ SP ejecutado correctamente\n";
    echo "📊 Total observaciones: " . count($results) . "\n";
    foreach ($results as $i => $row) {
        if ($i < 3) {
            echo ($i + 1) . ". ID: {$row['id_observacion']} - Trámite: {$row['num_tramite']} - {$row['tipo']}\n";
        }
    }
    echo str_repeat("-", 80) . "\n\n";

    echo "✅ TODOS LOS SPs CREADOS EXITOSAMENTE\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
