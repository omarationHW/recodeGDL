<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="address-card" /></div>
      <div class="module-view-info">
        <h1>Impresión Padrón Vehicular</h1>
        <p>Rango de IDs</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="mostrarDocumentacion"
          title="Documentacion Tecnica"
        >
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>

      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="consultar"><font-awesome-icon icon="play" /> Ejecutar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">ID desde</label>
              <input type="number" class="municipal-form-control" v-model.number="id1" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">ID hasta</label>
              <input type="number" class="municipal-form-control" v-model.number="id2" />
            </div>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Resultados</h5>
          <div v-if="loading" class="spinner-border" role="status"></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Placa</th>
                  <th>Nombre</th>
                  <th>Municipio</th>
                  <th>Marca</th>
                  <th>Modelo</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedRows" :key="r.out_id">
                  <td>{{ r.out_id }}</td>
                  <td>{{ r.out_placa }}</td>
                  <td>{{ r.out_nombre }}</td>
                  <td>{{ r.out_municipio }}</td>
                  <td>{{ r.out_marca }}</td>
                  <td>{{ r.out_modelo }}</td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td colspan="6">
                    <div class="empty-table-state">
                      <font-awesome-icon icon="address-card" class="empty-table-icon" />
                      <p>Ingrese un rango de IDs y presione "Ejecutar"</p>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="rows.length > 0" class="pagination-footer">
            <div class="text-muted">
              <font-awesome-icon icon="list" class="me-1" />
              Mostrando <strong>{{ startRecord }}</strong> a <strong>{{ endRecord }}</strong> de <strong>{{ totalRecords }}</strong> registros
            </div>
            <nav>
              <ul class="pagination mb-0">
                <li class="page-item" :class="{ disabled: currentPage === 1 }">
                  <a class="page-link" href="#" @click.prevent="currentPage = 1">
                    <font-awesome-icon icon="angles-left" />
                  </a>
                </li>
                <li class="page-item" :class="{ disabled: currentPage === 1 }">
                  <a class="page-link" href="#" @click.prevent="previousPage">
                    <font-awesome-icon icon="angle-left" />
                  </a>
                </li>
                <li class="page-item">
                  <span class="page-indicator">{{ currentPage }} / {{ totalPages }}</span>
                </li>
                <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                  <a class="page-link" href="#" @click.prevent="nextPage">
                    <font-awesome-icon icon="angle-right" />
                  </a>
                </li>
                <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                  <a class="page-link" href="#" @click.prevent="currentPage = totalPages">
                    <font-awesome-icon icon="angles-right" />
                  </a>
                </li>
              </ul>
            </nav>
            <div class="pagination-size">
              <select v-model.number="pageSize" class="municipal-form-control" @change="resetPagination">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - ImpPadronPublicos"
    >
      <h3>Imp Padron Publicos</h3>
      <p>Documentacion del modulo Estacionamiento Publico.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'ImpPadronPublicos'"
      :moduleName="'estacionamiento_publico'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'public'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const id1 = ref(1)
const id2 = ref(100)
const rows = ref([])

// Paginación
const currentPage = ref(1)
const pageSize = ref(25)

const totalRecords = computed(() => rows.value.length)
const totalPages = computed(() => Math.ceil(totalRecords.value / pageSize.value))
const startRecord = computed(() => (currentPage.value - 1) * pageSize.value + 1)
const endRecord = computed(() => Math.min(currentPage.value * pageSize.value, totalRecords.value))

const paginatedRows = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return rows.value.slice(start, end)
})

const nextPage = () => {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
  }
}

const previousPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

const resetPagination = () => {
  currentPage.value = 1
}

async function consultar() {
  if (!id1.value || !id2.value) {
    showToast('warning', 'Ingrese el rango de IDs')
    return
  }

  if (id1.value > id2.value) {
    showToast('warning', 'El ID inicial debe ser menor o igual al ID final')
    return
  }

  if (id2.value - id1.value > 1000) {
    showToast('warning', 'El rango máximo es de 1000 registros')
    return
  }

  showLoading('Consultando...', 'Obteniendo padrón vehicular')
  rows.value = []
  resetPagination()
  try {
    const params = [
      { nombre: 'p_id1', valor: id1.value, tipo: 'integer' },
      { nombre: 'p_id2', valor: id2.value, tipo: 'integer' }
    ]
    const resp = await execute('sp_get_padron_report', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    rows.value = Array.isArray(data) ? data : []

    if (rows.value.length === 0) {
      showToast('info', 'No se encontraron registros en el rango especificado')
    } else {
      showToast('success', `Se encontraron ${rows.value.length} registros`)
    }
  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>

