<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="calendar-times" /></div>
      <div class="module-view-info">
        <h1>Fechas de Vencimiento</h1>
        <p>Configuraci�n de Fechas L�mite por Mes</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header"><h5><font-awesome-icon icon="calendar-alt" /> Fechas de Vencimiento Configuradas</h5></div>
        <div class="municipal-card-body">
          <div class="stats-grid" style="margin-bottom: 20px;">
            <div class="stat-card gradient-primary">
              <div class="stat-icon"><font-awesome-icon icon="calendar" /></div>
              <div class="stat-info">
                <div class="stat-value">12</div>
                <div class="stat-label">Meses del A�o</div>
              </div>
            </div>
            <div class="stat-card gradient-success">
              <div class="stat-icon"><font-awesome-icon icon="check-circle" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ estadisticas.configurados }}</div>
                <div class="stat-label">Configurados</div>
              </div>
            </div>
            <div class="stat-card gradient-warning">
              <div class="stat-icon"><font-awesome-icon icon="exclamation-circle" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ estadisticas.pendientes }}</div>
                <div class="stat-label">Pendientes</div>
              </div>
            </div>
          </div>

          <div class="button-group" style="margin-bottom: 20px;">
            <button class="btn-municipal-primary" @click="cargarFechas" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'sync'" :spin="loading" /> Recargar
            </button>
            <button class="btn-municipal-success" @click="abrirModalNuevo">
              <font-awesome-icon icon="plus" /> Nueva Fecha
            </button>
          </div>

          <div class="municipal-table">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Mes</th>
                  <th>D�a Vencimiento</th>
                  <th>Fecha Descuento</th>
                  <th>Fecha Recargo</th>
                  <th>Usuario</th>
                  <th>�ltima Modificaci�n</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="fecha in fechas" :key="fecha.mes" class="row-hover">
                  <td><strong>{{ getMesNombre(fecha.mes) }}</strong></td>
                  <td><span class="badge-primary">{{ fecha.dia_vencimiento || 'No configurado' }}</span></td>
                  <td>{{ formatFecha(fecha.fecha_descuento) }}</td>
                  <td>{{ formatFecha(fecha.fecha_recargo) }}</td>
                  <td><small>{{ fecha.usuario }}</small></td>
                  <td><small>{{ formatFecha(fecha.fecha_modif) }}</small></td>
                  <td>
                    <button class="btn-icon btn-primary" @click="editarFecha(fecha)" title="Editar">
                      <font-awesome-icon icon="edit" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Modal de Edici�n -->
      <div v-if="showModal" class="modal-overlay" @click.self="cerrarModal">
        <div class="modal-content">
          <div class="modal-header">
            <h5>{{ modalTitle }}</h5>
            <button class="btn-close" @click="cerrarModal">&times;</button>
          </div>
          <div class="modal-body">
            <div class="form-group">
              <label class="municipal-form-label">Mes</label>
              <select class="municipal-form-control" v-model.number="formData.mes" :disabled="isEditMode">
                <option v-for="m in 12" :key="m" :value="m">{{ getMesNombre(m) }}</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">D�a de Vencimiento *</label>
              <input type="number" class="municipal-form-control" v-model.number="formData.dia_vencimiento" required min="1" max="31" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Descuento *</label>
              <input type="date" class="municipal-form-control" v-model="formData.fecha_descuento" required />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Recargo *</label>
              <input type="date" class="municipal-form-control" v-model="formData.fecha_recargo" required />
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn-municipal-secondary" @click="cerrarModal">Cancelar</button>
            <button class="btn-municipal-primary" @click="guardar" :disabled="saving">
              <font-awesome-icon :icon="saving ? 'spinner' : 'save'" :spin="saving" /> Guardar
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from 'vue-toastification'

const { executeStoredProcedure } = useApi()
const { handleError } = useLicenciasErrorHandler()
const toast = useToast()

const loading = ref(false)
const saving = ref(false)
const fechas = ref([])
const showModal = ref(false)
const isEditMode = ref(false)
const formData = ref({
  mes: 1,
  dia_vencimiento: null,
  fecha_descuento: '',
  fecha_recargo: ''
})

const estadisticas = computed(() => {
  const configurados = fechas.value.filter(f => f.dia_vencimiento != null).length
  return {
    configurados,
    pendientes: 12 - configurados
  }
})

const modalTitle = computed(() => {
  return isEditMode.value ? `Editar Vencimiento - ${getMesNombre(formData.value.mes)}` : 'Nueva Fecha de Vencimiento'
})

const getMesNombre = (m) => {
  const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
  return meses[m - 1] || m
}

const formatFecha = (fecha) => {
  if (!fecha) return 'No configurado'
  return new Date(fecha).toLocaleDateString('es-MX')
}

const cargarFechas = async () => {
  try {
    loading.value = true
    const result = await executeStoredProcedure('sp_get_fechas_vencimiento', {})

    if (result.success) {
      fechas.value = result.data || []
    } else {
      handleError(result)
    }
  } catch (error) {
    handleError(error)
  } finally {
    loading.value = false
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
    toast.warning('Por favor complete todos los campos requeridos')
    return
  }

  try {
    saving.value = true
    const sp = isEditMode.value ? 'sp_update_fecha_vencimiento' : 'sp_insert_fecha_vencimiento'

    const result = await executeStoredProcedure(sp, {
      p_mes: formData.value.mes,
      p_dia_vencimiento: formData.value.dia_vencimiento,
      p_fecha_descuento: formData.value.fecha_descuento,
      p_fecha_recargo: formData.value.fecha_recargo
    })

    if (result.success) {
      toast.success(isEditMode.value ? 'Fecha actualizada correctamente' : 'Fecha creada correctamente')
      cerrarModal()
      await cargarFechas()
    } else {
      handleError(result)
    }
  } catch (error) {
    handleError(error)
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  cargarFechas()
})
</script>


