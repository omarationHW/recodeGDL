<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-times" />
      </div>
      <div class="module-view-info">
        <h1>Fechas de Vencimiento</h1>
        <p>Inicio > Mercados > Configuración de Fechas Límite</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="abrirModalNuevo" :disabled="loading">
          <font-awesome-icon icon="plus" />
          Nueva Fecha
        </button>
        <button class="btn-municipal-primary" @click="cargarFechas" :disabled="loading">
          <font-awesome-icon :icon="loading ? 'spinner' : 'sync'" :spin="loading" />
          Recargar
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Estadísticas -->
      <div class="stats-grid mb-4">
        <div class="stat-card stat-card-primary">
          <div class="stat-icon">
            <font-awesome-icon icon="calendar" />
          </div>
          <div class="stat-content">
            <div class="stat-value">12</div>
            <div class="stat-label">Meses del Año</div>
          </div>
        </div>
        <div class="stat-card stat-card-success">
          <div class="stat-icon">
            <font-awesome-icon icon="check-circle" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ estadisticas.configurados }}</div>
            <div class="stat-label">Configurados</div>
          </div>
        </div>
        <div class="stat-card stat-card-warning">
          <div class="stat-icon">
            <font-awesome-icon icon="exclamation-circle" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ estadisticas.pendientes }}</div>
            <div class="stat-label">Pendientes</div>
          </div>
        </div>
      </div>

      <!-- Tabla de fechas -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="calendar-alt" />
            Fechas de Vencimiento Configuradas
          </h5>
          <div class="header-right">
            <span class="badge-municipal badge-purple" v-if="fechas.length > 0">
              {{ fechas.length }} meses
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando fechas de vencimiento...</p>
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
                  <th>Mes</th>
                  <th>Día Vencimiento</th>
                  <th>Fecha Descuento</th>
                  <th>Fecha Recargo</th>
                  <th>Usuario</th>
                  <th>Última Modificación</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="fechas.length === 0">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No hay fechas de vencimiento configuradas</p>
                  </td>
                </tr>
                <tr v-else v-for="fecha in fechas" :key="fecha.mes" class="row-hover">
                  <td>
                    <span class="badge-municipal badge-primary badge-gradient">{{ getMesNombre(fecha.mes) }}</span>
                  </td>
                  <td>
                    <span class="badge-municipal badge-info">Día {{ fecha.dia_vencimiento || 'N/A' }}</span>
                  </td>
                  <td>
                    <font-awesome-icon icon="calendar-check" class="icon-small text-success" />
                    {{ formatFecha(fecha.fecha_descuento) }}
                  </td>
                  <td>
                    <font-awesome-icon icon="calendar-times" class="icon-small text-danger" />
                    {{ formatFecha(fecha.fecha_recargo) }}
                  </td>
                  <td>
                    <font-awesome-icon icon="user" class="icon-small text-muted" />
                    {{ fecha.usuario || 'N/A' }}
                  </td>
                  <td>{{ formatFecha(fecha.fecha_modif) }}</td>
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
        </div>
      </div>
    </div>

    <!-- Modal de Edición -->
    <div v-if="showModal" class="modal-backdrop" @click.self="cerrarModal">
      <div class="modal-content modal-municipal">
        <div class="modal-header municipal-modal-header">
          <h5 class="modal-title">
            <font-awesome-icon icon="calendar-edit" />
            {{ modalTitle }}
          </h5>
          <button type="button" class="btn-close btn-close-white" @click="cerrarModal"></button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="guardar">
            <div class="form-group">
              <label class="municipal-form-label">Mes <span class="text-danger">*</span></label>
              <select
                class="municipal-form-control"
                v-model.number="formData.mes"
                :disabled="isEditMode"
                required>
                <option v-for="m in 12" :key="m" :value="m">{{ getMesNombre(m) }}</option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Día de Vencimiento <span class="text-danger">*</span></label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="formData.dia_vencimiento"
                required
                min="1"
                max="31"
                placeholder="Día del mes (1-31)">
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Fecha Descuento <span class="text-danger">*</span></label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="formData.fecha_descuento"
                required>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Fecha Recargo <span class="text-danger">*</span></label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="formData.fecha_recargo"
                required>
            </div>
          </form>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn-municipal-secondary" @click="cerrarModal" :disabled="saving">
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
          <button type="button" class="btn-municipal-primary" @click="guardar" :disabled="saving">
            <font-awesome-icon :icon="saving ? 'spinner' : 'save'" :spin="saving" />
            Guardar
          </button>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'

