<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="table" /></div>
      <div class="module-view-info">
        <h1>Listados — Estacionamientos Públicos</h1>
        <p>Reporte por clasificación y sector</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="run"><font-awesome-icon icon="play" /> Ejecutar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width"><label class="municipal-form-label">Ordenar por</label>
              <select class="municipal-form-control" v-model="orderBy">
                <option value="cve_sector, cve_categ, cve_numero">Sector, Categoría, Número</option>
                <option value="cve_categ, cve_sector, cve_numero">Categoría, Sector, Número</option>
                <option value="nombre">Nombre</option>
              </select>
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
                <tr><th>Sector</th><th>Cat</th><th>Número</th><th>Nombre</th><th>Cupo</th></tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedRows" :key="`${r.cve_sector}-${r.cve_categ}-${r.cve_numero}`">
                  <td>{{ r.cve_sector }}</td>
                  <td>{{ r.cve_categ }}</td>
                  <td>{{ r.cve_numero }}</td>
                  <td>{{ r.nombre }}</td>
                  <td>{{ r.cupo }}</td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td colspan="5">
                    <div class="empty-table-state">
                      <font-awesome-icon icon="table" class="empty-state-icon" />
                      <p>Seleccione un orden y presione "Ejecutar"</p>
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
                  <a class="page-link" href="#" @click.prevent="prevPage">
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
              <select v-model.number="pageSize" class="municipal-form-control" @change="currentPage = 1">
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
    
    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'ListadosPublicos'"
      :moduleName="'estacionamiento_publico'"
      :docType="docType"
      :title="'Listados — Estacionamientos Públicos'"
      @close="showDocModal = false"
    />

  </div>
</template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const rows = ref([])
const orderBy = ref('cve_sector, cve_categ, cve_numero')

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

const prevPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

async function run() {
  showLoading('Consultando...', 'Generando listado')
  rows.value = []
  currentPage.value = 1
  try {
    const params = [{ nombre: 'order_by', valor: orderBy.value, tipo: 'string' }]
    const resp = await execute('sqrp_publicos_report', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    rows.value = Array.isArray(data) ? data : []

    if (rows.value.length > 0) {
      showToast('success', `Se encontraron ${rows.value.length} registros`)
    } else {
      showToast('info', 'No se encontraron registros')
    }
  } catch (e) {
    handleApiError(e)
    rows.value = []
  } finally {
    hideLoading()
  }
}

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

</script>

