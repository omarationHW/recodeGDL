<template>
  <div class="container-fluid">
    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-ban me-2 text-danger"></i>
              Bloqueo de RFC *
            </h2>
            <p class="text-muted mb-0">Gestión de bloqueos por RFC por incumplimiento del programa de autoevaluación</p>
          </div>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
              <li class="breadcrumb-item">
                <router-link to="/dashboard" class="text-decoration-none">Dashboard</router-link>
              </li>
              <li class="breadcrumb-item">
                <router-link to="/licencias" class="text-decoration-none">Licencias</router-link>
              </li>
              <li class="breadcrumb-item active">Bloqueo RFC</li>
            </ol>
          </nav>
        </div>
      </div>
    </div>

    <!-- Filtros y acciones -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="mb-0">
          <i class="fas fa-search me-2"></i>
          Búsqueda y Acciones
        </h5>
      </div>
      <div class="card-body">
        <div class="row g-3">
          <div class="col-md-4">
            <label for="buscarRfc" class="form-label">Buscar por RFC</label>
            <input
              type="text"
              class="form-control"
              id="buscarRfc"
              v-model="filtros.rfc"
              placeholder="Ingrese RFC"
              @keyup.enter="buscarBloqueos"
            >
          </div>
          <div class="col-md-3">
            <label for="estadoVigencia" class="form-label">Estado</label>
            <select
              class="form-select"
              id="estadoVigencia"
              v-model="filtros.vigencia"
              @change="buscarBloqueos"
            >
              <option value="">Todos</option>
              <option value="V">Vigentes</option>
              <option value="C">Cancelados</option>
            </select>
          </div>
          <div class="col-md-3 d-flex align-items-end">
            <button
              type="button"
              class="btn btn-primary w-100"
              @click="buscarBloqueos"
              :disabled="cargando"
            >
              <i class="fas fa-search me-2"></i>
              {{ cargando ? 'Buscando...' : 'Buscar' }}
            </button>
          </div>
          <div class="col-md-2 d-flex align-items-end">
            <button
              type="button"
              class="btn btn-success w-100"
              @click="abrirModalNuevo"
            >
              <i class="fas fa-plus me-2"></i>
              Nuevo Bloqueo
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Lista de bloqueos -->
    <div class="card">
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">
          <i class="fas fa-list me-2"></i>
          Bloqueos de RFC ({{ bloqueos.length }})
        </h5>
        <button
          type="button"
          class="btn btn-outline-success btn-sm"
          @click="exportarExcel"
          :disabled="bloqueos.length === 0"
        >
          <i class="fas fa-file-excel me-2"></i>
          Exportar Excel
        </button>
      </div>
      <div class="card-body p-0">
        <div v-if="cargando" class="p-4 text-center">
          <div class="spinner-border text-primary me-2" role="status"></div>
          <span>Cargando bloqueos...</span>
        </div>
        <div v-else-if="bloqueos.length === 0" class="p-4 text-center text-muted">
          <i class="fas fa-search me-2"></i>
          No se encontraron bloqueos de RFC
        </div>
        <div v-else class="table-responsive">
          <table class="table table-hover table-striped mb-0">
            <thead class="table-dark">
              <tr>
                <th>RFC</th>
                <th>Trámite</th>
                <th>Licencia</th>
                <th>Propietario</th>
                <th>Fecha/Hora</th>
                <th>Vigencia</th>
                <th>Capturista</th>
                <th>Motivo</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="bloqueo in bloqueos" :key="`${bloqueo.rfc}-${bloqueo.id_tramite}`">
                <td>
                  <strong>{{ bloqueo.rfc }}</strong>
                </td>
                <td>{{ bloqueo.id_tramite || 'N/A' }}</td>
                <td>{{ bloqueo.licencia || 'N/A' }}</td>
                <td>{{ bloqueo.propietario || 'N/A' }}</td>
                <td>{{ formatearFecha(bloqueo.fecha_hora) }}</td>
                <td>
                  <span class="badge" :class="bloqueo.vigencia === 'V' ? 'bg-success' : 'bg-secondary'">
                    {{ bloqueo.vigencia === 'V' ? 'Vigente' : 'Cancelado' }}
                  </span>
                </td>
                <td>{{ bloqueo.capturista || 'N/A' }}</td>
                <td>{{ bloqueo.observacion || 'Sin observaciones' }}</td>
                <td>
                  <div class="btn-group btn-group-sm">
                    <button
                      v-if="bloqueo.vigencia === 'V'"
                      type="button"
                      class="btn btn-outline-warning"
                      @click="editarBloqueo(bloqueo)"
                      title="Editar"
                    >
                      <i class="fas fa-edit"></i>
                    </button>
                    <button
                      v-if="bloqueo.vigencia === 'V'"
                      type="button"
                      class="btn btn-outline-danger"
                      @click="desbloquearRfc(bloqueo)"
                      title="Desbloquear"
                    >
                      <i class="fas fa-unlock"></i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Modal para nuevo/editar bloqueo -->
    <div v-if="showModal" class="modal fade show d-block" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header" :class="modoEdicion ? 'bg-warning text-dark' : 'bg-success text-white'">
            <h5 class="modal-title">
              <i class="fas me-2" :class="modoEdicion ? 'fa-edit' : 'fa-plus'"></i>
              {{ modoEdicion ? 'Editar Bloqueo RFC' : 'Nuevo Bloqueo RFC' }}
            </h5>
            <button type="button" class="btn-close" :class="modoEdicion ? '' : 'btn-close-white'" @click="cerrarModal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="guardarBloqueo">
              <div class="row g-3">
                <div class="col-md-6">
                  <label for="modalTramite" class="form-label">Trámite *</label>
                  <div class="input-group">
                    <input
                      type="text"
                      class="form-control"
                      id="modalTramite"
                      v-model="formulario.id_tramite"
                      :readonly="modoEdicion"
                      placeholder="ID del trámite"
                      required
                    >
                    <button
                      v-if="!modoEdicion"
                      type="button"
                      class="btn btn-outline-secondary"
                      @click="buscarTramite"
                    >
                      <i class="fas fa-search"></i>
                    </button>
                  </div>
                </div>
                <div class="col-md-6">
                  <label for="modalRfc" class="form-label">RFC *</label>
                  <input
                    type="text"
                    class="form-control"
                    id="modalRfc"
                    v-model="formulario.rfc"
                    :readonly="modoEdicion"
                    placeholder="RFC del contribuyente"
                    required
                  >
                </div>
                <div class="col-md-6">
                  <label for="modalLicencia" class="form-label">Licencia</label>
                  <input
                    type="text"
                    class="form-control"
                    id="modalLicencia"
                    v-model="formulario.licencia"
                    readonly
                    placeholder="Se autocompleta"
                  >
                </div>
                <div class="col-md-6">
                  <label for="modalPropietario" class="form-label">Propietario</label>
                  <input
                    type="text"
                    class="form-control"
                    id="modalPropietario"
                    v-model="formulario.propietario"
                    readonly
                    placeholder="Se autocompleta"
                  >
                </div>
                <div class="col-12">
                  <label for="modalActividad" class="form-label">Actividad</label>
                  <input
                    type="text"
                    class="form-control"
                    id="modalActividad"
                    v-model="formulario.actividad"
                    readonly
                    placeholder="Se autocompleta"
                  >
                </div>
                <div class="col-12">
                  <label for="modalObservacion" class="form-label">Motivo del Bloqueo *</label>
                  <textarea
                    class="form-control"
                    id="modalObservacion"
                    v-model="formulario.observacion"
                    rows="3"
                    placeholder="Ingrese el motivo del bloqueo por RFC"
                    required
                  ></textarea>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button
              type="button"
              class="btn btn-secondary"
              @click="cerrarModal"
              :disabled="guardando"
            >
              Cancelar
            </button>
            <button
              type="button"
              class="btn"
              :class="modoEdicion ? 'btn-warning' : 'btn-success'"
              @click="guardarBloqueo"
              :disabled="!formulario.id_tramite || !formulario.rfc || !formulario.observacion || guardando"
            >
              <i class="fas fa-spinner fa-spin me-2" v-if="guardando"></i>
              <i class="fas me-2" :class="modoEdicion ? 'fa-save' : 'fa-plus'" v-else></i>
              {{ guardando ? 'Guardando...' : (modoEdicion ? 'Actualizar' : 'Crear Bloqueo') }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal backdrop -->
    <div v-if="showModal" class="modal-backdrop fade show"></div>

    <!-- Alertas -->
    <div v-if="mensaje" class="position-fixed top-0 end-0 p-3" style="z-index: 1060">
      <div class="toast show" role="alert">
        <div class="toast-header">
          <i class="fas me-2" :class="mensaje.tipo === 'success' ? 'fa-check-circle text-success' : 'fa-exclamation-triangle text-danger'"></i>
          <strong class="me-auto">{{ mensaje.tipo === 'success' ? 'Éxito' : 'Error' }}</strong>
          <button type="button" class="btn-close" @click="mensaje = null"></button>
        </div>
        <div class="toast-body">
          {{ mensaje.texto }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'bloqueoRFCfrm',
  data() {
    return {
      bloqueos: [],
      filtros: {
        rfc: '',
        vigencia: ''
      },
      formulario: {
        id: null,
        id_tramite: '',
        rfc: '',
        licencia: '',
        propietario: '',
        actividad: '',
        observacion: ''
      },
      cargando: false,
      guardando: false,
      showModal: false,
      modoEdicion: false,
      mensaje: null
    }
  },

  mounted() {
    this.cargarBloqueos()
  },

  methods: {
    async cargarBloqueos() {
      this.cargando = true
      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_bloqueos_rfc_listar',
              Base: 'padron_licencias',
              Parametros: [],
              Tenant: 'guadalajara'
            }
          })
        });
        const data = await response.json();

        if (data.eResponse.success) {
          this.bloqueos = data.eResponse.data.result || []
        } else {
          this.mostrarMensaje('error', 'Error al cargar los bloqueos')
        }
      } catch (error) {
        console.error('Error cargando bloqueos:', error)
        this.mostrarMensaje('error', 'Error al cargar los bloqueos')
      } finally {
        this.cargando = false
      }
    },

    async buscarBloqueos() {
      this.cargando = true
      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_bloqueos_rfc_buscar',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_rfc', valor: this.filtros.rfc || null, tipo: 'varchar' },
                { nombre: 'p_vigencia', valor: this.filtros.vigencia || null, tipo: 'char' }
              ],
              Tenant: 'guadalajara'
            }
          })
        });
        const data = await response.json();

        if (data.eResponse.success) {
          this.bloqueos = data.eResponse.data.result || []
          if (this.bloqueos.length === 0) {
            this.mostrarMensaje('info', 'No se encontraron bloqueos con los criterios especificados')
          }
        } else {
          this.mostrarMensaje('error', 'Error al buscar bloqueos')
        }
      } catch (error) {
        console.error('Error buscando bloqueos:', error)
        this.mostrarMensaje('error', 'Error al buscar bloqueos')
      } finally {
        this.cargando = false
      }
    },

    async buscarTramite() {
      if (!this.formulario.id_tramite) return

      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_tramite_buscar_para_rfc',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_id_tramite', valor: parseInt(this.formulario.id_tramite), tipo: 'integer' }
              ],
              Tenant: 'guadalajara'
            }
          })
        });
        const data = await response.json();

        if (data.eResponse.success && data.eResponse.data.result.length > 0) {
          const tramite = data.eResponse.data.result[0]
          this.formulario.rfc = tramite.rfc || ''
          this.formulario.licencia = tramite.id_licencia || ''
          this.formulario.propietario = tramite.propietario || ''
          this.formulario.actividad = tramite.actividad || ''
          this.mostrarMensaje('success', 'Información del trámite cargada')
        } else {
          this.mostrarMensaje('error', 'No se encontró el trámite especificado')
        }
      } catch (error) {
        console.error('Error buscando trámite:', error)
        this.mostrarMensaje('error', 'Error al buscar el trámite')
      }
    },

    abrirModalNuevo() {
      this.modoEdicion = false
      this.formulario = {
        id: null,
        id_tramite: '',
        rfc: '',
        licencia: '',
        propietario: '',
        actividad: '',
        observacion: ''
      }
      this.showModal = true
    },

    editarBloqueo(bloqueo) {
      this.modoEdicion = true
      this.formulario = {
        id: bloqueo.id,
        id_tramite: bloqueo.id_tramite,
        rfc: bloqueo.rfc,
        licencia: bloqueo.licencia,
        propietario: bloqueo.propietario,
        actividad: bloqueo.actividad,
        observacion: bloqueo.observacion
      }
      this.showModal = true
    },

    cerrarModal() {
      this.showModal = false
      this.modoEdicion = false
      this.formulario = {
        id: null,
        id_tramite: '',
        rfc: '',
        licencia: '',
        propietario: '',
        actividad: '',
        observacion: ''
      }
    },

    async guardarBloqueo() {
      if (!this.formulario.id_tramite || !this.formulario.rfc || !this.formulario.observacion) return

      this.guardando = true
      try {
        const operacion = this.modoEdicion ? 'sp_bloqueo_rfc_actualizar' : 'sp_bloqueo_rfc_crear'
        const parametros = [
          { nombre: 'p_id_tramite', valor: parseInt(this.formulario.id_tramite), tipo: 'integer' },
          { nombre: 'p_rfc', valor: this.formulario.rfc, tipo: 'varchar' },
          { nombre: 'p_observacion', valor: this.formulario.observacion, tipo: 'varchar' },
          { nombre: 'p_usuario', valor: 'admin', tipo: 'varchar' }
        ]

        if (this.modoEdicion) {
          parametros.unshift({ nombre: 'p_id', valor: this.formulario.id, tipo: 'integer' })
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: operacion,
              Base: 'padron_licencias',
              Parametros: parametros,
              Tenant: 'guadalajara'
            }
          })
        });
        const data = await response.json();

        if (data.eResponse.success && data.eResponse.data.result[0]?.success) {
          this.mostrarMensaje('success', data.eResponse.data.result[0].message)
          this.cerrarModal()
          await this.cargarBloqueos()
        } else {
          this.mostrarMensaje('error', data.eResponse.data.result[0]?.message || 'Error al guardar el bloqueo')
        }
      } catch (error) {
        console.error('Error guardando bloqueo:', error)
        this.mostrarMensaje('error', 'Error al guardar el bloqueo')
      } finally {
        this.guardando = false
      }
    },

    async desbloquearRfc(bloqueo) {
      if (!confirm('¿Está seguro de desbloquear este RFC?')) return

      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_bloqueo_rfc_desbloquear',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_id', valor: bloqueo.id, tipo: 'integer' },
                { nombre: 'p_usuario', valor: 'admin', tipo: 'varchar' }
              ],
              Tenant: 'guadalajara'
            }
          })
        });
        const data = await response.json();

        if (data.eResponse.success && data.eResponse.data.result[0]?.success) {
          this.mostrarMensaje('success', data.eResponse.data.result[0].message)
          await this.cargarBloqueos()
        } else {
          this.mostrarMensaje('error', data.eResponse.data.result[0]?.message || 'Error al desbloquear RFC')
        }
      } catch (error) {
        console.error('Error desbloqueando RFC:', error)
        this.mostrarMensaje('error', 'Error al desbloquear RFC')
      }
    },

    exportarExcel() {
      // TODO: Implementar exportación a Excel
      this.mostrarMensaje('info', 'Función de exportación pendiente de implementar')
    },

    formatearFecha(fecha) {
      if (!fecha) return 'N/A'
      return new Date(fecha).toLocaleString('es-MX')
    },

    mostrarMensaje(tipo, texto) {
      this.mensaje = { tipo, texto }
      setTimeout(() => {
        this.mensaje = null
      }, 5000)
    }
  }
}
</script>

