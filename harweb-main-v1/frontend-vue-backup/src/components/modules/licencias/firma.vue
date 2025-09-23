<template>
  <div class="container-fluid px-4 py-3">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-4">
      <ol class="breadcrumb bg-light rounded p-3">
        <li class="breadcrumb-item"><i class="fas fa-home"></i> <router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item"><i class="fas fa-shield-alt"></i> Seguridad</li>
        <li class="breadcrumb-item active" aria-current="page">Gestión de Firmas Digitales</li>
      </ol>
    </nav>

    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h3 mb-1"><i class="fas fa-signature text-primary me-2"></i>Gestión de Firmas Digitales</h2>
            <p class="text-muted mb-0">Administración y validación de firmas electrónicas del sistema</p>
          </div>
          <button class="btn btn-primary" @click="showModal = true; modalTitle = 'Nueva Firma'; currentItem = {};">
            <i class="fas fa-plus me-1"></i>Nueva Firma
          </button>
        </div>
      </div>
    </div>

    <!-- Filtros -->
    <div class="card mb-4">
      <div class="card-body">
        <div class="row g-3">
          <div class="col-md-4">
            <label class="form-label">Buscar por usuario:</label>
            <input v-model="filters.usuario" @input="loadFirmas" type="text" class="form-control" placeholder="Usuario...">
          </div>
          <div class="col-md-3">
            <label class="form-label">Estado:</label>
            <select v-model="filters.estado" @change="loadFirmas" class="form-select">
              <option value="">Todos</option>
              <option value="1">Activo</option>
              <option value="0">Inactivo</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="form-label">Nivel de seguridad:</label>
            <select v-model="filters.securityLevel" @change="loadFirmas" class="form-select">
              <option value="">Todos</option>
              <option value="1">Básico</option>
              <option value="2">Medio</option>
              <option value="3">Alto</option>
            </select>
          </div>
          <div class="col-md-2 d-flex align-items-end">
            <button @click="resetFilters" class="btn btn-outline-secondary">
              <i class="fas fa-eraser me-1"></i>Limpiar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de firmas -->
    <div class="card">
      <div class="card-header bg-light">
        <h5 class="mb-0">Listado de Firmas Registradas</h5>
      </div>
      <div class="card-body p-0">
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary" role="status"></div>
          <p class="mt-2 mb-0">Cargando firmas...</p>
        </div>

        <div v-else>
          <div class="table-responsive">
            <table class="table table-hover mb-0">
              <thead class="table-light">
                <tr>
                  <th>ID</th>
                  <th>Usuario</th>
                  <th>Hash Firma</th>
                  <th>Nivel Seguridad</th>
                  <th>Último Acceso</th>
                  <th>Estado</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="firma in firmas" :key="firma.id">
                  <td>{{ firma.id }}</td>
                  <td>
                    <div class="d-flex align-items-center">
                      <i class="fas fa-user-circle text-muted me-2"></i>
                      {{ firma.usuario }}
                    </div>
                  </td>
                  <td>
                    <span class="font-monospace text-muted">{{ firma.hash_firma ? firma.hash_firma.substring(0, 16) + '...' : 'N/A' }}</span>
                  </td>
                  <td>
                    <span :class="getSecurityLevelClass(firma.nivel_seguridad)">
                      {{ getSecurityLevelText(firma.nivel_seguridad) }}
                    </span>
                  </td>
                  <td>{{ formatDate(firma.ultimo_acceso) }}</td>
                  <td>
                    <span :class="firma.estado == 1 ? 'badge bg-success' : 'badge bg-danger'">
                      {{ firma.estado == 1 ? 'Activo' : 'Inactivo' }}
                    </span>
                  </td>
                  <td>
                    <button @click="editItem(firma)" class="btn btn-sm btn-outline-primary me-1" title="Editar">
                      <i class="fas fa-edit"></i>
                    </button>
                    <button @click="verifyFirma(firma)" class="btn btn-sm btn-outline-info me-1" title="Verificar">
                      <i class="fas fa-check-circle"></i>
                    </button>
                    <button @click="deleteItem(firma)" class="btn btn-sm btn-outline-danger" title="Eliminar">
                      <i class="fas fa-trash"></i>
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="pagination.total > pagination.limit" class="d-flex justify-content-between align-items-center p-3 bg-light">
            <span class="text-muted">
              Mostrando {{ ((pagination.page - 1) * pagination.limit) + 1 }} a {{ Math.min(pagination.page * pagination.limit, pagination.total) }} de {{ pagination.total }} registros
            </span>
            <nav>
              <ul class="pagination pagination-sm mb-0">
                <li class="page-item" :class="{ disabled: pagination.page <= 1 }">
                  <button class="page-link" @click="changePage(pagination.page - 1)">Anterior</button>
                </li>
                <li v-for="page in getPageNumbers()" :key="page" class="page-item" :class="{ active: page === pagination.page }">
                  <button class="page-link" @click="changePage(page)">{{ page }}</button>
                </li>
                <li class="page-item" :class="{ disabled: pagination.page >= Math.ceil(pagination.total / pagination.limit) }">
                  <button class="page-link" @click="changePage(pagination.page + 1)">Siguiente</button>
                </li>
              </ul>
            </nav>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal para firma -->
    <div class="modal fade" :class="{ show: showModal }" :style="{ display: showModal ? 'block' : 'none' }" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ modalTitle }}</h5>
            <button type="button" class="btn-close" @click="closeModal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="saveItem">
              <div class="row g-3">
                <div class="col-md-6">
                  <label class="form-label">Usuario <span class="text-danger">*</span></label>
                  <input v-model="currentItem.usuario" type="text" class="form-control" required>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Nivel de Seguridad <span class="text-danger">*</span></label>
                  <select v-model="currentItem.nivel_seguridad" class="form-select" required>
                    <option value="1">Básico</option>
                    <option value="2">Medio</option>
                    <option value="3">Alto</option>
                  </select>
                </div>
                <div class="col-12">
                  <label class="form-label">Firma Digital <span class="text-danger">*</span></label>
                  <div class="input-group">
                    <input v-model="currentItem.firma_digital" :type="showPassword ? 'text' : 'password'" class="form-control" required>
                    <button type="button" class="btn btn-outline-secondary" @click="showPassword = !showPassword">
                      <i :class="showPassword ? 'fas fa-eye-slash' : 'fas fa-eye'"></i>
                    </button>
                  </div>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Estado</label>
                  <select v-model="currentItem.estado" class="form-select">
                    <option value="1">Activo</option>
                    <option value="0">Inactivo</option>
                  </select>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Observaciones</label>
                  <textarea v-model="currentItem.observaciones" class="form-control" rows="2"></textarea>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="closeModal">Cancelar</button>
            <button type="button" class="btn btn-primary" @click="saveItem">
              <i class="fas fa-save me-1"></i>Guardar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal backdrop -->
    <div v-if="showModal" class="modal-backdrop fade show"></div>
  </div>
