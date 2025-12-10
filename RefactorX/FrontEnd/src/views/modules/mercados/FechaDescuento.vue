<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-alt" />
      </div>
      <div class="module-view-info">
        <h1>Configuración de Fechas de Descuento</h1>
        <p>Inicio > Configuración > Fechas de Descuento</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="openEditModal" :disabled="loading || !selectedRow">
          <font-awesome-icon icon="edit" /> Modificar
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="calendar-check" /> Días de Vencimiento para Descuentos del Año Actual</h5>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th class="text-center">Mes</th>
                  <th class="text-center">Nombre</th>
                  <th class="text-center">Fecha Descuento</th>
                  <th class="text-center">Fecha Recargos</th>
                  <th class="text-center">Última Actualización</th>
                  <th class="text-center">Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in rows" :key="row.mes"
                    :class="{ 'row-selected': selectedRow && selectedRow.mes === row.mes, 'row-hover': true }"
                    @click="selectRow(row)">
                  <td class="text-center"><strong class="text-primary">{{ row.mes }}</strong></td>
                  <td>{{ getMesNombre(row.mes) }}</td>
                  <td class="text-center">{{ formatDate(row.fecha_descuento) }}</td>
                  <td class="text-center">{{ formatDate(row.fecha_recargos) }}</td>
                  <td class="text-center text-muted">{{ formatDateTime(row.fecha_alta) }}</td>
                  <td class="text-center">{{ row.usuario }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div v-if="!loading && rows.length === 0" class="text-center text-muted py-5">
        <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
        <p>No hay fechas de descuento configuradas</p>
      </div>
    </div>

    <!-- Modal de Edición -->
    <div v-if="showModal" class="modal-overlay">
      <div class="municipal-modal">
        <div class="municipal-modal-header">
          <h5>
            <font-awesome-icon icon="edit" />
            Modificar Fecha de Descuento - {{ getMesNombre(editForm.mes) }}
          </h5>
          <button class="modal-close-btn" @click="closeModal">
            <font-awesome-icon icon="times" />
          </button>
        </div>
        <div class="municipal-modal-body">
          <form @submit.prevent="save">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Mes <span class="required">*</span></label>
                <input type="number" class="municipal-form-control" v-model.number="editForm.mes" readonly />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Nombre del Mes</label>
                <input type="text" class="municipal-form-control" :value="getMesNombre(editForm.mes)" readonly />
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Fecha de Descuento <span class="required">*</span></label>
                <input type="date" class="municipal-form-control" v-model="editForm.fecha_descuento" required :disabled="loading" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Fecha de Recargos <span class="required">*</span></label>
                <input type="date" class="municipal-form-control" v-model="editForm.fecha_recargos" required :disabled="loading" />
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Usuario</label>
                <input type="text" class="municipal-form-control" :value="userName" readonly />
              </div>
            </div>
          </form>
        </div>
        <div class="municipal-modal-footer">
          <button class="btn-municipal-primary" @click="save" :disabled="loading || !isFormValid">
            <font-awesome-icon icon="save" /> Guardar
          </button>
          <button class="btn-municipal-secondary" @click="closeModal" :disabled="loading">
            <font-awesome-icon icon="times" /> Cancelar
          </button>
        </div>
      </div>
    </div>

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

const rows = ref([])
const selectedRow = ref(null)
const showModal = ref(false)
const editForm = ref({
  mes: null,
  fecha_descuento: '',
  fecha_recargos: ''
})
const loading = ref(false)
const toast = ref({ show: false, type: 'info', message: '' })
const userId = ref(1)
const userName = ref('admin')

const mesesNombres = [
  '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
]

const isFormValid = computed(() => {
  return editForm.value.mes && editForm.value.fecha_descuento && editForm.value.fecha_recargos
})

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
  showToast('Seleccione un mes de la tabla y haga clic en Modificar para actualizar las fechas de descuento y recargos.', 'info')
}

const getMesNombre = (mes) => {
  return mesesNombres[mes] || ''
}

