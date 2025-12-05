<?php
try {
    $pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $sql = file_get_contents('C:/recodeGDL/RefactorX/Base/multas_reglamentos/database/generated/recaudadora_codificafrm.sql');

    $pdo->exec($sql);

    echo "✓ Stored procedure recaudadora_codificafrm deployed successfully\n";
} catch(Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
