<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="leaf" />
      </div>
      <div class="module-view-info">
        <h1>Consulta Cementerio Jardín</h1>
        <p>Cementerios - Búsqueda de folios del Cementerio Jardín</p>
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
      <!-- Filtros de Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Consulta
          </h5>
        </div>
        <div class="municipal-card-body">
          <!-- Tipo de búsqueda -->
          <div class="form-row mb-3">
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Búsqueda</label>
              <div class="radio-group">
                <label class="radio-label">
                  <input type="radio" v-model="tipoBusqueda" value="ubicacion" />
                  Por Ubicación (Clase/Sección/Línea)
                </label>
                <label class="radio-label">
                  <input type="radio" v-model="tipoBusqueda" value="nombre" />
                  Por Nombre del Titular
                </label>
                <label class="radio-label">
                  <input type="radio" v-model="tipoBusqueda" value="todos" />
                  Listar Todos
                </label>
              </div>
            </div>
          </div>

          <!-- Filtros por ubicación -->
          <div v-if="tipoBusqueda === 'ubicacion'" class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Clase</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filtros.clase"
                placeholder="Número de clase..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Sección</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filtros.seccion"
                placeholder="Número de sección..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Línea (desde)</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filtros.linea"
                placeholder="Número de línea..."
              />
            </div>
          </div>

          <!-- Filtro por nombre -->
          <div v-if="tipoBusqueda === 'nombre'" class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label required">Nombre del Titular</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtros.nombre"
                @keyup.enter="buscarFolios"
                placeholder="Ingrese nombre del titular..."
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
              Buscar
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
            Folios del Cementerio Jardín
          </h5>
          <div class="header-right">
            <span class="badge-purple">
              {{ formatNumber(totalRecords) }} registros
            </span>
          </div>
        </div>
        <div class="municipal-card-body">
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
                <tr v-for="folio in paginatedFolios" :key="folio.control_rcm">
                  <td><strong>{{ folio.control_rcm }}</strong></td>
                  <td>{{ folio.nombre }}</td>
                  <td>{{ formatearDomicilio(folio) }}</td>
                  <td>{{ formatearUbicacion(folio) }}</td>
                  <td>{{ folio.axo_pagado }}</td>
                  <td>{{ folio.metros }} m²</td>
                  <td>
                    <button
                      @click="verDetalle(folio.control_rcm)"
                      class="btn-municipal-secondary btn-sm"
                    >
                      <font-awesome-icon icon="eye" />
                      Ver
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

    <!-- Modal de Ayuda/Documentación -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'ConsultaJardin'"
      :moduleName="'cementerios'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useRouter } from 'vue-router'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const router = useRouter()

// Sistema de Toast manual
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

const showToast = (type, message) => {
  toast.value = { show: true, type, message }
  setTimeout(() => {
    hideToast()
  }, 4000)
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

// Modal de documentación
const showDocumentation = ref(false)
const mostrarAyuda = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

// Estado
const loading = ref(false)
const tipoBusqueda = ref('todos') // ubicacion, nombre, todos
const filtros = reactive({
  clase: null,
  seccion: null,
  linea: null,
  nombre: ''
})
const folios = ref([])
const busquedaRealizada = ref(false)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)

// Computed - Paginación
const totalRecords = computed(() => folios.value.length)

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