</template>

<script>
import axios from 'axios'
import Swal from 'sweetalert2'

export default {
  name: 'FirmaElectronicaPage',
  data() {
    return {
      firmas: [],
      loading: false,
      showModal: false,
      modalTitle: '',
      currentItem: {
        usuario: '',
        firma_digital: '',
        nivel_seguridad: 1,
        estado: 1,
        observaciones: ''
      },
      showPassword: false,
      securityLevel: 1,
      auditLogs: [],
      filters: {
        usuario: '',
        estado: '',
        securityLevel: ''
      },
      pagination: {
        page: 1,
        limit: 10,
        total: 0
      }
    }
  },
  mounted() {
    this.loadFirmas()
  },
  methods: {
    async loadFirmas() {
      this.loading = true
      try {
        const response = await axios.post('http://localhost:8080/api/generic', {
          eRequest: {
            Operacion: 'sp_firma_list',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_usuario', valor: this.filters.usuario || null },
              { nombre: 'p_estado', valor: this.filters.estado || null },
              { nombre: 'p_nivel', valor: this.filters.securityLevel || null },
              { nombre: 'p_limite', valor: this.pagination.limit },
              { nombre: 'p_offset', valor: (this.pagination.page - 1) * this.pagination.limit }
            ],
            Tenant: 'informix'
          }
        })

        if (response.data && response.data.success) {
          this.firmas = response.data.data || []
          if (this.firmas.length > 0) {
            this.pagination.total = this.firmas[0].total_registros || 0
          }
        }
      } catch (error) {
        console.error('Error cargando firmas:', error)
        this.$toast.error('Error al cargar las firmas digitales')
      } finally {
        this.loading = false
      }
    },

    async saveItem() {
      try {
        const operation = this.currentItem.id ? 'U' : 'I'

        const response = await axios.post('http://localhost:8080/api/generic', {
          eRequest: {
            Operacion: operation === 'I' ? 'sp_firma_create' : 'sp_firma_update',
            Base: 'padron_licencias',
            Parametros: operation === 'I' ? [
              { nombre: 'p_usuario', valor: this.currentItem.usuario },
              { nombre: 'p_firma_digital', valor: this.currentItem.firma_digital },
              { nombre: 'p_nivel_seguridad', valor: this.currentItem.nivel_seguridad },
              { nombre: 'p_estado', valor: this.currentItem.estado },
              { nombre: 'p_observaciones', valor: this.currentItem.observaciones }
            ] : [
              { nombre: 'p_id', valor: this.currentItem.id },
              { nombre: 'p_usuario', valor: this.currentItem.usuario },
              { nombre: 'p_firma_digital', valor: this.currentItem.firma_digital },
              { nombre: 'p_nivel_seguridad', valor: this.currentItem.nivel_seguridad },
              { nombre: 'p_estado', valor: this.currentItem.estado },
              { nombre: 'p_observaciones', valor: this.currentItem.observaciones }
            ],
            Tenant: 'informix'
          }
        })

        if (response.data && response.data.success) {
          await Swal.fire({
            icon: 'success',
            title: 'Éxito',
            text: operation === 'I' ? 'Firma registrada correctamente' : 'Firma actualizada correctamente',
            timer: 3000,
            showConfirmButton: false
          })

          this.closeModal()
          this.loadFirmas()
        } else {
          throw new Error(response.data?.error || 'Error en la operación')
        }
      } catch (error) {
        console.error('Error guardando firma:', error)
        await Swal.fire({
          icon: 'error',
          title: 'Error',
          text: error.message || 'Error al guardar la firma',
          timer: 5000,
          showConfirmButton: false
        })
      }
    },

    async verifyFirma(firma) {
      try {
        const { value: firmaInput } = await Swal.fire({
          title: 'Verificar Firma Digital',
          text: `Ingrese la firma para verificar el usuario: ${firma.usuario}`,
          input: 'password',
          inputPlaceholder: 'Firma digital...',
          showCancelButton: true,
          confirmButtonText: 'Verificar',
          cancelButtonText: 'Cancelar',
          inputValidator: (value) => {
            if (!value) {
              return 'Debe ingresar la firma digital'
            }
          }
        })

        if (firmaInput) {
          const response = await axios.post('http://localhost:8080/api/generic', {
            eRequest: {
              Operacion: 'sp_firma_verificar',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_usuario', valor: firma.usuario },
                { nombre: 'p_firma_digital', valor: firmaInput }
              ],
              Tenant: 'informix'
            }
          })

          if (response.data?.success && response.data?.data?.[0]?.verificado) {
            await Swal.fire({
              icon: 'success',
              title: 'Verificación Exitosa',
              text: 'La firma digital es válida',
              timer: 3000,
              showConfirmButton: false
            })
          } else {
            await Swal.fire({
              icon: 'error',
              title: 'Verificación Fallida',
              text: 'La firma digital no es válida',
              timer: 5000,
              showConfirmButton: false
            })
          }
        }
      } catch (error) {
        console.error('Error verificando firma:', error)
        await Swal.fire({
          icon: 'error',
          title: 'Error',
          text: 'Error al verificar la firma digital',
          timer: 5000,
          showConfirmButton: false
        })
      }
    },

    async deleteItem(firma) {
      const result = await Swal.fire({
        title: '¿Está seguro?',
        text: `¿Desea eliminar la firma del usuario: ${firma.usuario}?`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: 'Sí, eliminar',
        cancelButtonText: 'Cancelar'
      })

      if (result.isConfirmed) {
        try {
          const response = await axios.post('http://localhost:8080/api/generic', {
            eRequest: {
              Operacion: 'sp_firma_delete',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_id', valor: firma.id }
              ],
              Tenant: 'informix'
            }
          })

          if (response.data?.success) {
            await Swal.fire({
              icon: 'success',
              title: 'Eliminado',
              text: 'Firma eliminada correctamente',
              timer: 3000,
              showConfirmButton: false
            })
            this.loadFirmas()
          }
        } catch (error) {
          console.error('Error eliminando firma:', error)
          await Swal.fire({
            icon: 'error',
            title: 'Error',
            text: 'Error al eliminar la firma',
            timer: 5000,
            showConfirmButton: false
          })
        }
      }
    },

    editItem(firma) {
      this.currentItem = { ...firma }
      this.modalTitle = 'Editar Firma'
      this.showModal = true
    },

    closeModal() {
      this.showModal = false
      this.currentItem = {
        usuario: '',
        firma_digital: '',
        nivel_seguridad: 1,
        estado: 1,
        observaciones: ''
      }
      this.showPassword = false
    },

    resetFilters() {
      this.filters = {
        usuario: '',
        estado: '',
        securityLevel: ''
      }
      this.pagination.page = 1
      this.loadFirmas()
    },

    changePage(page) {
      this.pagination.page = page
      this.loadFirmas()
    },

    getPageNumbers() {
      const total = Math.ceil(this.pagination.total / this.pagination.limit)
      const current = this.pagination.page
      const pages = []

      for (let i = Math.max(1, current - 2); i <= Math.min(total, current + 2); i++) {
        pages.push(i)
      }

      return pages
    },

    getSecurityLevelClass(level) {
      const classes = {
        1: 'badge bg-info',
        2: 'badge bg-warning',
        3: 'badge bg-danger'
      }
      return classes[level] || 'badge bg-secondary'
    },

    getSecurityLevelText(level) {
      const texts = {
        1: 'Básico',
        2: 'Medio',
        3: 'Alto'
      }
      return texts[level] || 'N/A'
    },

    formatDate(date) {
      if (!date) return 'N/A'
      return new Date(date).toLocaleString('es-MX')
    }
  }
}
</script>

