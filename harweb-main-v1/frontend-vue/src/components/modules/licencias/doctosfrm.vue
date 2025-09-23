<template>
  <div class="documentos-module">
    <!-- Header del módulo -->
    <div class="module-header">
      <div class="row align-items-center">
        <div class="col">
          <h3 class="module-title">
            <i class="fas fa-file-alt"></i>
            Gestión de Documentos
          </h3>
          <p class="module-description mb-0">
            Administración del catálogo de documentos requeridos para trámites
          </p>
        </div>
        <div class="col-auto">
          <button
            class="btn btn-primary"
            @click="showCreateModal = true"
            :disabled="loading"
          >
            <i class="fas fa-plus"></i>
            Nuevo Documento
          </button>
        </div>
      </div>
    </div>

    <!-- Filtros de búsqueda -->
    <div class="card mb-4">
      <div class="card-body">
        <div class="row">
          <div class="col-md-4">
            <label class="form-label">Código</label>
            <input
              type="text"
              class="form-control"
              v-model="filters.codigo"
              placeholder="Código del documento"
            >
          </div>
          <div class="col-md-4">
            <label class="form-label">Descripción</label>
            <input
              type="text"
              class="form-control"
              v-model="filters.descripcion"
              placeholder="Descripción del documento"
            >
          </div>
          <div class="col-md-4">
            <label class="form-label">Estado</label>
            <select class="form-select" v-model="filters.activo">
              <option value="">Todos</option>
              <option value="S">Activos</option>
              <option value="N">Inactivos</option>
            </select>
          </div>
        </div>
        <div class="row mt-3">
          <div class="col-12">
            <button
              class="btn btn-outline-primary me-2"
              @click="searchDocumentos"
              :disabled="loading"
            >
              <i class="fas fa-search"></i>
              Buscar
            </button>
            <button
              class="btn btn-outline-secondary me-2"
              @click="clearFilters"
              :disabled="loading"
            >
              <i class="fas fa-times"></i>
              Limpiar
            </button>
            <button
              class="btn btn-outline-success"
              @click="loadDocumentos"
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
    <div class="card">
      <div class="card-header">
        <h6 class="mb-0">
          <i class="fas fa-list"></i>
          Documentos Registrados
          <span v-if="documentos.length > 0" class="badge bg-primary ms-2">
            {{ documentos.length }} registros
          </span>
        </h6>
      </div>
      <div class="card-body">
        <!-- Loading state -->
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
          <p class="mt-2 text-muted">Cargando documentos...</p>
        </div>

        <!-- Error state -->
        <div v-else-if="error" class="alert alert-danger">
          <h6 class="alert-heading">Error al cargar datos</h6>
          <p class="mb-0">{{ error }}</p>
          <hr>
          <button class="btn btn-outline-danger btn-sm" @click="loadDocumentos">
            <i class="fas fa-retry"></i>
            Reintentar
          </button>
        </div>

        <!-- Empty state -->
        <div v-else-if="documentos.length === 0" class="text-center py-5">
          <i class="fas fa-file-alt fa-3x text-muted mb-3"></i>
          <h5 class="text-muted">No se encontraron documentos</h5>
          <p class="text-muted">
            {{ hasActiveFilters ? 'No hay registros que coincidan con los filtros aplicados.' : 'No hay documentos registrados en el sistema.' }}
          </p>
          <button
            v-if="!hasActiveFilters"
            class="btn btn-primary"
            @click="showCreateModal = true"
          >
            <i class="fas fa-plus"></i>
            Registrar primer documento
          </button>
        </div>

        <!-- Tabla con datos -->
        <div v-else class="table-responsive">
          <table class="table table-hover">
            <thead class="table-light">
              <tr>
                <th>Código</th>
                <th>Descripción</th>
                <th>Obligatorio</th>
                <th>Estado</th>
                <th>Fecha Registro</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="documento in paginatedDocumentos" :key="documento.id">
                <td>
                  <strong class="text-primary">{{ documento.codigo }}</strong>
                </td>
                <td>{{ documento.descripcion }}</td>
                <td>
                  <span class="badge" :class="documento.obligatorio === 'S' ? 'bg-warning' : 'bg-info'">
                    {{ documento.obligatorio === 'S' ? 'Obligatorio' : 'Opcional' }}
                  </span>
                </td>
                <td>
                  <span class="badge" :class="documento.activo === 'S' ? 'bg-success' : 'bg-secondary'">
                    {{ documento.activo === 'S' ? 'Activo' : 'Inactivo' }}
                  </span>
                </td>
                <td>{{ formatDate(documento.fecha_registro) }}</td>
                <td>
                  <div class="btn-group btn-group-sm">
                    <button
                      class="btn btn-outline-primary"
                      @click="viewDocumento(documento)"
                      title="Ver detalles"
                    >
                      <i class="fas fa-eye"></i>
                    </button>
                    <button
                      class="btn btn-outline-warning"
                      @click="editDocumento(documento)"
                      title="Editar"
                    >
                      <i class="fas fa-edit"></i>
                    </button>
                    <button
                      class="btn btn-outline-danger"
                      @click="deleteDocumento(documento)"
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
          <nav aria-label="Paginación de documentos">
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

    <!-- Modal para crear/editar documento -->
    <div class="modal fade" tabindex="-1" v-if="showCreateModal" style="display: block;" @click.self="showCreateModal = false">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <i class="fas fa-plus"></i>
              {{ editingDocumento ? 'Editar Documento' : 'Nuevo Documento' }}
            </h5>
            <button type="button" class="btn-close" @click="showCreateModal = false"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="saveDocumento">
              <div class="row">
                <div class="col-md-6">
                  <label class="form-label">Código <span class="text-danger">*</span></label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="newDocumento.codigo"
                    placeholder="Ej: DOC001"
                    required
                    maxlength="10"
                    :disabled="editingDocumento"
                  >
                </div>
                <div class="col-md-6">
                  <label class="form-label">Estado</label>
                  <select class="form-select" v-model="newDocumento.activo">
                    <option value="S">Activo</option>
                    <option value="N">Inactivo</option>
                  </select>
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-12">
                  <label class="form-label">Descripción <span class="text-danger">*</span></label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="newDocumento.descripcion"
                    placeholder="Descripción del documento"
                    required
                    maxlength="255"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-md-6">
                  <label class="form-label">Obligatorio</label>
                  <select class="form-select" v-model="newDocumento.obligatorio">
                    <option value="S">Sí</option>
                    <option value="N">No</option>
                  </select>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Orden</label>
                  <input
                    type="number"
                    class="form-control"
                    v-model="newDocumento.orden"
                    placeholder="1"
                    min="1"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-12">
                  <label class="form-label">Observaciones</label>
                  <textarea
                    class="form-control"
                    rows="3"
                    v-model="newDocumento.observaciones"
                    placeholder="Observaciones adicionales sobre el documento"
                  ></textarea>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="showCreateModal = false">
              Cancelar
            </button>
            <button
              type="button"
              class="btn btn-primary"
              @click="saveDocumento"
              :disabled="creating || !newDocumento.codigo || !newDocumento.descripcion"
            >
              <span v-if="creating">
                <i class="fas fa-spinner fa-spin"></i>
                {{ editingDocumento ? 'Actualizando...' : 'Creando...' }}
              </span>
              <span v-else>
                <i class="fas fa-save"></i>
                {{ editingDocumento ? 'Actualizar Documento' : 'Crear Documento' }}
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
          <button class="btn btn-primary" @click="closeSweetAlert">
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
  name: 'DocumentosForm',
  data() {
    return {
      // Estado de carga
      loading: false,
      creating: false,
      error: null,

      // Datos
      documentos: [],
      totalRegistros: 0,

      // Paginación
      currentPage: 1,
      itemsPerPage: 10,
      totalPages: 0,

      // Filtros
      filters: {
        codigo: '',
        descripcion: '',
        activo: ''
      },

      // Modal
      showCreateModal: false,
      editingDocumento: null,

      // SweetAlert
      sweetAlert: {
        show: false,
        type: 'info',
        title: '',
        text: ''
      },

      // Toast notifications
      toasts: [],

      // Nuevo documento
      newDocumento: {
        codigo: '',
        descripcion: '',
        obligatorio: 'S',
        orden: 1,
        activo: 'S',
        observaciones: ''
      }
    }
  },

  computed: {
    hasActiveFilters() {
      return Object.values(this.filters).some(value => value !== null && value !== '')
    },

    paginatedDocumentos() {
      const start = (this.currentPage - 1) * this.itemsPerPage
      const end = start + this.itemsPerPage
      return this.documentos.slice(start, end)
    }
  },

  methods: {
    async loadDocumentos() {
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
              Operacion: 'sp_documentos_list',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_codigo', valor: this.filters.codigo || null },
                { nombre: 'p_descripcion', valor: this.filters.descripcion || null },
                { nombre: 'p_activo', valor: this.filters.activo || null },
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

        if (data.eResponse.success && data.eResponse.data.result) {
          this.documentos = data.eResponse.data.result || []

          // Obtener el total de registros del primer elemento (si existe)
          if (this.documentos.length > 0) {
            this.totalRegistros = parseInt(this.documentos[0].total_registros) || 0
            this.totalPages = Math.ceil(this.totalRegistros / this.itemsPerPage)
          } else {
            this.totalRegistros = 0
            this.totalPages = 0
          }

          console.log(`Cargados ${this.documentos.length} documentos de ${this.totalRegistros} totales`)
        } else {
          throw new Error(data.eResponse.message || 'Error en la respuesta del servidor')
        }

      } catch (error) {
        this.error = 'Error al cargar los documentos: ' + error.message
        console.error('Error loading documentos:', error)
        this.showToast('error', 'Error al cargar documentos')
      } finally {
        this.loading = false
      }
    },

    async searchDocumentos() {
      console.log('Buscando documentos con filtros:', this.filters)
      this.currentPage = 1
      this.loadDocumentos()
    },

    clearFilters() {
      this.filters = {
        codigo: '',
        descripcion: '',
        activo: ''
      }
      this.currentPage = 1
      this.loadDocumentos()
    },

    async saveDocumento() {
      if (!this.newDocumento.codigo || !this.newDocumento.descripcion) {
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
              Operacion: this.editingDocumento ? 'sp_documentos_update' : 'sp_documentos_create',
              Base: 'padron_licencias',
              Parametros: this.editingDocumento ? [
                { nombre: 'p_id', valor: this.editingDocumento.id },
                { nombre: 'p_descripcion', valor: this.newDocumento.descripcion },
                { nombre: 'p_obligatorio', valor: this.newDocumento.obligatorio },
                { nombre: 'p_orden', valor: this.newDocumento.orden },
                { nombre: 'p_activo', valor: this.newDocumento.activo },
                { nombre: 'p_observaciones', valor: this.newDocumento.observaciones }
              ] : [
                { nombre: 'p_codigo', valor: this.newDocumento.codigo },
                { nombre: 'p_descripcion', valor: this.newDocumento.descripcion },
                { nombre: 'p_obligatorio', valor: this.newDocumento.obligatorio },
                { nombre: 'p_orden', valor: this.newDocumento.orden },
                { nombre: 'p_activo', valor: this.newDocumento.activo },
                { nombre: 'p_observaciones', valor: this.newDocumento.observaciones }
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

        if (data.eResponse.success && data.eResponse.data.result) {
          const result = data.eResponse.data.result[0]
          if (result.success) {
            this.showSweetAlert(
              'success',
              this.editingDocumento ? 'Documento Actualizado' : 'Documento Creado',
              result.message || (this.editingDocumento ? 'Documento actualizado exitosamente' : 'Documento creado exitosamente')
            )
            this.resetCreateForm()
            this.showCreateModal = false
            this.loadDocumentos()
          } else {
            this.showSweetAlert('error', 'Error', result.message || 'Error en la operación')
            return
          }
        } else {
          throw new Error(data.eResponse.message || 'Error en la respuesta del servidor')
        }

      } catch (error) {
        this.showSweetAlert('error', 'Error al Guardar', 'Error al guardar el documento: ' + error.message)
        console.error('Error saving documento:', error)
      } finally {
        this.creating = false
      }
    },

    editDocumento(documento) {
      this.editingDocumento = documento
      this.newDocumento = {
        codigo: documento.codigo,
        descripcion: documento.descripcion,
        obligatorio: documento.obligatorio || 'S',
        orden: documento.orden || 1,
        activo: documento.activo || 'S',
        observaciones: documento.observaciones || ''
      }
      this.showCreateModal = true
    },

    async deleteDocumento(documento) {
      if (!confirm(`¿Está seguro de eliminar el documento "${documento.descripcion}"?`)) {
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
              Operacion: 'sp_documentos_delete',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_id', valor: documento.id }
              ],
              Tenant: 'informix'
            }
          })
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()

        if (data.eResponse.success && data.eResponse.data.result) {
          this.showSweetAlert('success', 'Documento Eliminado', 'El documento ha sido eliminado exitosamente')
          this.loadDocumentos()
        } else {
          throw new Error(data.eResponse.message || 'Error al eliminar el documento')
        }

      } catch (error) {
        this.showSweetAlert('error', 'Error al Eliminar', 'Error al eliminar el documento: ' + error.message)
        console.error('Error deleting documento:', error)
      }
    },

    viewDocumento(documento) {
      this.showSweetAlert('info', 'Información del Documento',
        `Código: ${documento.codigo}\nDescripción: ${documento.descripcion}\nObligatorio: ${documento.obligatorio === 'S' ? 'Sí' : 'No'}\nEstado: ${documento.activo === 'S' ? 'Activo' : 'Inactivo'}`)
    },

    resetCreateForm() {
      this.editingDocumento = null
      this.newDocumento = {
        codigo: '',
        descripcion: '',
        obligatorio: 'S',
        orden: 1,
        activo: 'S',
        observaciones: ''
      }
    },

    formatDate(dateString) {
      if (!dateString) return 'N/A'
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
        this.loadDocumentos()
      }
    },

    previousPage() {
      if (this.currentPage > 1) {
        this.currentPage--
        this.loadDocumentos()
      }
    },

    nextPage() {
      if (this.currentPage < this.totalPages) {
        this.currentPage++
        this.loadDocumentos()
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
    console.log('DocumentosForm component mounted')
    this.loadDocumentos()
  }
}
</script>

