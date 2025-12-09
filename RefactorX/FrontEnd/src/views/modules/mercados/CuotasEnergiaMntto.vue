<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="bolt" />
      </div>
      <div class="module-view-info">
        <h1>Mantenimiento Cuotas de Energía Eléctrica</h1>
        <p>Inicio > Catálogos > Cuotas Energía Mntto</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="abrirModalNuevo" :disabled="loading">
          <font-awesome-icon icon="plus" /> Nuevo
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Filtros de Consulta</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Año</label>
              <input type="number" class="municipal-form-control" v-model.number="filtros.axo"
                     min="2002" max="2999" placeholder="Año" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Periodo (Mes)</label>
              <input type="number" class="municipal-form-control" v-model.number="filtros.periodo"
                     min="1" max="12" placeholder="Periodo (1-12)" :disabled="loading" />
            </div>
          </div>
          <div class="row mt-3">
            <div class="col-12 text-end">
              <button class="btn-municipal-primary me-2" @click="cargarCuotas" :disabled="loading">
                <font-awesome-icon icon="search" /> Buscar
              </button>
              <button class="btn-municipal-secondary" @click="limpiarFiltros" :disabled="loading">
                <font-awesome-icon icon="eraser" /> Limpiar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list" /> Listado de Cuotas</h5>
          <div class="header-right">
            <span class="badge-purple" v-if="cuotas.length > 0">
              {{ cuotas.length }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando datos, por favor espere...</p>
          </div>

          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th>ID</th>
                  <th>Año</th>
                  <th>Periodo</th>
                  <th class="text-end">Cuota</th>
                  <th class="text-center">Fecha Alta</th>
                  <th>Usuario</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="cuotas.length === 0">
                  <td colspan="8" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No hay cuotas registradas. Use los filtros o cree una nueva cuota.</p>
                  </td>
                </tr>
                <tr v-else v-for="(cuota, idx) in paginatedCuotas" :key="cuota.id_kilowhatts"
                    class="row-hover" @click="seleccionarCuota(cuota)"
                    :class="{ 'table-row-selected': cuotaSeleccionada === cuota }">
                  <td class="text-center">{{ (currentPage - 1) * itemsPerPage + idx + 1 }}</td>
                  <td>{{ cuota.id_kilowhatts }}</td>
                  <td>{{ cuota.axo }}</td>
                  <td class="text-center"><span class="badge-primary">{{ cuota.periodo }}</span></td>
                  <td class="text-end"><strong>{{ formatCurrency(cuota.importe) }}</strong></td>
                  <td class="text-center">{{ formatDateTime(cuota.fecha_alta) }}</td>
                  <td>{{ cuota.usuario || 'N/A' }}</td>
                  <td class="text-center">
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-primary btn-sm" @click.stop="editarCuota(cuota)" title="Editar">
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button class="btn-municipal-danger btn-sm" @click.stop="confirmarEliminar(cuota)" title="Eliminar">
                        <font-awesome-icon icon="trash" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="cuotas.length > itemsPerPage" class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ (currentPage - 1) * itemsPerPage + 1 }} a
              {{ Math.min(currentPage * itemsPerPage, cuotas.length) }} de {{ cuotas.length }} registros
            </div>
            <div class="pagination-controls">
              <button class="btn-municipal-secondary btn-sm" @click="previousPage" :disabled="currentPage === 1">
                <font-awesome-icon icon="angle-left" />
              </button>
              <span class="pagination-current">Página {{ currentPage }} de {{ totalPages }}</span>
              <button class="btn-municipal-secondary btn-sm" @click="nextPage" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="angle-right" />
              </button>
            </div>
            <div class="items-per-page">
              <label>
                Registros por página:
                <select v-model.number="itemsPerPage" class="municipal-form-control" style="width: auto; display: inline-block;">
                  <option :value="10">10</option>
                  <option :value="25">25</option>
                  <option :value="50">50</option>
                  <option :value="100">100</option>
                </select>
              </label>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal para crear/editar cuota -->
    <div v-if="showModal" class="modal d-block" @click.self="cerrarModal">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <font-awesome-icon icon="bolt" />
              {{ isEdit ? 'Editar Cuota de Energía' : 'Nueva Cuota de Energía' }}
            </h5>
            <button type="button" class="btn-close" @click="cerrarModal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="guardarCuota">
              <div class="mb-3" v-if="isEdit">
                <label class="municipal-form-label">Control (ID)</label>
                <input type="text" class="municipal-form-control" v-model="form.id_kilowhatts" readonly />
              </div>
              <div class="mb-3">
                <label class="municipal-form-label">Año <span class="required">*</span></label>
                <input type="number" class="municipal-form-control" v-model.number="form.axo"
                       min="2002" max="2999" required :readonly="isEdit" />
              </div>
              <div class="mb-3">
                <label class="municipal-form-label">Periodo (Mes) <span class="required">*</span></label>
                <input type="number" class="municipal-form-control" v-model.number="form.periodo"
                       min="1" max="12" required :readonly="isEdit" />
                <small class="form-text text-muted">Ingrese un número del 1 al 12</small>
              </div>
              <div class="mb-3">
                <label class="municipal-form-label">Cuota <span class="required">*</span></label>
                <input type="number" class="municipal-form-control" v-model.number="form.importe"
                       min="0.01" step="0.01" required />
                <small class="form-text text-muted">Ingrese el monto de la cuota</small>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="cerrarModal">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <button type="button" class="btn-municipal-primary" @click="guardarCuota" :disabled="!isFormValid || loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'save'" :spin="loading" />
              {{ isEdit ? 'Actualizar' : 'Guardar' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de confirmación de eliminación -->
    <div v-if="showDeleteConfirm" class="modal-overlay" @click.self="cancelarEliminar">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header bg-danger text-white">
            <h5 class="modal-title">
              <font-awesome-icon icon="exclamation-triangle" /> Confirmar Eliminación
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="cancelarEliminar"></button>
          </div>
          <div class="modal-body">
            <p>¿Está seguro de eliminar esta cuota de energía?</p>
            <div class="alert alert-warning">
              <strong>ID:</strong> {{ cuotaAEliminar?.id_kilowhatts }}<br>
              <strong>Año:</strong> {{ cuotaAEliminar?.axo }}<br>
              <strong>Periodo:</strong> {{ cuotaAEliminar?.periodo }}<br>
              <strong>Cuota:</strong> {{ formatCurrency(cuotaAEliminar?.importe) }}
            </div>
            <p class="text-danger"><strong>Esta acción no se puede deshacer.</strong></p>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="cancelarEliminar">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <button type="button" class="btn-municipal-danger" @click="eliminarCuota" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'trash'" :spin="loading" />
              Eliminar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Toast notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const { showLoading, hideLoading } = useGlobalLoading()

const cuotas = ref([])
const cuotaSeleccionada = ref(null)
const cuotaAEliminar = ref(null)
const loading = ref(false)
const showModal = ref(false)
const showDeleteConfirm = ref(false)
const isEdit = ref(false)
const toast = ref({ show: false, type: 'info', message: '' })

const filtros = ref({
  axo: null,
  periodo: null
})

const form = ref({
  id_kilowhatts: '',
  axo: new Date().getFullYear(),
  periodo: 1,
  importe: null,
  id_usuario: 1 // TODO: Obtener del sistema de autenticación
})

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(25)

const totalPages = computed(() => Math.ceil(cuotas.value.length / itemsPerPage.value))

const paginatedCuotas = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return cuotas.value.slice(start, end)
})

