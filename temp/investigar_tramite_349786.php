<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');

echo "========================================\n";
echo "INVESTIGACIÓN: TRÁMITE 349786\n";
echo "========================================\n\n";

// 1. Buscar tabla tramites en todos los esquemas
echo "1. Buscando tabla 'tramites' en todos los esquemas:\n\n";
$stmt = $pdo->query("
    SELECT schemaname, tablename
    FROM pg_tables
    WHERE tablename LIKE '%tramite%'
    ORDER BY schemaname, tablename
");

$tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($tables as $table) {
    echo "   {$table['schemaname']}.{$table['tablename']}\n";
}

// 2. Buscar el trámite 349786 en cada tabla encontrada
echo "\n2. Buscando trámite 349786 en las tablas encontradas:\n\n";

foreach ($tables as $table) {
    $schema = $table['schemaname'];
    $tablename = $table['tablename'];

    try {
        // Primero verificar qué columnas tiene la tabla
        $stmt = $pdo->query("
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = '$schema'
            AND table_name = '$tablename'
            AND column_name IN ('id_tramite', 'folio', 'tramite', 'id')
            LIMIT 1
        ");

        $idColumn = $stmt->fetchColumn();

        if ($idColumn) {
            // Buscar el trámite
            $stmt = $pdo->query("
                SELECT *
                FROM $schema.$tablename
                WHERE $idColumn = 349786
                LIMIT 1
            ");

            $tramite = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($tramite) {
                echo "   ✓ ENCONTRADO en: $schema.$tablename\n";
                echo "   Columna ID: $idColumn\n";
                echo "   Datos:\n";
                foreach ($tramite as $key => $value) {
                    if ($value !== null && $value !== '') {
                        echo "      - $key: $value\n";
                    }
                }
                echo "\n";
            }
        }
    } catch (Exception $e) {
        // Ignorar errores de permisos
    }
}

// 3. Ver qué SP usa ConsultaTramitefrm para buscar
echo "\n3. Buscando SPs que consultan trámites:\n\n";
$stmt = $pdo->query("
    SELECT n.nspname, p.proname, pg_get_function_identity_arguments(p.oid) as args
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE p.proname LIKE '%tramite%'
    AND p.proname LIKE 'sp_%'
    ORDER BY p.proname
    LIMIT 20
");

$sps = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($sps as $sp) {
    echo "   {$sp['nspname']}.{$sp['proname']}({$sp['args']})\n";
}

echo "\n========================================\n";
