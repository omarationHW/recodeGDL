<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="church" />
      </div>
      <div class="module-view-info">
        <h1>Consulta Cementerio San Andrés</h1>
        <p>Cementerios - Consulta de folios del Cementerio San Andrés</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-purple"
          @click="mostrarAyuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Botones de Acción -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Listado de Folios
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="cargarFolios"
              :disabled="loading"
            >
              <font-awesome-icon icon="sync" />
              {{ folios.length > 0 ? 'Actualizar' : 'Cargar Folios' }}
            </button>
          </div>
        </div>
      </div>

      <!-- Resultados -->
      <div class="municipal-card" v-if="folios.length > 0">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Folios del Cementerio San Andrés
          </h5>
          <div class="header-right">
            <span class="badge-purple">
              {{ formatNumber(totalRecords) }} registros
            </span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Folio</th>
                  <th>Titular</th>
                  <th>Domicilio</th>
                  <th>Ubicación</th>
                  <th>Año Pagado</th>
                  <th>Metros</th>
                  <th>Acción</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="folio in paginatedFolios" :key="folio.control_rcm" class="row-hover">
                  <td><strong class="text-primary">{{ folio.control_rcm }}</strong></td>
                  <td>{{ folio.nombre }}</td>
                  <td>{{ formatearDomicilio(folio) }}</td>
                  <td><small>{{ formatearUbicacion(folio) }}</small></td>
                  <td>{{ folio.axo_pagado }}</td>
                  <td>{{ folio.metros }} m²</td>
                  <td>
                    <button
                      @click="verDetalle(folio.control_rcm)"
                      class="btn-municipal-secondary btn-sm"
                      title="Ver detalle"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de Paginación -->
          <div v-if="folios.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
                de {{ totalRecords }} registros
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
                <option value="5">5</option>
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

      <!-- Sin resultados -->
      <div v-else-if="busquedaRealizada" class="municipal-card">
        <div class="municipal-card-body text-center">
          <font-awesome-icon icon="info-circle" class="text-info" size="2x" />
          <p class="mt-2">No se encontraron folios en este cementerio</p>
        </div>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'ConsultaSAndres'"
      :moduleName="'cementerios'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useRouter } from 'vue-router'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const router = useRouter()

// Estado
const loading = ref(false)
const folios = ref([])
const busquedaRealizada = ref(false)
const showDocumentation = ref(false)

// Sistema de toast manual
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

let toastTimeout = null

const showToast = (type, message) => {
  if (toastTimeout) {
    clearTimeout(toastTimeout)
  }

  toast.value = {
    show: true,
    type,
    message
  }

  toastTimeout = setTimeout(() => {
    hideToast()
  }, 3000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'exclamation-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = computed(() => folios.value.length)

// Métodos
const cargarFolios = async () => {
  loading.value = true
  showLoading('Cargando folios...', 'Por favor espere')
  currentPage.value = 1

  try {
    /* TODO FUTURO: Query SQL original (Pascal ConsultaSAndres.pas línea 54-59, .dfm línea 172-173)
    -- DatabaseName: 'sanandres'
    -- SQL: 'select * from datos'
    -- Sin filtros, sin parámetros - lista TODO el cementerio
    */

    const response = await execute(
      'sp_consultasandres_listar_todos',
      'cementerio',
      [],
      'function',
      null,
      'public'
    )

    if(response?.result?.length > 0) {
      folios.value = response.result
    } else {
      folios.value = []
    }
    busquedaRealizada.value = true

    if (folios.value.length > 0) {
      showToast('success', `Se encontraron ${folios.value.length} folio(s)`)
    } else {
      showToast('info', 'No se encontraron folios en este cementerio')
    }
  } catch (error) {
    console.error('Error al cargar folios:', error)
    showToast('error', 'Error al cargar folios: ' + error.message)
    folios.value = []
  } finally {
    loading.value = false
    hideLoading()
  }
}

const verDetalle = (folio) => {
  router.push({
    name: 'cementerios-conindividual',
    query: { folio }
  })
}

const mostrarAyuda = () => {
  showDocumentation.value = true
}

const closeDocumentation = () => {
  showDocumentation.value = false
}

const formatearUbicacion = (folio) => {
  const partes = []
  partes.push(`Cl:${folio.clase}${folio.clase_alfa || ''}`)
  partes.push(`Sec:${folio.seccion}${folio.seccion_alfa || ''}`)
  partes.push(`Lin:${folio.linea}${folio.linea_alfa || ''}`)
  partes.push(`Fosa:${folio.fosa}${folio.fosa_alfa || ''}`)
  return partes.join(' ')
}

const formatearDomicilio = (folio) => {
  const partes = []
  if (folio.domicilio) partes.push(folio.domicilio)
  if (folio.colonia) partes.push(folio.colonia)
  return partes.join(', ') || 'N/A'
}

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

// Paginación - Computed
const totalPages = computed(() => {
  return Math.ceil(totalRecords.value / itemsPerPage.value)
})

const paginatedFolios = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return folios.value.slice(start, end)
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

// Paginación - Métodos
const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
}

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size)
  currentPage.value = 1
}
</script>