const isFormValid = computed(() => {
  return form.value.axo >= 2002 &&
         form.value.periodo >= 1 && form.value.periodo <= 12 &&
         form.value.importe > 0
})

const previousPage = () => {
  if (currentPage.value > 1) currentPage.value--
}

const nextPage = () => {
  if (currentPage.value < totalPages.value) currentPage.value++
}

const showToast = (type, message) => {
  toast.value = { show: true, type, message }
  setTimeout(() => hideToast(), 5000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = { success: 'check-circle', error: 'times-circle', warning: 'exclamation-triangle', info: 'info-circle' }
  return icons[type] || 'info-circle'
}

const mostrarAyuda = () => {
  showToast('info', 'Administre las cuotas de energía eléctrica por año y periodo. Puede crear nuevas cuotas o editar las existentes.')
}

const cargarCuotas = async () => {
  loading.value = true
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_list_cuotas_energia',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_axo', Valor: filtros.value.axo || null },
          { Nombre: 'p_periodo', Valor: filtros.value.periodo || null }
        ]
      }
    })

    if (res.data.eResponse.success) {
      cuotas.value = res.data.eResponse.data.result || []
      currentPage.value = 1
      if (cuotas.value.length === 0) {
        showToast('info', 'No se encontraron cuotas con los criterios especificados')
      } else {
        showToast('success', `Se encontraron ${cuotas.value.length} cuotas`)
      }
    } else {
      showToast('error', res.data.eResponse.message || 'Error al cargar cuotas')
    }
  } catch (err) {
    showToast('error', 'Error de conexión al cargar cuotas')
    console.error(err)
  } finally {
    loading.value = false
  }
}

const limpiarFiltros = () => {
  filtros.value.axo = null
  filtros.value.periodo = null
  cargarCuotas()
}

const seleccionarCuota = (cuota) => {
  cuotaSeleccionada.value = cuota
}

