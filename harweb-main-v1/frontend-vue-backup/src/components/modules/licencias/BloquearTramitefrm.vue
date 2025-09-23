<template>
  <div class="container-fluid">
    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-lock me-2 text-warning"></i>
              Bloquear Trámite
            </h2>
            <p class="text-muted mb-0">Gestión de bloqueos y desbloqueos de trámites</p>
          </div>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
              <li class="breadcrumb-item">
                <router-link to="/dashboard" class="text-decoration-none">Dashboard</router-link>
              </li>
              <li class="breadcrumb-item">
                <router-link to="/licencias" class="text-decoration-none">Licencias</router-link>
              </li>
              <li class="breadcrumb-item active">Bloquear Trámite</li>
            </ol>
          </nav>
        </div>
      </div>
    </div>

    <!-- Formulario de búsqueda -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="mb-0">
          <i class="fas fa-search me-2"></i>
          Buscar Trámite
        </h5>
      </div>
      <div class="card-body">
        <div class="row g-3 align-items-end">
          <div class="col-md-4">
            <label for="numeroTramite" class="form-label">Número de Trámite</label>
            <input 
              type="number" 
              class="form-control" 
              id="numeroTramite"
              v-model="numeroTramite"
              placeholder="Ingrese número de trámite"
              @keyup.enter="buscarTramite"
            >
          </div>
          <div class="col-md-2">
            <button 
              type="button" 
              class="btn btn-primary w-100"
              @click="buscarTramite"
              :disabled="buscando || !numeroTramite"
            >
              <i class="fas fa-search me-2"></i>
              {{ buscando ? 'Buscando...' : 'Buscar' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Información del trámite encontrado -->
    <div v-if="tramite" class="card mb-4">
      <div class="card-header bg-info text-white">
        <h5 class="mb-0">
          <i class="fas fa-file-alt me-2"></i>
          Información del Trámite
        </h5>
      </div>
      <div class="card-body">
        <div class="row g-3">
          <div class="col-md-6">
            <div class="mb-2">
              <strong>ID Trámite:</strong> {{ tramite.id_tramite }}
            </div>
            <div class="mb-2">
              <strong>Folio:</strong> {{ tramite.folio || 'N/A' }}
            </div>
            <div class="mb-2">
              <strong>Tipo:</strong> {{ tramite.tipo_tramite || 'N/A' }}
            </div>
            <div class="mb-2">
              <strong>Giro:</strong> {{ tramite.giro || 'N/A' }}
            </div>
          </div>
          <div class="col-md-6">
            <div class="mb-2">
              <strong>Propietario:</strong> 
              {{ tramite.primer_ap }} {{ tramite.segundo_ap }} {{ tramite.propietario }}
            </div>
            <div class="mb-2">
              <strong>Ubicación:</strong> 
              {{ tramite.ubicacion }} 
              <span v-if="tramite.numext_ubic">No. ext: {{ tramite.numext_ubic }}</span>
              <span v-if="tramite.letraext_ubic">{{ tramite.letraext_ubic }}</span>
              <span v-if="tramite.numint_ubic">No. int: {{ tramite.numint_ubic }}</span>
              <span v-if="tramite.letraint_ubic">{{ tramite.letraint_ubic }}</span>
            </div>
            <div class="mb-2">
              <strong>Actividad:</strong> {{ tramite.actividad || 'N/A' }}
            </div>
            <div class="mb-2">
              <strong>Estado:</strong> 
              <span :class="getEstadoClass()">{{ getEstadoTexto() }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Acciones de bloqueo/desbloqueo -->
    <div v-if="tramite" class="card mb-4">
      <div class="card-header">
        <h5 class="mb-0">
          <i class="fas fa-cogs me-2"></i>
          Acciones
        </h5>
      </div>
      <div class="card-body">
        <div class="row g-2">
          <div class="col-md-6">
            <button 
              type="button"
              class="btn btn-warning w-100"
              :disabled="tramite.bloqueado > 0 || procesando"
              @click="abrirModalBloqueo"
            >
              <i class="fas fa-lock me-2"></i>
              Bloquear Trámite
            </button>
          </div>
          <div class="col-md-6">
            <button 
              type="button"
              class="btn btn-success w-100"
              :disabled="!bloqueosActivos.length || procesando"
              @click="abrirModalDesbloqueo"
            >
              <i class="fas fa-unlock me-2"></i>
              Desbloquear Trámite
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de bloqueo -->
    <div v-if="showModalBloqueo" class="modal fade show d-block" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header bg-warning text-dark">
            <h5 class="modal-title">
              <i class="fas fa-lock me-2"></i>
              Bloquear Trámite
            </h5>
            <button type="button" class="btn-close" @click="cerrarModalBloqueo"></button>
          </div>
          <div class="modal-body">
            <div class="mb-3">
              <label for="tipoBloqueo" class="form-label">Tipo de Bloqueo *</label>
              <select 
                class="form-select" 
                id="tipoBloqueo"
                v-model="tipoBloqueo"
              >
                <option value="">Seleccione tipo de bloqueo...</option>
                <option 
                  v-for="tipo in tiposBloqueo" 
                  :key="tipo.id" 
                  :value="tipo.id"
                >
                  {{ tipo.descripcion }}
                </option>
              </select>
            </div>
            <div class="mb-3">
              <label for="motivoBloqueo" class="form-label">Motivo del Bloqueo *</label>
              <textarea 
                class="form-control" 
                id="motivoBloqueo"
                v-model="motivoBloqueo"
                rows="3"
                placeholder="Ingrese el motivo del bloqueo..."
              ></textarea>
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
              class="btn btn-warning" 
              @click="confirmarBloqueo"
              :disabled="!tipoBloqueo || !motivoBloqueo || procesando"
            >
              <i class="fas fa-spinner fa-spin me-2" v-if="procesando"></i>
              <i class="fas fa-lock me-2" v-else></i>
              {{ procesando ? 'Bloqueando...' : 'Confirmar Bloqueo' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de desbloqueo -->
    <div v-if="showModalDesbloqueo" class="modal fade show d-block" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header bg-success text-white">
            <h5 class="modal-title">
              <i class="fas fa-unlock me-2"></i>
              Desbloquear Trámite
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="cerrarModalDesbloqueo"></button>
          </div>
          <div class="modal-body">
            <div class="mb-3">
              <label for="tipoDesbloqueo" class="form-label">Bloqueo a Eliminar *</label>
              <select 
                class="form-select" 
                id="tipoDesbloqueo"
                v-model="tipoDesbloqueo"
              >
                <option value="">Seleccione bloqueo a eliminar...</option>
                <option 
                  v-for="bloq in bloqueosActivos" 
                  :key="bloq.id" 
                  :value="bloq.id"
                >
                  {{ bloq.descripcion }}
                </option>
              </select>
            </div>
            <div class="mb-3">
              <label for="motivoDesbloqueo" class="form-label">Motivo del Desbloqueo *</label>
              <textarea 
                class="form-control" 
                id="motivoDesbloqueo"
                v-model="motivoDesbloqueo"
                rows="3"
                placeholder="Ingrese el motivo del desbloqueo..."
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
              @click="confirmarDesbloqueo"
              :disabled="!tipoDesbloqueo || !motivoDesbloqueo || procesando"
            >
              <i class="fas fa-spinner fa-spin me-2" v-if="procesando"></i>
              <i class="fas fa-unlock me-2" v-else></i>
              {{ procesando ? 'Desbloqueando...' : 'Confirmar Desbloqueo' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Histórico de bloqueos -->
    <div v-if="tramite && historialBloqueos.length" class="card mb-4">
      <div class="card-header">
        <h5 class="mb-0">
          <i class="fas fa-history me-2"></i>
          Histórico de Bloqueos
        </h5>
      </div>
      <div class="card-body">
        <div class="table-responsive">
          <table class="table table-striped table-hover">
            <thead class="table-dark">
              <tr>
                <th>Estado</th>
                <th>Capturista</th>
                <th>Fecha</th>
                <th>Vigencia</th>
                <th>Motivo</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="bloq in historialBloqueos" :key="`${bloq.fecha_mov}-${bloq.bloqueado}`">
                <td>
                  <span :class="getBloqClass(bloq)">
                    {{ bloq.estado }}
                  </span>
                </td>
                <td>{{ bloq.capturista }}</td>
                <td>{{ formatDate(bloq.fecha_mov) }}</td>
                <td>
                  <span :class="getVigenciaClass(bloq.vigente)">
                    {{ bloq.vigente === 'V' ? 'Vigente' : 'Cancelado' }}
                  </span>
                </td>
                <td>{{ bloq.observa }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Alertas -->
    <div v-if="alertMessage" :class="`alert alert-${alertType} alert-dismissible fade show`">
      <i :class="`fas ${alertType === 'success' ? 'fa-check-circle' : 'fa-exclamation-triangle'} me-2`"></i>
      {{ alertMessage }}
      <button type="button" class="btn-close" @click="clearAlert"></button>
    </div>

    <!-- Modal backdrop -->
    <div v-if="showModalBloqueo || showModalDesbloqueo" class="modal-backdrop fade show"></div>
  </div>
</template>

<script>
export default {
  name: 'BloquearTramitefrm',
  data() {
    return {
      numeroTramite: '',
      tramite: null,
      historialBloqueos: [],
      bloqueosActivos: [],
      tiposBloqueo: [],
      
      // Estados de UI
      buscando: false,
      procesando: false,
      
      // Modales
      showModalBloqueo: false,
      showModalDesbloqueo: false,
      
      // Formularios
      tipoBloqueo: '',
      motivoBloqueo: '',
      tipoDesbloqueo: '',
      motivoDesbloqueo: '',
      
      // Alertas
      alertMessage: '',
      alertType: 'info'
    }
  },
  
  async mounted() {
    await this.cargarTiposBloqueo()
  },
  
  methods: {
    async cargarTiposBloqueo() {
      try {
        const eRequest = {
          Operacion: 'sp_tipobloqueo_list',
          Base: 'licencias',
          Parametros: [],
          Tenant: 'guadalajara'
        }

        const response = await this.$axios.post('/api/generic', {
          eRequest: eRequest
        })

        if (response.data.eResponse && response.data.eResponse.success && response.data.eResponse.data.result) {
          this.tiposBloqueo = response.data.eResponse.data.result
        }
      } catch (error) {
        console.error('Error cargando tipos de bloqueo:', error)
        this.showAlert('Error cargando tipos de bloqueo', 'danger')
      }
    },
    
    async buscarTramite() {
      if (!this.numeroTramite) return
      
      this.buscando = true
      this.tramite = null
      this.historialBloqueos = []
      this.bloqueosActivos = []
      this.clearAlert()
      
      try {
        // Buscar trámite
        const eRequestTramite = {
          Operacion: 'sp_buscar_tramite',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_numero_tramite', valor: parseInt(this.numeroTramite), tipo: 'integer' }
          ],
          Tenant: 'guadalajara'
        }

        const tramiteResponse = await this.$axios.post('/api/generic', {
          eRequest: eRequestTramite
        })

        if (tramiteResponse.data.eResponse && tramiteResponse.data.eResponse.success && tramiteResponse.data.eResponse.data.result && tramiteResponse.data.eResponse.data.result.length > 0) {
          this.tramite = tramiteResponse.data.eResponse.data.result[0]

          // Cargar historial de bloqueos
          const eRequestHistorial = {
            Operacion: 'sp_consultar_historial_tramite',
            Base: 'licencias',
            Parametros: [
              { nombre: 'p_id_tramite', valor: this.tramite.id_tramite, tipo: 'integer' }
            ],
            Tenant: 'guadalajara'
          }

          const historialResponse = await this.$axios.post('/api/generic', {
            eRequest: eRequestHistorial
          })

          if (historialResponse.data.eResponse && historialResponse.data.eResponse.success && historialResponse.data.eResponse.data.result) {
            this.historialBloqueos = historialResponse.data.eResponse.data.result

            // Filtrar bloqueos activos
            this.bloqueosActivos = this.historialBloqueos.filter(b =>
              b.vigente === 'V' && b.bloqueado > 0
            ).map(b => ({
              id: b.bloqueado,
              descripcion: b.estado
            }))
          }

          this.showAlert('Trámite encontrado correctamente', 'success')
        } else {
          this.showAlert('Trámite no encontrado', 'warning')
        }
      } catch (error) {
        console.error('Error buscando trámite:', error)
        this.showAlert('Error al buscar el trámite', 'danger')
      } finally {
        this.buscando = false
      }
    },
    
    abrirModalBloqueo() {
      this.tipoBloqueo = ''
      this.motivoBloqueo = ''
      this.showModalBloqueo = true
    },
    
    cerrarModalBloqueo() {
      this.showModalBloqueo = false
      this.tipoBloqueo = ''
      this.motivoBloqueo = ''
    },
    
    abrirModalDesbloqueo() {
      this.tipoDesbloqueo = ''
      this.motivoDesbloqueo = ''
      this.showModalDesbloqueo = true
    },
    
    cerrarModalDesbloqueo() {
      this.showModalDesbloqueo = false
      this.tipoDesbloqueo = ''
      this.motivoDesbloqueo = ''
    },
    
    async confirmarBloqueo() {
      if (!this.tipoBloqueo || !this.motivoBloqueo) return
      
      this.procesando = true
      
      try {
        const eRequest = {
          Operacion: 'sp_bloquear_tramite',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_id_tramite', valor: this.tramite.id_tramite, tipo: 'integer' },
            { nombre: 'p_tipo_bloqueo', valor: parseInt(this.tipoBloqueo), tipo: 'integer' },
            { nombre: 'p_motivo', valor: this.motivoBloqueo, tipo: 'varchar' },
            { nombre: 'p_usuario', valor: 'admin', tipo: 'varchar' }
          ],
          Tenant: 'guadalajara'
        }

        const response = await this.$axios.post('/api/generic', {
          eRequest: eRequest
        })

        if (response.data.eResponse && response.data.eResponse.success) {
          this.showAlert(response.data.eResponse.data.result[0]?.message || 'Trámite bloqueado correctamente', 'success')
          this.cerrarModalBloqueo()
          await this.buscarTramite() // Recargar datos
        } else {
          this.showAlert(response.data.eResponse?.message || 'Error al bloquear el trámite', 'danger')
        }
      } catch (error) {
        console.error('Error bloqueando trámite:', error)
        this.showAlert('Error al bloquear el trámite', 'danger')
      } finally {
        this.procesando = false
      }
    },
    
    async confirmarDesbloqueo() {
      if (!this.tipoDesbloqueo || !this.motivoDesbloqueo) return

      this.procesando = true

      try {
        const eRequest = {
          Operacion: 'sp_desbloquear_tramite',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_id_tramite', valor: this.tramite.id_tramite, tipo: 'integer' },
            { nombre: 'p_tipo_bloqueo', valor: parseInt(this.tipoDesbloqueo), tipo: 'integer' },
            { nombre: 'p_motivo', valor: this.motivoDesbloqueo, tipo: 'varchar' },
            { nombre: 'p_usuario', valor: 'admin', tipo: 'varchar' }
          ],
          Tenant: 'guadalajara'
        }

        const response = await this.$axios.post('/api/generic', {
          eRequest: eRequest
        })

        if (response.data.eResponse && response.data.eResponse.success) {
          this.showAlert(response.data.eResponse.data.result[0]?.message || 'Trámite desbloqueado correctamente', 'success')
          this.cerrarModalDesbloqueo()
          await this.buscarTramite() // Recargar datos
        } else {
          this.showAlert(response.data.eResponse?.message || 'Error al desbloquear el trámite', 'danger')
        }
      } catch (error) {
        console.error('Error desbloqueando trámite:', error)
        this.showAlert('Error al desbloquear el trámite', 'danger')
      } finally {
        this.procesando = false
      }
    },
    
    getEstadoTexto() {
      if (!this.tramite) return ''
      
      switch (this.tramite.bloqueado) {
        case 0: return 'NO BLOQUEADO'
        case 1: return 'BLOQUEADO GENERAL'
        case 2: return 'ESTADO 1'
        case 3: return 'CABARET'
        case 4: return 'SUSPENDIDO'
        case 5: return 'RESPONSIVA'
        case 6: return 'CONVENIADO'
        case 7: return 'DESGLOSAR'
        default: return 'BLOQUEADO'
      }
    },
    
    getEstadoClass() {
      if (!this.tramite) return ''
      return this.tramite.bloqueado > 0 ? 'badge bg-danger' : 'badge bg-success'
    },
    
    getBloqClass(bloq) {
      if (bloq.bloqueado === 0) return 'badge bg-success'
      return 'badge bg-warning text-dark'
    },
    
    getVigenciaClass(vigente) {
      return vigente === 'V' ? 'badge bg-primary' : 'badge bg-secondary'
    },
    
    formatDate(dateStr) {
      if (!dateStr) return ''
      return new Date(dateStr).toLocaleDateString('es-ES')
    },
    
    showAlert(message, type = 'info') {
      this.alertMessage = message
      this.alertType = type
      
      // Auto-hide después de 5 segundos
      setTimeout(() => {
        this.clearAlert()
      }, 5000)
    },
    
    clearAlert() {
      this.alertMessage = ''
      this.alertType = 'info'
    }
  }
}
</script>

<style scoped>
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

.card-header {
  font-weight: 500;
}

.badge {
  font-size: 0.75rem;
}

.btn:disabled {
  opacity: 0.65;
}

.alert {
  margin-top: 1rem;
}

.form-select:focus,
.form-control:focus {
  border-color: #86b7fe;
  box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
}
</style>