const fetchRows = async () => {
  showLoading('Cargando Fechas de Descuento', 'Preparando configuración del sistema...')
  loading.value = true
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_fechadescuento_list',
        Base: 'mercados',
        Parametros: []
      }
    })
    if (res.data.eResponse.success) {
      rows.value = res.data.eResponse.data.result || []
    } else {
      showToast(res.data.eResponse.message || 'Error al cargar fechas de descuento', 'error')
    }
  } catch (err) {
    showToast('Error de conexión al cargar datos', 'error')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const selectRow = (row) => {
  selectedRow.value = row
}

const openEditModal = () => {
  if (!selectedRow.value) {
    showToast('Seleccione un mes de la tabla', 'warning')
    return
  }
  editForm.value = {
    mes: selectedRow.value.mes,
    fecha_descuento: selectedRow.value.fecha_descuento ? selectedRow.value.fecha_descuento.substr(0, 10) : '',
    fecha_recargos: selectedRow.value.fecha_recargos ? selectedRow.value.fecha_recargos.substr(0, 10) : ''
  }
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
}

const save = async () => {
  if (!isFormValid.value) {
    showToast('Complete todos los campos requeridos', 'warning')
    return
  }
  if (!confirm(`¿Está seguro de actualizar las fechas para ${getMesNombre(editForm.value.mes)}?`)) {
    return
  }
  loading.value = true
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_fechadescuento_update',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_mes', Valor: parseInt(editForm.value.mes) },
          { Nombre: 'p_fecha_descuento', Valor: editForm.value.fecha_descuento },
          { Nombre: 'p_fecha_recargos', Valor: editForm.value.fecha_recargos },
          { Nombre: 'p_id_usuario', Valor: parseInt(userId.value) }
        ]
      }
    })
    if (res.data.eResponse.success) {
      const result = res.data.eResponse.data.result[0]
      if (result.success) {
        showToast(result.message || 'Fecha de descuento actualizada exitosamente', 'success')
        showModal.value = false
        selectedRow.value = null
        await fetchRows()
      } else {
        showToast(result.message || 'Error al actualizar', 'error')
      }
    } else {
      showToast(res.data.eResponse.message || 'Error al guardar', 'error')
    }
  } catch (err) {
    showToast('Error de conexión al guardar', 'error')
  } finally {
    loading.value = false
  }
}

const formatDate = (dateStr) => {
  if (!dateStr) return ''
  const d = new Date(dateStr + 'T00:00:00')
  return d.toLocaleDateString('es-MX', { year: 'numeric', month: '2-digit', day: '2-digit' })
}

const formatDateTime = (dateStr) => {
  if (!dateStr) return ''
  const d = new Date(dateStr)
  return d.toLocaleDateString('es-MX', { year: 'numeric', month: '2-digit', day: '2-digit' }) + ' ' +
         d.toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit' })
}

onMounted(() => {
  // Obtener usuario actual (en producción usar auth real)
  userId.value = window?.AppUser?.id_usuario || 1
  userName.value = window?.AppUser?.usuario || 'admin'
  fetchRows()
})
</script>

<style scoped>
.empty-icon {
  color: #6c757d;
  opacity: 0.5;
  margin-bottom: 1rem;
}

.row-selected {
  background-color: #e7f3ff !important;
  border-left: 3px solid var(--municipal-blue);
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1050;
}

.municipal-modal {
  background: white;
  border-radius: 8px;
  max-width: 600px;
  width: 90%;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.2);
  max-height: 90vh;
  overflow-y: auto;
}

.municipal-modal-header {
  padding: 1.5rem;
  border-bottom: 1px solid #e0e0e0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: linear-gradient(135deg, var(--municipal-blue) 0%, var(--municipal-blue-dark) 100%);
  color: white;
  border-radius: 8px 8px 0 0;
}

.municipal-modal-header h5 {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 600;
}

.modal-close-btn {
  background: transparent;
  border: none;
  color: white;
  font-size: 1.5rem;
  cursor: pointer;
  padding: 0;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  transition: background-color 0.2s;
}

.modal-close-btn:hover {
  background: rgba(255, 255, 255, 0.1);
}

.municipal-modal-body {
  padding: 1.5rem;
}

.municipal-modal-footer {
  padding: 1rem 1.5rem;
  border-top: 1px solid #e0e0e0;
  display: flex;
  gap: 0.75rem;
  justify-content: flex-end;
}
</style>