<style scoped>
/* Forzar colores visibles en todo el componente */
.container-fluid {
  background: #f8f9fa !important;
  color: #212529 !important;
  min-height: 100vh !important;
}

.card {
  background: white !important;
  border: 1px solid #dee2e6 !important;
  border-radius: 0.25rem !important;
  box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075) !important;
  margin-bottom: 1.5rem !important;
}

.card-header {
  background: #f8f9fa !important;
  border-bottom: 1px solid #dee2e6 !important;
  padding: 0.75rem 1.25rem !important;
  color: #212529 !important;
}

.card-body {
  background: white !important;
  color: #212529 !important;
  padding: 1.25rem !important;
}

.form-label {
  color: #212529 !important;
  font-weight: 500 !important;
  margin-bottom: 0.5rem !important;
}

.form-control,
.form-select {
  background: white !important;
  border: 1px solid #ced4da !important;
  color: #212529 !important;
  padding: 0.375rem 0.75rem !important;
}

.form-control:focus,
.form-select:focus {
  background: white !important;
  border-color: #86b7fe !important;
  color: #212529 !important;
  box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25) !important;
}

.btn {
  color: white !important;
  border: 1px solid transparent !important;
  padding: 0.375rem 0.75rem !important;
  font-size: 1rem !important;
  border-radius: 0.25rem !important;
}

