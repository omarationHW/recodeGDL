<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="coins" />
      </div>
      <div class="module-view-info">
        <h1>Mantenimiento a Cuotas de Mercados por Año</h1>
        <p>Inicio > Catálogos > Cuotas Mercado Mntto</p>
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
      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list" /> Listado de Cuotas por Año</h5>
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
                  <th>Categoría</th>
                  <th>Sección</th>
                  <th>Clave Cuota</th>
                  <th class="text-end">Importe</th>
                  <th class="text-center">Fecha Alta</th>
                  <th>Usuario</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="cuotas.length === 0">
                  <td colspan="10" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No hay cuotas registradas. Cree una nueva cuota.</p>
                  </td>
                </tr>
                <tr v-else v-for="(cuota, idx) in paginatedCuotas" :key="cuota.id_cuotas" class="row-hover"
                  @click="seleccionarCuota(cuota)" :class="{ 'table-row-selected': cuotaSeleccionada === cuota }">
                  <td class="text-center">{{ (currentPage - 1) * itemsPerPage + idx + 1 }}</td>
                  <td>{{ cuota.id_cuotas }}</td>
                  <td>{{ cuota.axo }}</td>
                  <td class="text-center"><span class="badge-secondary">{{ cuota.categoria }}</span></td>
                  <td class="text-center"><span class="badge-info">{{ cuota.seccion }}</span></td>
                  <td class="text-center">{{ cuota.clave_cuota }}</td>
                  <td class="text-end"><strong>{{ formatCurrency(cuota.importe_cuota) }}</strong></td>
                  <td class="text-center">{{ formatDate(cuota.fecha_alta) }}</td>
                  <td>{{ cuota.id_usuario }}</td>
                  <td class="text-center">
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-primary btn-sm" @click.stop="editarCuota(cuota)" title="Editar">
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button class="btn-municipal-danger btn-sm" @click.stop="confirmarEliminar(cuota)"
                        title="Eliminar">
                        <font-awesome-icon icon="trash" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de Paginación -->
          <div v-if="cuotas.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, cuotas.length) }}
                de {{ cuotas.length }} registros
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

    <!-- Modal para crear/editar cuota -->
    <div v-if="showModal" class="modal-overlay">
      <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <font-awesome-icon icon="coins" />
              {{ isEdit ? 'Editar Cuota de Mercado' : 'Nueva Cuota de Mercado' }}
            </h5>
            <button type="button" class="btn-close" @click="cerrarModal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="guardarCuota">
              <div class="row">
                <div class="col-md-6 mb-3" v-if="isEdit">
                  <label class="municipal-form-label">Control (ID)</label>
                  <input type="text" class="municipal-form-control" v-model="form.id_cuotas" readonly />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="municipal-form-label">Año <span class="required">*</span></label>
                  <input type="number" class="municipal-form-control" v-model.number="form.axo" min="1992" max="2999"
                    required />
                </div>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="municipal-form-label">Categoría <span class="required">*</span></label>
                  <select class="municipal-form-control" v-model.number="form.categoria" required>
                    <option value="">Seleccione...</option>
                    <option v-for="cat in categorias" :key="cat.categoria" :value="cat.categoria">
                      {{ cat.categoria }} - {{ cat.descripcion }}
                    </option>
                  </select>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="municipal-form-label">Sección <span class="required">*</span></label>
                  <select class="municipal-form-control" v-model="form.seccion" required>
                    <option value="">Seleccione...</option>
                    <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">
                      {{ sec.seccion }} - {{ sec.descripcion }}
                    </option>
                  </select>
                </div>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="municipal-form-label">Clave de Cuota <span class="required">*</span></label>
                  <select class="municipal-form-control" v-model.number="form.clave_cuota" required>
                    <option value="">Seleccione...</option>
                    <option v-for="cve in clavesCuota" :key="cve.clave_cuota" :value="cve.clave_cuota">
                      {{ cve.clave_cuota }} - {{ cve.descripcion }}
                    </option>
                  </select>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="municipal-form-label">Cuota (Importe) <span class="required">*</span></label>
                  <input type="number" class="municipal-form-control" v-model.number="form.importe" min="0.01"
                    step="0.01" required />
                  <small class="form-text text-muted">Ingrese el monto de la cuota</small>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="cerrarModal">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <button type="button" class="btn-municipal-primary" @click="guardarCuota"
              :disabled="!isFormValid || loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'save'" :spin="loading" />
              {{ isEdit ? 'Actualizar' : 'Guardar' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal confirmación eliminar -->
    <div v-if="showDeleteConfirm" class="modal-overlay">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header bg-danger text-white">
            <h5 class="modal-title">
              <font-awesome-icon icon="exclamation-triangle" /> Confirmar Eliminación
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="cancelarEliminar"></button>
          </div>
          <div class="modal-body">
            <p>¿Está seguro de eliminar esta cuota?</p>
            <div class="alert alert-warning">
              <strong>ID:</strong> {{ cuotaAEliminar?.id_cuotas }}<br>
              <strong>Año:</strong> {{ cuotaAEliminar?.axo }}<br>
              <strong>Categoría:</strong> {{ cuotaAEliminar?.categoria }}<br>
              <strong>Sección:</strong> {{ cuotaAEliminar?.seccion }}<br>
              <strong>Importe:</strong> {{ formatCurrency(cuotaAEliminar?.importe_cuota) }}
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

// Catálogos
const categorias = ref([])
const secciones = ref([])
const clavesCuota = ref([])

const form = ref({
  id_cuotas: '',
  axo: new Date().getFullYear(),
  categoria: '',
  seccion: '',
  clave_cuota: '',
  importe: null,
  id_usuario: 1 // TODO: Obtener del sistema de autenticación
})

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)

const totalPages = computed(() => Math.ceil(cuotas.value.length / itemsPerPage.value))

const paginatedCuotas = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return cuotas.value.slice(start, end)
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

const isFormValid = computed(() => {
  return form.value.axo >= 1992 &&
    form.value.categoria &&
    form.value.seccion &&
    form.value.clave_cuota &&
    form.value.importe > 0
})

const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
  cuotaSeleccionada.value = null
}

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size)
  currentPage.value = 1
  cuotaSeleccionada.value = null
}

