<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="dollar-sign" />
      </div>
      <div class="module-view-info">
        <h1>Cuotas de Mercados</h1>
        <p>Inicio > Mercados > Cuotas</p>
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
        
        <button class="btn-municipal-primary" @click="openCreate">
          <font-awesome-icon icon="plus" />
          Agregar
        </button>
        
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Búsqueda
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" v-model.number="axo" class="municipal-form-control" min="2000" max="2100"
                :disabled="loading" />
            </div>
            <div class="form-group align-self-end">
              <button class="btn-municipal-primary" @click="fetchCuotas" :disabled="loading">
                <font-awesome-icon icon="search" />
                Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla de Cuotas -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Listado de Cuotas
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="paginatedCuotas.length > 0">
              {{ totalRecords }} registros
            </span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando cuotas...</p>
          </div>

          <div v-else-if="cuotas.length > 0">
            <div class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Año</th>
                    <th>Categoría</th>
                    <th>Sección</th>
                    <th>Clave Cuota</th>
                    <th>Descripción</th>
                    <th class="text-end">Importe</th>
                    <th>Fecha Alta</th>
                    <th>Usuario</th>
                    <th class="text-center">Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="cuota in paginatedCuotas" :key="cuota.id_cuotas" class="row-hover">
                    <td>{{ cuota.axo }}</td>
                    <td>{{ cuota.categoria }}</td>
                    <td>{{ cuota.seccion }}</td>
                    <td>{{ cuota.clave_cuota }}</td>
                    <td>{{ cuota.descripcion }}</td>
                    <td class="text-end">{{ formatCurrency(cuota.importe_cuota) }}</td>
                    <td>{{ formatDate(cuota.fecha_alta) }}</td>
                    <td>{{ cuota.usuario }}</td>

                    <td class="text-center">
                      <div class="button-group button-group-sm">
                        <button class="btn-municipal-primary btn-sm" @click="editCuota(cuota)" title="Editar">
                          <font-awesome-icon icon="edit" />
                        </button>
                        <button class="btn-municipal-danger btn-sm" @click="deleteCuota(cuota)" title="Eliminar">
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
                  Mostrando {{ startRecord }} a {{ endRecord }} de {{ totalRecords }} registros
                </span>
              </div>

              <div class="pagination-size">
                <label class="municipal-form-label me-2">Registros por página:</label>
                <select
                  class="municipal-form-control form-control-sm"
                  :value="pageSize"
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

          <div v-else class="text-center text-muted py-4">
            <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
            <p>No hay cuotas registradas para el año seleccionado</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Crear/Editar -->
    <Modal :show="showModal" :title="showEdit ? 'Editar Cuota' : 'Agregar Cuota'" size="lg" @close="closeModal">
      <template #header>
        <h5 class="modal-title">
          <font-awesome-icon :icon="showEdit ? 'edit' : 'plus-circle'" />
          {{ showEdit ? 'Editar Cuota' : 'Agregar Cuota' }}
        </h5>
      
  <DocumentationModal :show="showAyuda" :component-name="'CuotasMdo'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - CuotasMdo'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'CuotasMdo'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - CuotasMdo'" @close="showDocumentacion = false" />
