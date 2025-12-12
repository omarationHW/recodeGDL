<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-circle-check" /></div>
      <div class="module-view-info">
        <h1>Generación — Estacionamientos Públicos</h1>
        <p>Reportes y salidas</p>
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
        <button class="btn-municipal-secondary" :disabled="loading" @click="generar">
          <font-awesome-icon icon="play" /> Generar
        </button>
        <button
          v-if="registros.length > 0"
          class="btn-municipal-primary"
          @click="toggleView"
        >
          <font-awesome-icon :icon="showTable ? 'code' : 'table'" />
          {{ showTable ? 'Ver JSON' : 'Ver Tabla' }}
        </button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Generando...</span>
            </div>
            <p class="mt-3 text-muted">Generando listado...</p>
          </div>

          <!-- Vista JSON -->
          <div v-else-if="!showTable && output">
            <pre class="text-muted">{{ output }}</pre>
          </div>

          <!-- Vista Tabla -->
          <div v-else-if="showTable && registros.length > 0">
            <div class="table-responsive">
              <table class="table table-hover table-striped">
                <thead>
                  <tr>
                    <th v-for="column in columns" :key="column">{{ column }}</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(item, index) in paginatedData" :key="index">
                    <td v-for="column in columns" :key="column">{{ item[column] }}</td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Paginación -->
            <div v-if="totalPages > 1" class="pagination-footer">
              <div class="text-muted">
                <font-awesome-icon icon="list" class="me-1" />
                Mostrando <strong>{{ startRecord }}</strong> a <strong>{{ endRecord }}</strong> de <strong>{{ registros.length }}</strong> registros
              </div>
              <nav>
                <ul class="pagination mb-0">
                  <li class="page-item" :class="{ disabled: currentPage === 1 }">
                    <a class="page-link" href="#" @click.prevent="currentPage = 1">
                      <font-awesome-icon icon="angles-left" />
                    </a>
                  </li>
                  <li class="page-item" :class="{ disabled: currentPage === 1 }">
                    <a class="page-link" href="#" @click.prevent="currentPage--">
                      <font-awesome-icon icon="angle-left" />
                    </a>
                  </li>
                  <li
                    v-for="page in visiblePages"
                    :key="page"
                    class="page-item"
                    :class="{ active: currentPage === page }"
                  >
                    <a class="page-link" href="#" @click.prevent="currentPage = page">{{ page }}</a>
                  </li>
                  <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                    <a class="page-link" href="#" @click.prevent="currentPage++">
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
            </div>
          </div>

          <!-- Estado vacío -->
          <div v-else class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="file-circle-check" />
            </div>
            <h4 class="empty-state-title">Generación de Listados</h4>
            <p class="empty-state-text">Presione "Generar" para obtener el listado de estacionamientos públicos</p>
            <div class="empty-state-example">
              <div class="example-card">
                <div class="example-header">
                  <font-awesome-icon icon="lightbulb" class="example-icon" />
                  <span>Información</span>
                </div>
                <div class="example-body">
                  <div class="example-row">
                    <span class="example-label">1. Clic en "Generar"</span>
                    <span class="example-value">Obtiene todos los registros</span>
                  </div>
                  <div class="example-row">
                    <span class="example-label">2. Ver Tabla/JSON</span>
                    <span class="example-value">Alterna entre vistas</span>
                  </div>
                  <div class="example-row">
                    <span class="example-label">3. Paginación</span>
                    <span class="example-value">Navega entre páginas</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - GenerarPublicos"
    >
      <h3>Generar Publicos</h3>
      <p>Documentacion del modulo Estacionamiento Publico.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'GenerarPublicos'"
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
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const output = ref('')
const registros = ref([])
const showTable = ref(false)
const currentPage = ref(1)
const itemsPerPage = ref(10)

// Computed properties para tabla y paginación
const columns = computed(() => {
  if (registros.value.length > 0) {
    return Object.keys(registros.value[0])
  }
  return []
})

const totalPages = computed(() => {
  return Math.ceil(registros.value.length / itemsPerPage.value)
})

const paginatedData = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return registros.value.slice(start, end)
})

const startRecord = computed(() => {
  return (currentPage.value - 1) * itemsPerPage.value + 1
})

const endRecord = computed(() => {
  const end = currentPage.value * itemsPerPage.value
  return end > registros.value.length ? registros.value.length : end
})

const visiblePages = computed(() => {
  const pages = []
  const total = totalPages.value
  const current = currentPage.value
  const delta = 2

  for (let i = Math.max(2, current - delta); i <= Math.min(total - 1, current + delta); i++) {
    pages.push(i)
  }

  if (current - delta > 2) {
    pages.unshift('...')
  }
  if (current + delta < total - 1) {
    pages.push('...')
  }

  pages.unshift(1)
  if (total > 1) {
    pages.push(total)
  }

  return pages.filter((p, index, arr) => arr.indexOf(p) === index)
})

async function generar() {
  showLoading('Generando...', 'Obteniendo listado')
  output.value = ''
  registros.value = []
  currentPage.value = 1

  try {
    const resp = await execute('sp_get_public_parking_list', BASE_DB, [], '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []

    output.value = JSON.stringify(data, null, 2)

    if (Array.isArray(data) && data.length > 0) {
      registros.value = data
      showTable.value = true
      showToast('success', `Listado generado: ${data.length} registros`)
    } else {
      showToast('info', 'No se encontraron registros')
    }
  } catch (e) {
    handleApiError(e)
    output.value = e.message || 'Error al generar'
  } finally {
    hideLoading()
  }
}

function toggleView() {
  showTable.value = !showTable.value
}

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>

