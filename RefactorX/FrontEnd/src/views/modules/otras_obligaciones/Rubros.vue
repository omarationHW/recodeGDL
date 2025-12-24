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
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
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

      <!-- Grid de Tablas Existentes -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="table" />
            Tablas de Rubros Existentes
          </h5>
          <span class="badge-purple" v-if="rubros.length > 0">
            {{ formatNumber(rubros.length) }} tabla(s)
          </span>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive" style="max-height: 300px; overflow-y: auto;">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th class="text-center">Clave</th>
                  <th>Nombre</th>
                  <th class="text-center">Tipo</th>
                  <th class="text-center">Cajero</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="rubros.length === 0">
                  <td colspan="4" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-state-icon" />
                    <p>No hay tablas disponibles</p>
                  </td>
                </tr>
                <tr
                  v-else
                  v-for="rubro in rubros"
                  :key="rubro.cve_tab"
                  @click="seleccionarRubro(rubro)"
                  :class="{ 'row-hover': true, 'table-row-selected': rubroSeleccionado?.cve_tab === rubro.cve_tab }"
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
                      {{ rubro.auto_tab ? 'Automático' : 'Manual' }}
                    </span>
                  </td>
                  <td class="text-center">{{ rubro.cajero || 'N' }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Grid de Status Seleccionables -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="check-square" />
            Status Disponibles (Selección Múltiple)
          </h5>
          <span class="badge-info" v-if="statusSeleccionados.length > 0">
            {{ statusSeleccionados.length }} seleccionado(s)
          </span>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive" style="max-height: 300px; overflow-y: auto;">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th class="text-center" style="width: 50px;">
                    <input
                      type="checkbox"
                      @change="toggleTodosStatus"
                      :checked="todosStatusSeleccionados"
                    />
                  </th>
                  <th class="text-center">Cve</th>
                  <th>Descripción</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="statusDisponibles.length === 0">
                  <td colspan="3" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-state-icon" />
                    <p>No hay status disponibles</p>
                  </td>
                </tr>
                <tr
                  v-else
                  v-for="status in statusDisponibles"
                  :key="status.cve_stat"
                  @click="toggleStatus(status)"
                  :class="{ 'row-hover': true, 'table-row-selected': isStatusSeleccionado(status) }"
                  style="cursor: pointer;"
                >
                  <td class="text-center">
                    <input
                      type="checkbox"
                      :checked="isStatusSeleccionado(status)"
                      @click.stop="toggleStatus(status)"
                    />
                  </td>
                  <td class="text-center">
                    <strong>{{ status.cve_stat }}</strong>
                  </td>
                  <td>{{ status.descripcion }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

    </div>

    <!-- Modal de Detalle -->
    <div class="modal-overlay" v-if="showDetalleModal" @click.self="closeDetalleModal">
      <div class="modal-dialog">
        <div class="modal-header">
          <h5>Detalle del Rubro</h5>
          <button class="modal-close" @click="closeDetalleModal">
            <font-awesome-icon icon="times" />
          </button>
        </div>
        <div class="modal-body">
          <div class="registro-header" v-if="rubroSeleccionado.cve_tab">
            <div class="registro-control">
              <span class="control-label">Clave</span>
              <span class="control-value">{{ rubroSeleccionado.cve_tab }}</span>
            </div>
            <div class="registro-concesionario">
              <font-awesome-icon icon="list-ul" class="concesionario-icon" />
              <div class="concesionario-info">
                <span class="concesionario-label">Nombre del Rubro</span>
                <span class="concesionario-value">{{ rubroSeleccionado.nombre }}</span>
              </div>
            </div>
          </div>
          <div class="registro-grid" v-if="rubroSeleccionado.cve_tab">
            <div class="registro-item">
              <div class="item-icon">
                <font-awesome-icon :icon="rubroSeleccionado.auto_tab ? 'magic' : 'hand-paper'" />
              </div>
              <div class="item-content">
                <span class="item-label">Tipo de Rubro</span>
                <span class="item-value">{{ rubroSeleccionado.auto_tab ? 'Automático' : 'Manual' }}</span>
              </div>
            </div>
            <div class="registro-item">
              <div class="item-icon">
                <font-awesome-icon icon="cash-register" />
              </div>
              <div class="item-content">
                <span class="item-label">Cajero</span>
                <span class="item-value">{{ rubroSeleccionado.cajero || 'No aplica' }}</span>
              </div>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-municipal-secondary" @click="closeDetalleModal">Cerrar</button>
          <button class="btn-municipal-primary" @click="abrirEdicion">
            <font-awesome-icon icon="edit" /> Editar
          </button>
        </div>
      </div>
    </div>

    <!-- Modal de Nuevo -->
    <div class="modal-overlay" v-if="showFormulario" @click.self="cancelarCreacionSilent">
      <div class="modal-dialog">
        <div class="modal-header">
          <h5>Nuevo Rubro</h5>
          <button class="modal-close" @click="cancelarCreacionSilent">
            <font-awesome-icon icon="times" />
          </button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="municipal-form-label">Nombre del Rubro: <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="formData.nombre"
              maxlength="200"
              placeholder="Ingrese el nombre del rubro"
            />
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-municipal-secondary" @click="cancelarCreacionSilent">Cancelar</button>
          <button class="btn-municipal-success" @click="handleCrear" :disabled="loading || !formData.nombre">
            <font-awesome-icon icon="save" /> Guardar
          </button>
        </div>
      </div>
    </div>

    <!-- Modal de Edición -->
    <div class="modal-overlay" v-if="showEditModal" @click.self="closeEditModal">
      <div class="modal-dialog">
        <div class="modal-header">
          <h5>Editar Rubro</h5>
          <button class="modal-close" @click="closeEditModal">
            <font-awesome-icon icon="times" />
          </button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="municipal-form-label">Clave:</label>
            <input type="text" class="municipal-form-control" :value="editData.cve_tab" disabled />
          </div>
          <div class="form-group mt-3">
            <label class="municipal-form-label">Nombre del Rubro: <span class="required">*</span></label>
            <input type="text" class="municipal-form-control" v-model="editData.nombre" maxlength="200" />
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-municipal-secondary" @click="closeEditModal">Cancelar</button>
          <button class="btn-municipal-success" @click="handleEditar" :disabled="loading || !editData.nombre">
            <font-awesome-icon icon="save" /> Guardar
          </button>
        </div>
      </div>
    </div>

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

    <!-- Modal de Ayuda y Documentacion -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'Rubros'"
      :moduleName="'otras_obligaciones'"
      :docType="docType"
      :title="'Catálogo de Rubros'"
      @close="showDocModal = false"
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
import Swal from 'sweetalert2'

// Composables
const router = useRouter()
const { execute } = useApi()
const BASE_DB = 'otras_obligaciones'
const { showLoading, hideLoading } = useGlobalLoading()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Documentacion y Ayuda
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

// Estado
const loading = ref(false)
const showFormulario = ref(false)
const showDetalleModal = ref(false)
const showEditModal = ref(false)
const rubros = ref([])
const rubroSeleccionado = ref({})
const loadingEstadisticas = ref(true)

// Status
const statusDisponibles = ref([])
const statusSeleccionados = ref([])

// Estadísticas
const stats = ref({
  totales: 0,
  automaticos: 0
})

// Formulario
const formData = reactive({
  nombre: ''
})

// Edición
const editData = reactive({
  cve_tab: '',
  nombre: ''
})

// Computed
const todosStatusSeleccionados = computed(() => {
  return statusDisponibles.value.length > 0 &&
         statusSeleccionados.value.length === statusDisponibles.value.length
})

// Métodos de navegación
const toggleFormulario = () => {
  showFormulario.value = !showFormulario.value
  if (showFormulario.value) {
    formData.nombre = ''
  }
}

// Métodos de Status
const toggleStatus = (status) => {
  const index = statusSeleccionados.value.findIndex(s => s.cve_stat === status.cve_stat)
  if (index >= 0) {
    statusSeleccionados.value.splice(index, 1)
  } else {
    statusSeleccionados.value.push(status)
  }
}

const toggleTodosStatus = () => {
  if (todosStatusSeleccionados.value) {
    statusSeleccionados.value = []
  } else {
    statusSeleccionados.value = [...statusDisponibles.value]
  }
}

const isStatusSeleccionado = (status) => {
  return statusSeleccionados.value.some(s => s.cve_stat === status.cve_stat)
}

const seleccionarRubro = (rubro) => {
  rubroSeleccionado.value = rubro
  showDetalleModal.value = true
}

// Métodos de datos
const cargarRubros = async () => {
  const startTime = performance.now()
  showLoading('Cargando rubros...', 'Consultando base de datos')

  try {
    const response = await execute(
      'sp_rubros_listar',
      BASE_DB,
      [],
      'guadalajara'
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

// Cargar status disponibles
const cargarStatus = async () => {
  // Status predefinidos para otras obligaciones
  statusDisponibles.value = [
    { cve_stat: 'V', descripcion: 'Vigente' },
    { cve_stat: 'B', descripcion: 'Baja' },
    { cve_stat: 'S', descripcion: 'Suspendido' },
    { cve_stat: 'C', descripcion: 'Cancelado' }
  ]
}

const actualizarListado = () => {
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
    title: '¿Crear nuevo rubro?',
    text: `Se creará el rubro: ${formData.nombre}`,
    showCancelButton: true,
    confirmButtonColor: '#7c3aed',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  showLoading('Creando rubro...')

  try {
    const response = await execute(
      'ins34_rubro_01',
      BASE_DB,
      [{ nombre: 'par_nombre', valor: formData.nombre.trim(), tipo: 'varchar' }],
      'guadalajara'
    )

    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]

      if (resultado.status > 0) {
        showToast('success', resultado.concepto_status || 'Rubro creado exitosamente')
        formData.nombre = ''
        showFormulario.value = false
        await cargarRubros()
      } else {
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
  statusSeleccionados.value = []
  showFormulario.value = false
}

const cancelarCreacionSilent = () => {
  formData.nombre = ''
  showFormulario.value = false
}

const verDetalle = (rubro) => {
  rubroSeleccionado.value = rubro
  showDetalleModal.value = true
}

const closeDetalleModal = () => {
  showDetalleModal.value = false
  rubroSeleccionado.value = {}
}

// Funciones de edición
const abrirEdicion = () => {
  editData.cve_tab = rubroSeleccionado.value.cve_tab
  editData.nombre = rubroSeleccionado.value.nombre
  showDetalleModal.value = false
  showEditModal.value = true
}

const closeEditModal = () => {
  showEditModal.value = false
  editData.cve_tab = ''
  editData.nombre = ''
}

const handleEditar = async () => {
  if (!editData.nombre || editData.nombre.trim() === '') {
    showToast('warning', 'El nombre del rubro es obligatorio')
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Actualizar rubro?',
    text: `Se actualizará el rubro ${editData.cve_tab} a: ${editData.nombre}`,
    showCancelButton: true,
    confirmButtonColor: '#7c3aed',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  showLoading('Actualizando rubro...')

  try {
    const response = await execute(
      'upd34_rubro_01',
      BASE_DB,
      [
        { nombre: 'par_cve_tab', valor: editData.cve_tab, tipo: 'varchar' },
        { nombre: 'par_nombre', valor: editData.nombre.trim(), tipo: 'varchar' }
      ],
      'guadalajara'
    )

    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]
      if (resultado.status > 0) {
        showToast('success', resultado.concepto_status || 'Rubro actualizado')
        closeEditModal()
        await cargarRubros()
      } else {
        showToast('error', resultado.concepto_status || 'Error al actualizar')
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

// Utilidades
const formatNumber = (num) => {
  return new Intl.NumberFormat('es-MX').format(num)
}

// Lifecycle
onMounted(async () => {
  await cargarStatus()
  await cargarRubros()
})
</script>
