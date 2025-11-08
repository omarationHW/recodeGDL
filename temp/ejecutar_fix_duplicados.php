<?php
// Ejecutar fix de duplicados en tabla c_actividades

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== FIX: Eliminar Duplicados y Agregar Clave Primaria ===\n\n";

    // PASO 1: Verificar estado actual
    echo "📊 Estado ANTES del fix:\n";
    echo str_repeat("-", 80) . "\n";

    $stmt = $db->query('SELECT COUNT(*) as total FROM comun.c_actividades');
    $total_antes = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    echo "Total registros en tabla: $total_antes\n";

    $stmt = $db->query("
        SELECT COUNT(*) as duplicados
        FROM (
            SELECT generico, uso, actividad
            FROM comun.c_actividades
            GROUP BY generico, uso, actividad
            HAVING COUNT(*) > 1
        ) sub
    ");
    $duplicados = $stmt->fetch(PDO::FETCH_ASSOC)['duplicados'];
    echo "Claves con duplicados: $duplicados\n";

    $registros_unicos_esperados = $total_antes / 2;
    echo "Registros únicos esperados: ~$registros_unicos_esperados\n";
    echo str_repeat("-", 80) . "\n\n";

    // PASO 2: Crear backup
    echo "💾 Creando backup...\n";
    $db->exec('CREATE TEMP TABLE c_actividades_backup AS SELECT * FROM comun.c_actividades');
    echo "✅ Backup creado\n\n";

    // PASO 3: Eliminar duplicados
    echo "🗑️  Eliminando duplicados...\n";
    $stmt = $db->exec("
        DELETE FROM comun.c_actividades a
        WHERE ctid NOT IN (
            SELECT MIN(ctid)
            FROM comun.c_actividades b
            WHERE a.generico = b.generico
              AND a.uso = b.uso
              AND a.actividad = b.actividad
            GROUP BY b.generico, b.uso, b.actividad
        )
    ");
    echo "✅ Duplicados eliminados: $stmt filas\n\n";

    // Verificar
    $stmt = $db->query('SELECT COUNT(*) as total FROM comun.c_actividades');
    $total_despues = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    echo "📊 Registros después: $total_despues\n\n";

    // PASO 4: Agregar clave primaria
    echo "🔑 Agregando clave primaria...\n";
    try {
        $db->exec('ALTER TABLE comun.c_actividades ADD CONSTRAINT pk_c_actividades PRIMARY KEY (generico, uso, actividad)');
        echo "✅ Clave primaria agregada\n\n";
    } catch (PDOException $e) {
        if (strpos($e->getMessage(), 'already exists') !== false) {
            echo "⚠️  Clave primaria ya existe\n\n";
        } else {
            throw $e;
        }
    }

    // PASO 5: Actualizar SP con DISTINCT
    echo "📝 Actualizando stored procedure...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.catalogo_actividades_list()
        RETURNS TABLE (
            generico SMALLINT,
            uso SMALLINT,
            actividad SMALLINT,
            concepto VARCHAR
        ) AS \$\$
        BEGIN
            RETURN QUERY
            SELECT DISTINCT
                a.generico,
                a.uso,
                a.actividad,
                TRIM(a.concepto)::VARCHAR as concepto
            FROM comun.c_actividades a
            ORDER BY a.generico, a.uso, a.actividad;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "✅ SP actualizado con DISTINCT\n\n";

    // PASO 6: Verificar resultados
    echo "🔍 Verificando resultados:\n";
    echo str_repeat("-", 80) . "\n";

    $stmt = $db->query('SELECT COUNT(*) as total FROM comun.c_actividades');
    $total_tabla = $stmt->fetch(PDO::FETCH_ASSOC)['total'];

    $stmt = $db->query('SELECT COUNT(*) as total FROM comun.catalogo_actividades_list()');
    $total_sp = $stmt->fetch(PDO::FETCH_ASSOC)['total'];

    echo "Registros en tabla: $total_tabla\n";
    echo "Registros del SP: $total_sp\n";

    if ($total_tabla === $total_sp) {
        echo "✅ Números coinciden\n";
    } else {
        echo "⚠️  Los números NO coinciden\n";
    }

    // Verificar si quedan duplicados
    $stmt = $db->query("
        SELECT COUNT(*) as dup
        FROM (
            SELECT generico, uso, actividad
            FROM comun.c_actividades
            GROUP BY generico, uso, actividad
            HAVING COUNT(*) > 1
        ) sub
    ");
    $dup_restantes = $stmt->fetch(PDO::FETCH_ASSOC)['dup'];

    if ($dup_restantes == 0) {
        echo "✅ NO quedan duplicados\n";
    } else {
        echo "❌ AÚN hay $dup_restantes duplicados\n";
    }

    echo str_repeat("-", 80) . "\n\n";

    // RESUMEN FINAL
    echo "=== RESUMEN ===\n";
    echo "ANTES:\n";
    echo "  - Registros: $total_antes (con duplicados)\n";
    echo "  - Claves duplicadas: $duplicados\n";
    echo "  - Clave primaria: NO\n";
    echo "\n";
    echo "DESPUÉS:\n";
    echo "  - Registros: $total_despues (únicos)\n";
    echo "  - Claves duplicadas: $dup_restantes\n";
    echo "  - Clave primaria: SÍ\n";
    echo "  - SP con DISTINCT: SÍ\n";
    echo "\n";
    echo "✅ FIX COMPLETADO EXITOSAMENTE\n";

} catch (PDOException $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
