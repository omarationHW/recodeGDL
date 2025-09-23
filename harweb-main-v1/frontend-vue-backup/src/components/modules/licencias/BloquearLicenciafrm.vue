<template>
  <div class="container-fluid">
    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-lock me-2 text-warning"></i>
              Bloquear Licencia
            </h2>
            <p class="text-muted mb-0">Gestión de bloqueos y desbloqueos de licencias</p>
          </div>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
              <li class="breadcrumb-item">
                <router-link to="/dashboard" class="text-decoration-none">Dashboard</router-link>
              </li>
              <li class="breadcrumb-item">
                <router-link to="/licencias" class="text-decoration-none">Licencias</router-link>
              </li>
              <li class="breadcrumb-item active">Bloquear Licencia</li>
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
          Buscar Licencia
        </h5>
      </div>
      <div class="card-body">
        <div class="row g-3 align-items-end">
          <div class="col-md-4">
            <label for="numeroLicencia" class="form-label">Número de Licencia</label>
            <input 
              type="number" 
              class="form-control" 
              id="numeroLicencia"
              v-model="numeroLicencia"
              placeholder="Ingrese número de licencia"
              @keyup.enter="buscarLicencia"
            >
          </div>
          <div class="col-md-2">
            <button 
              type="button" 
              class="btn btn-primary w-100"
              @click="buscarLicencia"
              :disabled="buscando || !numeroLicencia"
            >
              <i class="fas fa-search me-2"></i>
              {{ buscando ? 'Buscando...' : 'Buscar' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Información de la licencia encontrada -->
    <div v-if="licenciaEncontrada" class="card mb-4">
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">
          <i class="fas fa-info-circle me-2 text-info"></i>
          Información de la Licencia
        </h5>
        <span class="badge fs-6" :class="getBadgeClass(licenciaEncontrada.bloqueado)">
          {{ getEstadoLicencia(licenciaEncontrada.bloqueado) }}
        </span>
      </div>
      <div class="card-body">
        <div class="row g-3">
          <div class="col-md-3">
            <label class="form-label fw-bold">ID Licencia</label>
            <div class="form-control-plaintext">{{ licenciaEncontrada.id_licencia }}</div>
          </div>
          <div class="col-md-3">
            <label class="form-label fw-bold">Giro</label>
            <div class="form-control-plaintext">{{ licenciaEncontrada.giro || 'N/A' }}</div>
          </div>
          <div class="col-md-3">
            <label class="form-label fw-bold">Fecha Expedición</label>
            <div class="form-control-plaintext">{{ formatearFecha(licenciaEncontrada.fecha_expedicion) }}</div>
          </div>
          <div class="col-md-3">
            <label class="form-label fw-bold">Vigencia</label>
            <div class="form-control-plaintext">{{ formatearFecha(licenciaEncontrada.vigencia_hasta) }}</div>
          </div>
          <div class="col-md-6">
            <label class="form-label fw-bold">Propietario</label>
            <div class="form-control-plaintext">{{ licenciaEncontrada.nombre_propietario || 'N/A' }}</div>
          </div>
          <div class="col-md-6">
            <label class="form-label fw-bold">Ubicación</label>
            <div class="form-control-plaintext">{{ licenciaEncontrada.ubicacion || 'N/A' }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Acciones de bloqueo/desbloqueo -->
    <div v-if="licenciaEncontrada" class="card mb-4">
      <div class="card-header">
        <h5 class="mb-0">
          <i class="fas fa-cogs me-2"></i>
          Acciones de Bloqueo
        </h5>
      </div>
      <div class="card-body">
        <div class="row g-3">
          <div class="col-md-3">
            <label for="tipoBloqueo" class="form-label">Tipo de Bloqueo *</label>
            <select 
              class="form-select" 
              id="tipoBloqueo"
              v-model="tipoBloqueoSeleccionado"
              :disabled="cargandoTipos"
            >
              <option value="">{{ cargandoTipos ? 'Cargando...' : 'Seleccione tipo' }}</option>
              <option 
                v-for="tipo in tiposBloqueo" 
                :key="tipo.id" 
                :value="tipo.id"
              >
                {{ tipo.descripcion }}
              </option>
            </select>
          </div>
          <div class="col-md-5">
            <label for="observaciones" class="form-label">Observaciones *</label>
            <textarea 
              class="form-control" 
              id="observaciones"
              v-model="observaciones"
              rows="3"
              placeholder="Ingrese las observaciones del bloqueo/desbloqueo"
            ></textarea>
          </div>
          <div class="col-md-4 d-flex flex-column justify-content-end">
            <div class="d-grid gap-2">
              <button 
                v-if="licenciaEncontrada.bloqueado === 0"
                type="button" 
                class="btn btn-danger"
                @click="bloquearLicencia"
                :disabled="procesando || !tipoBloqueoSeleccionado || !observaciones.trim()"
              >
                <i class="fas fa-lock me-2"></i>
                {{ procesando ? 'Bloqueando...' : 'Bloquear Licencia' }}
              </button>
              <button 
                v-if="licenciaEncontrada.bloqueado > 0"
                type="button" 
                class="btn btn-success"
                @click="desbloquearLicencia"
                :disabled="procesando || !tipoBloqueoSeleccionado || !observaciones.trim()"
              >
                <i class="fas fa-unlock me-2"></i>
                {{ procesando ? 'Desbloqueando...' : 'Desbloquear Licencia' }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Historial de bloqueos -->
    <div v-if="licenciaEncontrada" class="card">
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">
          <i class="fas fa-history me-2"></i>
          Historial de Bloqueos
        </h5>
        <button 
          type="button" 
          class="btn btn-outline-secondary btn-sm"
          @click="cargarHistorial"
          :disabled="cargandoHistorial"
        >
          <i class="fas fa-sync-alt me-1"></i>
          {{ cargandoHistorial ? 'Cargando...' : 'Actualizar' }}
        </button>
      </div>
      <div class="card-body p-0">
        <div v-if="cargandoHistorial" class="p-4 text-center">
          <p class="mt-3"><i class="fas fa-clock me-2"></i>Cargando historial...</p>
        </div>
        <div v-else-if="historialBloqueos.length === 0" class="p-4 text-center text-muted">
          <i class="fas fa-info-circle me-2"></i>
          No hay movimientos registrados para esta licencia
        </div>
        <div v-else class="table-responsive">
          <table class="table table-hover table-striped mb-0">
            <thead class="table-dark">
              <tr>
                <th>Fecha</th>
                <th>Estado</th>
                <th>Tipo</th>
                <th>Capturista</th>
                <th>Observaciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="bloqueo in historialBloqueos" :key="bloqueo.id_bloqueo">
                <td>{{ formatearFecha(bloqueo.fecha_mov) }}</td>
                <td>
                  <span class="badge" :class="getBadgeClass(bloqueo.bloqueado)">
                    {{ getEstadoBloqueo(bloqueo.bloqueado) }}
                  </span>
                </td>
                <td>{{ getTipoBloqueoNombre(bloqueo.bloqueado) }}</td>
                <td>{{ bloqueo.capturista || 'N/A' }}</td>
                <td>{{ bloqueo.observa || 'Sin observaciones' }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Alertas -->
    <div v-if="mensaje" class="position-fixed top-0 end-0 p-3" style="z-index: 1050">
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
  name: 'BloquearLicenciafrm',
  data() {
    return {
      numeroLicencia: '',
      licenciaEncontrada: null,
      tiposBloqueo: [],
      tipoBloqueoSeleccionado: '',
      observaciones: '',
      historialBloqueos: [],
      buscando: false,
      procesando: false,
      cargandoHistorial: false,
      cargandoTipos: false,
      mensaje: null
    }
  },
  methods: {
    // Buscar licencia por número
    async buscarLicencia() {
      if (!this.numeroLicencia) return
      
      this.buscando = true
      this.licenciaEncontrada = null
      this.historialBloqueos = []
      this.observaciones = ''
      this.tipoBloqueoSeleccionado = ''
      
      try {
        const eRequest = {
          Operacion: 'sp_buscar_licencia',
          Base: 'licencias',
          Parametros: [
            { nombre: 'numero_licencia', valor: parseInt(this.numeroLicencia), tipo: 'integer' }
          ],
          Tenant: 'guadalajara'
        }
        
        const response = await this.$axios.post('/api/generic', {
          eRequest
        })
        
        if (response.data.eResponse.success && response.data.eResponse.data.result.length > 0) {
          this.licenciaEncontrada = response.data.eResponse.data.result[0]
          this.mostrarMensaje('success', `Licencia ${this.numeroLicencia} encontrada`)
          this.cargarTiposBloqueo()
          this.cargarHistorial()
        } else {
          this.mostrarMensaje('error', `No se encontró la licencia ${this.numeroLicencia}`)
        }
        
      } catch (error) {
        console.error('Error buscando licencia:', error)
        this.mostrarMensaje('error', 'Error al buscar la licencia')
      } finally {
        this.buscando = false
      }
    },

    // Cargar tipos de bloqueo
    async cargarTiposBloqueo() {
      this.cargandoTipos = true
      
      try {
        const eRequest = {
          Operacion: 'sp_tipobloqueo_list',
          Base: 'licencias',
          Parametros: [],
          Tenant: 'guadalajara'
        }
        
        const response = await this.$axios.post('/api/generic', {
          eRequest
        })
        
        if (response.data.eResponse.success) {
          this.tiposBloqueo = response.data.eResponse.data.result || []
        }
        
      } catch (error) {
        console.error('Error cargando tipos de bloqueo:', error)
      } finally {
        this.cargandoTipos = false
      }
    },

    // Bloquear licencia
    async bloquearLicencia() {
      if (!this.tipoBloqueoSeleccionado || !this.observaciones.trim()) return
      
      this.procesando = true
      
      try {
        const eRequest = {
          Operacion: 'sp_bloquear_licencia',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_id_licencia', valor: this.licenciaEncontrada.id_licencia, tipo: 'integer' },
            { nombre: 'p_tipo_bloqueo', valor: parseInt(this.tipoBloqueoSeleccionado), tipo: 'integer' },
            { nombre: 'p_motivo', valor: this.observaciones, tipo: 'string' },
            { nombre: 'p_usuario', valor: 'admin', tipo: 'string' }
          ],
          Tenant: 'guadalajara'
        }
        
        const response = await this.$axios.post('/api/generic', {
          eRequest
        })
        
        if (response.data.eResponse.success && response.data.eResponse.data.result[0]?.success) {
          this.licenciaEncontrada.bloqueado = parseInt(this.tipoBloqueoSeleccionado)
          this.observaciones = ''
          this.tipoBloqueoSeleccionado = ''
          this.mostrarMensaje('success', response.data.eResponse.data.result[0].message)
          this.cargarHistorial()
        } else {
          this.mostrarMensaje('error', response.data.eResponse.data.result[0]?.message || 'Error al bloquear licencia')
        }
        
      } catch (error) {
        console.error('Error bloqueando licencia:', error)
        this.mostrarMensaje('error', 'Error al bloquear la licencia')
      } finally {
        this.procesando = false
      }
    },

    // Desbloquear licencia
    async desbloquearLicencia() {
      if (!this.tipoBloqueoSeleccionado || !this.observaciones.trim()) return
      
      this.procesando = true
      
      try {
        const eRequest = {
          Operacion: 'sp_desbloquear_licencia',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_id_licencia', valor: this.licenciaEncontrada.id_licencia, tipo: 'integer' },
            { nombre: 'p_tipo_bloqueo', valor: parseInt(this.tipoBloqueoSeleccionado), tipo: 'integer' },
            { nombre: 'p_motivo', valor: this.observaciones, tipo: 'string' },
            { nombre: 'p_usuario', valor: 'admin', tipo: 'string' }
          ],
          Tenant: 'guadalajara'
        }
        
        const response = await this.$axios.post('/api/generic', {
          eRequest
        })
        
        if (response.data.eResponse.success && response.data.eResponse.data.result[0]?.success) {
          this.licenciaEncontrada.bloqueado = 0
          this.observaciones = ''
          this.tipoBloqueoSeleccionado = ''
          this.mostrarMensaje('success', response.data.eResponse.data.result[0].message)
          this.cargarHistorial()
        } else {
          this.mostrarMensaje('error', response.data.eResponse.data.result[0]?.message || 'Error al desbloquear licencia')
        }
        
      } catch (error) {
        console.error('Error desbloqueando licencia:', error)
        this.mostrarMensaje('error', 'Error al desbloquear la licencia')
      } finally {
        this.procesando = false
      }
    },

    // Cargar historial de bloqueos
    async cargarHistorial() {
      if (!this.licenciaEncontrada) return
      
      this.cargandoHistorial = true
      
      try {
        const eRequest = {
          Operacion: 'sp_consultar_historial_licencia',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_id_licencia', valor: this.licenciaEncontrada.id_licencia, tipo: 'integer' }
          ],
          Tenant: 'guadalajara'
        }
        
        const response = await this.$axios.post('/api/generic', {
          eRequest
        })
        
        if (response.data.eResponse.success) {
          this.historialBloqueos = response.data.eResponse.data.result || []
        }
        
      } catch (error) {
        console.error('Error cargando historial:', error)
      } finally {
        this.cargandoHistorial = false
      }
    },

    // Formatear fecha
    formatearFecha(fecha) {
      if (!fecha) return 'N/A'
      return new Date(fecha).toLocaleDateString('es-MX')
    },

    // Obtener estado de licencia
    getEstadoLicencia(bloqueado) {
      return bloqueado === 0 ? 'ACTIVA' : `BLOQUEADA (TIPO ${bloqueado})`
    },

    // Obtener estado de bloqueo
    getEstadoBloqueo(bloqueado) {
      return bloqueado === 0 ? 'DESBLOQUEADO' : 'BLOQUEADO'
    },

    // Obtener clase CSS para badge
    getBadgeClass(bloqueado) {
      return bloqueado === 0 ? 'bg-success' : 'bg-danger'
    },

    // Obtener nombre del tipo de bloqueo
    getTipoBloqueoNombre(bloqueadoId) {
      if (bloqueadoId === 0) return 'N/A'
      const tipo = this.tiposBloqueo.find(t => t.id === bloqueadoId)
      return tipo ? tipo.descripcion : `Tipo ${bloqueadoId}`
    },

    // Mostrar mensaje
    mostrarMensaje(tipo, texto) {
      this.mensaje = { tipo, texto }
      setTimeout(() => {
        this.mensaje = null
      }, 5000)
    }
  },

  mounted() {
    console.log('🚀 BloquearLicenciafrm cargado')
  }
}
</script>

<style scoped>
.toast {
  min-width: 300px;
}

.form-control-plaintext {
  background: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 0.375rem;
  padding: 0.375rem 0.75rem;
}
</style>