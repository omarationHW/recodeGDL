<?php
// Verificar stored procedures de bloqueoDomicilios

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== VERIFICAR SPS DE BLOQUEO DOMICILIOS ===\n\n";

    $sps = [
        'sp_bloqueodomicilios_list',
        'sp_bloqueodomicilios_create',
        'sp_bloqueodomicilios_cancel'
    ];

    foreach ($sps as $spName) {
        echo "🔍 Buscando {$spName}...\n";

        // Buscar en todos los esquemas
        $stmt = $db->prepare("
            SELECT
                n.nspname as schema_name,
                p.proname as function_name,
                pg_get_function_identity_arguments(p.oid) as arguments
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE LOWER(p.proname) = LOWER(?)
            ORDER BY n.nspname
        ");
        $stmt->execute([$spName]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($results) > 0) {
            echo "   ✅ Encontrado:\n";
            foreach ($results as $r) {
                echo "      - {$r['schema_name']}.{$r['function_name']}({$r['arguments']})\n";
            }
        } else {
            echo "   ❌ NO EXISTE\n";
        }
        echo "\n";
    }

    // Verificar tabla de bloqueos
    echo "🔍 Verificando tablas relacionadas...\n";
    $stmt = $db->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name LIKE '%bloqueo%'
        ORDER BY table_schema, table_name
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        echo "   Tablas encontradas:\n";
        foreach ($tables as $t) {
            echo "      - {$t['table_schema']}.{$t['table_name']}\n";
        }
    } else {
        echo "   ⚠️  No se encontraron tablas relacionadas\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
