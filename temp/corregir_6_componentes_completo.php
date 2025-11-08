<?php
/**
 * Corrección COMPLETA de los 6 componentes para que sigan el patrón exacto de empresasfrm.vue
 */

$base = 'C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/FrontEnd/src/views/modules/padron_licencias/';

// Patrón correcto del ejemplo
$patron_header = '<div class="button-group ms-auto">
        <button class="btn-municipal-success" @click="ACCION_NUEVA">
          <font-awesome-icon icon="plus" />
          TEXTO_NUEVO
        </button>
        <button class="btn-municipal-primary" @click="ACCION_ACTUALIZAR">
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
        <button class="btn-municipal-purple" @click="openDocumentation">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>';

// Definir cada componente con sus configuraciones específicas
$componentes = [
    'estatusfrm.vue' => [
        'tipo' => 'operativo',
        'botones' => [
            ['clase' => 'btn-municipal-primary', 'accion' => 'searchTramite', 'icono' => 'sync-alt', 'texto' => 'Actualizar'],
            ['clase' => 'btn-municipal-purple', 'accion' => 'openDocumentation', 'icono' => 'question-circle', 'texto' => 'Ayuda']
        ]
    ],
    'dependenciasfrm.vue' => [
        'tipo' => 'operativo',
        'botones' => [
            ['clase' => 'btn-municipal-primary', 'accion' => 'searchTramite', 'icono' => 'sync-alt', 'texto' => 'Actualizar'],
            ['clase' => 'btn-municipal-purple', 'accion' => 'openDocumentation', 'icono' => 'question-circle', 'texto' => 'Ayuda']
        ]
    ],
    'tipobloqueofrm.vue' => [
        'tipo' => 'crud',
        'botones' => [
            ['clase' => 'btn-municipal-success', 'accion' => 'openCreateModal', 'icono' => 'plus', 'texto' => 'Nuevo Tipo'],
            ['clase' => 'btn-municipal-primary', 'accion' => 'loadTiposBloqueo', 'icono' => 'sync-alt', 'texto' => 'Actualizar'],
            ['clase' => 'btn-municipal-purple', 'accion' => 'openDocumentation', 'icono' => 'question-circle', 'texto' => 'Ayuda']
        ]
    ],
    'CatRequisitos.vue' => [
        'tipo' => 'crud',
        'botones' => [
            ['clase' => 'btn-municipal-success', 'accion' => 'openCreateModal', 'icono' => 'plus', 'texto' => 'Nuevo Requisito'],
            ['clase' => 'btn-municipal-primary', 'accion' => 'loadRequisitos', 'icono' => 'sync-alt', 'texto' => 'Actualizar'],
            ['clase' => 'btn-municipal-purple', 'accion' => 'openDocumentation', 'icono' => 'question-circle', 'texto' => 'Ayuda']
        ]
    ],
    'CatalogoActividadesFrm.vue' => [
        'tipo' => 'crud',
        'botones' => [
            ['clase' => 'btn-municipal-success', 'accion' => 'openCreateModal', 'icono' => 'plus', 'texto' => 'Nueva Actividad'],
            ['clase' => 'btn-municipal-primary', 'accion' => 'loadActividades', 'icono' => 'sync-alt', 'texto' => 'Actualizar'],
            ['clase' => 'btn-municipal-purple', 'accion' => 'openDocumentation', 'icono' => 'question-circle', 'texto' => 'Ayuda']
        ]
    ],
    'doctosfrm.vue' => [
        'tipo' => 'crud',
        'botones' => [
            ['clase' => 'btn-municipal-success', 'accion' => 'openCreateModal', 'icono' => 'plus', 'texto' => 'Nuevo Documento'],
            ['clase' => 'btn-municipal-primary', 'accion' => 'loadDocumentos', 'icono' => 'sync-alt', 'texto' => 'Actualizar'],
            ['clase' => 'btn-municipal-purple', 'accion' => 'openDocumentation', 'icono' => 'question-circle', 'texto' => 'Ayuda']
        ]
    ]
];