.btn-primary {
  background: #0d6efd !important;
  border-color: #0d6efd !important;
}

.btn-primary:hover {
  background: #0b5ed7 !important;
  border-color: #0a58ca !important;
}

.btn-success {
  background: #198754 !important;
  border-color: #198754 !important;
}

.btn-success:hover {
  background: #157347 !important;
  border-color: #146c43 !important;
}

.btn-warning {
  background: #ffc107 !important;
  border-color: #ffc107 !important;
  color: #000 !important;
}

.btn-warning:hover {
  background: #ffca2c !important;
  border-color: #ffc720 !important;
}

.btn-danger {
  background: #dc3545 !important;
  border-color: #dc3545 !important;
}

.btn-danger:hover {
  background: #bb2d3b !important;
  border-color: #b02a37 !important;
}

.btn-secondary {
  background: #6c757d !important;
  border-color: #6c757d !important;
}

.btn-outline-success {
  background: transparent !important;
  border-color: #198754 !important;
  color: #198754 !important;
}

.btn-outline-success:hover {
  background: #198754 !important;
  border-color: #198754 !important;
  color: white !important;
}

.btn-outline-warning {
  background: transparent !important;
  border-color: #ffc107 !important;
  color: #ffc107 !important;
}

.btn-outline-warning:hover {
  background: #ffc107 !important;
  border-color: #ffc107 !important;
  color: #000 !important;
}

