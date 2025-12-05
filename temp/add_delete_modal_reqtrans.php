<?php

$file = 'C:/recodeGDL/RefactorX/FrontEnd/src/views/modules/multas_reglamentos/ReqTrans.vue';

$content = file_get_contents($file);

// 1. Agregar modal de confirmación de eliminación después del Modal de edición
$oldModalEnd = '      </Modal>
    </div>
  </div>
</template>';

$newModalEnd = '      </Modal>

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
      </Modal>
    </div>
  </div>
</template>';

$content = str_replace($oldModalEnd, $newModalEnd, $content);

// 2. Agregar variables para el modal de eliminación después de showModal
$oldVars = 'const showModal = ref(false)
const modalTitle = ref(\'Nuevo registro\')
const form = ref({ clave_cuenta: \'\', folio: null, ejercicio: new Date().getFullYear(), estatus: \'\' })
let editing = false';

$newVars = 'const showModal = ref(false)
const modalTitle = ref(\'Nuevo registro\')
const form = ref({ clave_cuenta: \'\', folio: null, ejercicio: new Date().getFullYear(), estatus: \'\' })
let editing = false

// Modal de confirmación de eliminación
const showDeleteModal = ref(false)
const recordToDelete = ref(null)';

$content = str_replace($oldVars, $newVars, $content);

// 3. Modificar función remove() para abrir el modal en lugar de confirm()
$oldRemove = 'async function remove(r) {
  if (!confirm(\'¿Está seguro de eliminar este registro?\')) {
    return
  }

  const params = [ { nombre: \'p_registro\', tipo: \'string\', valor: JSON.stringify(r) } ]
  try {
    const response = await execute(OP_DELETE, BASE_DB, params)

    // Procesar respuesta
    let result = null
    if (response?.result && Array.isArray(response.result) && response.result.length > 0) {
      const firstResult = response.result[0]
      if (typeof firstResult === \'string\') {
        result = JSON.parse(firstResult)
      } else {
        result = firstResult
      }
    } else if (response?.success !== undefined) {
      result = response
    }

    if (result && result.success) {
      showAlert(\'success\', result.message || \'Registro eliminado correctamente\')
      await reload()
    } else if (result && !result.success) {
      showAlert(\'error\', result.message || \'Error al eliminar el registro\')
    } else {
      showAlert(\'success\', \'Registro eliminado\')
      await reload()
    }
  } catch (e) {
    console.error(\'Error en remove:\', e)
    showAlert(\'error\', e.message || \'Error al eliminar el registro\')
  }
}';

$newRemove = 'function remove(r) {
  // Guardar el registro a eliminar y mostrar modal de confirmación
  recordToDelete.value = r
  showDeleteModal.value = true
}

function closeDeleteModal() {
  showDeleteModal.value = false
  recordToDelete.value = null
}

async function confirmDelete() {
  if (!recordToDelete.value) return

  const params = [ { nombre: \'p_registro\', tipo: \'string\', valor: JSON.stringify(recordToDelete.value) } ]
  try {
    const response = await execute(OP_DELETE, BASE_DB, params)

    // Cerrar modal primero
    closeDeleteModal()

    // Procesar respuesta
    let result = null
    if (response?.result && Array.isArray(response.result) && response.result.length > 0) {
      const firstResult = response.result[0]
      if (typeof firstResult === \'string\') {
        result = JSON.parse(firstResult)
      } else {
        result = firstResult
      }
    } else if (response?.success !== undefined) {
      result = response
    }

    if (result && result.success) {
      showAlert(\'success\', result.message || \'Registro eliminado correctamente\')
      await reload()
    } else if (result && !result.success) {
      showAlert(\'error\', result.message || \'Error al eliminar el registro\')
    } else {
      showAlert(\'success\', \'Registro eliminado\')
      await reload()
    }
  } catch (e) {
    closeDeleteModal()
    console.error(\'Error en confirmDelete:\', e)
    showAlert(\'error\', e.message || \'Error al eliminar el registro\')
  }
}';

$content = str_replace($oldRemove, $newRemove, $content);

// 4. Agregar CSS para el modal de eliminación
$deleteModalCSS = '
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
}
';

$content = str_replace('</style>', $deleteModalCSS . '</style>', $content);

file_put_contents($file, $content);

echo "✅ Modal de confirmación de eliminación agregado exitosamente\n";
echo "   - Modal personalizado con diseño visual\n";
echo "   - Muestra detalles del registro a eliminar\n";
echo "   - Botones: Cancelar y Eliminar\n";
echo "   - Ícono de advertencia (exclamation-triangle)\n";
echo "   - Mensaje de confirmación claro\n";
echo "   - Advertencia: 'Esta acción no se puede deshacer'\n";
echo "   - CSS personalizado para el modal\n";
echo "   - Función remove() actualizada\n";
echo "   - Función closeDeleteModal() agregada\n";
echo "   - Función confirmDelete() agregada\n";