const previousPage = () => {
  goToPage(currentPage.value - 1)
}

const nextPage = () => {
  goToPage(currentPage.value + 1)
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
  showToast('info', 'Administre las cuotas de mercados por año. Puede crear, editar o eliminar cuotas. Seleccione categoría, sección y clave de cuota para definir la tarifa.')
}

const cargarCatalogos = async () => {
  try {
    // Cargar categorías
    const resCat = await axios.post('/api/generic', {
      eRequest: { Operacion: 'sp_get_categorias', Base: 'mercados', Esquema: 'publico', Parametros: [] }
    })
    if (resCat.data.eResponse.success) {
      categorias.value = resCat.data.eResponse.data.result || []
    }

    // Cargar secciones
    const resSec = await axios.post('/api/generic', {
      eRequest: { Operacion: 'sp_get_secciones', Base: 'mercados', Esquema: 'publico', Parametros: [] }
    })
    if (resSec.data.eResponse.success) {
      secciones.value = resSec.data.eResponse.data.result || []
    }

    // Cargar claves de cuota
    const resCve = await axios.post('/api/generic', {
      eRequest: { Operacion: 'sp_get_claves_cuota', Base: 'mercados', Esquema: 'publico', Parametros: [] }
    })
    if (resCve.data.eResponse.success) {
      clavesCuota.value = resCve.data.eResponse.data.result || []
    }
  } catch (err) {
    showToast('error', 'Error al cargar catálogos')
    console.error(err)
  }
}

