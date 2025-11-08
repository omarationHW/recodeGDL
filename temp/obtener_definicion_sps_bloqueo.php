<?php
// Obtener la definición completa de los SPs de bloqueo desde catastro_gdl

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== OBTENER DEFINICIONES DE SPS BLOQUEO ===\n\n";

    $sps = [
        'sp_bloqueodomicilios_list',
        'sp_bloqueodomicilios_create',
        'sp_bloqueodomicilios_cancel'
    ];

    foreach ($sps as $spName) {
        echo "📋 {$spName}\n";
        echo str_repeat("=", 80) . "\n";

        // Obtener definición completa del SP
        $stmt = $db->prepare("
            SELECT pg_get_functiondef(p.oid) as definition
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE n.nspname = 'catastro_gdl'
            AND p.proname = ?
        ");
        $stmt->execute([$spName]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            echo $result['definition'] . "\n\n";
        } else {
            echo "❌ No se encontró el SP\n\n";
        }
    }

    // Verificar estructura de tablas
    echo "\n📋 ESTRUCTURA DE TABLAS\n";
    echo str_repeat("=", 80) . "\n";

    $tables = ['bloqueo_dom', 'h_bloqueo_dom'];
    foreach ($tables as $table) {
        echo "\nTabla: public.{$table}\n";
        $stmt = $db->prepare("
            SELECT column_name, data_type, character_maximum_length, is_nullable
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = ?
            ORDER BY ordinal_position
        ");
        $stmt->execute([$table]);
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($columns as $col) {
            $type = $col['data_type'];
            if ($col['character_maximum_length']) {
                $type .= "({$col['character_maximum_length']})";
            }
            echo "  - {$col['column_name']}: {$type} " . ($col['is_nullable'] == 'NO' ? 'NOT NULL' : 'NULL') . "\n";
        }
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
