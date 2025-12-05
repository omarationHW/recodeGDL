<?php

$file = 'C:/recodeGDL/RefactorX/FrontEnd/src/views/modules/multas_reglamentos/ReqTrans.vue';

echo "📋 Configurando estatus como 'Pendiente' y deshabilitado en nuevo registro...\n\n";

$content = file_get_contents($file);

// 1. Cambiar el input de estatus para que esté deshabilitado en modo creación
$oldInput = '          <div class="form-group full-width">
            <label class="municipal-form-label">Estatus</label>
            <input class="municipal-form-control" v-model="form.estatus" />
          </div>';

$newInput = '          <div class="form-group full-width">
            <label class="municipal-form-label">Estatus</label>
            <input class="municipal-form-control" v-model="form.estatus" :disabled="!editing" />
          </div>';

$changed1 = false;
if (strpos($content, $oldInput) !== false) {
    $content = str_replace($oldInput, $newInput, $content);
    $changed1 = true;
    echo "✅ Campo Estatus configurado como disabled en modo creación\n";
} else {
    echo "ℹ️  Campo Estatus ya está configurado o no se encontró el patrón exacto\n";
}

// 2. Asegurar que openCreate() establece estatus como 'Pendiente'
$oldOpenCreate = "function openCreate() {
  editing = false
  modalTitle.value = 'Nuevo registro'
  form.value = { clave_cuenta: '', folio: null, ejercicio: new Date().getFullYear(), estatus: '' }
  showModal.value = true
}";

$newOpenCreate = "function openCreate() {
  editing = false
  modalTitle.value = 'Nuevo registro'
  form.value = { clave_cuenta: '', folio: null, ejercicio: new Date().getFullYear(), estatus: 'Pendiente' }
  showModal.value = true
}";

$changed2 = false;
if (strpos($content, $oldOpenCreate) !== false) {
    $content = str_replace($oldOpenCreate, $newOpenCreate, $content);
    $changed2 = true;
    echo "✅ openCreate() configurado para establecer estatus como 'Pendiente'\n";
} else {
    echo "ℹ️  openCreate() ya está configurado o no se encontró el patrón exacto\n";
}

// 3. También actualizar la declaración inicial de form
$oldFormDeclaration = "const form = ref({ clave_cuenta: '', folio: null, ejercicio: new Date().getFullYear(), estatus: '' })";
$newFormDeclaration = "const form = ref({ clave_cuenta: '', folio: null, ejercicio: new Date().getFullYear(), estatus: 'Pendiente' })";

$changed3 = false;
if (strpos($content, $oldFormDeclaration) !== false) {
    $content = str_replace($oldFormDeclaration, $newFormDeclaration, $content);
    $changed3 = true;
    echo "✅ Declaración de form configurada con estatus 'Pendiente'\n";
} else {
    echo "ℹ️  Declaración de form ya está configurada\n";
}

if ($changed1 || $changed2 || $changed3) {
    file_put_contents($file, $content);

    echo "\n";
    echo "╔════════════════════════════════════════════════════════════╗\n";
    echo "║              🎉 CONFIGURACIÓN APLICADA 🎉                  ║\n";
    echo "╚════════════════════════════════════════════════════════════╝\n";
    echo "\n";
    echo "📋 CAMBIOS REALIZADOS:\n";
    echo "   ✅ Campo Estatus deshabilitado en modo creación\n";
    echo "   ✅ Estatus precargado como 'Pendiente'\n";
    echo "   ✅ Estatus editable solo en modo edición\n";
    echo "\n";
    echo "🎯 COMPORTAMIENTO:\n";
    echo "   📝 Nuevo Registro:\n";
    echo "      - Estatus: 'Pendiente' (no editable)\n";
    echo "      - Usuario no puede cambiar el estatus\n";
    echo "\n";
    echo "   ✏️  Editar Registro:\n";
    echo "      - Estatus: [valor actual] (editable)\n";
    echo "      - Usuario puede cambiar el estatus\n";
    echo "\n";
    echo "🚀 Ahora puedes probar crear un nuevo registro\n";
    echo "\n";

} else {
    echo "\nℹ️  No se realizaron cambios (todo ya está configurado correctamente)\n\n";
}
