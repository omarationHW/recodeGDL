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
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
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
    <div v-if="showModal" class="modal d-block" @click.self="cerrarModal">
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

  <DocumentationModal :show="showAyuda" :component-name="'FechasDescuentoMntto'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - FechasDescuentoMntto'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'FechasDescuentoMntto'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - FechasDescuentoMntto'" @close="showDocumentacion = false" />
</template>

<script setup>
import Swal from 'sweetalert2'

const confirmarAccion = async (titulo, texto, confirmarTexto = 'Sí, continuar') => {
  const result = await Swal.fire({
    title: titulo,
    text: texto,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#3085d6',
    cancelButtonColor: '#6c757d',
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
    cancelButtonColor: '#6c757d',
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
    const res = await apiService.execute(
          'fechas_descuento_get_all',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (res.success) {
      fechas.value = res.data.result || []
      if (fechas.value.length > 0) {
        showToast(`Se cargaron ${fechas.value.length} registros`, 'success')
      }
    } else {
      showToast(res.message || 'Error al cargar fechas', 'error')
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
    const res = await apiService.execute(
          'fechas_descuento_update',
          'mercados',
          [
          { nombre: 'p_mes', valor: parseInt(form.value.mes) },
          { nombre: 'p_fecha_descuento', valor: form.value.fecha_descuento },
          { nombre: 'p_fecha_recargos', valor: form.value.fecha_recargos }
        ],
          '',
          null,
          'publico'
        )

    if (res.success) {
      const result = res.data.result
      if (result && result.length > 0 && result[0].success) {
        showToast(result[0].message || 'Fechas actualizadas', 'success')
        cerrarModal()
        cargarFechas()
      } else {
        showToast(result && result[0] ? result[0].message : 'Error al actualizar', 'error')
      }
    } else {
      showToast(res.message || 'Error al guardar', 'error')
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