// Composables
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

// Estado
const loading = ref(false)
const saving = ref(false)
const error = ref('')
const fechas = ref([])
const showModal = ref(false)
const isEditMode = ref(false)

// Formulario
const formData = ref({
  mes: 1,
  dia_vencimiento: null,
  fecha_descuento: '',
  fecha_recargo: ''
})

// Computed
const estadisticas = computed(() => {
  const configurados = fechas.value.filter(f => f.dia_vencimiento != null).length
  return {
    configurados,
    pendientes: 12 - configurados
  }
})

const modalTitle = computed(() => {
  return isEditMode.value
    ? `Editar Vencimiento - ${getMesNombre(formData.value.mes)}`
    : 'Nueva Fecha de Vencimiento'
})

// Métodos de UI
const mostrarAyuda = () => {
  showToast('info', 'Configure los días de vencimiento y fechas de descuento/recargo para cada mes del año.')
}

// Utilidades
const getMesNombre = (m) => {
  const meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ]
  return meses[m - 1] || m
}

const formatFecha = (fecha) => {
  if (!fecha) return 'No configurado'
  try {
    return new Date(fecha).toLocaleDateString('es-MX')
  } catch (e) {
    return fecha
  }
}

// API
const cargarFechas = async () => {
  loading.value = true
  error.value = ''
  showLoading('Cargando fechas de vencimiento...')

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_fechas_vencimiento',
        Base: 'mercados',
        Parametros: []
      }
    })

    if (response.data.eResponse && response.data.eResponse.success === true) {
      fechas.value = response.data.eResponse.data.result || []
      if (fechas.value.length > 0) {
        showToast(`Se cargaron ${fechas.value.length} meses`, 'success')
      }
    } else {
      error.value = response.data.eResponse?.message || 'Error al cargar fechas'
      showToast(error.value, 'error')
    }
  } catch (err) {
    error.value = err.response?.data?.eResponse?.message || 'Error al cargar fechas'
    console.error('Error al cargar fechas:', err)
    showToast(error.value, 'error')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const abrirModalNuevo = () => {
  isEditMode.value = false
  formData.value = {
    mes: 1,
    dia_vencimiento: null,
    fecha_descuento: '',
    fecha_recargo: ''
  }
  showModal.value = true
}

const editarFecha = (fecha) => {
  isEditMode.value = true
  formData.value = {
    mes: fecha.mes,
    dia_vencimiento: fecha.dia_vencimiento,
    fecha_descuento: fecha.fecha_descuento ? fecha.fecha_descuento.split('T')[0] : '',
    fecha_recargo: fecha.fecha_recargo ? fecha.fecha_recargo.split('T')[0] : ''
  }
  showModal.value = true
}

const cerrarModal = () => {
  showModal.value = false
  formData.value = {
    mes: 1,
    dia_vencimiento: null,
    fecha_descuento: '',
    fecha_recargo: ''
  }
}

const guardar = async () => {
  if (!formData.value.dia_vencimiento || !formData.value.fecha_descuento || !formData.value.fecha_recargo) {
    showToast('Por favor complete todos los campos requeridos', 'warning')
    return
  }

  saving.value = true
  showLoading('Guardando fecha de vencimiento...')

  try {
    const sp = isEditMode.value ? 'sp_update_fecha_vencimiento' : 'sp_insert_fecha_vencimiento'

    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: sp,
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_mes', Valor: formData.value.mes },
          { Nombre: 'p_dia_vencimiento', Valor: formData.value.dia_vencimiento },
          { Nombre: 'p_fecha_descuento', Valor: formData.value.fecha_descuento },
          { Nombre: 'p_fecha_recargo', Valor: formData.value.fecha_recargo }
        ]
      }
    })

    if (response.data.eResponse && response.data.eResponse.success === true) {
      showToast(isEditMode.value ? 'Fecha actualizada correctamente' : 'Fecha creada correctamente', 'success')
      cerrarModal()
      await cargarFechas()
    } else {
      showToast(response.data.eResponse?.message || 'Error al guardar', 'error')
    }
  } catch (err) {
    showToast(err.response?.data?.eResponse?.message || 'Error al guardar', 'error')
    console.error('Error al guardar:', err)
  } finally {
    saving.value = false
    hideLoading()
  }
}

// Lifecycle
onMounted(() => {
  cargarFechas()
})
</script>
