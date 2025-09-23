<template>
  <div class="container-fluid px-4 py-3">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-4">
      <ol class="breadcrumb bg-light rounded p-3">
        <li class="breadcrumb-item"><i class="fas fa-home"></i> <router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item"><i class="fas fa-shield-alt"></i> Seguridad</li>
        <li class="breadcrumb-item active" aria-current="page">Autenticación de Usuarios</li>
      </ol>
    </nav>

    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h3 mb-1"><i class="fas fa-user-lock text-primary me-2"></i>Autenticación de Usuarios</h2>
            <p class="text-muted mb-0">Gestión de usuarios con autenticación PIN y control de sesiones</p>
          </div>
          <button class="btn btn-primary" @click="showModal = true; modalTitle = 'Nuevo Usuario'; currentItem = {};">
            <i class="fas fa-plus me-1"></i>Nuevo Usuario
          </button>
        </div>
      </div>
    </div>

    <!-- Filtros -->
    <div class="card mb-4">
      <div class="card-body">
        <div class="row g-3">
          <div class="col-md-4">
            <label class="form-label">Buscar usuario:</label>
            <input v-model="filters.usuario" @input="loadUsuarios" type="text" class="form-control" placeholder="Usuario...">
          </div>
          <div class="col-md-3">
            <label class="form-label">Estado:</label>
            <select v-model="filters.estado" @change="loadUsuarios" class="form-select">
              <option value="">Todos</option>
              <option value="1">Activo</option>
              <option value="0">Inactivo</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="form-label">Sesión activa:</label>
            <select v-model="filters.sesionActiva" @change="loadUsuarios" class="form-select">
              <option value="">Todas</option>
              <option value="1">Con sesión</option>
              <option value="0">Sin sesión</option>
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

    <!-- Tabla de usuarios -->
    <div class="card">
      <div class="card-header bg-light">
        <h5 class="mb-0">Listado de Usuarios Autenticados</h5>
      </div>
      <div class="card-body p-0">
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary" role="status"></div>
          <p class="mt-2 mb-0">Cargando usuarios...</p>
        </div>

        <div v-else>
          <div class="table-responsive">
            <table class="table table-hover mb-0">
              <thead class="table-light">
                <tr>
                  <th>ID</th>
                  <th>Usuario</th>
                  <th>PIN</th>
                  <th>Último Acceso</th>
                  <th>Sesión Activa</th>
                  <th>Intentos Fallidos</th>
                  <th>Estado</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="usuario in usuarios" :key="usuario.id">
                  <td>{{ usuario.id }}</td>
                  <td>
                    <div class="d-flex align-items-center">
                      <i class="fas fa-user-circle text-muted me-2"></i>
                      {{ usuario.usuario }}
                    </div>
                  </td>
                  <td>
                    <span class="badge bg-secondary">{{ usuario.pin ? '****' : 'Sin PIN' }}</span>
                  </td>
                  <td>{{ formatDate(usuario.ultimo_acceso) }}</td>
                  <td>
                    <span :class="usuario.sesion_activa ? 'badge bg-success' : 'badge bg-warning'">
                      <i :class="usuario.sesion_activa ? 'fas fa-check' : 'fas fa-times' "></i>
                      {{ usuario.sesion_activa ? 'Activa' : 'Inactiva' }}
                    </span>
                  </td>
                  <td>
                    <span :class="getIntentosClass(usuario.intentos_fallidos)">
                      {{ usuario.intentos_fallidos || 0 }}
                    </span>
                  </td>
                  <td>
                    <span :class="usuario.estado == 1 ? 'badge bg-success' : 'badge bg-danger'">
                      {{ usuario.estado == 1 ? 'Activo' : 'Bloqueado' }}
                    </span>
                  </td>
                  <td>
                    <button @click="editItem(usuario)" class="btn btn-sm btn-outline-primary me-1" title="Editar">
                      <i class="fas fa-edit"></i>
                    </button>
                    <button @click="authenticateUser(usuario)" class="btn btn-sm btn-outline-info me-1" title="Autenticar">
                      <i class="fas fa-key"></i>
                    </button>
                    <button @click="viewSessions(usuario)" class="btn btn-sm btn-outline-warning me-1" title="Ver Sesiones">
                      <i class="fas fa-history"></i>
                    </button>
                    <button @click="deleteItem(usuario)" class="btn btn-sm btn-outline-danger" title="Eliminar">
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

    <!-- Modal para usuario -->
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
                  <label class="form-label">PIN <span class="text-danger">*</span></label>
                  <div class="input-group">
                    <input v-model="currentItem.pin" :type="showPin ? 'text' : 'password'" class="form-control" required>
                    <button type="button" class="btn btn-outline-secondary" @click="showPin = !showPin">
                      <i :class="showPin ? 'fas fa-eye-slash' : 'fas fa-eye'"></i>
                    </button>
                  </div>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Estado</label>
                  <select v-model="currentItem.estado" class="form-select">
                    <option value="1">Activo</option>
                    <option value="0">Bloqueado</option>
                  </select>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Reiniciar intentos fallidos</label>
                  <select v-model="currentItem.reset_intentos" class="form-select">
                    <option value="0">No</option>
                    <option value="1">Sí</option>
                  </select>
                </div>
                <div class="col-12">
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

    <!-- Modal de sesiones -->
    <div class="modal fade" :class="{ show: showSessionModal }" :style="{ display: showSessionModal ? 'block' : 'none' }" tabindex="-1">
      <div class="modal-dialog modal-xl">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Historial de Sesiones - {{ selectedUser?.usuario }}</h5>
            <button type="button" class="btn-close" @click="showSessionModal = false"></button>
          </div>
          <div class="modal-body">
            <div class="table-responsive">
              <table class="table table-striped">
                <thead>
                  <tr>
                    <th>ID Sesión</th>
                    <th>Fecha Inicio</th>
                    <th>Fecha Fin</th>
                    <th>IP Address</th>
                    <th>User Agent</th>
                    <th>Estado</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="sesion in sesiones" :key="sesion.id">
                    <td>{{ sesion.id }}</td>
                    <td>{{ formatDate(sesion.fecha_inicio) }}</td>
                    <td>{{ sesion.fecha_fin ? formatDate(sesion.fecha_fin) : 'Activa' }}</td>
                    <td>{{ sesion.ip_address }}</td>
                    <td class="text-truncate" style="max-width: 200px;" :title="sesion.user_agent">{{ sesion.user_agent }}</td>
                    <td>
                      <span :class="sesion.fecha_fin ? 'badge bg-secondary' : 'badge bg-success'">
                        {{ sesion.fecha_fin ? 'Cerrada' : 'Activa' }}
                      </span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal backdrop -->
    <div v-if="showModal || showSessionModal" class="modal-backdrop fade show"></div>
  </div>