.btn-outline-danger {
  background: transparent !important;
  border-color: #dc3545 !important;
  color: #dc3545 !important;
}

.btn-outline-danger:hover {
  background: #dc3545 !important;
  border-color: #dc3545 !important;
  color: white !important;
}

.table {
  background: white !important;
  color: #212529 !important;
  border-collapse: collapse !important;
  width: 100% !important;
}

.table th,
.table td {
  background: white !important;
  color: #212529 !important;
  padding: 0.75rem !important;
  border-bottom: 1px solid #dee2e6 !important;
}

.table-dark {
  background: #212529 !important;
}

.table-dark th {
  background: #212529 !important;
  color: white !important;
  border-color: #32383e !important;
}

.table-striped tbody tr:nth-of-type(odd) {
  background: rgba(0, 0, 0, 0.05) !important;
}

.table-hover tbody tr:hover {
  background: rgba(0, 0, 0, 0.075) !important;
}

.badge {
  padding: 0.35em 0.65em !important;
  font-size: 0.75em !important;
  font-weight: 700 !important;
  border-radius: 0.25rem !important;
}

.bg-success {
  background: #198754 !important;
  color: white !important;
}

.bg-secondary {
  background: #6c757d !important;
  color: white !important;
}

.breadcrumb {
  background: transparent !important;
  padding: 0 !important;
  margin: 0 !important;
  list-style: none !important;
  display: flex !important;
}

