<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="exchange-alt" /></div>
      <div class="module-view-info">
        <h1>Requerimientos de Tránsito</h1>
        <p>CRUD real contra BD</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-primary" :disabled="loading" @click="openCreate()">
          <font-awesome-icon icon="plus" /> Nuevo
        </button>
      </div>
    </div>

    <div class="module-view-content">
    <!-- Alertas de éxito/error -->
    <div v-if="alert.show" :class="['alert', alert.type === 'success' ? 'alert-success' : 'alert-error']">
      <div class="alert-content">
        <font-awesome-icon :icon="alert.type === 'success' ? 'check-circle' : 'exclamation-circle'" />
        <span>{{ alert.message }}</span>
      </div>
      <button class="alert-close" @click="alert.show = false">&times;</button>
    </div>

      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Cuenta</label>
              <input class="municipal-form-control" v-model="filters.cuenta" @keyup.enter="reload" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año</label>
              <input class="municipal-form-control" type="number" v-model.number="filters.ejercicio" @keyup.enter="reload" />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="reload"><font-awesome-icon icon="search" /> Buscar</button>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Registros</h5>
          <div v-if="loading" class="spinner-border" role="status"><span class="visually-hidden">Cargando...</span></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="results-header" v-if="rows.length > 0">
            <h3>Resultados: {{ rows.length }} registros encontrados</h3>
          </div>
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Cuenta</th>
                  <th>Folio</th>
                  <th>Año</th>
                  <th>Estatus</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in paginatedRows" :key="idx" class="row-hover">
                  <td><code>{{ r.clave_cuenta }}</code></td>
                  <td>{{ r.folio }}</td>
                  <td>{{ r.ejercicio }}</td>
                  <td>{{ r.estatus }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-info btn-sm" @click="edit(r)"><font-awesome-icon icon="edit" /></button>
                      <button class="btn-municipal-danger btn-sm" @click="remove(r)"><font-awesome-icon icon="trash" /></button>
                    </div>
                  </td>
                </tr>
                <tr v-if="rows.length===0"><td colspan="5" class="text-center text-muted">Sin registros</td></tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container" v-if="rows.length > 0">
            <div class="pagination-info">
              Mostrando {{ startIndex + 1 }} a {{ endIndex }} de {{ rows.length }} registros
            </div>
            <div class="pagination-controls">
              <button
                class="btn-pagination"
                :disabled="currentPage === 1"
                @click="previousPage"
              >
                ‹ Anterior
              </button>
              <span class="page-info">
                Página {{ currentPage }} de {{ totalPages }}
              </span>
              <button
                class="btn-pagination"
                :disabled="currentPage === totalPages"
                @click="nextPage"
              >
                Siguiente ›
              </button>
            </div>
          </div>
        </div>
      </div>

      <Modal :show="showModal" :title="modalTitle" @close="closeModal" :showDefaultFooter="true" @confirm="save">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Cuenta</label>
            <input class="municipal-form-control" v-model="form.clave_cuenta" />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Folio</label>
            <input class="municipal-form-control" v-model.number="form.folio" type="number" />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Año</label>
            <input class="municipal-form-control" v-model.number="form.ejercicio" type="number" />
          </div>
          <div class="form-group full-width">
            <label class="municipal-form-label">Estatus</label>
            <input class="municipal-form-control" v-model="form.estatus" :disabled="!editing" />
          </div>
        </div>
      </Modal>

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
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import Modal from '@/components/common/Modal.vue'

const BASE_DB = 'multas_reglamentos' // TODO confirmar
const OP_LIST = 'RECAUDADORA_REQTRANS_LIST' // TODO confirmar
const OP_CREATE = 'RECAUDADORA_REQTRANS_CREATE' // TODO confirmar
const OP_UPDATE = 'RECAUDADORA_REQTRANS_UPDATE' // TODO confirmar
const OP_DELETE = 'RECAUDADORA_REQTRANS_DELETE' // TODO confirmar

const { loading, execute } = useApi()

const filters = ref({ cuenta: '', ejercicio: new Date().getFullYear() })
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
}