</template>

      <form @submit.prevent="showEdit ? updateCuota() : createCuota()">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Año <span class="required">*</span></label>
            <input type="number" v-model.number="form.axo" class="municipal-form-control" required min="2000"
              max="2100" />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Categoría <span class="required">*</span></label>
            <select v-model="form.categoria" class="municipal-form-control" required>
              <option value="">Seleccione...</option>
              <option v-for="cat in categorias" :key="cat.categoria" :value="cat.categoria">
                {{ cat.categoria }} - {{ cat.descripcion }}
              </option>
            </select>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Sección <span class="required">*</span></label>
            <select v-model="form.seccion" class="municipal-form-control" required>
              <option value="">Seleccione...</option>
              <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">
                {{ sec.seccion }} - {{ sec.descripcion }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Clave Cuota <span class="required">*</span></label>
            <select v-model="form.clave_cuota" class="municipal-form-control" required>
              <option value="">Seleccione...</option>
              <option v-for="cve in clavesCuota" :key="cve.clave_cuota" :value="cve.clave_cuota">
                {{ cve.clave_cuota }} - {{ cve.descripcion }}
              </option>
            </select>
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Importe <span class="required">*</span></label>
            <input type="number" v-model.number="form.importe_cuota" class="municipal-form-control" required min="0.01"
              step="0.01" />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Usuario <span class="required">*</span></label>
            <input type="number" v-model.number="form.id_usuario" class="municipal-form-control" required />
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn-municipal-secondary" @click="closeModal">
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
          <button type="submit" class="btn-municipal-primary" :disabled="saving">
            <font-awesome-icon :icon="saving ? 'spinner' : 'save'" :spin="saving" />
            {{ showEdit ? 'Actualizar' : 'Guardar' }}
          </button>
        </div>
      </form>
    </Modal>

    <!-- Modal Confirmar Eliminación -->
    <Modal :show="showDeleteModal" title="Confirmar Eliminación" size="sm" @close="closeDeleteModal">
      <template #header>
        <h5 class="modal-title text-danger">
          <font-awesome-icon icon="exclamation-triangle" />
          Confirmar Eliminación
        </h5>
      </template>

      <div class="text-center">
        <div class="delete-icon-wrapper">
          <font-awesome-icon icon="trash-alt" class="delete-icon" />
        </div>
        <p class="delete-message">¿Está seguro de eliminar esta cuota?</p>
        <div class="delete-details" v-if="cuotaToDelete">
          <p><strong>Año:</strong> {{ cuotaToDelete.axo }}</p>
          <p><strong>Categoría:</strong> {{ cuotaToDelete.categoria }}</p>
          <p><strong>Sección:</strong> {{ cuotaToDelete.seccion }}</p>
          <p><strong>Importe:</strong> {{ formatCurrency(cuotaToDelete.importe_cuota) }}</p>
        </div>
        <p class="text-muted small">Esta acción no se puede deshacer</p>
      </div>

      <template #footer>
        <div class="modal-footer-centered">
          <button type="button" class="btn-municipal-secondary" @click="closeDeleteModal">
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
          <button type="button" class="btn-municipal-danger" @click="confirmDelete" :disabled="deleting">
            <font-awesome-icon :icon="deleting ? 'spinner' : 'trash'" :spin="deleting" />
            Eliminar
          </button>
        </div>
      </template>
    </Modal>
  </div>
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
import { ref, onMounted, computed, watch } from 'vue'
import axios from 'axios'
import Modal from '@/components/common/Modal.vue'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


// Composables
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

// Estado
const axo = ref(new Date().getFullYear())
const cuotas = ref([])
const categorias = ref([])
const secciones = ref([])
const clavesCuota = ref([])
const showModal = ref(false)
const showEdit = ref(false)
const showDeleteModal = ref(false)
const cuotaToDelete = ref(null)
const loading = ref(false)
const saving = ref(false)
const deleting = ref(false)

// Paginación
const currentPage = ref(1)
const pageSize = ref(10)

const form = ref({
  id_cuotas: null,
  axo: new Date().getFullYear(),
  categoria: '',
  seccion: '',
  clave_cuota: '',
  importe_cuota: '',
  id_usuario: 1
})

// Computed para paginación
const totalRecords = computed(() => cuotas.value.length)
const totalPages = computed(() => Math.ceil(totalRecords.value / pageSize.value))
const startRecord = computed(() => (currentPage.value - 1) * pageSize.value + 1)
const endRecord = computed(() => Math.min(currentPage.value * pageSize.value, totalRecords.value))

const paginatedCuotas = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
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

// Watch para resetear página cuando cambia el tamaño
watch(pageSize, () => {
  currentPage.value = 1
})

// Funciones de paginación
const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
}

const changePageSize = (size) => {
  pageSize.value = parseInt(size)
  currentPage.value = 1
}

const nextPage = () => {
  goToPage(currentPage.value + 1)
}

const previousPage = () => {
  goToPage(currentPage.value - 1)
}

// Utilidades
const formatCurrency = (val) => {
  if (val == null) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN',
    minimumFractionDigits: 2
  }).format(parseFloat(val))
}

const formatDate = (val) => {
  if (!val) return ''
  return new Date(val).toLocaleDateString('es-MX')
}

const mostrarAyuda = () => {
  showToast('Administración de cuotas de mercados por año', 'info')
}

