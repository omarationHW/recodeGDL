<?php
$file = 'C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\FrontEnd\src\views\modules\padron_licencias\tipobloqueofrm.vue';
$content = file_get_contents($file);

// 1. Fix toast structure
$old_toast = '/<div v-if="toast\.show" class="toast-notification" :class="`toast-\${toast\.type}`">\s+<font-awesome-icon :icon="getToastIcon\(toast\.type\)" class="toast-icon" \/>\s+<span class="toast-message">{{ toast\.message }}<\/span>\s+<button class="toast-close" @click="hideToast">/s';
$new_toast = '<div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <div class="toast-content">
        <span class="toast-message">{{ toast.message }}</span>
        <span v-if="toast.duration" class="toast-duration">
          <font-awesome-icon icon="clock" class="toast-duration-icon" />
          {{ toast.duration }}
        </span>
      </div>
      <button class="toast-close" @click="hideToast">';

$content = preg_replace($old_toast, $new_toast, $content);

// 2. Add useGlobalLoading import
$content = preg_replace(
    '/import { useLicenciasErrorHandler } from/',
    "import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'\nimport { useGlobalLoading } from",
    $content
);

// 3. Update composables section
$old_composables = '/const \{ execute \} = useApi\(\)\s+const \{\s+loading,\s+setLoading,\s+toast,/s';
$new_composables = 'const { execute } = useApi()
const {
  toast,';

$content = preg_replace($old_composables, $new_composables, $content);

// 4. Add useGlobalLoading composable
$content = preg_replace(
    '/\} = useLicenciasErrorHandler\(\)/',
    '} = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const loading = ref(false)',
    $content
);

// 5. Replace all setLoading(true, 'msg') with loading.value = true + showLoading
$content = preg_replace_callback(
    '/setLoading\(true,\s*[\'"]([^\'"]+)[\'"]\)/',
    function($matches) {
        return "loading.value = true\n  showLoading('{$matches[1]}', 'Procesando')";
    },
    $content
);

// 6. Replace all setLoading(false) with loading.value = false + hideLoading()
$content = preg_replace(
    '/setLoading\(false\)/',
    "loading.value = false\n    hideLoading()",
    $content
);

file_put_contents($file, $content);
echo "✓ tipobloqueofrm.vue actualizado con composables y toast corregidos\n";
