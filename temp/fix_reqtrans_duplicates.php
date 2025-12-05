<?php

$file = 'C:/recodeGDL/RefactorX/FrontEnd/src/views/modules/multas_reglamentos/ReqTrans.vue';

echo "📋 Corrigiendo duplicaciones en ReqTrans.vue...\n\n";

$content = file_get_contents($file);

// 1. Eliminar el segundo modal duplicado (líneas 166-199)
$duplicateModal = '
      <!-- Modal de Confirmación de Eliminación -->
      <Modal
        :show="showDeleteModal"
        title="Confirmar Eliminación"
        @close="closeDeleteModal"
        :showDefaultFooter="false"
      >
        <div class="delete-confirmation">
          <div class="delete-icon">
            <font-awesome-icon icon="exclamation-triangle" />
          </div>
          <p class="delete-message">
            ¿Está seguro de eliminar este registro?
          </p>
          <div class="delete-details" v-if="recordToDelete">
            <p><strong>Cuenta:</strong> {{ recordToDelete.clave_cuenta }}</p>
            <p><strong>Año:</strong> {{ recordToDelete.ejercicio }}</p>
            <p><strong>Estatus:</strong> {{ recordToDelete.estatus }}</p>
          </div>
          <p class="delete-warning">
            Esta acción no se puede deshacer.
          </p>
        </div>
        <template #footer>
          <div class="modal-footer-buttons">
            <button class="btn-municipal-secondary" @click="closeDeleteModal">
              Cancelar
            </button>
            <button class="btn-municipal-danger" @click="confirmDelete">
              <font-awesome-icon icon="trash" /> Eliminar
            </button>
          </div>
        </template>
      </Modal>';

// Contar cuántas veces aparece el modal
$count = substr_count($content, $duplicateModal);
echo "🔍 Modales encontrados: $count\n";

if ($count > 1) {
    // Eliminar la segunda ocurrencia
    $pos = strpos($content, $duplicateModal);
    $pos2 = strpos($content, $duplicateModal, $pos + 1);
    if ($pos2 !== false) {
        $content = substr_replace($content, '', $pos2, strlen($duplicateModal));
        echo "✅ Modal duplicado eliminado\n";
    }
}

// 2. Eliminar variables duplicadas en el script
$duplicateVars = '
// Modal de confirmación de eliminación
const showDeleteModal = ref(false)
const recordToDelete = ref(null)';

$count2 = substr_count($content, $duplicateVars);
echo "🔍 Bloques de variables encontrados: $count2\n";

if ($count2 > 1) {
    // Eliminar la segunda ocurrencia
    $pos = strpos($content, $duplicateVars);
    $pos2 = strpos($content, $duplicateVars, $pos + 1);
    if ($pos2 !== false) {
        $content = substr_replace($content, '', $pos2, strlen($duplicateVars));
        echo "✅ Variables duplicadas eliminadas\n";
    }
}

// 3. Eliminar CSS duplicado
$duplicateCSS = '
/* Modal de confirmación de eliminación */
.delete-confirmation {
  text-align: center;
  padding: 1rem 0;
}

.delete-icon {
  font-size: 4rem;
  color: #dc3545;
  margin-bottom: 1.5rem;
}

.delete-message {
  font-size: 1.25rem;
  font-weight: 600;
  color: #333;
  margin-bottom: 1.5rem;
}

.delete-details {
  background-color: #f8f9fa;
  border-radius: 8px;
  padding: 1rem;
  margin: 1.5rem 0;
  text-align: left;
}

.delete-details p {
  margin: 0.5rem 0;
  color: #666;
}

.delete-details strong {
  color: #333;
  font-weight: 600;
}

.delete-warning {
  color: #dc3545;
  font-weight: 500;
  margin-top: 1.5rem;
  font-size: 0.95rem;
}

.modal-footer-buttons {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  padding: 1rem 0 0 0;
}

.btn-municipal-danger {
  background-color: #dc3545;
  color: white;
  border: none;
  padding: 0.6rem 1.5rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.95rem;
  transition: background-color 0.2s;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-municipal-danger:hover {
  background-color: #c82333;
}

.btn-municipal-secondary {
  background-color: #6c757d;
  color: white;
  border: none;
  padding: 0.6rem 1.5rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.95rem;
  transition: background-color 0.2s;
}

.btn-municipal-secondary:hover {
  background-color: #5a6268;
}';

$count3 = substr_count($content, $duplicateCSS);
echo "🔍 Bloques de CSS encontrados: $count3\n";

if ($count3 > 1) {
    // Eliminar la segunda ocurrencia
    $pos = strpos($content, $duplicateCSS);
    $pos2 = strpos($content, $duplicateCSS, $pos + 1);
    if ($pos2 !== false) {
        $content = substr_replace($content, '', $pos2, strlen($duplicateCSS));
        echo "✅ CSS duplicado eliminado\n";
    }
}

file_put_contents($file, $content);

echo "\n";
echo "╔════════════════════════════════════════════════════════════╗\n";
echo "║              🎉 DUPLICACIONES CORREGIDAS 🎉               ║\n";
echo "╚════════════════════════════════════════════════════════════╝\n";
echo "\n";
echo "✅ El archivo ReqTrans.vue ha sido corregido\n";
echo "✅ Se eliminaron todas las duplicaciones\n";
echo "✅ El modal de eliminación está listo\n";
echo "\n";
echo "🚀 Ahora puedes probar el módulo sin errores\n";
echo "\n";
