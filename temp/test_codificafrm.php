<?php
try {
    $pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "===========================================\n";
    echo "EJEMPLOS PARA PROBAR codificafrm.vue\n";
    echo "===========================================\n\n";

    // Ejemplo 1: Texto simple
    echo "EJEMPLO 1: Codificar texto simple\n";
    echo "---------------------------------------------\n";
    $texto1 = "Hola Mundo";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_codificafrm(?)");
    $stmt->execute([$texto1]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "En el módulo codificafrm.vue:\n";
    echo "- Texto: $texto1\n\n";
    echo "Resultado esperado:\n";
    echo "  Texto Original: {$result['texto_original']}\n";
    echo "  Base64:         {$result['base64_encode']}\n";
    echo "  Hexadecimal:    {$result['hex_encode']}\n";
    echo "  MD5 Hash:       {$result['md5_hash']}\n";
    echo "  Mayúsculas:     {$result['upper_text']}\n";
    echo "  Minúsculas:     {$result['lower_text']}\n";
    echo "  Longitud:       {$result['length_chars']} caracteres\n";
    echo "  Invertido:      {$result['reverse_text']}\n";

    // Ejemplo 2: Número de cuenta
    echo "\n\nEJEMPLO 2: Codificar número de cuenta\n";
    echo "---------------------------------------------\n";
    $texto2 = "120912";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_codificafrm(?)");
    $stmt->execute([$texto2]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "En el módulo codificafrm.vue:\n";
    echo "- Texto: $texto2\n\n";
    echo "Resultado esperado:\n";
    echo "  Texto Original: {$result['texto_original']}\n";
    echo "  Base64:         {$result['base64_encode']}\n";
    echo "  Hexadecimal:    {$result['hex_encode']}\n";
    echo "  MD5 Hash:       {$result['md5_hash']}\n";
    echo "  Mayúsculas:     {$result['upper_text']}\n";
    echo "  Minúsculas:     {$result['lower_text']}\n";
    echo "  Longitud:       {$result['length_chars']} caracteres\n";
    echo "  Invertido:      {$result['reverse_text']}\n";

    // Ejemplo 3: Email
    echo "\n\nEJEMPLO 3: Codificar correo electrónico\n";
    echo "---------------------------------------------\n";
    $texto3 = "usuario@guadalajara.gob.mx";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_codificafrm(?)");
    $stmt->execute([$texto3]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "En el módulo codificafrm.vue:\n";
    echo "- Texto: $texto3\n\n";
    echo "Resultado esperado:\n";
    echo "  Texto Original: {$result['texto_original']}\n";
    echo "  Base64:         {$result['base64_encode']}\n";
    echo "  Hexadecimal:    {$result['hex_encode']}\n";
    echo "  MD5 Hash:       {$result['md5_hash']}\n";
    echo "  Mayúsculas:     {$result['upper_text']}\n";
    echo "  Minúsculas:     {$result['lower_text']}\n";
    echo "  Longitud:       {$result['length_chars']} caracteres\n";
    echo "  Invertido:      {$result['reverse_text']}\n";

    echo "\n\n===========================================\n";
    echo "MÉTODOS DE CODIFICACIÓN DISPONIBLES:\n";
    echo "===========================================\n";
    echo "1. Base64:      Codificación estándar para datos binarios\n";
    echo "2. Hexadecimal: Representación en base 16\n";
    echo "3. MD5:         Hash criptográfico de 128 bits\n";
    echo "4. Mayúsculas:  Convierte todo a MAYÚSCULAS\n";
    echo "5. Minúsculas:  Convierte todo a minúsculas\n";
    echo "6. Longitud:    Cuenta el número de caracteres\n";
    echo "7. Invertido:   Invierte el texto\n";
    echo "\nUsos prácticos:\n";
    echo "- Base64: Para transmitir datos en URLs o APIs\n";
    echo "- MD5: Para generar identificadores únicos\n";
    echo "- Hex: Para debugging de datos binarios\n";

} catch(Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
