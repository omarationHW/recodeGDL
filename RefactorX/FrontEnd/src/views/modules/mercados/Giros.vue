<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="tags" />
      </div>
      <div class="module-view-info">
        <h1>Giros Comerciales</h1>
        <p>Inicio > Mercados > Catálogo de Giros</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
        </button>
        
        <button class="btn-municipal-primary" @click="cargarGiros" :disabled="loading">
          <font-awesome-icon :icon="loading ? 'spinner' : 'sync'" :spin="loading" />
          Recargar
        </button>
        
      </div>
    </div>

    <div class="module-view-content">
      <!-- Estadísticas -->
      <div class="stats-grid mb-4">
        <div class="stat-card stat-card-primary">
          <div class="stat-icon">
            <font-awesome-icon icon="tags" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ formatNumber(estadisticas.totalGiros) }}</div>
            <div class="stat-label">Giros Registrados</div>
          </div>
        </div>
        <div class="stat-card stat-card-success">
          <div class="stat-icon">
            <font-awesome-icon icon="store" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ formatNumber(estadisticas.totalLocales) }}</div>
            <div class="stat-label">Locales con Giro</div>
          </div>
        </div>
        <div class="stat-card stat-card-info">
          <div class="stat-icon">
            <font-awesome-icon icon="chart-bar" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ estadisticas.promedio }}</div>
            <div class="stat-label">Promedio Locales/Giro</div>
          </div>
        </div>
      </div>

      <!-- Tabla de giros -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Listado de Giros
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="giros.length > 0">
              {{ giros.length }} giros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando giros...</p>
          </div>

          <!-- Mensaje de error -->
          <div v-else-if="error" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ error }}
          </div>

          <!-- Tabla -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th>ID</th>
                  <th>Descripción</th>
                  <th class="text-end">Locales</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="giros.length === 0">
                  <td colspan="5" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron giros registrados</p>
                  </td>
                </tr>
                <tr v-else v-for="(giro, idx) in paginatedGiros" :key="giro.id_giro" class="row-hover">
                  <td class="text-center">{{ (currentPage - 1) * itemsPerPage + idx + 1 }}</td>
                  <td>
                    <span class="badge-id">{{ giro.id_giro }}</span>
                  </td>
                  <td>
                    <font-awesome-icon icon="tag" class="icon-small text-primary" />
                    <strong>{{ giro.descripcion }}</strong>
                  </td>
                  <td class="text-end">
                    <span class="badge-count">{{ formatNumber(giro.cantidad_locales) }}</span>
                  </td>
                  <td class="text-center">
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click.stop="verLocales(giro)"
                        title="Ver locales">
                        <font-awesome-icon icon="eye" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de paginación -->
          <div v-if="giros.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, giros.length) }}
                de {{ giros.length }} registros
              </span>
            </div>

            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select
                class="municipal-form-control form-control-sm"
                :value="itemsPerPage"
                @change="changePageSize($event.target.value)"
                style="width: auto; display: inline-block;"
              >
                <option value="10">10</option>
                <option value="25">25</option>
                <option value="50">50</option>
                <option value="100">100</option>
              </select>
            </div>

            <div class="pagination-buttons">
              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(1)"
                :disabled="currentPage === 1"
                title="Primera página"
              >
                <font-awesome-icon icon="angle-double-left" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(currentPage - 1)"
                :disabled="currentPage === 1"
                title="Página anterior"
              >
                <font-awesome-icon icon="angle-left" />
              </button>

              <button
                v-for="page in visiblePages"
                :key="page"
                class="btn-sm"
                :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                @click="goToPage(page)"
              >
                {{ page }}
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(currentPage + 1)"
                :disabled="currentPage === totalPages"
                title="Página siguiente"
              >
                <font-awesome-icon icon="angle-right" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(totalPages)"
                :disabled="currentPage === totalPages"
                title="Última página"
              >
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Locales por Giro usando Modal.vue -->
    <Modal
      :show="showModal"
      title=""
      size="xl"
      @close="cerrarModal"
    >
      <template #header>
        <h5 class="modal-title">
          <font-awesome-icon icon="store" />
          Locales con Giro: {{ giroSeleccionado?.descripcion }}
        </h5>
      
  <DocumentationModal :show="showAyuda" :component-name="'Giros'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - Giros'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'Giros'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - Giros'" @close="showDocumentacion = false" />
