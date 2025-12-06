<?php
\ = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "Tipos de ta_11_pagos_local:\n\n";
\ = \->query("SELECT column_name, udt_name, character_maximum_length FROM information_schema.columns WHERE table_schema = 'publico' AND table_name = 'ta_11_pagos_local' ORDER BY ordinal_position")->fetchAll(PDO::FETCH_ASSOC);
foreach (\ as \/c/Users/luis_/bash_completion.d/*.bash) {
    echo \/c/Users/luis_/bash_completion.d/*.bash['column_name'] . ': ' . \/c/Users/luis_/bash_completion.d/*.bash['udt_name'];
    if (\/c/Users/luis_/bash_completion.d/*.bash['character_maximum_length']) echo '(' . \/c/Users/luis_/bash_completion.d/*.bash['character_maximum_length'] . ')';
    echo "\n";
}