<style scoped>
/* Estilos específicos del módulo de documentos */
.documentos-module {
  padding: 1rem;
}

.module-header {
  background: linear-gradient(135deg, #6f42c1 0%, #8b5cf6 100%);
  color: white;
  padding: 1.5rem;
  border-radius: 0.5rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.module-title {
  margin: 0;
  font-weight: 600;
}

.module-description {
  opacity: 0.9;
  font-size: 0.95rem;
}

/* Hover específico para documentos */
.table-hover tbody tr:hover {
  background-color: rgba(111, 66, 193, 0.05);
}

/* Paginación con tema violeta para documentos */
.pagination .page-link {
  color: #6f42c1;
  border-color: #dee2e6;
  padding: 0.375rem 0.75rem;
}

.pagination .page-link:hover {
  color: #5a2d91;
  background-color: #e9ecef;
  border-color: #adb5bd;
}

.pagination .page-item.active .page-link {
  background-color: #6f42c1;
  border-color: #6f42c1;
  color: white;
}

.pagination .page-link:focus {
  box-shadow: 0 0 0 0.2rem rgba(111, 66, 193, 0.25);
}

/* Estilos globales importados desde src/styles/global.css */
.swal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
}

.swal-modal {
  background: white;
  border-radius: 0.5rem;
  padding: 2rem;
  text-align: center;
  max-width: 500px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
}

.swal-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.swal-icon.success { color: #28a745; }
.swal-icon.error { color: #dc3545; }
.swal-icon.warning { color: #ffc107; }
.swal-icon.info { color: #17a2b8; }

.swal-title {
  font-size: 1.5rem;
  font-weight: 600;
  margin-bottom: 1rem;
}

.swal-text {
  margin-bottom: 2rem;
  color: #6c757d;
}

.toast-notification {
  position: fixed;
  right: 20px;
  z-index: 9999;
  min-width: 300px;
  background: white;
  border-radius: 0.5rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  display: flex;
  align-items: center;
  padding: 1rem;
  border-left: 4px solid;
  animation: slideInRight 0.3s ease-out;
}

.toast-notification.success { border-left-color: #28a745; }
.toast-notification.error { border-left-color: #dc3545; }
.toast-notification.warning { border-left-color: #ffc107; }
.toast-notification.info { border-left-color: #17a2b8; }

.toast-icon {
  margin-right: 0.75rem;
  font-size: 1.25rem;
}

.toast-notification.success .toast-icon { color: #28a745; }
.toast-notification.error .toast-icon { color: #dc3545; }
.toast-notification.warning .toast-icon { color: #ffc107; }
.toast-notification.info .toast-icon { color: #17a2b8; }

.toast-message {
  flex: 1;
  font-weight: 500;
}

.toast-close {
  background: none;
  border: none;
  font-size: 1rem;
  color: #6c757d;
  cursor: pointer;
  margin-left: 0.75rem;
}

@keyframes slideInRight {
  from { transform: translateX(100%); opacity: 0; }
  to { transform: translateX(0); opacity: 1; }
}
</style>