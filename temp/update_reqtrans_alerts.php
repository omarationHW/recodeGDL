<?php

$file = 'C:/recodeGDL/RefactorX/FrontEnd/src/views/modules/multas_reglamentos/ReqTrans.vue';

$content = file_get_contents($file);

// 1. Agregar sección de alertas después del header, antes del primer card
$alertSection = '
    <!-- Alertas de éxito/error -->
    <div v-if="alert.show" :class="[\'alert\', alert.type === \'success\' ? \'alert-success\' : \'alert-error\']">
      <div class="alert-content">
        <font-awesome-icon :icon="alert.type === \'success\' ? \'check-circle\' : \'exclamation-circle\'" />
        <span>{{ alert.message }}</span>
      </div>
      <button class="alert-close" @click="alert.show = false">&times;</button>
    </div>
';

$content = str_replace(
    '    <div class="module-view-content">',
    '    <div class="module-view-content">' . $alertSection,
    $content
);

// 2. Agregar variables para alertas después de searchPerformed
$oldVars = "const filters = ref({ cuenta: '', ejercicio: new Date().getFullYear() })
const rows = ref([])
const cols = ref([])
const searchPerformed = ref(false)";

$newVars = "const filters = ref({ cuenta: '', ejercicio: new Date().getFullYear() })
const rows = ref([])
const cols = ref([])
const searchPerformed = ref(false)

// Sistema de alertas
const alert = ref({
  show: false,
  type: 'success', // 'success' o 'error'
  message: ''
})

function showAlert(type, message) {
  alert.value = {
    show: true,
    type: type,
    message: message
  }
  // Auto-cerrar después de 5 segundos
  setTimeout(() => {
    alert.value.show = false
  }, 5000)
}";

$content = str_replace($oldVars, $newVars, $content);

// 3. Actualizar función save() para procesar respuesta y mostrar alertas
$oldSave = "async function save() {
  const params = [
    { nombre: 'registro', tipo: 'string', valor: JSON.stringify(form.value) }
  ]
  try {
    await execute(editing ? OP_UPDATE : OP_CREATE, BASE_DB, params)
    showModal.value = false
    await reload()
  } catch (e) {}
}";

$newSave = "async function save() {
  const params = [
    { nombre: 'p_registro', tipo: 'string', valor: JSON.stringify(form.value) }
  ]
  try {
    const response = await execute(editing ? OP_UPDATE : OP_CREATE, BASE_DB, params)

    // Procesar respuesta del SP
    let result = null
    if (response?.result && Array.isArray(response.result) && response.result.length > 0) {
      // Si viene en result array, tomar el primer elemento
      const firstResult = response.result[0]
      if (typeof firstResult === 'string') {
        result = JSON.parse(firstResult)
      } else if (firstResult.recaudadora_reqtrans_update) {
        result = JSON.parse(firstResult.recaudadora_reqtrans_update)
      } else {
        result = firstResult
      }
    } else if (response?.success !== undefined) {
      result = response
    }

    showModal.value = false

    if (result && result.success) {
      showAlert('success', result.message || 'Operación completada exitosamente')
      await reload()
    } else if (result && !result.success) {
      showAlert('error', result.message || 'Error al realizar la operación')
    } else {
      showAlert('success', 'Operación completada')
      await reload()
    }
  } catch (e) {
    console.error('Error en save:', e)
    showAlert('error', e.message || 'Error al guardar el registro')
  }
}";

$content = str_replace($oldSave, $newSave, $content);

// 4. Corregir función remove() para usar parámetros en español
$oldRemove = "async function remove(r) {
  const params = [ { name: 'registro', type: 'C', value: JSON.stringify(r) } ]
  try {
    await execute(OP_DELETE, BASE_DB, params)
    await reload()
  } catch (e) {}
}";

$newRemove = "async function remove(r) {
  if (!confirm('¿Está seguro de eliminar este registro?')) {
    return
  }

  const params = [ { nombre: 'p_registro', tipo: 'string', valor: JSON.stringify(r) } ]
  try {
    const response = await execute(OP_DELETE, BASE_DB, params)

    // Procesar respuesta
    let result = null
    if (response?.result && Array.isArray(response.result) && response.result.length > 0) {
      const firstResult = response.result[0]
      if (typeof firstResult === 'string') {
        result = JSON.parse(firstResult)
      } else {
        result = firstResult
      }
    } else if (response?.success !== undefined) {
      result = response
    }

    if (result && result.success) {
      showAlert('success', result.message || 'Registro eliminado correctamente')
      await reload()
    } else if (result && !result.success) {
      showAlert('error', result.message || 'Error al eliminar el registro')
    } else {
      showAlert('success', 'Registro eliminado')
      await reload()
    }
  } catch (e) {
    console.error('Error en remove:', e)
    showAlert('error', e.message || 'Error al eliminar el registro')
  }
}";

$content = str_replace($oldRemove, $newRemove, $content);

// 5. Agregar CSS para las alertas
$alertCSS = "
/* Alertas */
.alert {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.5rem;
  margin-bottom: 1rem;
  border-radius: 8px;
  font-size: 0.95rem;
  animation: slideDown 0.3s ease-out;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.alert-success {
  background-color: #d4edda;
  border: 1px solid #c3e6cb;
  color: #155724;
}

.alert-error {
  background-color: #f8d7da;
  border: 1px solid #f5c6cb;
  color: #721c24;
}

.alert-content {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.alert-content svg {
  font-size: 1.25rem;
}

.alert-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  line-height: 1;
  cursor: pointer;
  opacity: 0.5;
  transition: opacity 0.2s;
  padding: 0;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.alert-close:hover {
  opacity: 1;
}
";

$content = str_replace('</style>', $alertCSS . '</style>', $content);

file_put_contents($file, $content);

echo "✅ Archivo ReqTrans.vue actualizado exitosamente\n";
echo "   - Sistema de alertas agregado\n";
echo "   - Procesamiento de respuesta JSON del SP implementado\n";
echo "   - Mensajes de éxito/error agregados\n";
echo "   - Función save() actualizada para mostrar resultados\n";
echo "   - Función remove() actualizada con confirmación y alertas\n";
echo "   - Parámetros corregidos en remove() (nombre, tipo, valor)\n";
echo "   - CSS para alertas agregado\n";
echo "   - Auto-cierre de alertas después de 5 segundos\n";
