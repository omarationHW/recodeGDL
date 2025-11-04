<template>
  <div class="container-fluid" style="background: #f8f9fa; color: #212529; padding: 20px; min-height: 100vh;">

    <!-- Header -->
    <div style="margin-bottom: 2rem;">
      <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap;">
        <div>
          <h2 style="color: #212529; font-size: 1.5rem; margin-bottom: 0.5rem;">
            <i class="fas fa-map-marked-alt" style="color: #ffc107; margin-right: 0.5rem;"></i>
            Bloqueo de Domicilios
          </h2>
          <p style="color: #6c757d; margin-bottom: 0;">Gestión de bloqueos por domicilio para licencias y trámites</p>
        </div>
        <nav aria-label="breadcrumb">
          <ol style="list-style: none; display: flex; margin: 0; padding: 0; background: transparent;">
            <li style="margin-right: 0.5rem;">
              <router-link to="/dashboard" style="color: #007bff; text-decoration: none;">Dashboard</router-link>
              <span style="margin-left: 0.5rem; color: #6c757d;">/</span>
            </li>
            <li style="margin-right: 0.5rem;">
              <router-link to="/licencias" style="color: #007bff; text-decoration: none;">Licencias</router-link>
              <span style="margin-left: 0.5rem; color: #6c757d;">/</span>
            </li>
            <li style="color: #6c757d;">Bloqueo Domicilios</li>
          </ol>
        </nav>
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

    <!-- Modal de detalle de domicilio -->
    <div v-if="showModalDetalle" class="modal fade show d-block" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header bg-info text-white">
            <h5 class="modal-title">
              <i class="fas fa-info-circle me-2"></i>
              Detalle del Domicilio
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="cerrarModalDetalle"></button>
          </div>
          <div class="modal-body">
            <div v-if="domicilioDetalle">
              <!-- Información del domicilio -->
              <div class="mb-4">
                <h6 class="border-bottom pb-2 mb-3">
                  <i class="fas fa-map-marker-alt me-2 text-primary"></i>
                  Información del Domicilio
                </h6>
                <div class="row">
                  <div class="col-md-12 mb-3">
                    <strong>Dirección Completa:</strong>
                    <p class="mb-0">{{ domicilioDetalle.direccion_completa }}</p>
                  </div>
                  <div class="col-md-6 mb-2">
                    <strong>Colonia:</strong>
                    <p class="mb-0">{{ domicilioDetalle.colonia || 'N/A' }}</p>
                  </div>
                  <div class="col-md-6 mb-2">
                    <strong>Código Postal:</strong>
                    <p class="mb-0">{{ domicilioDetalle.codigo_postal || 'N/A' }}</p>
                  </div>
                </div>
              </div>

              <!-- Información de la licencia -->
              <div class="mb-4">
                <h6 class="border-bottom pb-2 mb-3">
                  <i class="fas fa-id-card me-2 text-success"></i>
                  Información de la Licencia
                </h6>
                <div class="row">
                  <div class="col-md-6 mb-2">
                    <strong>Número de Licencia:</strong>
                    <p class="mb-0">{{ domicilioDetalle.licencia }}</p>
                  </div>
                  <div class="col-md-6 mb-2">
                    <strong>Propietario:</strong>
                    <p class="mb-0">{{ domicilioDetalle.propietario }}</p>
                  </div>
                  <div class="col-md-6 mb-2">
                    <strong>Estado:</strong>
                    <span class="badge" :class="domicilioDetalle.bloqueado === 'S' ? 'bg-danger' : 'bg-success'">
                      {{ domicilioDetalle.bloqueado === 'S' ? 'Bloqueado' : 'Activo' }}
                    </span>
                  </div>
                  <div class="col-md-6 mb-2">
                    <strong>Licencias Afectadas:</strong>
                    <span class="badge bg-info">{{ domicilioDetalle.licencias_afectadas || 0 }}</span>
                  </div>
                </div>
              </div>

              <!-- Información del bloqueo (si está bloqueado) -->
              <div v-if="domicilioDetalle.bloqueado === 'S'" class="mb-4">
                <h6 class="border-bottom pb-2 mb-3">
                  <i class="fas fa-lock me-2 text-danger"></i>
                  Información del Bloqueo
                </h6>
                <div class="row">
                  <div class="col-md-6 mb-2">
                    <strong>Fecha de Bloqueo:</strong>
                    <p class="mb-0">{{ formatearFecha(domicilioDetalle.fecha_bloqueo) }}</p>
                  </div>
                  <div class="col-md-6 mb-2">
                    <strong>Usuario:</strong>
                    <p class="mb-0">{{ domicilioDetalle.usuario_bloqueo || 'N/A' }}</p>
                  </div>
                  <div class="col-md-12 mb-2">
                    <strong>Motivo:</strong>
                    <p class="mb-0">{{ domicilioDetalle.motivo_bloqueo || 'Sin motivo especificado' }}</p>
                  </div>
                </div>
              </div>

              <!-- Nota informativa -->
              <div class="alert alert-info mb-0">
                <i class="fas fa-info-circle me-2"></i>
                <strong>Nota:</strong> Esta información corresponde al estado actual del domicilio en el sistema.
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button
              type="button"
              class="btn btn-secondary"
              @click="cerrarModalDetalle"
            >
              <i class="fas fa-times me-2"></i>
              Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal backdrop -->
    <div v-if="showModalBloqueo || showModalDesbloqueo || showModalDetalle" class="modal-backdrop fade show"></div>

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
      domicilioDetalle: null,
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
      showModalDetalle: false,
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
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_domicilios_buscar',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_calle', valor: this.filtros.calle || null, tipo: 'varchar' },
                { nombre: 'p_numero_exterior', valor: this.filtros.numeroExterior || null, tipo: 'varchar' },
                { nombre: 'p_colonia', valor: this.filtros.colonia || null, tipo: 'varchar' },
                { nombre: 'p_codigo_postal', valor: this.filtros.codigoPostal || null, tipo: 'varchar' },
                { nombre: 'p_estado_bloqueo', valor: this.filtros.estadoBloqueo || null, tipo: 'char' }
              ],
              Tenant: 'guadalajara'
            }
          })
        });
        const data = await response.json();

        if (data.eResponse.success) {
          this.domicilios = data.eResponse.data.result || []
          if (this.domicilios.length === 0) {
            this.mostrarMensaje('info', 'No se encontraron domicilios con los criterios especificados')
          }
        } else {
          this.mostrarMensaje('error', data.eResponse.message || 'Error al buscar domicilios')
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

    cerrarModalDetalle() {
      this.showModalDetalle = false
      this.domicilioDetalle = null
    },

    async confirmarBloqueoMasivo() {
      if (!this.formulario.motivo) return

      this.procesando = true
      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_domicilios_bloquear_masivo',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_ids_domicilios', valor: this.domiciliosSeleccionados.join(','), tipo: 'varchar' },
                { nombre: 'p_motivo', valor: this.formulario.motivo, tipo: 'varchar' },
                { nombre: 'p_fecha_vigencia', valor: this.formulario.fechaVigencia || null, tipo: 'date' },
                { nombre: 'p_usuario', valor: 'admin', tipo: 'varchar' }
              ],
              Tenant: 'guadalajara'
            }
          })
        });
        const data = await response.json();

        if (data.eResponse.success && data.eResponse.data.result[0]?.success) {
          this.mostrarMensaje('success', data.eResponse.data.result[0].message)
          this.cerrarModalBloqueo()
          this.domiciliosSeleccionados = []
          await this.buscarDomicilios()
        } else {
          this.mostrarMensaje('error', data.eResponse.data.result[0]?.message || data.eResponse.message || 'Error al bloquear domicilios')
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
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_domicilios_desbloquear_masivo',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_ids_domicilios', valor: this.domiciliosSeleccionados.join(','), tipo: 'varchar' },
                { nombre: 'p_motivo', valor: this.formulario.motivo, tipo: 'varchar' },
                { nombre: 'p_usuario', valor: 'admin', tipo: 'varchar' }
              ],
              Tenant: 'guadalajara'
            }
          })
        });
        const data = await response.json();

        if (data.eResponse.success && data.eResponse.data.result[0]?.success) {
          this.mostrarMensaje('success', data.eResponse.data.result[0].message)
          this.cerrarModalDesbloqueo()
          this.domiciliosSeleccionados = []
          await this.buscarDomicilios()
        } else {
          this.mostrarMensaje('error', data.eResponse.data.result[0]?.message || data.eResponse.message || 'Error al desbloquear domicilios')
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
      this.domicilioDetalle = domicilio
      this.showModalDetalle = true
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
/* Forzar colores visibles en todo el componente */
.container-fluid {
  background: #f8f9fa !important;
  color: #212529 !important;
}

.card {
  background: white !important;
  border: 1px solid #dee2e6 !important;
  border-radius: 0.25rem !important;
  box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075) !important;
  color: #212529 !important;
}