const abrirModalNuevo = () => {
  isEdit.value = false
  form.value = {
    id_kilowhatts: '',
    axo: new Date().getFullYear(),
    periodo: 1,
    importe: null,
    id_usuario: 1
  }
  showModal.value = true
}

const editarCuota = (cuota) => {
  isEdit.value = true
  form.value = {
    id_kilowhatts: cuota.id_kilowhatts,
    axo: cuota.axo,
    periodo: cuota.periodo,
    importe: cuota.importe,
    id_usuario: 1
  }
  showModal.value = true
}

const guardarCuota = async () => {
  if (!isFormValid.value) {
    showToast('warning', 'Complete todos los campos requeridos correctamente')
    return
  }

  loading.value = true
  try {
    const operacion = isEdit.value ? 'sp_update_cuota_energia' : 'sp_insert_cuota_energia'
    const parametros = isEdit.value ? [
      { Nombre: 'p_id_kilowhatts', Valor: parseInt(form.value.id_kilowhatts) },
      { Nombre: 'p_axo', Valor: parseInt(form.value.axo) },
      { Nombre: 'p_periodo', Valor: parseInt(form.value.periodo) },
      { Nombre: 'p_importe', Valor: parseFloat(form.value.importe) },
      { Nombre: 'p_id_usuario', Valor: parseInt(form.value.id_usuario) }
    ] : [
      { Nombre: 'p_axo', Valor: parseInt(form.value.axo) },
      { Nombre: 'p_periodo', Valor: parseInt(form.value.periodo) },
      { Nombre: 'p_importe', Valor: parseFloat(form.value.importe) },
      { Nombre: 'p_id_usuario', Valor: parseInt(form.value.id_usuario) }
    ]

    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: operacion,
        Base: 'mercados',
        Parametros: parametros
      }
    })

    if (res.data.eResponse.success) {
      showToast('success', isEdit.value ? 'Cuota actualizada exitosamente' : 'Cuota creada exitosamente')
      cerrarModal()
      cargarCuotas()
    } else {
      showToast('error', res.data.eResponse.message || 'Error al guardar cuota')
    }
  } catch (err) {
    showToast('error', 'Error de conexión al guardar cuota')
    console.error(err)
  } finally {
    loading.value = false
  }
}

const cerrarModal = () => {
  showModal.value = false
  isEdit.value = false
}

const confirmarEliminar = (cuota) => {
  cuotaAEliminar.value = cuota
  showDeleteConfirm.value = true
}

const cancelarEliminar = () => {
  cuotaAEliminar.value = null
  showDeleteConfirm.value = false
}

const eliminarCuota = async () => {
  if (!cuotaAEliminar.value) return

  loading.value = true
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_delete_cuota_energia',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_kilowhatts', Valor: parseInt(cuotaAEliminar.value.id_kilowhatts) }
        ]
      }
    })

    if (res.data.eResponse.success) {
      showToast('success', 'Cuota eliminada exitosamente')
      cancelarEliminar()
      cargarCuotas()
    } else {
      showToast('error', res.data.eResponse.message || 'Error al eliminar cuota')
    }
  } catch (err) {
    showToast('error', 'Error de conexión al eliminar cuota')
    console.error(err)
  } finally {
    loading.value = false
  }
}

const formatCurrency = (val) => {
  if (val === null || val === undefined) return '$0.00'
  const num = typeof val === 'number' ? val : parseFloat(val)
  return '$' + num.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const formatDateTime = (dateStr) => {
  if (!dateStr) return ''
  const d = new Date(dateStr)
  return d.toLocaleDateString('es-MX', { year: 'numeric', month: '2-digit', day: '2-digit' }) + ' ' +
         d.toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit' })
}

onMounted(async () => {
  showLoading('Cargando Mantenimiento de Cuotas de Energía', 'Preparando catálogo de cuotas...')
  try {
    await cargarCuotas()
  } finally {
    hideLoading()
  }
})
</script>

<style scoped>
.empty-icon {
  color: #6c757d;
  opacity: 0.5;
  margin-bottom: 1rem;
}

.badge-primary {
  background: var(--municipal-blue);
  color: white;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-weight: 600;
}

.btn-municipal-sm {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

.btn-municipal-warning {
  background: linear-gradient(135deg, #ffc107 0%, #ff9800 100%);
  color: #000;
  border: none;
  transition: all 0.3s ease;
}

.btn-municipal-warning:hover {
  background: linear-gradient(135deg, #ff9800 0%, #f57c00 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(255, 152, 0, 0.3);
}

.required {
  color: #dc3545;
}

.modal-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.module-view-header .btn-municipal-primary {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  color: white !important;
}

.button-group {
  display: inline-flex;
  gap: 0.25rem;
}

.button-group-sm {
  gap: 0.125rem;
}
</style>
