<template>
  <div class="container-fluid">
    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-map-marked-alt me-2 text-warning"></i>
              Bloqueo de Domicilios
            </h2>
            <p class="text-muted mb-0">Gestión de bloqueos por domicilio para licencias y trámites</p>
          </div>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
              <li class="breadcrumb-item">
                <router-link to="/dashboard" class="text-decoration-none">Dashboard</router-link>
              </li>
              <li class="breadcrumb-item">
                <router-link to="/licencias" class="text-decoration-none">Licencias</router-link>
              </li>
              <li class="breadcrumb-item active">Bloqueo Domicilios</li>
            </ol>
          </nav>
        </div>
      </div>
    </div>

    <!-- Filtros de búsqueda -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="mb-0">
          <i class="fas fa-search me-2"></i>
          Búsqueda de Domicilios
        </h5>
      </div>
      <div class="card-body">
        <div class="row g-3">
          <div class="col-md-4">
            <label for="calle" class="form-label">Calle</label>
            <input
              type="text"
              class="form-control"
              id="calle"
              v-model="filtros.calle"
              placeholder="Ingrese nombre de la calle"
              @keyup.enter="buscarDomicilios"
            >
          </div>
          <div class="col-md-3">
            <label for="numeroExterior" class="form-label">Número Exterior</label>
            <input
              type="text"
              class="form-control"
              id="numeroExterior"
              v-model="filtros.numeroExterior"
              placeholder="No. exterior"
              @keyup.enter="buscarDomicilios"
            >
          </div>
          <div class="col-md-3">
            <label for="colonia" class="form-label">Colonia</label>
            <input
              type="text"
              class="form-control"
              id="colonia"
              v-model="filtros.colonia"
              placeholder="Ingrese colonia"
              @keyup.enter="buscarDomicilios"
            >
          </div>
          <div class="col-md-2 d-flex align-items-end">
            <button
              type="button"
              class="btn btn-primary w-100"
              @click="buscarDomicilios"
              :disabled="buscando"
            >
              <i class="fas fa-search me-2"></i>
              {{ buscando ? 'Buscando...' : 'Buscar' }}
            </button>
          </div>
        </div>
        <div class="row g-3 mt-2">
          <div class="col-md-3">
            <label for="estadoBloqueo" class="form-label">Estado</label>
            <select
              class="form-select"
              id="estadoBloqueo"
              v-model="filtros.estadoBloqueo"
              @change="buscarDomicilios"
            >
              <option value="">Todos</option>
              <option value="S">Bloqueados</option>
              <option value="N">No Bloqueados</option>
            </select>
          </div>
          <div class="col-md-3">
            <label for="codigoPostal" class="form-label">Código Postal</label>
            <input
              type="text"
              class="form-control"
              id="codigoPostal"
              v-model="filtros.codigoPostal"
              placeholder="CP"
              @keyup.enter="buscarDomicilios"
            >
          </div>
          <div class="col-md-3 d-flex align-items-end">
            <button
              type="button"
              class="btn btn-outline-secondary w-100"
              @click="limpiarFiltros"
            >
              <i class="fas fa-eraser me-2"></i>
              Limpiar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Resultados de domicilios -->
    <div class="card">
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">
          <i class="fas fa-list me-2"></i>
          Domicilios Encontrados ({{ domicilios.length }})
        </h5>
        <div class="d-flex gap-2">
          <button
            type="button"
            class="btn btn-success btn-sm"
            @click="abrirModalBloqueoMasivo"
            :disabled="!domiciliosSeleccionados.length"
          >
            <i class="fas fa-lock me-2"></i>
            Bloquear Seleccionados ({{ domiciliosSeleccionados.length }})
          </button>
          <button
            type="button"
            class="btn btn-warning btn-sm"
            @click="abrirModalDesbloqueoMasivo"
            :disabled="!domiciliosSeleccionados.length"
          >
            <i class="fas fa-unlock me-2"></i>
            Desbloquear Seleccionados ({{ domiciliosSeleccionados.length }})
          </button>
        </div>
      </div>
      <div class="card-body p-0">
        <div v-if="buscando" class="p-4 text-center">
          <div class="spinner-border text-primary me-2" role="status"></div>
          <span>Buscando domicilios...</span>
        </div>
        <div v-else-if="domicilios.length === 0" class="p-4 text-center text-muted">
          <i class="fas fa-search me-2"></i>
          Use los filtros para buscar domicilios
        </div>
        <div v-else class="table-responsive">
          <table class="table table-hover table-striped mb-0">
            <thead class="table-dark">
              <tr>
                <th width="50">
                  <input
                    type="checkbox"
                    class="form-check-input"
                    :checked="todoSeleccionado"
                    @change="seleccionarTodos"
                  >
                </th>
                <th>Domicilio Completo</th>
                <th>Colonia</th>
                <th>CP</th>
                <th>Estado</th>
                <th>Licencias Afectadas</th>
                <th>Fecha Bloqueo</th>
                <th>Usuario</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="domicilio in domicilios" :key="domicilio.id">
                <td>
                  <input
                    type="checkbox"
                    class="form-check-input"
                    :value="domicilio.id"
                    v-model="domiciliosSeleccionados"
                  >
                </td>
                <td>
                  <strong>{{ domicilio.direccion_completa }}</strong>
                </td>
                <td>{{ domicilio.colonia || 'N/A' }}</td>
                <td>{{ domicilio.codigo_postal || 'N/A' }}</td>
                <td>
                  <span class="badge" :class="domicilio.bloqueado === 'S' ? 'bg-danger' : 'bg-success'">
                    {{ domicilio.bloqueado === 'S' ? 'Bloqueado' : 'Activo' }}
                  </span>
                </td>
                <td>
                  <span class="badge bg-info">{{ domicilio.licencias_afectadas || 0 }}</span>
                </td>
                <td>{{ formatearFecha(domicilio.fecha_bloqueo) }}</td>
                <td>{{ domicilio.usuario_bloqueo || 'N/A' }}</td>
                <td>
                  <div class="btn-group btn-group-sm">
                    <button
                      type="button"
                      class="btn btn-outline-info"
                      @click="verDetalle(domicilio)"
                      title="Ver detalle"
                    >
                      <i class="fas fa-eye"></i>
                    </button>
                    <button
                      v-if="domicilio.bloqueado !== 'S'"
                      type="button"
                      class="btn btn-outline-danger"
                      @click="bloquearDomicilio(domicilio)"
                      title="Bloquear"
                    >
                      <i class="fas fa-lock"></i>
                    </button>
                    <button
                      v-if="domicilio.bloqueado === 'S'"
                      type="button"
                      class="btn btn-outline-success"
                      @click="desbloquearDomicilio(domicilio)"
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

    <!-- Modal para bloqueo masivo -->
    <div v-if="showModalBloqueo" class="modal fade show d-block" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header bg-danger text-white">
            <h5 class="modal-title">
              <i class="fas fa-lock me-2"></i>
              Bloquear Domicilios
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="cerrarModalBloqueo"></button>
          </div>
          <div class="modal-body">
            <div class="alert alert-warning">
              <i class="fas fa-exclamation-triangle me-2"></i>
              Se bloquearán {{ domiciliosSeleccionados.length }} domicilio(s) seleccionado(s).
            </div>
            <div class="mb-3">
              <label for="motivoBloqueo" class="form-label">Motivo del Bloqueo *</label>
              <textarea
                class="form-control"
                id="motivoBloqueo"
                v-model="formulario.motivo"
                rows="3"
                placeholder="Ingrese el motivo del bloqueo"
                required
              ></textarea>
            </div>
            <div class="mb-3">
              <label for="fechaVigencia" class="form-label">Fecha de Vigencia</label>
              <input
                type="date"
                class="form-control"
                id="fechaVigencia"
                v-model="formulario.fechaVigencia"
              >
            </div>
          </div>
          <div class="modal-footer">
            <button
              type="button"
              class="btn btn-secondary"
              @click="cerrarModalBloqueo"
              :disabled="procesando"
            >
              Cancelar
            </button>
            <button
              type="button"
              class="btn btn-danger"
              @click="confirmarBloqueoMasivo"
              :disabled="!formulario.motivo || procesando"
            >
              <i class="fas fa-spinner fa-spin me-2" v-if="procesando"></i>
              <i class="fas fa-lock me-2" v-else></i>
              {{ procesando ? 'Bloqueando...' : 'Confirmar Bloqueo' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal para desbloqueo masivo -->
    <div v-if="showModalDesbloqueo" class="modal fade show d-block" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header bg-success text-white">
            <h5 class="modal-title">
              <i class="fas fa-unlock me-2"></i>
              Desbloquear Domicilios
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="cerrarModalDesbloqueo"></button>
          </div>
          <div class="modal-body">
            <div class="alert alert-info">
              <i class="fas fa-info-circle me-2"></i>
              Se desbloquearán {{ domiciliosSeleccionados.length }} domicilio(s) seleccionado(s).
            </div>
            <div class="mb-3">
              <label for="motivoDesbloqueo" class="form-label">Motivo del Desbloqueo *</label>
              <textarea
                class="form-control"
                id="motivoDesbloqueo"
                v-model="formulario.motivo"
                rows="3"
                placeholder="Ingrese el motivo del desbloqueo"
                required
              ></textarea>
            </div>
          </div>
          <div class="modal-footer">
            <button
              type="button"
              class="btn btn-secondary"
              @click="cerrarModalDesbloqueo"
              :disabled="procesando"
            >
              Cancelar
            </button>
            <button
              type="button"
              class="btn btn-success"
              @click="confirmarDesbloqueoMasivo"
              :disabled="!formulario.motivo || procesando"
            >
              <i class="fas fa-spinner fa-spin me-2" v-if="procesando"></i>
              <i class="fas fa-unlock me-2" v-else></i>
              {{ procesando ? 'Desbloqueando...' : 'Confirmar Desbloqueo' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal backdrop -->
    <div v-if="showModalBloqueo || showModalDesbloqueo" class="modal-backdrop fade show"></div>

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
  name: 'bloqueoDomiciliosfrm',
  data() {
    return {
      domicilios: [],
      domiciliosSeleccionados: [],
      filtros: {
        calle: '',
        numeroExterior: '',
        colonia: '',
        codigoPostal: '',
        estadoBloqueo: ''
      },
      formulario: {
        motivo: '',
        fechaVigencia: ''
      },
      buscando: false,
      procesando: false,
      showModalBloqueo: false,
      showModalDesbloqueo: false,
      mensaje: null
    }
  },

  computed: {
    todoSeleccionado() {
      return this.domicilios.length > 0 && this.domiciliosSeleccionados.length === this.domicilios.length
    }
  },

  methods: {
    async buscarDomicilios() {
      this.buscando = true
      this.domicilios = []
      this.domiciliosSeleccionados = []

      try {
        const eRequest = {
          Operacion: 'sp_domicilios_buscar',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_calle', valor: this.filtros.calle || null, tipo: 'varchar' },
            { nombre: 'p_numero_exterior', valor: this.filtros.numeroExterior || null, tipo: 'varchar' },
            { nombre: 'p_colonia', valor: this.filtros.colonia || null, tipo: 'varchar' },
            { nombre: 'p_codigo_postal', valor: this.filtros.codigoPostal || null, tipo: 'varchar' },
            { nombre: 'p_estado_bloqueo', valor: this.filtros.estadoBloqueo || null, tipo: 'char' }
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
          this.domicilios = data.eResponse.data.result || []
          if (this.domicilios.length === 0) {
            this.mostrarMensaje('info', 'No se encontraron domicilios con los criterios especificados')
          }
        } else {
          this.mostrarMensaje('error', 'Error al buscar domicilios')
        }
      } catch (error) {
        console.error('Error buscando domicilios:', error)
        this.mostrarMensaje('error', 'Error al buscar domicilios')
      } finally {
        this.buscando = false
      }
    },

    limpiarFiltros() {
      this.filtros = {
        calle: '',
        numeroExterior: '',
        colonia: '',
        codigoPostal: '',
        estadoBloqueo: ''
      }
      this.domicilios = []
      this.domiciliosSeleccionados = []
    },

    seleccionarTodos() {
      if (this.todoSeleccionado) {
        this.domiciliosSeleccionados = []
      } else {
        this.domiciliosSeleccionados = this.domicilios.map(d => d.id)
      }
    },

    abrirModalBloqueoMasivo() {
      this.formulario = {
        motivo: '',
        fechaVigencia: ''
      }
      this.showModalBloqueo = true
    },

    abrirModalDesbloqueoMasivo() {
      this.formulario = {
        motivo: '',
        fechaVigencia: ''
      }
      this.showModalDesbloqueo = true
    },

    cerrarModalBloqueo() {
      this.showModalBloqueo = false
      this.formulario = {
        motivo: '',
        fechaVigencia: ''
      }
    },

    cerrarModalDesbloqueo() {
      this.showModalDesbloqueo = false
      this.formulario = {
        motivo: '',
        fechaVigencia: ''
      }
    },

    async confirmarBloqueoMasivo() {
      if (!this.formulario.motivo) return

      this.procesando = true
      try {
        const eRequest = {
          Operacion: 'sp_domicilios_bloquear_masivo',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_ids_domicilios', valor: this.domiciliosSeleccionados.join(','), tipo: 'varchar' },
            { nombre: 'p_motivo', valor: this.formulario.motivo, tipo: 'varchar' },
            { nombre: 'p_fecha_vigencia', valor: this.formulario.fechaVigencia || null, tipo: 'date' },
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
          this.cerrarModalBloqueo()
          this.domiciliosSeleccionados = []
          await this.buscarDomicilios()
        } else {
          this.mostrarMensaje('error', data.eResponse.data.result[0]?.message || 'Error al bloquear domicilios')
        }
      } catch (error) {
        console.error('Error bloqueando domicilios:', error)
        this.mostrarMensaje('error', 'Error al bloquear domicilios')
      } finally {
        this.procesando = false
      }
    },

    async confirmarDesbloqueoMasivo() {
      if (!this.formulario.motivo) return

      this.procesando = true
      try {
        const eRequest = {
          Operacion: 'sp_domicilios_desbloquear_masivo',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_ids_domicilios', valor: this.domiciliosSeleccionados.join(','), tipo: 'varchar' },
            { nombre: 'p_motivo', valor: this.formulario.motivo, tipo: 'varchar' },
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
          this.cerrarModalDesbloqueo()
          this.domiciliosSeleccionados = []
          await this.buscarDomicilios()
        } else {
          this.mostrarMensaje('error', data.eResponse.data.result[0]?.message || 'Error al desbloquear domicilios')
        }
      } catch (error) {
        console.error('Error desbloqueando domicilios:', error)
        this.mostrarMensaje('error', 'Error al desbloquear domicilios')
      } finally {
        this.procesando = false
      }
    },

    async bloquearDomicilio(domicilio) {
      // Implementar bloqueo individual
      this.domiciliosSeleccionados = [domicilio.id]
      this.abrirModalBloqueoMasivo()
    },

    async desbloquearDomicilio(domicilio) {
      // Implementar desbloqueo individual
      this.domiciliosSeleccionados = [domicilio.id]
      this.abrirModalDesbloqueoMasivo()
    },

    verDetalle(domicilio) {
      // TODO: Implementar modal de detalle con historial
      this.mostrarMensaje('info', `Detalle de domicilio: ${domicilio.direccion_completa}`)
    },

    formatearFecha(fecha) {
      if (!fecha) return 'N/A'
      return new Date(fecha).toLocaleDateString('es-MX')
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