// Paginación
const currentPage = ref(1)
const itemsPerPage = 10

const totalPages = computed(() => {
  return Math.ceil(rows.value.length / itemsPerPage)
})

const startIndex = computed(() => {
  return (currentPage.value - 1) * itemsPerPage
})

const endIndex = computed(() => {
  return Math.min(startIndex.value + itemsPerPage, rows.value.length)
})

const paginatedRows = computed(() => {
  return rows.value.slice(startIndex.value, endIndex.value)
})

function nextPage() {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
  }
}

function previousPage() {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

function resetPagination() {
  currentPage.value = 1
}

function processResults(data) {
  let arr = []

  if (data?.result && Array.isArray(data.result)) {
    arr = data.result
  } else if (data?.rows && Array.isArray(data.rows)) {
    arr = data.rows
  } else if (Array.isArray(data)) {
    arr = data
  }

  rows.value = arr
  cols.value = arr.length ? Object.keys(arr[0]) : []
}

const showModal = ref(false)
const modalTitle = ref('Nuevo registro')
const form = ref({ clave_cuenta: '', folio: null, ejercicio: new Date().getFullYear(), estatus: 'Pendiente' })
let editing = false

// Modal de confirmación de eliminación
const showDeleteModal = ref(false)
const recordToDelete = ref(null)


async function reload() {
  searchPerformed.value = true
  resetPagination()

  const params = [
    { nombre: 'p_clave_cuenta', tipo: 'string', valor: String(filters.value.cuenta || '') },
    { nombre: 'p_ejercicio', tipo: 'integer', valor: Number(filters.value.ejercicio || 0) }
  ]
  try {
    const data = await execute(OP_LIST, BASE_DB, params)
    processResults(data)
  } catch (e) {
    rows.value = []
    cols.value = []
  }
}

function openCreate() {
  editing = false
  modalTitle.value = 'Nuevo registro'
  form.value = { clave_cuenta: '', folio: null, ejercicio: new Date().getFullYear(), estatus: 'Pendiente' }
  showModal.value = true
}

function edit(r) {
  editing = true
  modalTitle.value = `Editar registro: ${r.clave_cuenta}`
  form.value = { ...r }
  showModal.value = true
}

function closeModal() { showModal.value = false }

async function save() {
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
      } else if (firstResult.recaudadora_reqtrans_create) {
        result = JSON.parse(firstResult.recaudadora_reqtrans_create)
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
}

function remove(r) {
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

  const params = [ { nombre: 'p_registro', tipo: 'string', valor: JSON.stringify(recordToDelete.value) } ]
  try {
    const response = await execute(OP_DELETE, BASE_DB, params)

    // Cerrar modal primero
    closeDeleteModal()

    // Procesar respuesta
    let result = null
    if (response?.result && Array.isArray(response.result) && response.result.length > 0) {
      const firstResult = response.result[0]
      if (typeof firstResult === 'string') {
        result = JSON.parse(firstResult)
      } else if (firstResult.recaudadora_reqtrans_delete) {
        result = JSON.parse(firstResult.recaudadora_reqtrans_delete)
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
    closeDeleteModal()
    console.error('Error en confirmDelete:', e)
    showAlert('error', e.message || 'Error al eliminar el registro')
  }
}

reload()
</script>

<style scoped>
.results-header {
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #007bff;
}

.results-header h3 {
  font-size: 1.1rem;
  color: #333;
  margin: 0;
}

.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background-color: #f8f9fa;
  border-radius: 4px;
  flex-wrap: wrap;
  gap: 1rem;
  margin-top: 1rem;
}

.pagination-info {
  font-size: 0.9rem;
  color: #666;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.btn-pagination {
  background-color: #007bff;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background-color 0.2s;
}

.btn-pagination:hover:not(:disabled) {
  background-color: #0056b3;
}

.btn-pagination:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

.page-info {
  font-size: 0.9rem;
  color: #333;
  font-weight: 500;
}

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

</style>