const cargarCuotas = async () => {
  loading.value = true
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'cuotasmdo_listar',
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: []
      }
    })

    if (res.data.eResponse.success) {
      cuotas.value = res.data.eResponse.data.result || []
      currentPage.value = 1
      if (cuotas.value.length > 0) {
        showToast('success', `Se cargaron ${cuotas.value.length} cuotas`)
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

const seleccionarCuota = (cuota) => {
  cuotaSeleccionada.value = cuota
}

const abrirModalNuevo = () => {
  isEdit.value = false
  form.value = {
    id_cuotas: '',
    axo: new Date().getFullYear(),
    categoria: '',
    seccion: '',
    clave_cuota: '',
    importe: null,
    id_usuario: 1
  }
  showModal.value = true
}

const editarCuota = (cuota) => {
  isEdit.value = true
  form.value = {
    id_cuotas: cuota.id_cuotas,
    axo: cuota.axo,
    categoria: cuota.categoria,
    seccion: cuota.seccion,
    clave_cuota: cuota.clave_cuota,
    importe: cuota.importe_cuota,
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
    const operacion = isEdit.value ? 'cuotasmdo_actualizar' : 'cuotasmdo_insertar'
    const parametros = isEdit.value ? [
      { Nombre: 'p_id_cuotas', Valor: parseInt(form.value.id_cuotas) },
      { Nombre: 'p_axo', Valor: parseInt(form.value.axo) },
      { Nombre: 'p_categoria', Valor: parseInt(form.value.categoria) },
      { Nombre: 'p_seccion', Valor: form.value.seccion },
      { Nombre: 'p_clave_cuota', Valor: parseInt(form.value.clave_cuota) },
      { Nombre: 'p_importe', Valor: parseFloat(form.value.importe) },
      { Nombre: 'p_id_usuario', Valor: parseInt(form.value.id_usuario) }
    ] : [
      { Nombre: 'p_axo', Valor: parseInt(form.value.axo) },
      { Nombre: 'p_categoria', Valor: parseInt(form.value.categoria) },
      { Nombre: 'p_seccion', Valor: form.value.seccion },
      { Nombre: 'p_clave_cuota', Valor: parseInt(form.value.clave_cuota) },
      { Nombre: 'p_importe', Valor: parseFloat(form.value.importe) },
      { Nombre: 'p_id_usuario', Valor: parseInt(form.value.id_usuario) }
    ]

    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: operacion,
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: parametros
      }
    })

    if (res.data.eResponse.success) {
      const result = res.data.eResponse.data.result
      if (result && result.length > 0 && result[0][operacion.replace('cuotasmdo_', '')]) {
        showToast('success', isEdit.value ? 'Cuota actualizada exitosamente' : 'Cuota creada exitosamente')
        cerrarModal()
        cargarCuotas()
      } else {
        showToast('error', 'La cuota ya existe con esos parámetros')
      }
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
        Operacion: 'cuotasmdo_eliminar',
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: [
          { Nombre: 'p_id_cuotas', Valor: parseInt(cuotaAEliminar.value.id_cuotas) }
        ]
      }
    })

    if (res.data.eResponse.success) {
      const result = res.data.eResponse.data.result
      if (result && result.length > 0 && result[0].eliminar) {
        showToast('success', 'Cuota eliminada exitosamente')
        cancelarEliminar()
        cargarCuotas()
      } else {
        showToast('error', 'No se pudo eliminar la cuota')
      }
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

const cerrarModal = () => {
  showModal.value = false
  isEdit.value = false
}

const formatCurrency = (val) => {
  if (val === null || val === undefined) return '$0.00'
  const num = typeof val === 'number' ? val : parseFloat(val)
  return '$' + num.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const formatDate = (dateStr) => {
  if (!dateStr) return ''
  const d = new Date(dateStr)
  return d.toLocaleDateString('es-MX', { year: 'numeric', month: '2-digit', day: '2-digit' })
}

onMounted(async () => {
  showLoading('Cargando Mantenimiento de Cuotas de Mercado', 'Preparando catálogos y cuotas...')
  try {
    await cargarCatalogos()
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

.badge-info {
  background: #17a2b8;
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

.btn-municipal-danger {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
  color: white;
  border: none;
  transition: all 0.3s ease;
}

.btn-municipal-danger:hover {
  background: linear-gradient(135deg, #c82333 0%, #bd2130 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(220, 53, 69, 0.3);
}

.required {
  color: #dc3545;
}

.bg-danger {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%) !important;
}

/* Estilos para modal overlay - asegurar que aparezca sobre todo */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1050;
  animation: fadeIn 0.2s ease-in-out;
}

.modal-dialog {
  z-index: 1051;
  max-width: 90%;
  max-height: 90vh;
  overflow-y: auto;
  animation: slideDown 0.3s ease-in-out;
}

.modal-content {
  background: white;
  border-radius: 8px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }

  to {
    opacity: 1;
  }
}

@keyframes slideDown {
  from {
    transform: translateY(-50px);
    opacity: 0;
  }

  to {
    transform: translateY(0);
    opacity: 1;
  }
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
