<?php
$file = 'C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\FrontEnd\src\views\modules\padron_licencias\tipobloqueofrm.vue';
$content = file_get_contents($file);

// 1. Fix header: Remove inline style and reorganize buttons
$content = preg_replace(
    '/<div class="module-view-header" style="position: relative;">/',
    '<div class="module-view-header">',
    $content
);

// 2. Replace help button + actions section with button-group ms-auto structure
$old_header_end = '/<button\s+type="button"\s+class="btn-help-icon".*?<\/button>\s+<div class="module-view-actions">.*?<\/div>\s+<\/div>/s';
$new_header_end = '<div class="button-group ms-auto">
        <button class="btn-municipal-success" @click="openCreateModal" :disabled="loading">
          <font-awesome-icon icon="plus" />
          Nuevo Tipo
        </button>
        <button class="btn-municipal-primary" @click="loadTiposBloqueo" :disabled="loading">
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
        <button class="btn-municipal-purple" @click="openDocumentation">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>';

$content = preg_replace($old_header_end, $new_header_end, $content);

// 3. Fix badge-info to badge-purple
$content = preg_replace(
    '/<span class="badge-info" v-if="tiposBloqueo.length > 0">{{ tiposBloqueo.length }} tipos<\/span>/',
    '</h5>
        <span class="badge-purple" v-if="tiposBloqueo.length > 0">
          {{ tiposBloqueo.length }} tipo{{ tiposBloqueo.length !== 1 ? \'s\' : \'\' }}
        </span>',
    $content
);

// 4. Fix header structure to header-with-badge
$content = preg_replace(
    '/<div class="municipal-card-header">\s+<h5>\s+<font-awesome-icon icon="list" \/>\s+Catálogo de Tipos de Bloqueo\s+<\/h5>/',
    '<div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="list" />
          Catálogo de Tipos de Bloqueo
        </h5>',
    $content
);

file_put_contents($file, $content);
echo "✓ tipobloqueofrm.vue actualizado con correcciones de header y badges\n";