// API Calls
const fetchCuotas = async () => {
  loading.value = true
  showLoading('Cargando cuotas...', 'Por favor espere')
  try {
    const res = await apiService.execute(
          'sp_cuotasmdo_list',
          'mercados',
          [
          { nombre: 'p_axo', valor: axo.value }
        ],
          '',
          null,
          'publico'
        )
    if (res.success) {
      cuotas.value = res.data?.result || []
      currentPage.value = 1 // Reset a la primera página
      showToast(`Se encontraron ${cuotas.value.length} cuotas`, 'success')
    }
  } catch (err) {
    console.error('Error al cargar cuotas:', err)
    showToast('Error al cargar cuotas', 'error')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const fetchCategorias = async () => {
  try {
    const res = await apiService.execute(
          'sp_categoria_list',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (res.success) {
      categorias.value = res.data?.result || []
    }
  } catch (err) {
    console.error('Error al cargar categorías:', err)
    showToast('Error al cargar categorías', 'error')
  }
}

const fetchSecciones = async () => {
  try {
    const res = await apiService.execute(
          'sp_get_secciones',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (res.success) {
      secciones.value = res.data?.result || []
    }
  } catch (err) {
    console.error('Error al cargar secciones:', err)
    showToast('Error al cargar secciones', 'error')
  }
}

const fetchClavesCuota = async () => {
  try {
    const res = await apiService.execute(
          'sp_cve_cuota_list',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (res.success) {
      clavesCuota.value = res.data?.result || []
    }
  } catch (err) {
    console.error('Error al cargar claves de cuota:', err)
    showToast('Error al cargar claves de cuota', 'error')
  }
}

// CRUD Operations
const openCreate = () => {
  resetForm()
  showEdit.value = false
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  showEdit.value = false
  resetForm()
}

const resetForm = () => {
  form.value = {
    id_cuotas: null,
    axo: axo.value,
    categoria: '',
    seccion: '',
    clave_cuota: '',
    importe_cuota: '',
    id_usuario: 1
  }
}

const createCuota = async () => {
  saving.value = true
  showLoading('Guardando cuota...', 'Por favor espere')
  try {
    const res = await apiService.execute(
          'sp_cuotasmdo_create',
          'mercados',
          [
          { nombre: 'p_axo', valor: form.value.axo },
          { nombre: 'p_categoria', valor: form.value.categoria },
          { nombre: 'p_seccion', valor: form.value.seccion },
          { nombre: 'p_clave_cuota', valor: form.value.clave_cuota },
          { nombre: 'p_importe_cuota', valor: form.value.importe_cuota },
          { nombre: 'p_id_usuario', valor: form.value.id_usuario }
        ],
          '',
          null,
          'publico'
        )
    if (res.success) {
      showToast('Cuota creada correctamente', 'success')
      closeModal()
      fetchCuotas()
    } else {
      showToast(res.message || 'Error al crear cuota', 'error')
    }
  } catch (err) {
    console.error('Error al crear cuota:', err)
    showToast('Error al crear cuota', 'error')
  } finally {
    saving.value = false
    hideLoading()
  }
}

const editCuota = (cuota) => {
  form.value = { ...cuota }
  showEdit.value = true
  showModal.value = true
}

const updateCuota = async () => {
  saving.value = true
  showLoading('Actualizando cuota...', 'Por favor espere')
  try {
    const res = await apiService.execute(
          'sp_cuotasmdo_update',
          'mercados',
          [
          { nombre: 'p_id_cuotas', valor: form.value.id_cuotas },
          { nombre: 'p_axo', valor: form.value.axo },
          { nombre: 'p_categoria', valor: form.value.categoria },
          { nombre: 'p_seccion', valor: form.value.seccion },
          { nombre: 'p_clave_cuota', valor: form.value.clave_cuota },
          { nombre: 'p_importe_cuota', valor: form.value.importe_cuota },
          { nombre: 'p_id_usuario', valor: form.value.id_usuario }
        ],
          '',
          null,
          'publico'
        )
    if (res.success) {
      showToast('Cuota actualizada correctamente', 'success')
      closeModal()
      fetchCuotas()
    } else {
      showToast(res.message || 'Error al actualizar cuota', 'error')
    }
  } catch (err) {
    console.error('Error al actualizar cuota:', err)
    showToast('Error al actualizar cuota', 'error')
  } finally {
    saving.value = false
    hideLoading()
  }
}

const deleteCuota = (cuota) => {
  cuotaToDelete.value = cuota
  showDeleteModal.value = true
}

const closeDeleteModal = () => {
  showDeleteModal.value = false
  cuotaToDelete.value = null
}

const confirmDelete = async () => {
  if (!cuotaToDelete.value) return

  deleting.value = true
  showLoading('Eliminando cuota...', 'Por favor espere')
  try {
    const res = await apiService.execute(
          'sp_cuotasmdo_delete',
          'mercados',
          [
          { nombre: 'p_id_cuotas', valor: cuotaToDelete.value.id_cuotas }
        ],
          '',
          null,
          'publico'
        )
    if (res.success) {
      showToast('Cuota eliminada correctamente', 'success')
      closeDeleteModal()
      fetchCuotas()
    } else {
      showToast(res.message || 'Error al eliminar cuota', 'error')
    }
  } catch (err) {
    console.error('Error al eliminar cuota:', err)
    showToast('Error al eliminar cuota', 'error')
  } finally {
    deleting.value = false
    hideLoading()
  }
}

// Lifecycle
onMounted(async () => {
  showLoading('Cargando datos iniciales...', 'Por favor espere')
  try {
    await fetchCuotas()
    await fetchCategorias()
    await fetchSecciones()
    await fetchClavesCuota()
  } finally {
    hideLoading()
  }
})
</script>