</template>

      <template #default>
        <!-- Loading -->
        <div v-if="loadingLocales" class="text-center py-5">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
          <p class="mt-3 text-muted">Cargando locales...</p>
        </div>

        <!-- Tabla de locales -->
        <div v-else class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Control</th>
                <th>Oficina</th>
                <th>Mercado</th>
                <th>Cat.</th>
                <th>Sección</th>
                <th>Local</th>
                <th>Letra</th>
                <th>Nombre</th>
                <th>Arrendatario</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="locales.length === 0">
                <td colspan="9" class="text-center text-muted">
                  <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                  <p>No se encontraron locales</p>
                </td>
              </tr>
              <tr v-else v-for="local in locales" :key="local.id_local" class="row-hover">
                <td><strong class="text-primary">{{ local.id_local }}</strong></td>
                <td>{{ local.oficina }}</td>
                <td>{{ local.num_mercado }}</td>
                <td>{{ local.categoria }}</td>
                <td>{{ local.seccion }}</td>
                <td><span class="badge-local">{{ local.local }}</span></td>
                <td>{{ local.letra_local || '-' }}</td>
                <td>{{ local.nombre || 'N/A' }}</td>
                <td>{{ local.arrendatario || 'N/A' }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>

      <template #footer>
        <button type="button" class="btn-municipal-secondary" @click="cerrarModal">
          <font-awesome-icon icon="times" />
          Cerrar
        </button>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import apiService from '@/services/apiService';
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import Modal from '@/components/common/Modal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


// Composables
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

// Estado
const loading = ref(false)
const loadingLocales = ref(false)
const error = ref('')
const giros = ref([])
const locales = ref([])
const showModal = ref(false)
const giroSeleccionado = ref(null)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)

// Computed para estadísticas
const estadisticas = computed(() => {
  const totalGiros = giros.value.length
  const totalLocales = giros.value.reduce((sum, g) => sum + parseInt(g.cantidad_locales || 0), 0)
  const promedio = totalGiros > 0 ? Math.round(totalLocales / totalGiros) : 0

  return {
    totalGiros,
    totalLocales,
    promedio
  }
})

// Computed para paginación
const totalPages = computed(() => {
  return Math.ceil(giros.value.length / itemsPerPage.value)
})

const paginatedGiros = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return giros.value.slice(start, end)
})

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPages.value, startPage + maxVisible - 1)

  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }

  return pages
})

// Métodos de paginación
const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

const changePageSize = (newSize) => {
  itemsPerPage.value = parseInt(newSize)
  currentPage.value = 1
}

const resetPagination = () => {
  currentPage.value = 1
  itemsPerPage.value = 10
}

// Métodos de UI
const mostrarAyuda = () => {
  showToast('Este catálogo muestra todos los giros comerciales registrados en los locales de mercados.', 'info')
}

// Utilidades
const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

// API
const cargarGiros = async () => {
  loading.value = true
  error.value = ''
  showLoading('Cargando giros comerciales...', 'Por favor espere')

  try {
    const response = await apiService.execute(
          'sp_giros_list',
          'mercados',
          [],
          '',
          null,
          'publico'
        )

    if (response && response.success === true) {
      giros.value = response.data.result || []
      resetPagination()
      if (giros.value.length > 0) {
        showToast(`Se cargaron ${giros.value.length} giros`, 'success')
      }
    } else {
      error.value = response?.message || 'Error al cargar giros'
      showToast(error.value, 'error')
    }
  } catch (err) {
    error.value = err.response?.message || 'Error al cargar giros'
    console.error('Error al cargar giros:', err)
    showToast(error.value, 'error')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const verLocales = async (giro) => {
  giroSeleccionado.value = giro
  showModal.value = true
  loadingLocales.value = true
  locales.value = []
  showLoading('Cargando locales del giro...', 'Por favor espere')

  try {
    const response = await apiService.execute(
          'sp_giros_locales',
          'mercados',
          [
          { nombre: 'p_id_giro', valor: giro.id_giro }
        ],
          '',
          null,
          'publico'
        )

    if (response && response.success === true) {
      locales.value = response.data.result || []
    } else {
      showToast('Error al cargar locales', 'error')
    }
  } catch (err) {
    console.error('Error al cargar locales:', err)
    showToast('Error al cargar locales', 'error')
  } finally {
    loadingLocales.value = false
    hideLoading()
  }
}

const cerrarModal = () => {
  showModal.value = false
  locales.value = []
  giroSeleccionado.value = null
}

// Lifecycle
onMounted(() => {
  cargarGiros()
})
</script>