.card-header {
  background: #f8f9fa !important;
  border-bottom: 1px solid #dee2e6 !important;
  padding: 0.75rem 1.25rem !important;
  color: #212529 !important;
}

.card-body {
  padding: 1.25rem !important;
  background: white !important;
  color: #212529 !important;
}

.form-label {
  color: #212529 !important;
  margin-bottom: 0.5rem !important;
  display: inline-block !important;
}

.form-control, .form-select {
  display: block !important;
  width: 100% !important;
  padding: 0.375rem 0.75rem !important;
  font-size: 1rem !important;
  line-height: 1.5 !important;
  color: #212529 !important;
  background-color: #fff !important;
  border: 1px solid #ced4da !important;
  border-radius: 0.25rem !important;
}

.btn {
  display: inline-block !important;
  padding: 0.375rem 0.75rem !important;
  font-size: 1rem !important;
  line-height: 1.5 !important;
  border-radius: 0.25rem !important;
  border: 1px solid transparent !important;
  cursor: pointer !important;
}

.btn-primary {
  color: #fff !important;
  background-color: #007bff !important;
  border-color: #007bff !important;
}

.btn-secondary {
  color: #fff !important;
  background-color: #6c757d !important;
  border-color: #6c757d !important;
}

.btn-success {
  color: #fff !important;
  background-color: #28a745 !important;
  border-color: #28a745 !important;
}