</template>

<script>
import axios from 'axios'
import Swal from 'sweetalert2'

export default {
  name: 'FirmaUsuarioPage',
  data() {
    return {
      usuarios: [],
      loading: false,
      showModal: false,
      showSessionModal: false,
      modalTitle: '',
      currentItem: {
        usuario: '',
        pin: '',
        estado: 1,
        reset_intentos: 0,
        observaciones: ''
      },
      selectedUser: null,
      sesiones: [],
      showPin: false,
      filters: {
        usuario: '',
        estado: '',
        sesionActiva: ''
      },
      pagination: {
        page: 1,
        limit: 10,
        total: 0
      }
    }
  },
  mounted() {
    this.loadUsuarios()
  },
  methods: {
    async loadUsuarios() {
      this.loading = true
      try {
        const response = await axios.post('http://localhost:8080/api/generic', {
          eRequest: {
            Operacion: 'sp_firmausuario_list',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_usuario', valor: this.filters.usuario || null },
              { nombre: 'p_estado', valor: this.filters.estado || null },
              { nombre: 'p_sesion_activa', valor: this.filters.sesionActiva || null },
              { nombre: 'p_limite', valor: this.pagination.limit },
              { nombre: 'p_offset', valor: (this.pagination.page - 1) * this.pagination.limit }
            ],
            Tenant: 'informix'
          }
        })

        if (response.data && response.data.success) {
          this.usuarios = response.data.data || []
          this.pagination.total = this.usuarios.length > 0 ? this.usuarios[0].total_registros || 0 : 0
        }
      } catch (error) {
        console.error('Error cargando usuarios:', error)
        this.$toast.error('Error al cargar los usuarios')
      } finally {
        this.loading = false
      }
    },

    async saveItem() {
      try {
        const operation = this.currentItem.id ? 'U' : 'I'

        const response = await axios.post('http://localhost:8080/api/generic', {
          eRequest: {
            Operacion: 'sp_firmausuario_mantener',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_operacion', valor: operation },
              { nombre: 'p_id', valor: this.currentItem.id || null },
              { nombre: 'p_usuario', valor: this.currentItem.usuario },
              { nombre: 'p_pin', valor: this.currentItem.pin },
              { nombre: 'p_estado', valor: this.currentItem.estado },
              { nombre: 'p_reset_intentos', valor: this.currentItem.reset_intentos },
              { nombre: 'p_observaciones', valor: this.currentItem.observaciones }
            ],
            Tenant: 'informix'
          }
        })

        if (response.data && response.data.success) {
          await Swal.fire({
            icon: 'success',
            title: 'Éxito',
            text: operation === 'I' ? 'Usuario registrado correctamente' : 'Usuario actualizado correctamente',
            timer: 3000,
            showConfirmButton: false
          })

          this.closeModal()
          this.loadUsuarios()
        } else {
          throw new Error(response.data?.message || 'Error en la operación')
        }
      } catch (error) {
        console.error('Error guardando usuario:', error)
        await Swal.fire({
          icon: 'error',
          title: 'Error',
          text: error.message || 'Error al guardar el usuario',
          timer: 5000,
          showConfirmButton: false
        })
      }
    },

    async authenticateUser(usuario) {
      try {
        const { value: pinInput } = await Swal.fire({
          title: 'Autenticación de Usuario',
          text: `Ingrese el PIN para el usuario: ${usuario.usuario}`,
          input: 'password',
          inputPlaceholder: 'PIN...',
          showCancelButton: true,
          confirmButtonText: 'Autenticar',
          cancelButtonText: 'Cancelar',
          inputValidator: (value) => {
            if (!value) {
              return 'Debe ingresar el PIN'
            }
            if (value.length < 4) {
              return 'El PIN debe tener al menos 4 dígitos'
            }
          }
        })

        if (pinInput) {
          const response = await axios.post('http://localhost:8080/api/generic', {
            eRequest: {
              Operacion: 'sp_firmausuario_autenticar',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_usuario', valor: usuario.usuario },
                { nombre: 'p_pin', valor: pinInput }
              ],
              Tenant: 'informix'
            }
          })

          if (response.data?.success && response.data?.data?.[0]?.autenticado) {
            await Swal.fire({
              icon: 'success',
              title: 'Autenticación Exitosa',
              text: 'Usuario autenticado correctamente',
              timer: 3000,
              showConfirmButton: false
            })
            this.loadUsuarios() // Actualizar la lista para reflejar la nueva sesión
          } else {
            await Swal.fire({
              icon: 'error',
              title: 'Autenticación Fallida',
              text: 'PIN incorrecto o usuario bloqueado',
              timer: 5000,
              showConfirmButton: false
            })
          }
        }
      } catch (error) {
        console.error('Error autenticando usuario:', error)
        await Swal.fire({
          icon: 'error',
          title: 'Error',
          text: 'Error en el proceso de autenticación',
          timer: 5000,
          showConfirmButton: false
        })
      }
    },

    async viewSessions(usuario) {
      try {
        this.selectedUser = usuario
        const response = await axios.post('http://localhost:8080/api/generic', {
          eRequest: {
            Operacion: 'sp_firmausuario_sesiones',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_usuario', valor: usuario.usuario }
            ],
            Tenant: 'informix'
          }
        })

        if (response.data?.success) {
          this.sesiones = response.data.data || []
          this.showSessionModal = true
        }
      } catch (error) {
        console.error('Error cargando sesiones:', error)
        this.$toast.error('Error al cargar el historial de sesiones')
      }
    },

    async deleteItem(usuario) {
      const result = await Swal.fire({
        title: '¿Está seguro?',
        text: `¿Desea eliminar el usuario: ${usuario.usuario}?`,
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
              Operacion: 'sp_firmausuario_mantener',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_operacion', valor: 'D' },
                { nombre: 'p_id', valor: usuario.id }
              ],
              Tenant: 'informix'
            }
          })

          if (response.data?.success) {
            await Swal.fire({
              icon: 'success',
              title: 'Eliminado',
              text: 'Usuario eliminado correctamente',
              timer: 3000,
              showConfirmButton: false
            })
            this.loadUsuarios()
          }
        } catch (error) {
          console.error('Error eliminando usuario:', error)
          await Swal.fire({
            icon: 'error',
            title: 'Error',
            text: 'Error al eliminar el usuario',
            timer: 5000,
            showConfirmButton: false
          })
        }
      }
    },

    editItem(usuario) {
      this.currentItem = { ...usuario }
      this.modalTitle = 'Editar Usuario'
      this.showModal = true
    },

    closeModal() {
      this.showModal = false
      this.currentItem = {
        usuario: '',
        pin: '',
        estado: 1,
        reset_intentos: 0,
        observaciones: ''
      }
      this.showPin = false
    },

    resetFilters() {
      this.filters = {
        usuario: '',
        estado: '',
        sesionActiva: ''
      }
      this.pagination.page = 1
      this.loadUsuarios()
    },

    changePage(page) {
      this.pagination.page = page
      this.loadUsuarios()
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

    getIntentosClass(intentos) {
      if (!intentos) return 'badge bg-success'
      if (intentos < 3) return 'badge bg-warning'
      return 'badge bg-danger'
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

.text-truncate {
  max-width: 200px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

@media (max-width: 768px) {
  .container-fluid {
    padding-left: 15px;
    padding-right: 15px;
  }

  .table-responsive {
    border: none;
  }

  .btn-sm {
    padding: 0.125rem 0.25rem;
    font-size: 0.75rem;
  }
}
</style>
