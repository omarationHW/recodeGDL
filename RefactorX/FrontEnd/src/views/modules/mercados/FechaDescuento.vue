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
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
        </button>
        
        <button class="btn-municipal-primary" @click="openEditModal" :disabled="loading || !selectedRow">
          <font-awesome-icon icon="edit" /> Modificar
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

  <DocumentationModal :show="showAyuda" :component-name="'FechaDescuento'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - FechaDescuento'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'FechaDescuento'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - FechaDescuento'" @close="showDocumentacion = false" />
</template>

<script setup>
import Swal from 'sweetalert2'

// Helpers de confirmación SweetAlert
const confirmarAccion = async (titulo, texto, confirmarTexto = 'Sí, continuar') => {
  const result = await Swal.fire({
    title: titulo,
    text: texto,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#3085d6',
    cancelButtonColor: '#d33',
    confirmButtonText: confirmarTexto,
    cancelButtonText: 'Cancelar'
  })
  return result.isConfirmed
}

const mostrarConfirmacionEliminar = async (texto) => {
  const result = await Swal.fire({
    title: '¿Eliminar registro?',
    text: texto,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#d33',
    cancelButtonColor: '#3085d6',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })
  return result.isConfirmed
}
import apiService from '@/services/apiService';
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


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
    const res = await apiService.execute(
          'sp_fechadescuento_list',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (res.success) {
      rows.value = res.data.result || []
    } else {
      showToast(res.message || 'Error al cargar fechas de descuento', 'error')
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
    const res = await apiService.execute(
          'sp_fechadescuento_update',
          'mercados',
          [
          { nombre: 'p_mes', valor: parseInt(editForm.value.mes) },
          { nombre: 'p_fecha_descuento', valor: editForm.value.fecha_descuento },
          { nombre: 'p_fecha_recargos', valor: editForm.value.fecha_recargos },
          { nombre: 'p_id_usuario', valor: parseInt(userId.value) }
        ],
          '',
          null,
          'publico'
        )
    if (res.success) {
      const result = res.data.result[0]
      if (result.success) {
        showToast(result.message || 'Fecha de descuento actualizada exitosamente', 'success')
        showModal.value = false
        selectedRow.value = null
        await fetchRows()
      } else {
        showToast(result.message || 'Error al actualizar', 'error')
      }
    } else {
      showToast(res.message || 'Error al guardar', 'error')
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