.breadcrumb-item {
  color: #6c757d !important;
}

.breadcrumb-item a {
  color: #0d6efd !important;
  text-decoration: none !important;
}

.breadcrumb-item.active {
  color: #6c757d !important;
}

.text-muted {
  color: #6c757d !important;
}

.text-danger {
  color: #dc3545 !important;
}

.text-center {
  text-align: center !important;
}

.spinner-border {
  border: 0.25em solid currentColor !important;
  border-right-color: transparent !important;
  border-radius: 50% !important;
  animation: spinner-border 0.75s linear infinite !important;
}

.text-primary {
  color: #0d6efd !important;
}

/* Modal styles */
.modal.show {
  display: block !important;
}

.modal-backdrop {
  position: fixed !important;
  top: 0 !important;
  left: 0 !important;
  z-index: 1040 !important;
  width: 100vw !important;
  height: 100vh !important;
  background-color: #000 !important;
  opacity: 0.5 !important;
}

.modal-dialog {
  position: relative !important;
  width: auto !important;
  margin: 1.75rem auto !important;
  max-width: 800px !important;
}

.modal-content {
  position: relative !important;
  display: flex !important;
  flex-direction: column !important;
  width: 100% !important;
  pointer-events: auto !important;
  background: white !important;
  border: 1px solid rgba(0, 0, 0, 0.2) !important;
  border-radius: 0.3rem !important;
  color: #212529 !important;
}

