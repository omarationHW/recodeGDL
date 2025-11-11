<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="list-ul" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Rubros</h1>
        <p>Gestión de rubros de obligaciones fiscales</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-primary"
          @click="toggleFormulario"
        >
          <font-awesome-icon :icon="showFormulario ? 'times' : 'plus'" />
          {{ showFormulario ? 'Cancelar' : 'Nuevo Rubro' }}
        </button>
        <button
          class="btn-municipal-secondary"
          @click="actualizarListado"
        >
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Panel de Estadísticas -->
      <div class="stats-grid" v-if="loadingEstadisticas">
        <div class="stat-card stat-card-loading" v-for="n in 2" :key="`loading-${n}`">
          <div class="stat-content">
            <div class="skeleton-icon"></div>
            <div class="skeleton-number"></div>
            <div class="skeleton-label"></div>
          </div>
        </div>
      </div>

      <!-- Cards de estadísticas con datos -->
      <div class="stats-grid" v-else-if="!loadingEstadisticas">
        <div class="stat-card stat-activos">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="check-circle" />
            </div>
            <h3 class="stat-number">{{ formatNumber(stats.totales) }}</h3>
            <p class="stat-label">Rubros Totales</p>
          </div>
        </div>

        <div class="stat-card stat-inactivos">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="magic" />
            </div>
            <h3 class="stat-number">{{ formatNumber(stats.automaticos) }}</h3>
            <p class="stat-label">Rubros Automáticos</p>
          </div>
        </div>
      </div>

      <!-- Formulario de Creación (colapsable) -->
      <div class="municipal-card" v-show="showFormulario">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="plus-circle" />
            Crear Nuevo Rubro
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="handleCrear">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">
                  Nombre del Rubro:
                  <span class="required">*</span>
                </label>
                <input
                  type="text"
                  v-model="formData.nombre"
                  class="municipal-form-control"
                  placeholder="Ingrese el nombre del rubro"
                  maxlength="200"
                  required
                />
              </div>
            </div>

            <div class="button-group">
              <button
                type="submit"
                class="btn-municipal-success"
                :disabled="loading"
              >
                <font-awesome-icon icon="check" />
                Guardar Rubro
              </button>
              <button
                type="button"
                class="btn-municipal-secondary"
                @click="cancelarCreacion"
              >
                <font-awesome-icon icon="times" />
                Cancelar
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div
          class="municipal-card-header"
          @click="toggleFilters"
          style="cursor: pointer;"
        >
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Búsqueda
            <font-awesome-icon
              :icon="showFilters ? 'chevron-up' : 'chevron-down'"
              class="ms-2"
            />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Nombre del Rubro</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtros.nombre"
                placeholder="Buscar por nombre"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo</label>
              <select class="municipal-form-control" v-model="filtros.auto_tab">
                <option value="">Todos</option>
                <option value="true">Automáticos</option>
                <option value="false">Manuales</option>
              </select>
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="buscarRubros"
            >
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button
              class="btn-municipal-secondary"
              @click="limpiarFiltros"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <div class="header-with-badge">
            <h5>
              <font-awesome-icon icon="list" />
              Listado de Rubros
            </h5>
            <span class="badge-purple" v-if="totalResultados > 0">
              {{ formatNumber(totalResultados) }} registro(s) total(es)
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th class="text-center">Clave</th>
                  <th>Nombre del Rubro</th>
                  <th class="text-center">Tipo</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <!-- Sin búsqueda -->
                <tr v-if="rubros.length === 0 && !primeraBusqueda">
                  <td colspan="4" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Utiliza los filtros de búsqueda para encontrar rubros</p>
                  </td>
                </tr>

                <!-- Sin resultados -->
                <tr v-else-if="rubros.length === 0">
                  <td colspan="4" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron rubros con los filtros especificados</p>
                  </td>
                </tr>

                <!-- Resultados -->
                <tr
                  v-else
                  v-for="rubro in rubrosPaginados"
                  :key="rubro.cve_tab"
                  @click="rubroSeleccionado = rubro"
                  :class="{ 'row-hover': true, 'selected-row': rubroSeleccionado?.cve_tab === rubro.cve_tab }"
                  style="cursor: pointer;"
                >
                  <td class="text-center">
                    <strong class="text-primary">{{ rubro.cve_tab }}</strong>
                  </td>
                  <td>{{ rubro.nombre }}</td>
                  <td class="text-center">
                    <span
                      class="badge"
                      :class="rubro.auto_tab ? 'badge-success' : 'badge-purple'"
                    >
                      <font-awesome-icon
                        :icon="rubro.auto_tab ? 'magic' : 'hand-paper'"
                      />
                      {{ rubro.auto_tab ? 'Automático' : 'Manual' }}
                    </span>
                  </td>
                  <td class="text-center">
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-info btn-sm"
                        @click.stop="verDetalle(rubro)"
                        title="Ver detalles"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click.stop="editarRubro(rubro)"
                        title="Editar rubro"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        class="btn-municipal-danger btn-sm"
                        @click.stop="eliminarRubro(rubro)"
                        title="Eliminar rubro"
                      >
                        <font-awesome-icon icon="trash" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Controles de Paginación -->
        <div v-if="rubros.length > 0" class="pagination-controls">
          <div class="pagination-info">
            <span class="text-muted">
              Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
              a {{ Math.min(currentPage * itemsPerPage, totalResultados) }}
              de {{ totalResultados }} registros
            </span>
          </div>

          <div class="pagination-size">
            <label class="municipal-form-label me-2">Registros por página:</label>
            <select
              class="municipal-form-control form-control-sm"
              v-model="itemsPerPage"
              @change="changePageSize"
              style="width: auto; display: inline-block;"
            >
              <option :value="10">10</option>
              <option :value="20">20</option>
              <option :value="50">50</option>
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

    <!-- Modal de Detalle -->
    <Modal
      :show="showDetalleModal"
      :title="`Detalle del Rubro - ${rubroSeleccionado.nombre || ''}`"
      size="md"
      @close="closeDetalleModal"
      :showDefaultFooter="false"
    >
      <div v-if="rubroSeleccionado.cve_tab" class="rubro-details">
        <div class="detail-section">
          <h6 class="section-title">
            <font-awesome-icon icon="info-circle" />
            Información General
          </h6>
          <table class="detail-table">
            <tr>
              <td class="label">Clave:</td>
              <td><strong class="text-primary">{{ rubroSeleccionado.cve_tab }}</strong></td>
            </tr>
            <tr>
              <td class="label">Nombre:</td>
              <td>{{ rubroSeleccionado.nombre }}</td>
            </tr>
            <tr>
              <td class="label">Tipo:</td>
              <td>
                <span
                  class="badge"
                  :class="rubroSeleccionado.auto_tab ? 'badge-success' : 'badge-purple'"
                >
                  <font-awesome-icon
                    :icon="rubroSeleccionado.auto_tab ? 'magic' : 'hand-paper'"
                  />
                  {{ rubroSeleccionado.auto_tab ? 'Automático' : 'Manual' }}
                </span>
              </td>
            </tr>
          </table>
        </div>

        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="closeDetalleModal">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
          <button class="btn-municipal-primary" @click="editarRubro(rubroSeleccionado); closeDetalleModal()">
            <font-awesome-icon icon="edit" />
            Editar Rubro
          </button>
        </div>
      </div>
    </Modal>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <div class="toast-content">
        <span class="toast-message">{{ toast.message }}</span>
        <span v-if="toast.duration" class="toast-duration">
          <font-awesome-icon icon="clock" />
          {{ toast.duration }}
        </span>
      </div>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'Rubros'"
      :moduleName="'otras_obligaciones'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