<style scoped>
.container-fluid {
  background-color: #f8f9fa;
  min-height: 100vh;
}

.breadcrumb {
  background: none;
  padding: 0.75rem 1rem;
}

.breadcrumb-item a {
  text-decoration: none;
  color: #6c757d;
}

.breadcrumb-item.active {
  color: #495057;
  font-weight: 500;
}

.card {
  border: none;
  box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
  border-radius: 0.5rem;
}

.card-header {
  background-color: #f8f9fa;
  border-bottom: 1px solid #dee2e6;
  font-weight: 600;
}

.table th {
  border-top: none;
  font-weight: 600;
  color: #495057;
  background-color: #f8f9fa;
}

.table-hover tbody tr:hover {
  background-color: rgba(0, 123, 255, 0.075);
}

.btn {
  border-radius: 0.375rem;
}

.btn-sm {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

.badge {
  font-size: 0.75em;
}

.modal-content {
  border: none;
  box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
}

.modal-header {
  background-color: #f8f9fa;
  border-bottom: 1px solid #dee2e6;
}

.form-label {
  font-weight: 500;
  color: #495057;
}

.text-danger {
  color: #dc3545 !important;
}

.font-monospace {
  font-family: 'Courier New', monospace;
  font-size: 0.875rem;
}

@media (max-width: 768px) {
  .container-fluid {
    padding-left: 15px;
    padding-right: 15px;
  }

  .table-responsive {
    border: none;
  }
}
</style>