.modal-header {
  display: flex !important;
  align-items: center !important;
  justify-content: space-between !important;
  padding: 1rem !important;
  border-bottom: 1px solid #dee2e6 !important;
}

.modal-title {
  margin: 0 !important;
  line-height: 1.5 !important;
  color: inherit !important;
}

.modal-body {
  position: relative !important;
  flex: 1 1 auto !important;
  padding: 1rem !important;
  background: white !important;
  color: #212529 !important;
}

.modal-footer {
  display: flex !important;
  align-items: center !important;
  justify-content: flex-end !important;
  padding: 1rem !important;
  border-top: 1px solid #dee2e6 !important;
  background: #f8f9fa !important;
}

.btn-close {
  background: transparent url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16' fill='%23000'%3e%3cpath d='M.293.293a1 1 0 011.414 0L8 6.586 14.293.293a1 1 0 111.414 1.414L9.414 8l6.293 6.293a1 1 0 01-1.414 1.414L8 9.414l-6.293 6.293a1 1 0 01-1.414-1.414L6.586 8 .293 1.707a1 1 0 010-1.414z'/%3e%3c/svg%3e") center/1em auto no-repeat !important;
  border: 0 !important;
  padding: 0.25rem !important;
  width: 1em !important;
  height: 1em !important;
  opacity: 0.5 !important;
  cursor: pointer !important;
}

.btn-close-white {
  filter: invert(1) grayscale(100%) brightness(200%) !important;
}

/* Toast styles */
.toast {
  min-width: 300px !important;
  background: white !important;
  border: 1px solid rgba(0, 0, 0, 0.1) !important;
  border-radius: 0.25rem !important;
  box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15) !important;
}

.toast-header {
  display: flex !important;
  align-items: center !important;
  padding: 0.5rem 0.75rem !important;
  color: #212529 !important;
  background: #f8f9fa !important;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05) !important;
}

.toast-body {
  padding: 0.75rem !important;
  color: #212529 !important;
  background: white !important;
}

.text-success {
  color: #198754 !important;
}

/* Button groups */
.btn-group-sm > .btn {
  padding: 0.25rem 0.5rem !important;
  font-size: 0.875rem !important;
}

/* Input groups */
.input-group {
  display: flex !important;
  width: 100% !important;
}

.input-group-text {
  background: #e9ecef !important;
  border: 1px solid #ced4da !important;
  color: #212529 !important;
  padding: 0.375rem 0.75rem !important;
}

/* Utilities */
.position-fixed {
  position: fixed !important;
}

.top-0 {
  top: 0 !important;
}

.end-0 {
  right: 0 !important;
}

.p-3 {
  padding: 1rem !important;
}

.p-4 {
  padding: 1.5rem !important;
}

.p-0 {
  padding: 0 !important;
}

.mb-0 {
  margin-bottom: 0 !important;
}

.mb-4 {
  margin-bottom: 1.5rem !important;
}

.me-2 {
  margin-right: 0.5rem !important;
}

.me-auto {
  margin-right: auto !important;
}

.w-100 {
  width: 100% !important;
}

.d-flex {
  display: flex !important;
}

.d-block {
  display: block !important;
}

.align-items-center {
  align-items: center !important;
}

.align-items-end {
  align-items: flex-end !important;
}

.justify-content-between {
  justify-content: space-between !important;
}

.flex-wrap {
  flex-wrap: wrap !important;
}

.table-responsive {
  overflow-x: auto !important;
}

@keyframes spinner-border {
  to {
    transform: rotate(360deg) !important;
  }
}
</style>
