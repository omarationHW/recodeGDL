<?php
echo "========================================\n";
echo "DESPLIEGUE: DatosRequerimientos (4 SPs)\n";
echo "========================================\n\n";

// Leer archivo SQL
$sql_file = 'RefactorX/Base/mercados/database/ok/45_SP_MERCADOS_DATOSREQUERIMIENTOS_EXACTO_all_procedures.sql';

if (!file_exists($sql_file)) {
    die("ERROR: Archivo no encontrado: $sql_file\n");
}

$sql_content = file_get_contents($sql_file);

// Extraer los 4 CREATE FUNCTION statements
preg_match_all('/CREATE OR REPLACE FUNCTION.*?\$\$ LANGUAGE plpgsql;/s', $sql_content, $matches);

if (count($matches[0]) < 4) {
    die("ERROR: No se encontraron los 4 SPs en el archivo\n");
}

$sps = [
    'sp_get_locales' => $matches[0][0],
    'sp_get_mercado' => $matches[0][1],
    'sp_get_requerimientos' => $matches[0][2],
    'sp_get_periodos' => $matches[0][3]
];

echo "Archivo SQL leído: 4 SPs encontrados\n";
echo "Guardando en archivos individuales para despliegue manual...\n\n";

// Guardar cada SP en un archivo individual
foreach ($sps as $name => $sql) {
    $filename = "temp/{$name}_deploy.sql";
    file_put_contents($filename, "\\c ingresos;\n\n" . $sql . "\n\n\\df+ $name\n");
    echo "✓ Guardado: $filename\n";
}

echo "\n========================================\n";
echo "ARCHIVOS LISTOS PARA DESPLIEGUE MANUAL\n";
echo "========================================\n\n";

echo "Como psql no está disponible, usa uno de estos métodos:\n\n";

echo "MÉTODO A - pgAdmin (Recomendado):\n";
echo "1. Abre pgAdmin\n";
echo "2. Conecta al servidor 192.168.20.31\n";
echo "3. Selecciona base de datos 'ingresos'\n";
echo "4. Abre Query Tool (Ctrl+Shift+Q)\n";
echo "5. Carga y ejecuta: temp/deploy_sps_simple.sql\n\n";

echo "MÉTODO B - Copiar/Pegar SQL:\n";
echo "Abre el archivo: temp/deploy_sps_simple.sql\n";
echo "Copia TODO el contenido\n";
echo "Pega en tu cliente SQL (pgAdmin, DBeaver, etc.)\n";
echo "Ejecuta (F5)\n\n";

echo "MÉTODO C - Archivos Individuales:\n";
echo "Si prefieres desplegar uno por uno:\n";
foreach ($sps as $name => $sql) {
    echo "  - temp/{$name}_deploy.sql\n";
}

echo "\n========================================\n";
echo "CONTENIDO SQL PARA COPIAR/PEGAR:\n";
echo "========================================\n\n";

echo "-- Conectar a base de datos ingresos\n";
echo "-- Copiar y pegar el siguiente bloque completo:\n\n";

foreach ($sps as $name => $sql) {
    echo "-- SP: $name\n";
    echo $sql . "\n\n";
    echo "SELECT '$name desplegado' as status;\n\n";
}

echo "-- Verificar SPs\n";
echo "SELECT proname, pronargs FROM pg_proc WHERE proname IN ('sp_get_locales', 'sp_get_mercado', 'sp_get_requerimientos', 'sp_get_periodos') ORDER BY proname;\n";
