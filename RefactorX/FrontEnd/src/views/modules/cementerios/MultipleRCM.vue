<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="map-marker-alt" />
      </div>
      <div class="module-view-info">
        <h1>Consulta Múltiple por Ubicación</h1>
        <p>Cementerios - Búsqueda de folios por ubicación física (RCM)</p>
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
      <!-- Sección de Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Criterios de Búsqueda
          </h5>
        </div>
        <div class="municipal-card-body">
          <!-- Cementerio -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Cementerio</label>
              <select
                class="municipal-form-control"
                v-model="filtros.cementerio"
              >
                <option value="">Seleccione...</option>
                <option
                  v-for="cem in cementerios"
                  :key="cem.cementerio"
                  :value="cem.cementerio"
                >
                  {{ cem.nombre_cementerio }}
                </option>
              </select>
            </div>
          </div>

          <!-- Ubicación: Clase y Sección -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Clase >=</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filtros.clase"
                placeholder="0"
                min="0"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Clase Alfabético</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtros.clase_alfa"
                maxlength="10"
                placeholder="Opcional..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Sección >=</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filtros.seccion"
                placeholder="0"
                min="0"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Sección Alfabético</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtros.seccion_alfa"
                maxlength="10"
                placeholder="Opcional..."
              />
            </div>
          </div>

          <!-- Ubicación: Línea y Fosa -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Línea >=</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filtros.linea"
                placeholder="0"
                min="0"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Línea Alfabético</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtros.linea_alfa"
                maxlength="10"
                placeholder="Opcional..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fosa >=</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filtros.fosa"
                placeholder="0"
                min="0"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fosa Alfabético</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtros.fosa_alfa"
                maxlength="10"
                placeholder="Opcional..."
              />
            </div>
          </div>

          <!-- Botones -->
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="buscarFolios"
              :disabled="loading"
            >
              <font-awesome-icon icon="search" />
              Buscar Folios
            </button>
            <button
              class="btn-municipal-secondary"
              @click="limpiarFiltros"
              :disabled="loading"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Resultados -->
      <div class="municipal-card" v-if="folios.length > 0">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Folios Encontrados
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
                  <th>Nombre</th>
                  <th>Ubicación</th>
                  <th>Año Pag.</th>
                  <th>Metros</th>
                  <th>Estado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="folio in paginatedFolios" :key="folio.control_rcm" class="row-hover">
                  <td><strong class="text-primary">{{ folio.control_rcm }}</strong></td>
                  <td>{{ folio.nombre }}</td>
                  <td><small>{{ formatearUbicacion(folio) }}</small></td>
                  <td>{{ folio.axo_pagado || '-' }}</td>
                  <td>{{ formatearMoneda(folio.metros) }}</td>
                  <td>
                    <span class="badge badge-success" v-if="folio.vigencia === 'A'">
                      <font-awesome-icon icon="check-circle" />
                      Activo
                    </span>
                    <span class="badge badge-danger" v-else>
                      <font-awesome-icon icon="times-circle" />
                      Baja
                    </span>
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
          <p class="mt-2">No se encontraron folios con los criterios especificados</p>
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
      :componentName="'MultipleRCM'"
      :moduleName="'cementerios'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const loading = ref(false)
const showDocumentation = ref(false)
const busquedaRealizada = ref(false)
const cementerios = ref([])
const folios = ref([])

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

const filtros = reactive({
  cementerio: '',
  clase: 0,
  clase_alfa: '',
  seccion: 0,
  seccion_alfa: '',
  linea: 0,
  linea_alfa: '',
  fosa: 0,
  fosa_alfa: ''
})

// Métodos
onMounted(async () => {
  await cargarCementerios()
})

const cargarCementerios = async () => {
  try {
    /* TODO FUTURO: Query SQL original (MultipleRCM.pas línea 128):
    -- qrycem.open; (select * from tc_13_cementerios)
    */
    // Se utiliza sp Generico para mejorar rendimiento
    const response = await execute(
      //'sp_multiplercm_listar_cementerios',
      'sp_get_cementerios_list',
      'cementerio',
      [],
      'function',
      null,
      'public'
    )

     if (response?.result?.length > 0) {
      cementerios.value = response.result
    }
  } catch (error) {
    console.error('Error al cargar cementerios:', error)
    showToast('error', 'Error al cargar cementerios: ' + error.message)
  }
}

const buscarFolios = async () => {
  // Validaciones
  if (!filtros.cementerio) {
    showToast('warning', 'Seleccione un cementerio')
    return
  }

  loading.value = true
  showLoading('Buscando folios...', 'Por favor espere')
  currentPage.value = 1

  try {
    /* TODO FUTURO: Query SQL original (MultipleRCM.pas líneas 94-105):
    -- SQL: 'select first 100 * from ta_13_datosrcm where
    --       cementerio=:cem
    --       and clase>=:clase
    --       and seccion>=:seccion
    --       and linea>=:linea
    --       and fosa>=:fosa
    --       and control_rcm>0 order by clase,seccion,linea,fosa'
    -- Nota: Campos alfas comentados en búsqueda inicial (líneas 97, 99, 101)
    */

    const response = await execute(
      'sp_multiplercm_buscar_por_ubicacion',
      'cementerio',
      [
        { nombre: 'p_cementerio', valor: filtros.cementerio, tipo: 'varchar' },
        { nombre: 'p_clase', valor: filtros.clase , tipo: 'smallint' },
        { nombre: 'p_clase_alfa', valor: filtros.clase_alfa || '', tipo: 'varchar' },
        { nombre: 'p_seccion', valor: filtros.seccion , tipo: 'smallint' },
        { nombre: 'p_seccion_alfa', valor: filtros.seccion_alfa || '', tipo: 'varchar' },
        { nombre: 'p_linea', valor: filtros.linea , tipo: 'smallint' },
        { nombre: 'p_linea_alfa', valor: filtros.linea_alfa || '', tipo: 'varchar' },
        { nombre: 'p_fosa', valor: filtros.fosa , tipo: 'smallint' },
        { nombre: 'p_fosa_alfa', valor: filtros.fosa_alfa || '', tipo: 'varchar' }
      ],
      'function',
      null,
      'public'
    )

    if(response?.result?.length > 0){
      folios.value = response.result
    } else {
      folios.value = []
    }

    busquedaRealizada.value = true

    if (folios.value.length > 0) {
      showToast('success', `Se encontraron ${folios.value.length} folio(s)`)
    } else {
      showToast('info', 'No se encontraron folios con los criterios especificados')
    }
  } catch (error) {
    console.error('Error al buscar folios:', error)
    showToast('error', 'Error al realizar la búsqueda: ' + error.message)
    folios.value = []
  } finally {
    loading.value = false
    hideLoading()
  }
}

const limpiarFiltros = () => {
  filtros.cementerio = ''
  filtros.clase = 0
  filtros.clase_alfa = ''
  filtros.seccion = 0
  filtros.seccion_alfa = ''
  filtros.linea = 0
  filtros.linea_alfa = ''
  filtros.fosa = 0
  filtros.fosa_alfa = ''
  folios.value = []
  busquedaRealizada.value = false
  currentPage.value = 1
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

const formatearMoneda = (valor) => {
  if (!valor) return '0.00'
  return parseFloat(valor).toFixed(2)
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