// Composables
const router = useRouter()
const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const loading = ref(false)
const showDocumentation = ref(false)
const showFormulario = ref(false)
const showFilters = ref(false)
const showDetalleModal = ref(false)
const rubros = ref([])
const rubroSeleccionado = ref({})
const primeraBusqueda = ref(false)
const loadingEstadisticas = ref(true)
const currentPage = ref(1)
const itemsPerPage = ref(20)

// Estadísticas
const stats = ref({
  totales: 0,
  automaticos: 0
})

// Filtros
const filtros = ref({
  nombre: '',
  auto_tab: ''
})

// Formulario
const formData = reactive({
  nombre: ''
})

// Computed
const totalResultados = computed(() => rubros.value.length)

const totalPages = computed(() => {
  return Math.ceil(totalResultados.value / itemsPerPage.value)
})

const visiblePages = computed(() => {
  const pages = []
  const start = Math.max(1, currentPage.value - 2)
  const end = Math.min(totalPages.value, currentPage.value + 2)

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

const rubrosPaginados = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return rubros.value.slice(start, end)
})

// Métodos de navegación
const toggleFormulario = () => {
  showFormulario.value = !showFormulario.value
  if (showFormulario.value) {
    formData.nombre = ''
  }
}

const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

// Métodos de datos
const cargarRubros = async () => {
  const startTime = performance.now()
  showLoading('Cargando rubros...', 'Consultando base de datos')
  primeraBusqueda.value = true
  showFilters.value = false

  try {
    const response = await execute(
      'sp_rubros_listar',       // Nombre del SP (a crear en BD)
      'otras_obligaciones',     // Módulo
      [],                       // Sin parámetros - lista todos
      '',                       // Tenant vacío
      null,                     // Sin paginación
      'public'                  // Esquema
    )

    if (response && response.result) {
      rubros.value = response.result
    } else {
      rubros.value = []
    }

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const timeMessage = duration < 1
      ? `${(duration * 1000).toFixed(0)}ms`
      : `${duration}s`

    showToast('success', `${rubros.value.length} rubro(s) cargado(s)`, timeMessage)

    // Actualizar estadísticas
    calcularEstadisticas()
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
    loadingEstadisticas.value = false
  }
}

