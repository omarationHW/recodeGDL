<template>
  <div class="container-fluid">
    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-ban me-2 text-danger"></i>
              Bloqueo de RFC
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
        const eRequest = {
          Operacion: 'sp_bloqueos_rfc_listar',
          Base: 'licencias',
          Parametros: [],
          Tenant: 'guadalajara'
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
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
        const eRequest = {
          Operacion: 'sp_bloqueos_rfc_buscar',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_rfc', valor: this.filtros.rfc || null, tipo: 'varchar' },
            { nombre: 'p_vigencia', valor: this.filtros.vigencia || null, tipo: 'char' }
          ],
          Tenant: 'guadalajara'
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
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
        const eRequest = {
          Operacion: 'sp_tramite_buscar_para_rfc',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_id_tramite', valor: parseInt(this.formulario.id_tramite), tipo: 'integer' }
          ],
          Tenant: 'guadalajara'
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
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

        const eRequest = {
          Operacion: operacion,
          Base: 'licencias',
          Parametros: parametros,
          Tenant: 'guadalajara'
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
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
        const eRequest = {
          Operacion: 'sp_bloqueo_rfc_desbloquear',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_id', valor: bloqueo.id, tipo: 'integer' },
            { nombre: 'p_usuario', valor: 'admin', tipo: 'varchar' }
          ],
          Tenant: 'guadalajara'
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
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
.toast {
  min-width: 300px;
}

.modal.show {
  display: block;
}

.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  z-index: 1040;
  width: 100vw;
  height: 100vh;
  background-color: #000;
  opacity: 0.5;
}

.table th {
  border-top: none;
}

.btn-group-sm > .btn {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}
</style>