foreach ($componentes as $archivo => $config) {
    $file = $base . $archivo;

    if (!file_exists($file)) {
        echo "✗ $archivo - No encontrado\n";
        continue;
    }

    $content = file_get_contents($file);
    $original = $content;

    echo "\n=== Procesando $archivo ===\n";

    // 1. Corregir cierre de </p> si está pegado
    if (preg_match('/<\/p><\/div>/', $content)) {
        $content = preg_replace('/<\/p><\/div>/', "</p>\n      </div>", $content);
        echo "  ✓ Corregido cierre de </p>\n";
    }

    // 2. Remover inline styles
    if (preg_match('/style="[^"]*"/', $content)) {
        $content = preg_replace('/ style="[^"]*"/', '', $content);
        echo "  ✓ Removidos inline styles\n";
    }

    // 3. Construir el header correcto según el tipo
    $header_html = '      <div class="button-group ms-auto">' . "\n";
    foreach ($config['botones'] as $btn) {
        $disabled = '';
        if (in_array($btn['accion'], ['searchTramite', 'loadTiposBloqueo', 'loadRequisitos', 'loadActividades', 'loadDocumentos', 'openCreateModal'])) {
            $disabled = ' :disabled="loading"';
        }
        $header_html .= "        <button class=\"{$btn['clase']}\" @click=\"{$btn['accion']}\"{$disabled}>\n";
        $header_html .= "          <font-awesome-icon icon=\"{$btn['icono']}\" />\n";
        $header_html .= "          {$btn['texto']}\n";
        $header_html .= "        </button>\n";
    }
    $header_html .= "      </div>\n";
    $header_html .= "    </div>";

    // 4. Reemplazar el header completo (desde btn-help-icon o module-view-actions hasta </div>)
    $pattern = '/(<button[^>]*btn-help-icon[^>]*>.*?<\/button>.*?(<div class="module-view-actions">.*?<\/div>)?.*?<\/div>)/s';
    if (preg_match($pattern, $content)) {
        $content = preg_replace($pattern, $header_html, $content);
        echo "  ✓ Header actualizado con botones correctos\n";
    }

    // 5. Cambiar badge-info a badge-purple
    if (preg_match('/badge-info/', $content)) {
        $content = str_replace('badge-info', 'badge-purple', $content);
        echo "  ✓ Badges actualizados a badge-purple\n";
    }

    // 6. Agregar header-with-badge si tiene badge
    if (preg_match('/<div class="municipal-card-header">\s+<h5>/', $content) && preg_match('/badge-purple/', $content)) {
        $content = preg_replace(
            '/<div class="municipal-card-header">(\s+<h5>)/',
            '<div class="municipal-card-header header-with-badge">$1',
            $content,
            1
        );
        echo "  ✓ Agregado header-with-badge\n";
    }

    // 7. Corregir estructura del toast
    $toast_correcto = '<div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <div class="toast-content">
        <span class="toast-message">{{ toast.message }}</span>
        <span v-if="toast.duration" class="toast-duration">
          <font-awesome-icon icon="clock" class="toast-duration-icon" />
          {{ toast.duration }}
        </span>
      </div>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>';

    $pattern_toast = '/<div v-if="toast\.show"[^>]*>.*?<\/div>/s';
    if (preg_match($pattern_toast, $content) && !preg_match('/toast-duration/', $content)) {
        $content = preg_replace($pattern_toast, $toast_correcto, $content);
        echo "  ✓ Toast actualizado con estructura correcta\n";
    }

    if ($content !== $original) {
        file_put_contents($file, $content);
        echo "✓ $archivo - ACTUALIZADO\n";
    } else {
        echo "✓ $archivo - Sin cambios necesarios\n";
    }
}

echo "\n✓ Proceso completado\n";
