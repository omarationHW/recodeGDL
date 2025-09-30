<template>
  <div class="municipal-form-page">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-4">
      <ol class="breadcrumb bg-light rounded p-3">
        <li class="breadcrumb-item"><i class="fas fa-home"></i> <router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item"><i class="fas fa-shield-alt"></i> Seguridad</li>
        <li class="breadcrumb-item active" aria-current="page">Gestión de Firmas Digitales</li>
      </ol>
    </nav>

    <!-- Header -->
    <div class="municipal-header">
      <div class="row align-items-center">
        <div class="col">
          <h3 class="mb-0"><i class="fas fa-signature"></i> Gestión de Firmas Digitales</h3>
          <p class="mb-0 opacity-75">Administración y validación de firmas electrónicas del sistema</p>
        </div>
        <div class="col-auto">
          <button class="btn-municipal-primary" @click="showModal = true; modalTitle = 'Nueva Firma'; currentItem = {};">
            <i class="fas fa-plus me-1"></i>Nueva Firma
          </button>
        </div>
      </div>
    </div>

    <!-- Filtros -->
    <div class="municipal-card mb-4">
      <div class="municipal-card-body">
        <div class="row g-3">
          <div class="col-md-4">
            <label class="municipal-form-label">Buscar por usuario:</label>
            <input v-model="filters.usuario" @input="loadFirmas" type="text" class="municipal-form-control" placeholder="Usuario...">
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Estado:</label>
            <select v-model="filters.estado" @change="loadFirmas" class="municipal-form-control">
              <option value="">Todos</option>
              <option value="1">Activo</option>
              <option value="0">Inactivo</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Nivel de seguridad:</label>
            <select v-model="filters.securityLevel" @change="loadFirmas" class="municipal-form-control">
              <option value="">Todos</option>
              <option value="1">Básico</option>
              <option value="2">Medio</option>
              <option value="3">Alto</option>
            </select>
          </div>
          <div class="col-md-2 d-flex align-items-end">
            <button @click="resetFilters" class="btn-municipal-secondary">
              <i class="fas fa-eraser me-1"></i>Limpiar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de firmas -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5 class="mb-0">Listado de Firmas Registradas</h5>
      </div>
      <div class="municipal-card-body p-0">
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary" role="status"></div>
          <p class="mt-2 mb-0">Cargando firmas...</p>
        </div>

        <div v-else>
          <div class="table-responsive">
            <table class="municipal-table municipal-table-hover mb-0">
              <thead class="municipal-table-header">
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
                      <br><small class="text-muted">{{ firma.nombre }}</small>
                    </div>
                  </td>
                  <td>
                    <span class="font-monospace text-muted">Firma generada automáticamente</span>
                  </td>
                  <td>
                    <span :class="getNivelClass(firma.nivel)">
                      Nivel {{ firma.nivel }}
                    </span>
                  </td>
                  <td>{{ formatDate(firma.fecha_alta) }}</td>
                  <td>
                    <span :class="firma.activo == 'S' ? 'municipal-badge-success' : 'municipal-badge-danger'">
                      {{ firma.activo == 'S' ? 'Activo' : 'Inactivo' }}
                    </span>
                  </td>
                  <td>
                    <button @click="editItem(firma)" class="btn-municipal-primary btn-sm me-1" title="Editar">
                      <i class="fas fa-edit"></i>
                    </button>
                    <button @click="verifyFirma(firma)" class="btn-municipal-info btn-sm me-1" title="Verificar">
                      <i class="fas fa-check-circle"></i>
                    </button>
                    <button @click="deleteItem(firma)" class="btn-municipal-danger btn-sm" title="Eliminar">
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
                  <label class="municipal-form-label">Usuario <span class="text-danger">*</span></label>
                  <input v-model="currentItem.usuario" type="text" class="municipal-form-control" required>
                </div>
                <div class="col-md-6">
                  <label class="municipal-form-label">Nivel de Seguridad <span class="text-danger">*</span></label>
                  <select v-model="currentItem.nivel_seguridad" class="municipal-form-control" required>
                    <option value="1">Básico</option>
                    <option value="2">Medio</option>
                    <option value="3">Alto</option>
                  </select>
                </div>
                <div class="col-12">
                  <label class="municipal-form-label">Firma Digital <span class="text-danger">*</span></label>
                  <div class="input-group">
                    <input v-model="currentItem.firma_digital" :type="showPassword ? 'text' : 'password'" class="municipal-form-control" required>
                    <button type="button" class="btn-municipal-secondary" @click="showPassword = !showPassword">
                      <i :class="showPassword ? 'fas fa-eye-slash' : 'fas fa-eye'"></i>
                    </button>
                  </div>
                </div>
                <div class="col-md-6">
                  <label class="municipal-form-label">Estado</label>
                  <select v-model="currentItem.estado" class="municipal-form-control">
                    <option value="1">Activo</option>
                    <option value="0">Inactivo</option>
                  </select>
                </div>
                <div class="col-md-6">
                  <label class="municipal-form-label">Observaciones</label>
                  <textarea v-model="currentItem.observaciones" class="municipal-form-control" rows="2"></textarea>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="closeModal">Cancelar</button>
            <button type="button" class="btn-municipal-primary" @click="saveItem">
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
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'SP_FIRMA_LIST',
              Base: 'padron_licencias',
              Tenant: 'guadalajara',
              Parametros: [
                { nombre: 'p_usuario_id', valor: this.filters.usuario || null },
                { nombre: 'p_tipo_firma', valor: null },
                { nombre: 'p_estado', valor: this.filters.estado || null },
                { nombre: 'p_limite', valor: this.pagination.limit },
                { nombre: 'p_offset', valor: (this.pagination.page - 1) * this.pagination.limit }
              ]
            }
          })
        })
        const data = await response.json()

        if (data && data.eResponse.success) {
          this.firmas = data.eResponse.data.result || []
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

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: operation === 'I' ? 'SP_FIRMA_CREATE' : 'SP_FIRMA_UPDATE',
              Base: 'padron_licencias',
              Tenant: 'guadalajara',
              Parametros: operation === 'I' ? [
                { nombre: 'p_usuario_id', valor: this.currentItem.usuario },
                { nombre: 'p_nombre_completo', valor: this.currentItem.usuario },
                { nombre: 'p_firma_path', valor: `/firmas/${this.currentItem.usuario}_firma.png` },
                { nombre: 'p_hash_firma', valor: this.generateHash(this.currentItem.firma_digital) },
                { nombre: 'p_tipo_firma', valor: 'DIGITAL' },
                { nombre: 'p_fecha_vencimiento', valor: null },
                { nombre: 'p_observaciones', valor: this.currentItem.observaciones }
              ] : [
                { nombre: 'p_id', valor: this.currentItem.id },
                { nombre: 'p_nombre_completo', valor: this.currentItem.usuario },
                { nombre: 'p_firma_path', valor: null },
                { nombre: 'p_hash_firma', valor: this.generateHash(this.currentItem.firma_digital) },
                { nombre: 'p_tipo_firma', valor: 'DIGITAL' },
                { nombre: 'p_estado', valor: this.currentItem.estado === 1 ? 'A' : 'I' },
                { nombre: 'p_fecha_vencimiento', valor: null },
                { nombre: 'p_observaciones', valor: this.currentItem.observaciones }
              ]
            }
          })
        })
        const data = await response.json()

        if (data && data.eResponse.success) {
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
          throw new Error(data?.error || 'Error en la operación')
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
          const response = await fetch('http://localhost:8000/api/generic', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              eRequest: {
                Operacion: 'SP_FIRMA_VALIDATE',
                Base: 'padron_licencias',
                Tenant: 'guadalajara',
                Parametros: [
                  { nombre: 'p_hash_firma', valor: this.generateHash(firmaInput) }
                ]
              }
            })
          })
          const data = await response.json()

          if (data?.success && data?.data?.[0]?.verificado) {
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
          const response = await fetch('http://localhost:8000/api/generic', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              eRequest: {
                Operacion: 'SP_FIRMA_DELETE',
                Base: 'padron_licencias',
                Tenant: 'guadalajara',
                Parametros: [
                  { nombre: 'p_id', valor: firma.id }
                ]
              }
            })
          })
          const data = await response.json()

          if (data?.success) {
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
        1: 'municipal-badge-info',
        2: 'municipal-badge-warning',
        3: 'municipal-badge-danger'
      }
      return classes[level] || 'municipal-badge-secondary'
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
    },

    generateHash(input) {
      // Función simple de hash (en producción usar crypto más robusto)
      let hash = 0
      if (input.length === 0) return hash.toString()
      for (let i = 0; i < input.length; i++) {
        const char = input.charCodeAt(i)
        hash = ((hash << 5) - hash) + char
        hash = hash & hash // Convert to 32bit integer
      }
      return 'sha256_' + Math.abs(hash).toString(16) + '_' + Date.now()
    },

    getTipoFirmaClass(tipo) {
      const classes = {
        'DIGITAL': 'municipal-badge-primary',
        'ESCANEADA': 'municipal-badge-info',
        'MANUSCRITA': 'municipal-badge-warning'
      }
      return classes[tipo] || 'municipal-badge-secondary'
    },

    getEstadoText(estado) {
      const texts = {
        'A': 'Activo',
        'I': 'Inactivo',
        'S': 'Suspendido'
      }
      return texts[estado] || 'N/A'
    },

    getNivelClass(nivel) {
      const classes = {
        1: 'municipal-badge-info',
        5: 'municipal-badge-warning',
        9: 'municipal-badge-primary',
        10: 'municipal-badge-danger'
      }
      return classes[nivel] || 'municipal-badge-secondary'
    }
  }
}
</script>

