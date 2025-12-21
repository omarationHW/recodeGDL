<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-check" />
      </div>
      <div class="module-view-info">
        <h1>Mantenimiento de Fechas de Descuento</h1>
        <p>Inicio > Catálogos > Fechas de Descuento</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="calendar-alt" /> Listado de Fechas de Descuento por Mes</h5>
          <div class="header-right">
            <span class="badge-purple" v-if="fechas.length > 0">{{ fechas.length }} meses</span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando fechas...</p>
          </div>

          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th class="text-center">Mes</th>
                  <th>Nombre del Mes</th>
                  <th class="text-center">Fecha Descuento</th>
                  <th class="text-center">Fecha Recargos</th>
                  <th class="text-center">Última Actualización</th>
                  <th>Usuario</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="fechas.length === 0">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No hay fechas configuradas.</p>
                  </td>
                </tr>
                <tr v-else v-for="fecha in paginatedFechas" :key="fecha.mes" class="row-hover">
                  <td class="text-center"><span class="badge-primary">{{ fecha.mes }}</span></td>
                  <td><strong>{{ getMesNombre(fecha.mes) }}</strong></td>
                  <td class="text-center">{{ formatDate(fecha.fecha_descuento) }}</td>
                  <td class="text-center">{{ formatDate(fecha.fecha_recargos) }}</td>
                  <td class="text-center text-muted">{{ formatDateTime(fecha.fecha_alta) }}</td>
                  <td>{{ fecha.usuario }}</td>
                  <td class="text-center">
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-primary btn-sm" @click="editarFecha(fecha)" title="Editar">
                        <font-awesome-icon icon="edit" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de Paginación -->
          <div v-if="fechas.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, fechas.length) }}
                de {{ fechas.length }} registros
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

    <!-- Modal Editar -->
    <div v-if="showModal" class="modal d-block">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <font-awesome-icon icon="calendar-check" />
              Editar Fechas - {{ getMesNombre(form.mes) }}
            </h5>
            <button type="button" class="btn-close" @click="cerrarModal"></button>
          </div>
          <div class="modal-body">
            <div class="alert alert-info">
              <font-awesome-icon icon="info-circle" />
              Las fechas ingresadas deben corresponder al mes <strong>{{ getMesNombre(form.mes) }} ({{ form.mes }})</strong>
            </div>

            <div class="mb-3">
              <label class="municipal-form-label">Mes <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="form.mes"
                     min="1" max="12" required readonly />
            </div>

            <div class="mb-3">
              <label class="municipal-form-label">Fecha de Descuento <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="form.fecha_descuento" required />
              <small class="form-text text-muted">Debe ser del mes {{ getMesNombre(form.mes) }}</small>
            </div>

            <div class="mb-3">
              <label class="municipal-form-label">Fecha de Recargos <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="form.fecha_recargos" required />
              <small class="form-text text-muted">Debe ser del mes {{ getMesNombre(form.mes) }}</small>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="cerrarModal">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <button type="button" class="btn-municipal-primary" @click="guardar" :disabled="!isFormValid || loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'save'" :spin="loading" />
              Actualizar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Toast -->
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

const fechas = ref([])
const loading = ref(false)
const showModal = ref(false)
const toast = ref({ show: false, type: 'info', message: '' })

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)

const form = ref({
  mes: null,
  fecha_descuento: '',
  fecha_recargos: ''
})

const MESES = [
  '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
]

const isFormValid = computed(() => {
  return form.value.mes >= 1 &&
         form.value.mes <= 12 &&
         form.value.fecha_descuento.trim().length > 0 &&
         form.value.fecha_recargos.trim().length > 0
})

// Computed de paginación
const totalPages = computed(() => Math.ceil(fechas.value.length / itemsPerPage.value))

const paginatedFechas = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return fechas.value.slice(start, end)
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

const getMesNombre = (mes) => {
  return MESES[mes] || 'N/A'
}

const formatDate = (dateStr) => {
  if (!dateStr) return 'N/A'
  return new Date(dateStr).toLocaleDateString('es-MX')
}

const formatDateTime = (dateStr) => {
  if (!dateStr) return 'N/A'
  return new Date(dateStr).toLocaleString('es-MX')
}

const showToast = (message, type) => {
  toast.value = { show: true, type, message }
  setTimeout(() => hideToast(), 5000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'times-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

const mostrarAyuda = () => {
  showToast('Configure las fechas de descuento y recargos para cada mes del año.', 'info')
}

const cargarFechas = async () => {
  loading.value = true
  try {
    const res = await axios.post('/api/generic', {
      eRequest: { Operacion: 'fechas_descuento_get_all', Base: 'mercados', Esquema: 'publico', Parametros: [] }
    })
    if (res.data.eResponse.success) {
      fechas.value = res.data.eResponse.data.result || []
      if (fechas.value.length > 0) {
        showToast(`Se cargaron ${fechas.value.length} registros`, 'success')
      }
    } else {
      showToast(res.data.eResponse.message || 'Error al cargar fechas', 'error')
    }
  } catch (err) {
    showToast('Error de conexión', 'error')
    console.error(err)
  } finally {
    loading.value = false
  }
}

const editarFecha = (fecha) => {
  form.value = {
    mes: fecha.mes,
    fecha_descuento: fecha.fecha_descuento ? fecha.fecha_descuento.substr(0, 10) : '',
    fecha_recargos: fecha.fecha_recargos ? fecha.fecha_recargos.substr(0, 10) : ''
  }
  showModal.value = true
}

const guardar = async () => {
  if (!isFormValid.value) {
    showToast('Complete todos los campos correctamente', 'warning')
    return
  }

  loading.value = true
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'fechas_descuento_update',
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: [
          { Nombre: 'p_mes', Valor: parseInt(form.value.mes) },
          { Nombre: 'p_fecha_descuento', Valor: form.value.fecha_descuento },
          { Nombre: 'p_fecha_recargos', Valor: form.value.fecha_recargos }
        ]
      }
    })

    if (res.data.eResponse.success) {
      const result = res.data.eResponse.data.result
      if (result && result.length > 0 && result[0].success) {
        showToast(result[0].message || 'Fechas actualizadas', 'success')
        cerrarModal()
        cargarFechas()
      } else {
        showToast(result && result[0] ? result[0].message : 'Error al actualizar', 'error')
      }
    } else {
      showToast(res.data.eResponse.message || 'Error al guardar', 'error')
    }
  } catch (err) {
    showToast('Error de conexión', 'error')
    console.error(err)
  } finally {
    loading.value = false
  }
}

const cerrarModal = () => {
  showModal.value = false
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

onMounted(async () => {
  showLoading('Cargando Mantenimiento de Fechas de Descuento', 'Preparando fechas de descuento...')
  try {
    await cargarFechas()
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
  font-size: 0.9rem;
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

.form-text {
  font-size: 0.875rem;
  margin-top: 0.25rem;
}

.alert-info {
  background-color: #d1ecf1;
  border-color: #bee5eb;
  color: #0c5460;
  padding: 0.75rem 1.25rem;
  border-radius: 0.25rem;
  margin-bottom: 1rem;
}
</style>