// Métodos
const buscarFolios = async () => {
  // Validaciones según tipo de búsqueda
  if (tipoBusqueda.value === 'ubicacion') {
    if (!filtros.clase || !filtros.seccion || !filtros.linea) {
      showToast('warning', 'Debe completar Clase, Sección y Línea')
      return
    }
  }

  if (tipoBusqueda.value === 'nombre') {
    if (!filtros.nombre.trim()) {
      showToast('warning', 'Debe ingresar un nombre para buscar')
      return
    }
    if (filtros.nombre.trim().length < 3) {
      showToast('warning', 'El nombre debe tener al menos 3 caracteres')
      return
    }
  }

  loading.value = true
  showLoading()
  currentPage.value = 1

  try {
    /* TODO FUTURO: Queries SQL originales (Pascal ConsultaJardin.pas)
    -- Por ubicación (RCM):
    SELECT * FROM regprop WHERE clase=:vclase AND seccion=:vsec AND linea>=:vlinea

    -- Por nombre:
    SELECT * FROM regprop WHERE nombre LIKE :nom

    -- Por ppago (OMITIDO - campo no existe en ta_13_datosrcm):
    SELECT * FROM regprop WHERE ppago LIKE :vpago
    */

    let response

    if (tipoBusqueda.value === 'ubicacion') {
      // Búsqueda por ubicación usando SP
      response = await execute(
        'sp_consultajardin_buscar_por_ubicacion',
        'cementerio',
        [
        { nombre: 'p_clase', valor: filtros.clase, tipo: 'integer' },
        { nombre: 'p_seccion', valor: filtros.seccion, tipo: 'integer' },
        { nombre: 'p_linea', valor: filtros.linea, tipo: 'integer' }  
        ],
        'function',
        null,
        'publico'
      )
    } else if (tipoBusqueda.value === 'nombre') {
      // Búsqueda por nombre usando SP
      response = await execute(
        'sp_consultajardin_buscar_por_nombre',
        'cementerio',
        [
         { nombre: 'p_nombre', valor: filtros.nombre, tipo: 'varchar' },
         { nombre: 'p_limite', valor: 1000, tipo: 'integer' },
         { nombre: 'p_offset', valor: 0, tipo: 'integer' }
        ],
        'function',
        null,
        'publico'
      )
    } else {
      // Listar todos usando SP
      response = await execute(
        'sp_consultajardin_listar_todos',
        'cementerio',
        [
        { nombre: 'p_limite', valor: 1000, tipo: 'integer' },
        { nombre: 'p_offset', valor: 0, tipo: 'integer' }
        ],
        'function',
        null,
        'publico'
      )
    }

    if (response?.result?.length > 0) {
      folios.value = response.result
    }
    busquedaRealizada.value = true

    if (folios.value.length > 0) {
      showToast('success', `Se encontraron ${folios.value.length} folio(s)`)
    } else {
      showToast('info', 'No se encontraron folios con los criterios especificados')
    }
  } catch (error) {
    console.error('Error al buscar folios:', error)
    showToast('error', 'Error al buscar folios: ' + error.message)
    folios.value = []
  } finally {
    loading.value = false
    hideLoading()
  }
}

// MÉTODO COMENTADO - Reemplazado por sistema de paginación con botones
/*
const cargarMas = async () => {
  loading.value = true
  showLoading()
  paginaActual.value++

  try {
    const offset = paginaActual.value * LIMITE_RESULTADOS
    let response

    if (tipoBusqueda.value === 'nombre') {
      response = await execute(
        'sp_consultajardin_buscar_por_nombre',
        'cementerio',
        [
        { nombre: 'p_nombre', valor: filtros.nombre, tipo: 'varchar' },
         { nombre: 'p_limite', valor: LIMITE_RESULTADOS, tipo: 'integer' },
         { nombre: 'p_offset', valor: offset, tipo: 'integer' }
        ],
        'function',
        null,
        'publico'
      )
    } else {
      // Para listar todos (ubicación no aplica paginación porque es filtro específico)
      response = await execute(
        'sp_consultajardin_listar_todos',
        'cementerio',
        [
          { nombre: 'p_limite', valor: LIMITE_RESULTADOS, tipo: 'integer' },
          { nombre: 'p_offset', valor: offset, tipo: 'integer' }
      ],
        'function',
        null,
        'publico'
      )
    }
    const nuevosFolios = []
    if(response?.result?.length > 0) {
      nuevosFolios= response.result
    }

    if (nuevosFolios.length === 0) {
      hayMasResultados.value = false
      showToast('info', 'No hay más registros')
    } else {
      folios.value = [...folios.value, ...nuevosFolios]
      hayMasResultados.value = nuevosFolios.length === LIMITE_RESULTADOS
      showToast('success', `Se cargaron ${nuevosFolios.length} folio(s) adicionales`)
    }
  } catch (error) {
    console.error('Error al cargar más folios:', error)
    showToast('error', 'Error al cargar más folios: ' + error.message)
  } finally {
    loading.value = false
    hideLoading()
  }
}
*/

const limpiarFiltros = () => {
  filtros.clase = null
  filtros.seccion = null
  filtros.linea = null
  filtros.nombre = ''
  folios.value = []
  busquedaRealizada.value = false
  currentPage.value = 1
}

const verDetalle = (folio) => {
  router.push({
    name: 'cementerios-conindividual',
    query: { folio }
  })
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

// Métodos de paginación
const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
}

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size)
  currentPage.value = 1
}

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}
</script>