.btn-danger {
  color: #fff !important;
  background-color: #dc3545 !important;
  border-color: #dc3545 !important;
}

.btn-warning {
  color: #212529 !important;
  background-color: #ffc107 !important;
  border-color: #ffc107 !important;
}

.btn-outline-secondary {
  color: #6c757d !important;
  background-color: transparent !important;
  border-color: #6c757d !important;
}

.btn-outline-info {
  color: #17a2b8 !important;
  background-color: transparent !important;
  border-color: #17a2b8 !important;
}

.table {
  width: 100% !important;
  color: #212529 !important;
  background-color: white !important;
}

.table th {
  border-top: none;
  background-color: #343a40 !important;
  color: white !important;
  padding: 0.75rem !important;
}

.table td {
  padding: 0.75rem !important;
  border-top: 1px solid #dee2e6 !important;
}

.badge {
  display: inline-block !important;
  padding: 0.25em 0.4em !important;
  font-size: 75% !important;
  font-weight: 700 !important;
  line-height: 1 !important;
  text-align: center !important;
  white-space: nowrap !important;
  vertical-align: baseline !important;
  border-radius: 0.25rem !important;
}

.bg-danger {
  background-color: #dc3545 !important;
  color: white !important;
}

.bg-success {
  background-color: #28a745 !important;
  color: white !important;
}

.bg-info {
  background-color: #17a2b8 !important;
  color: white !important;
}

.alert {
  padding: 0.75rem 1.25rem !important;
  margin-bottom: 1rem !important;
  border: 1px solid transparent !important;
  border-radius: 0.25rem !important;
}

.alert-warning {
  color: #856404 !important;
  background-color: #fff3cd !important;
  border-color: #ffeaa7 !important;
}

.alert-info {
  color: #0c5460 !important;
  background-color: #d1ecf1 !important;
  border-color: #bee5eb !important;
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

.modal-dialog {
  position: relative;
  width: auto;
  max-width: 500px;
  margin: 1.75rem auto;
}

.modal-content {
  position: relative;
  display: flex;
  flex-direction: column;
  background-color: #fff !important;
  border: 1px solid rgba(0,0,0,.2);
  border-radius: 0.3rem;
  color: #212529 !important;
}

.modal-header {
  padding: 1rem !important;
  border-bottom: 1px solid #dee2e6 !important;
}

.modal-body {
  position: relative;
  flex: 1 1 auto;
  padding: 1rem !important;
  background: white !important;
  color: #212529 !important;
}

.modal-footer {
  padding: 1rem !important;
  border-top: 1px solid #dee2e6 !important;
  background: white !important;
}

.toast {
  min-width: 300px;
}

.btn-group-sm > .btn {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

.text-center {
  text-align: center !important;
}

.text-muted {
  color: #6c757d !important;
}
</style>