const buscarRubros = async () => {
  const startTime = performance.now()
  showLoading('Buscando rubros...', 'Aplicando filtros')
  primeraBusqueda.value = true
  showFilters.value = false

  try {
    const response = await execute(
      'sp_rubros_listar',
      'otras_obligaciones',
      [],
      '',
      null,
      'public'
    )

    let datos = []
    if (response && response.result) {
      datos = response.result
    }

    // Aplicar filtros locales
    if (filtros.value.nombre) {
      const nombreBuscar = filtros.value.nombre.toLowerCase()
      datos = datos.filter(r => r.nombre.toLowerCase().includes(nombreBuscar))
    }

    if (filtros.value.auto_tab !== '') {
      const autoValue = filtros.value.auto_tab === 'true'
      datos = datos.filter(r => r.auto_tab === autoValue)
    }

    rubros.value = datos
    currentPage.value = 1

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const timeMessage = duration < 1
      ? `${(duration * 1000).toFixed(0)}ms`
      : `${duration}s`

    showToast('success', `${rubros.value.length} rubro(s) encontrado(s)`, timeMessage)

    // Actualizar estadísticas con datos filtrados
    calcularEstadisticas()
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const actualizarListado = () => {
  cargarRubros()
}

const limpiarFiltros = () => {
  filtros.value = {
    nombre: '',
    auto_tab: ''
  }
  currentPage.value = 1
  cargarRubros()
}

const calcularEstadisticas = () => {
  stats.value.totales = rubros.value.length
  stats.value.automaticos = rubros.value.filter(r => r.auto_tab === true).length
}

// Métodos CRUD
const handleCrear = async () => {
  if (!formData.nombre || formData.nombre.trim() === '') {
    showToast('warning', 'Debe ingresar el nombre del rubro')
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar creación?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se creará un nuevo rubro con los siguientes datos:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Nombre:</strong> ${formData.nombre}</li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear rubro',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  const startTime = performance.now()
  showLoading('Creando rubro...', 'Guardando información')

  try {
    const params = [
      { nombre: 'par_nombre', valor: formData.nombre.trim(), tipo: 'varchar' }
    ]

    const response = await execute(
      'ins34_rubro_01',         // SP existente para insertar
      'otras_obligaciones',     // Módulo
      params,                   // Parámetros
      '',                       // Tenant vacío
      null,                     // Sin paginación
      'public'                  // Esquema
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const timeMessage = duration < 1
      ? `${(duration * 1000).toFixed(0)}ms`
      : `${duration}s`

    hideLoading()

    // Verificar respuesta del SP
    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]

      if (resultado.status > 0) {
        // Éxito - status > 0 es el ID del nuevo rubro
        await Swal.fire({
          icon: 'success',
          title: 'Rubro creado!',
          text: resultado.concepto_status || 'El rubro ha sido creado exitosamente',
          confirmButtonColor: '#ea8215'
        })

        showToast('success', resultado.concepto_status || 'Rubro creado exitosamente', timeMessage)
        formData.nombre = ''
        showFormulario.value = false
        await cargarRubros()
      } else {
        // Error de negocio (duplicado, validación, etc.)
        await Swal.fire({
          icon: 'error',
          title: 'Error al crear rubro',
          text: resultado.concepto_status || 'No se pudo crear el rubro',
          confirmButtonColor: '#ea8215'
        })
        showToast('error', resultado.concepto_status || 'Error al crear el rubro')
      }
    } else {
      throw new Error('No se recibió respuesta del servidor')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const cancelarCreacion = () => {
  formData.nombre = ''
  showFormulario.value = false
  showToast('info', 'Creación cancelada')
}

const verDetalle = (rubro) => {
  rubroSeleccionado.value = rubro
  showDetalleModal.value = true
}

const closeDetalleModal = () => {
  showDetalleModal.value = false
  rubroSeleccionado.value = {}
}

const editarRubro = async (rubro) => {
  await Swal.fire({
    icon: 'info',
    title: 'Editar Rubro',
    text: `Funcionalidad para editar el rubro "${rubro.nombre}" (Clave: ${rubro.cve_tab})`,
    confirmButtonColor: '#ea8215'
  })
}

const eliminarRubro = async (rubro) => {
  const result = await Swal.fire({
    icon: 'warning',
    title: '¿Eliminar rubro?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p>¿Está seguro que desea eliminar el siguiente rubro?</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Clave:</strong> ${rubro.cve_tab}</li>
          <li style="margin: 5px 0;"><strong>Nombre:</strong> ${rubro.nombre}</li>
        </ul>
        <p style="color: #dc3545; margin-top: 10px;"><strong>Esta acción no se puede deshacer</strong></p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await Swal.fire({
      icon: 'info',
      title: 'Funcionalidad en desarrollo',
      text: 'El procedimiento de eliminación aún no está implementado',
      confirmButtonColor: '#ea8215'
    })
  }
}

// Paginación
const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

const changePageSize = () => {
  currentPage.value = 1
}

// Utilidades
const formatNumber = (num) => {
  return new Intl.NumberFormat('es-MX').format(num)
}

// Documentación
const openDocumentation = () => {
  showDocumentation.value = true
}

const closeDocumentation = () => {
  showDocumentation.value = false
}

// Lifecycle
onMounted(() => {
  cargarRubros()
})
</script>
