<template>
  <div class="municipal-form-page">
    <!-- Header del módulo -->
    <div class="municipal-header">
      <div class="row align-items-center">
        <div class="col">
          <h3 class="mb-0">
            <i class="fas fa-list-ul"></i>
            Gestión de Estatus
          </h3>
          <p class="mb-0 opacity-75">
            Administración del catálogo de estatus de trámites
          </p>
        </div>
        <div class="col-auto">
          <button
            class="btn-municipal-primary"
            @click="showCreateModal = true"
            :disabled="loading"
          >
            <i class="fas fa-plus"></i>
            Nuevo Estatus
          </button>
        </div>
      </div>
    </div>

    <!-- Filtros de búsqueda -->
    <div class="municipal-card mb-4">
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-3">
            <label class="municipal-form-label">Código</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.codigo"
              placeholder="Código del estatus"
            >
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Descripción</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.descripcion"
              placeholder="Descripción del estatus"
            >
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Estado</label>
            <select class="municipal-form-control" v-model="filters.activo">
              <option value="">Todos</option>
              <option value="A">Activos</option>
              <option value="I">Inactivos</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Color</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.color"
              placeholder="Color del estatus"
            >
          </div>
        </div>
        <div class="row mt-3">
          <div class="col-12">
            <button
              class="btn-municipal-primary me-2"
              @click="searchEstatus"
              :disabled="loading"
            >
              <i class="fas fa-search"></i>
              Buscar
            </button>
            <button
              class="btn-municipal-secondary me-2"
              @click="clearFilters"
              :disabled="loading"
            >
              <i class="fas fa-times"></i>
              Limpiar
            </button>
            <button
              class="btn-municipal-success"
              @click="loadEstatus"
              :disabled="loading"
            >
              <i class="fas fa-sync-alt"></i>
              Actualizar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de resultados -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h6 class="mb-0">
          <i class="fas fa-list"></i>
          Estatus Registrados
          <span v-if="estatus.length > 0" class="municipal-badge-primary ms-2">
            {{ estatus.length }} registros
          </span>
        </h6>
      </div>
      <div class="municipal-card-body">
        <!-- Loading state -->
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
          <p class="mt-2 text-muted">Cargando estatus...</p>
        </div>

        <!-- Error state -->
        <div v-else-if="error" class="municipal-alert-danger">
          <h6 class="alert-heading">Error al cargar datos</h6>
          <p class="mb-0">{{ error }}</p>
          <hr>
          <button class="btn-municipal-danger btn-sm" @click="loadEstatus">
            <i class="fas fa-retry"></i>
            Reintentar
          </button>
        </div>

        <!-- Empty state -->
        <div v-else-if="estatus.length === 0" class="text-center py-5">
          <i class="fas fa-list-ul fa-3x text-muted mb-3"></i>
          <h5 class="text-muted">No se encontraron estatus</h5>
          <p class="text-muted">
            {{ hasActiveFilters ? 'No hay registros que coincidan con los filtros aplicados.' : 'No hay estatus registrados en el sistema.' }}
          </p>
          <button
            v-if="!hasActiveFilters"
            class="btn-municipal-primary"
            @click="showCreateModal = true"
          >
            <i class="fas fa-plus"></i>
            Registrar primer estatus
          </button>
        </div>

        <!-- Tabla con datos -->
        <div v-else class="table-responsive">
          <table class="municipal-table municipal-table-hover">
            <thead class="municipal-table-header">
              <tr>
                <th>Código</th>
                <th>Descripción</th>
                <th>Color</th>
                <th>Orden</th>
                <th>Estado</th>
                <th>Fecha Creación</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in paginatedEstatus" :key="item.id">
                <td>
                  <strong class="text-primary">{{ item.codigo }}</strong>
                </td>
                <td>{{ item.descripcion }}</td>
                <td>
                  <span
                    class="badge rounded-pill"
                    :style="{ backgroundColor: item.color, color: '#fff' }"
                  >
                    {{ item.color }}
                  </span>
                </td>
                <td>{{ item.orden }}</td>
                <td>
                  <span class="municipal-badge" :class="item.activo === 'A' ? 'municipal-badge-success' : 'municipal-badge-secondary'">
                    {{ item.activo === 'A' ? 'Activo' : 'Inactivo' }}
                  </span>
                </td>
                <td>{{ formatDate(item.created_at) }}</td>
                <td>
                  <div class="btn-group btn-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="viewEstatus(item)"
                      title="Ver detalles"
                    >
                      <i class="fas fa-eye"></i>
                    </button>
                    <button
                      class="btn-municipal-warning btn-sm"
                      @click="editEstatus(item)"
                      title="Editar"
                    >
                      <i class="fas fa-edit"></i>
                    </button>
                    <button
                      class="btn-municipal-danger btn-sm"
                      @click="deleteEstatus(item)"
                      title="Eliminar"
                    >
                      <i class="fas fa-trash"></i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Paginación -->
        <div v-if="totalPages > 1" class="d-flex justify-content-between align-items-center mt-4">
          <div class="pagination-info">
            <span class="text-muted">
              Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }} a
              {{ Math.min(currentPage * itemsPerPage, totalRegistros) }} de
              {{ totalRegistros }} registros
            </span>
          </div>
          <nav aria-label="Paginación de estatus">
            <ul class="pagination pagination-sm mb-0">
              <li class="page-item" :class="{ disabled: currentPage === 1 }">
                <button
                  class="page-link"
                  @click="previousPage"
                  :disabled="currentPage === 1"
                  aria-label="Página anterior"
                >
                  <i class="fas fa-chevron-left"></i>
                </button>
              </li>

              <li
                v-for="page in getVisiblePages()"
                :key="page"
                class="page-item"
                :class="{ active: page === currentPage }"
              >
                <button
                  class="page-link"
                  @click="goToPage(page)"
                  :aria-label="`Página ${page}`"
                >
                  {{ page }}
                </button>
              </li>

              <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                <button
                  class="page-link"
                  @click="nextPage"
                  :disabled="currentPage === totalPages"
                  aria-label="Página siguiente"
                >
                  <i class="fas fa-chevron-right"></i>
                </button>
              </li>
            </ul>
          </nav>
        </div>
      </div>
    </div>

    <!-- Modal para crear/editar estatus -->
    <div class="modal fade" tabindex="-1" v-if="showCreateModal" style="display: block;" @click.self="showCreateModal = false">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <i class="fas fa-plus"></i>
              {{ editingEstatus ? 'Editar Estatus' : 'Nuevo Estatus' }}
            </h5>
            <button type="button" class="btn-close" @click="showCreateModal = false"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="saveEstatus">
              <div class="row">
                <div class="col-md-6">
                  <label class="municipal-form-label">Código <span class="text-danger">*</span></label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="newEstatus.codigo"
                    placeholder="Ej: PEN, APR, REC"
                    required
                    maxlength="10"
                    :disabled="editingEstatus"
                  >
                </div>
                <div class="col-md-6">
                  <label class="municipal-form-label">Orden</label>
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model="newEstatus.orden"
                    placeholder="1"
                    min="1"
                    max="999"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-12">
                  <label class="municipal-form-label">Descripción <span class="text-danger">*</span></label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="newEstatus.descripcion"
                    placeholder="Descripción del estatus"
                    required
                    maxlength="100"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-md-6">
                  <label class="municipal-form-label">Color</label>
                  <input
                    type="color"
                    class="municipal-form-control"
                    v-model="newEstatus.color"
                    title="Seleccionar color"
                  >
                </div>
                <div class="col-md-6">
                  <label class="municipal-form-label">Estado</label>
                  <select class="municipal-form-control" v-model="newEstatus.activo">
                    <option value="A">Activo</option>
                    <option value="I">Inactivo</option>
                  </select>
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-12">
                  <label class="municipal-form-label">Observaciones</label>
                  <textarea
                    class="municipal-form-control"
                    rows="3"
                    v-model="newEstatus.observaciones"
                    placeholder="Observaciones adicionales"
                  ></textarea>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="showCreateModal = false">
              Cancelar
            </button>
            <button
              type="button"
              class="btn-municipal-primary"
              @click="saveEstatus"
              :disabled="creating || !newEstatus.codigo || !newEstatus.descripcion"
            >
              <span v-if="creating">
                <i class="fas fa-spinner fa-spin"></i>
                {{ editingEstatus ? 'Actualizando...' : 'Creando...' }}
              </span>
              <span v-else>
                <i class="fas fa-save"></i>
                {{ editingEstatus ? 'Actualizar Estatus' : 'Crear Estatus' }}
              </span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal backdrop -->
    <div v-if="showCreateModal" class="modal-backdrop fade show"></div>

    <!-- SweetAlert Modal -->
    <div v-if="sweetAlert.show" class="swal-overlay" @click.self="closeSweetAlert">
      <div class="swal-modal">
        <div class="swal-icon" :class="sweetAlert.type">
          <i v-if="sweetAlert.type === 'success'" class="fas fa-check-circle"></i>
          <i v-else-if="sweetAlert.type === 'error'" class="fas fa-times-circle"></i>
          <i v-else-if="sweetAlert.type === 'warning'" class="fas fa-exclamation-triangle"></i>
          <i v-else-if="sweetAlert.type === 'info'" class="fas fa-info-circle"></i>
          <i v-else class="fas fa-question-circle"></i>
        </div>
        <h3 class="swal-title">{{ sweetAlert.title }}</h3>
        <p class="swal-text">{{ sweetAlert.text }}</p>
        <div class="swal-footer">
          <button class="btn-municipal-primary" @click="closeSweetAlert">
            Aceptar
          </button>
        </div>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-for="toast in toasts" :key="toast.id"
         class="toast-notification"
         :class="toast.type"
         :style="{ top: (20 + (toasts.indexOf(toast) * 80)) + 'px' }">
      <div class="toast-icon">
        <i v-if="toast.type === 'success'" class="fas fa-check-circle"></i>
        <i v-else-if="toast.type === 'error'" class="fas fa-times-circle"></i>
        <i v-else-if="toast.type === 'warning'" class="fas fa-exclamation-triangle"></i>
        <i v-else-if="toast.type === 'info'" class="fas fa-info-circle"></i>
      </div>
      <div class="toast-message">{{ toast.message }}</div>
      <button class="toast-close" @click="removeToast(toast.id)">
        <i class="fas fa-times"></i>
      </button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EstatusForm',
  data() {
    return {
      // Estado de carga
      loading: false,
      creating: false,
      error: null,

      // Datos principales
      estatus: [],
      totalRegistros: 0,

      // Paginación
      currentPage: 1,
      itemsPerPage: 10,
      totalPages: 0,

      // Filtros de búsqueda
      filters: {
        codigo: '',
        descripcion: '',
        activo: '',
        color: ''
      },

      // Modal
      showCreateModal: false,
      editingEstatus: null,

      // SweetAlert
      sweetAlert: {
        show: false,
        type: 'info',
        title: '',
        text: ''
      },

      // Toast notifications
      toasts: [],

      // Formulario de estatus
      newEstatus: {
        codigo: '',
        descripcion: '',
        color: '#007bff',
        orden: 1,
        activo: 'A',
        observaciones: ''
      }
    }
  },

  computed: {
    hasActiveFilters() {
      return Object.values(this.filters).some(value => value !== null && value !== '')
    },

    paginatedEstatus() {
      const start = (this.currentPage - 1) * this.itemsPerPage
      const end = start + this.itemsPerPage
      return this.estatus.slice(start, end)
    }
  },

  methods: {
    async loadEstatus() {
      this.loading = true
      this.error = null

      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_estatus_list',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_codigo', valor: this.filters.codigo || null },
                { nombre: 'p_descripcion', valor: this.filters.descripcion || null },
                { nombre: 'p_activo', valor: this.filters.activo || null },
                { nombre: 'p_color', valor: this.filters.color || null },
                { nombre: 'p_limite', valor: this.itemsPerPage },
                { nombre: 'p_offset', valor: (this.currentPage - 1) * this.itemsPerPage }
              ],
              Tenant: 'informix'
            }
          })
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()
        console.log('Respuesta del servidor:', data)

        if (data.eResponse && data.eResponse.success) {
          this.estatus = data.eResponse.data.result || []

          // Obtener el total de registros del primer elemento (si existe)
          if (this.estatus.length > 0) {
            this.totalRegistros = parseInt(this.estatus[0].total_registros) || 0
            this.totalPages = Math.ceil(this.totalRegistros / this.itemsPerPage)
          } else {
            this.totalRegistros = 0
            this.totalPages = 0
          }

          console.log(`Cargados ${this.estatus.length} estatus de ${this.totalRegistros} totales`)
        } else {
          throw new Error(data.eResponse.message || 'Error en la respuesta del servidor')
        }

      } catch (error) {
        this.error = 'Error al cargar los estatus: ' + error.message
        console.error('Error loading estatus:', error)
        this.showToast('error', 'Error al cargar estatus')
      } finally {
        this.loading = false
      }
    },

    async searchEstatus() {
      console.log('Buscando estatus con filtros:', this.filters)
      this.currentPage = 1
      this.loadEstatus()
    },

    clearFilters() {
      this.filters = {
        codigo: '',
        descripcion: '',
        activo: '',
        color: ''
      }
      this.currentPage = 1
      this.loadEstatus()
    },

    async saveEstatus() {
      if (!this.newEstatus.codigo || !this.newEstatus.descripcion) {
        this.showSweetAlert('warning', 'Campos Requeridos', 'Por favor complete los campos requeridos (Código y Descripción)')
        return
      }

      this.creating = true

      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: this.editingEstatus ? 'sp_estatus_update' : 'sp_estatus_create',
              Base: 'padron_licencias',
              Parametros: this.editingEstatus ? [
                { nombre: 'p_id', valor: this.editingEstatus.id },
                { nombre: 'p_descripcion', valor: this.newEstatus.descripcion },
                { nombre: 'p_color', valor: this.newEstatus.color },
                { nombre: 'p_orden', valor: this.newEstatus.orden },
                { nombre: 'p_activo', valor: this.newEstatus.activo },
                { nombre: 'p_observaciones', valor: this.newEstatus.observaciones }
              ] : [
                { nombre: 'p_codigo', valor: this.newEstatus.codigo },
                { nombre: 'p_descripcion', valor: this.newEstatus.descripcion },
                { nombre: 'p_color', valor: this.newEstatus.color },
                { nombre: 'p_orden', valor: this.newEstatus.orden },
                { nombre: 'p_activo', valor: this.newEstatus.activo },
                { nombre: 'p_observaciones', valor: this.newEstatus.observaciones }
              ],
              Tenant: 'informix'
            }
          })
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()
        console.log('Respuesta del servidor:', data)

        if (data.eResponse && data.eResponse.success) {
          const result = data.eResponse.data.result[0]
          if (result.success) {
            this.showSweetAlert(
              'success',
              this.editingEstatus ? 'Estatus Actualizado' : 'Estatus Creado',
              result.message || (this.editingEstatus ? 'Estatus actualizado exitosamente' : 'Estatus creado exitosamente')
            )
            this.resetCreateForm()
            this.showCreateModal = false
            this.loadEstatus()
          } else {
            this.showSweetAlert('error', 'Error', result.message || 'Error en la operación')
            return
          }
        } else {
          throw new Error(data.eResponse.message || 'Error en la respuesta del servidor')
        }

      } catch (error) {
        this.showSweetAlert('error', 'Error al Guardar', 'Error al guardar el estatus: ' + error.message)
        console.error('Error saving estatus:', error)
      } finally {
        this.creating = false
      }
    },

    editEstatus(estatus) {
      this.editingEstatus = estatus
      this.newEstatus = {
        codigo: estatus.codigo,
        descripcion: estatus.descripcion,
        color: estatus.color || '#007bff',
        orden: estatus.orden || 1,
        activo: estatus.activo || 'A',
        observaciones: estatus.observaciones || ''
      }
      this.showCreateModal = true
    },

    async deleteEstatus(estatus) {
      if (!confirm(`¿Está seguro de eliminar el estatus "${estatus.descripcion}"?`)) {
        return
      }

      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_estatus_delete',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_id', valor: estatus.id }
              ],
              Tenant: 'informix'
            }
          })
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()

        if (data.eResponse && data.eResponse.success) {
          this.showSweetAlert('success', 'Estatus Eliminado', 'El estatus ha sido eliminado exitosamente')
          this.loadEstatus()
        } else {
          throw new Error(data.eResponse.message || 'Error al eliminar el estatus')
        }

      } catch (error) {
        this.showSweetAlert('error', 'Error al Eliminar', 'Error al eliminar el estatus: ' + error.message)
        console.error('Error deleting estatus:', error)
      }
    },

    viewEstatus(estatus) {
      this.showSweetAlert('info', 'Información del Estatus',
        `Código: ${estatus.codigo}\nDescripción: ${estatus.descripcion}\nColor: ${estatus.color}\nOrden: ${estatus.orden}\nEstado: ${estatus.activo === 'A' ? 'Activo' : 'Inactivo'}`)
    },

    resetCreateForm() {
      this.editingEstatus = null
      this.newEstatus = {
        codigo: '',
        descripcion: '',
        color: '#007bff',
        orden: 1,
        activo: 'A',
        observaciones: ''
      }
    },

    formatDate(dateString) {
      if (!dateString) return 'No registrada'
      try {
        return new Date(dateString).toLocaleDateString('es-MX')
      } catch {
        return dateString
      }
    },

    // Métodos de paginación
    goToPage(page) {
      if (page >= 1 && page <= this.totalPages && page !== this.currentPage) {
        this.currentPage = page
        this.loadEstatus()
      }
    },

    previousPage() {
      if (this.currentPage > 1) {
        this.currentPage--
        this.loadEstatus()
      }
    },

    nextPage() {
      if (this.currentPage < this.totalPages) {
        this.currentPage++
        this.loadEstatus()
      }
    },

    getVisiblePages() {
      const pages = []
      const maxVisible = 5
      let start = Math.max(1, this.currentPage - Math.floor(maxVisible / 2))
      let end = Math.min(this.totalPages, start + maxVisible - 1)

      if (end - start + 1 < maxVisible) {
        start = Math.max(1, end - maxVisible + 1)
      }

      for (let i = start; i <= end; i++) {
        pages.push(i)
      }

      return pages
    },

    // SweetAlert personalizado
    showSweetAlert(type, title, text) {
      this.sweetAlert = {
        show: true,
        type: type,
        title: title,
        text: text
      }

      // Auto cerrar después de 3 segundos para success, 5 segundos para error y warning
      const autoCloseTime = (type === 'success' || type === 'info') ? 3000 : 5000
      setTimeout(() => {
        this.sweetAlert.show = false
      }, autoCloseTime)
    },

    closeSweetAlert() {
      this.sweetAlert.show = false
    },

    // Sistema de Toast
    showToast(type, message) {
      const toast = {
        id: Date.now(),
        type: type,
        message: message
      }

      this.toasts.push(toast)

      // Auto remover después de 4 segundos
      setTimeout(() => {
        this.removeToast(toast.id)
      }, 4000)
    },

    removeToast(toastId) {
      const index = this.toasts.findIndex(toast => toast.id === toastId)
      if (index > -1) {
        this.toasts.splice(index, 1)
      }
    }
  },

  mounted() {
    console.log('EstatusForm component mounted')
    this.loadEstatus()
  }
}
</script>

