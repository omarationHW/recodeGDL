<template>
  <div class="empleados-module">
    <!-- Header del módulo -->
    <div class="module-header">
      <div class="row align-items-center">
        <div class="col">
          <h3 class="module-title">
            <i class="fas fa-users"></i>
            Gestión de Empleados
          </h3>
          <p class="module-description mb-0">
            Administración del catálogo de empleados del sistema
          </p>
        </div>
        <div class="col-auto">
          <button
            class="btn btn-primary"
            @click="showCreateModal = true"
            :disabled="loading"
          >
            <i class="fas fa-plus"></i>
            Nuevo Empleado
          </button>
        </div>
      </div>
    </div>

    <!-- Filtros de búsqueda -->
    <div class="card mb-4">
      <div class="card-body">
        <div class="row">
          <div class="col-md-4">
            <label class="form-label">Nombre</label>
            <input
              type="text"
              class="form-control"
              v-model="filters.nombre"
              placeholder="Nombre del empleado"
            >
          </div>
          <div class="col-md-4">
            <label class="form-label">Correo</label>
            <input
              type="text"
              class="form-control"
              v-model="filters.correo"
              placeholder="Correo electrónico"
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
              @click="searchEmpleados"
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
              @click="loadEmpleados"
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
          Empleados Registrados
          <span v-if="empleados.length > 0" class="badge bg-primary ms-2">
            {{ empleados.length }} registros
          </span>
        </h6>
      </div>
      <div class="card-body">
        <!-- Loading state -->
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
          <p class="mt-2 text-muted">Cargando empleados...</p>
        </div>

        <!-- Error state -->
        <div v-else-if="error" class="alert alert-danger">
          <h6 class="alert-heading">Error al cargar datos</h6>
          <p class="mb-0">{{ error }}</p>
          <hr>
          <button class="btn btn-outline-danger btn-sm" @click="loadEmpleados">
            <i class="fas fa-retry"></i>
            Reintentar
          </button>
        </div>

        <!-- Empty state -->
        <div v-else-if="empleados.length === 0" class="text-center py-5">
          <i class="fas fa-users fa-3x text-muted mb-3"></i>
          <h5 class="text-muted">No se encontraron empleados</h5>
          <p class="text-muted">
            {{ hasActiveFilters ? 'No hay registros que coincidan con los filtros aplicados.' : 'No hay empleados registrados en el sistema.' }}
          </p>
          <button
            v-if="!hasActiveFilters"
            class="btn btn-primary"
            @click="showCreateModal = true"
          >
            <i class="fas fa-plus"></i>
            Registrar primer empleado
          </button>
        </div>

        <!-- Tabla con datos -->
        <div v-else class="table-responsive">
          <table class="table table-hover">
            <thead class="table-light">
              <tr>
                <th>ID</th>
                <th>Nombre</th>
                <th>Correo</th>
                <th>Fecha Registro</th>
                <th>Estado</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="empleado in paginatedEmpleados" :key="empleado.id">
                <td>
                  <strong class="text-primary">#{{ empleado.id }}</strong>
                </td>
                <td>{{ empleado.nombre }}</td>
                <td>{{ empleado.correo }}</td>
                <td>{{ formatDate(empleado.created_at) }}</td>
                <td>
                  <span class="badge" :class="empleado.activo === 'S' ? 'bg-success' : 'bg-secondary'">
                    {{ empleado.activo === 'S' ? 'Activo' : 'Inactivo' }}
                  </span>
                </td>
                <td>
                  <div class="btn-group btn-group-sm">
                    <button
                      class="btn btn-outline-primary"
                      @click="viewEmpleado(empleado)"
                      title="Ver detalles"
                    >
                      <i class="fas fa-eye"></i>
                    </button>
                    <button
                      class="btn btn-outline-warning"
                      @click="editEmpleado(empleado)"
                      title="Editar"
                    >
                      <i class="fas fa-edit"></i>
                    </button>
                    <button
                      class="btn btn-outline-danger"
                      @click="deleteEmpleado(empleado)"
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
          <nav aria-label="Paginación de empleados">
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

    <!-- Modal para crear/editar empleado -->
    <div class="modal fade" tabindex="-1" v-if="showCreateModal" style="display: block;" @click.self="showCreateModal = false">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <i class="fas fa-plus"></i>
              {{ editingEmpleado ? 'Editar Empleado' : 'Nuevo Empleado' }}
            </h5>
            <button type="button" class="btn-close" @click="showCreateModal = false"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="saveEmpleado">
              <div class="row">
                <div class="col-md-6">
                  <label class="form-label">Nombre <span class="text-danger">*</span></label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="newEmpleado.nombre"
                    placeholder="Nombre completo"
                    required
                    maxlength="255"
                  >
                </div>
                <div class="col-md-6">
                  <label class="form-label">Correo <span class="text-danger">*</span></label>
                  <input
                    type="email"
                    class="form-control"
                    v-model="newEmpleado.correo"
                    placeholder="correo@ejemplo.com"
                    required
                    maxlength="255"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-md-6">
                  <label class="form-label">Estado</label>
                  <select class="form-select" v-model="newEmpleado.activo">
                    <option value="S">Activo</option>
                    <option value="N">Inactivo</option>
                  </select>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Departamento</label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="newEmpleado.departamento"
                    placeholder="Departamento"
                    maxlength="100"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-12">
                  <label class="form-label">Observaciones</label>
                  <textarea
                    class="form-control"
                    rows="3"
                    v-model="newEmpleado.observaciones"
                    placeholder="Observaciones adicionales sobre el empleado"
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
              @click="saveEmpleado"
              :disabled="creating || !newEmpleado.nombre || !newEmpleado.correo"
            >
              <span v-if="creating">
                <i class="fas fa-spinner fa-spin"></i>
                {{ editingEmpleado ? 'Actualizando...' : 'Creando...' }}
              </span>
              <span v-else>
                <i class="fas fa-save"></i>
                {{ editingEmpleado ? 'Actualizar Empleado' : 'Crear Empleado' }}
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
  name: 'EmpleadosListado',
  data() {
    return {
      // Estado de carga
      loading: false,
      creating: false,
      error: null,

      // Datos
      empleados: [],
      totalRegistros: 0,

      // Paginación
      currentPage: 1,
      itemsPerPage: 10,
      totalPages: 0,

      // Filtros
      filters: {
        nombre: '',
        correo: '',
        activo: ''
      },

      // Modal
      showCreateModal: false,
      editingEmpleado: null,

      // SweetAlert
      sweetAlert: {
        show: false,
        type: 'info',
        title: '',
        text: ''
      },

      // Toast notifications
      toasts: [],

      // Nuevo empleado
      newEmpleado: {
        nombre: '',
        correo: '',
        departamento: '',
        activo: 'S',
        observaciones: ''
      }
    }
  },

  computed: {
    hasActiveFilters() {
      return Object.values(this.filters).some(value => value !== null && value !== '')
    },

    paginatedEmpleados() {
      const start = (this.currentPage - 1) * this.itemsPerPage
      const end = start + this.itemsPerPage
      return this.empleados.slice(start, end)
    }
  },

  methods: {
    async loadEmpleados() {
      this.loading = true
      this.error = null

      try {
        const response = await fetch('http://localhost:8080/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_empleados_list',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_nombre', valor: this.filters.nombre || null },
                { nombre: 'p_correo', valor: this.filters.correo || null },
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

        if (data.success && data.data) {
          this.empleados = data.data || []

          // Obtener el total de registros del primer elemento (si existe)
          if (this.empleados.length > 0) {
            this.totalRegistros = parseInt(this.empleados[0].total_registros) || 0
            this.totalPages = Math.ceil(this.totalRegistros / this.itemsPerPage)
          } else {
            this.totalRegistros = 0
            this.totalPages = 0
          }

          console.log(`Cargados ${this.empleados.length} empleados de ${this.totalRegistros} totales`)
        } else {
          throw new Error(data.error || 'Error en la respuesta del servidor')
        }

      } catch (error) {
        this.error = 'Error al cargar los empleados: ' + error.message
        console.error('Error loading empleados:', error)
        this.showToast('error', 'Error al cargar empleados')
      } finally {
        this.loading = false
      }
    },

    async searchEmpleados() {
      console.log('Buscando empleados con filtros:', this.filters)
      this.currentPage = 1
      this.loadEmpleados()
    },

    clearFilters() {
      this.filters = {
        nombre: '',
        correo: '',
        activo: ''
      }
      this.currentPage = 1
      this.loadEmpleados()
    },

    async saveEmpleado() {
      if (!this.newEmpleado.nombre || !this.newEmpleado.correo) {
        this.showSweetAlert('warning', 'Campos Requeridos', 'Por favor complete los campos requeridos (Nombre y Correo)')
        return
      }

      this.creating = true

      try {
        const response = await fetch('http://localhost:8080/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: this.editingEmpleado ? 'sp_empleados_update' : 'sp_empleados_create',
              Base: 'padron_licencias',
              Parametros: this.editingEmpleado ? [
                { nombre: 'p_id', valor: this.editingEmpleado.id },
                { nombre: 'p_nombre', valor: this.newEmpleado.nombre },
                { nombre: 'p_correo', valor: this.newEmpleado.correo },
                { nombre: 'p_departamento', valor: this.newEmpleado.departamento },
                { nombre: 'p_activo', valor: this.newEmpleado.activo },
                { nombre: 'p_observaciones', valor: this.newEmpleado.observaciones }
              ] : [
                { nombre: 'p_nombre', valor: this.newEmpleado.nombre },
                { nombre: 'p_correo', valor: this.newEmpleado.correo },
                { nombre: 'p_departamento', valor: this.newEmpleado.departamento },
                { nombre: 'p_activo', valor: this.newEmpleado.activo },
                { nombre: 'p_observaciones', valor: this.newEmpleado.observaciones }
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

        if (data.success && data.data) {
          const result = data.data[0]
          if (result.success) {
            this.showSweetAlert(
              'success',
              this.editingEmpleado ? 'Empleado Actualizado' : 'Empleado Creado',
              result.message || (this.editingEmpleado ? 'Empleado actualizado exitosamente' : 'Empleado creado exitosamente')
            )
            this.resetCreateForm()
            this.showCreateModal = false
            this.loadEmpleados()
          } else {
            this.showSweetAlert('error', 'Error', result.message || 'Error en la operación')
            return
          }
        } else {
          throw new Error(data.error || 'Error en la respuesta del servidor')
        }

      } catch (error) {
        this.showSweetAlert('error', 'Error al Guardar', 'Error al guardar el empleado: ' + error.message)
        console.error('Error saving empleado:', error)
      } finally {
        this.creating = false
      }
    },

    editEmpleado(empleado) {
      this.editingEmpleado = empleado
      this.newEmpleado = {
        nombre: empleado.nombre,
        correo: empleado.correo,
        departamento: empleado.departamento || '',
        activo: empleado.activo || 'S',
        observaciones: empleado.observaciones || ''
      }
      this.showCreateModal = true
    },

    async deleteEmpleado(empleado) {
      if (!confirm(`¿Está seguro de eliminar al empleado "${empleado.nombre}"?`)) {
        return
      }

      try {
        const response = await fetch('http://localhost:8080/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_empleados_delete',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_id', valor: empleado.id }
              ],
              Tenant: 'informix'
            }
          })
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()

        if (data.success && data.data) {
          this.showSweetAlert('success', 'Empleado Eliminado', 'El empleado ha sido eliminado exitosamente')
          this.loadEmpleados()
        } else {
          throw new Error(data.error || 'Error al eliminar el empleado')
        }

      } catch (error) {
        this.showSweetAlert('error', 'Error al Eliminar', 'Error al eliminar el empleado: ' + error.message)
        console.error('Error deleting empleado:', error)
      }
    },

    viewEmpleado(empleado) {
      this.showSweetAlert('info', 'Información del Empleado',
        `Nombre: ${empleado.nombre}\nCorreo: ${empleado.correo}\nDepartamento: ${empleado.departamento || 'No asignado'}\nEstado: ${empleado.activo === 'S' ? 'Activo' : 'Inactivo'}`)
    },

    resetCreateForm() {
      this.editingEmpleado = null
      this.newEmpleado = {
        nombre: '',
        correo: '',
        departamento: '',
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
        this.loadEmpleados()
      }
    },

    previousPage() {
      if (this.currentPage > 1) {
        this.currentPage--
        this.loadEmpleados()
      }
    },

    nextPage() {
      if (this.currentPage < this.totalPages) {
        this.currentPage++
        this.loadEmpleados()
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
    console.log('EmpleadosListado component mounted')
    this.loadEmpleados()
  }
}
</script>

<style scoped>
/* Estilos específicos del módulo de empleados */
.empleados-module {
  padding: 1rem;
}

.module-header {
  background: linear-gradient(135deg, #17a2b8 0%, #20c997 100%);
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

/* Hover específico para empleados */
.table-hover tbody tr:hover {
  background-color: rgba(23, 162, 184, 0.05);
}

/* Paginación con tema cyan para empleados */
.pagination .page-link {
  color: #17a2b8;
  border-color: #dee2e6;
  padding: 0.375rem 0.75rem;
}

.pagination .page-link:hover {
  color: #117a8b;
  background-color: #e9ecef;
  border-color: #adb5bd;
}

.pagination .page-item.active .page-link {
  background-color: #17a2b8;
  border-color: #17a2b8;
  color: white;
}

.pagination .page-link:focus {
  box-shadow: 0 0 0 0.2rem rgba(23, 162, 184, 0.25);
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