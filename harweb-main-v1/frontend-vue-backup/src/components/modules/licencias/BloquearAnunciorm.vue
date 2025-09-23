<template>
  <div class="container-fluid">
    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-ban me-2 text-warning"></i>
              Bloquear Anuncio
            </h2>
            <p class="text-muted mb-0">Gestión de bloqueos y desbloqueos de anuncios</p>
          </div>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
              <li class="breadcrumb-item">
                <router-link to="/dashboard" class="text-decoration-none">Dashboard</router-link>
              </li>
              <li class="breadcrumb-item">
                <router-link to="/licencias" class="text-decoration-none">Licencias</router-link>
              </li>
              <li class="breadcrumb-item active">Bloquear Anuncio</li>
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
          Buscar Anuncio
        </h5>
      </div>
      <div class="card-body">
        <div class="row g-3 align-items-end">
          <div class="col-md-4">
            <label for="numeroAnuncio" class="form-label">Número de Anuncio</label>
            <input 
              type="number" 
              class="form-control" 
              id="numeroAnuncio"
              v-model="numeroAnuncio"
              placeholder="Ingrese número de anuncio"
              @keyup.enter="buscarAnuncio"
            >
          </div>
          <div class="col-md-2">
            <button 
              type="button" 
              class="btn btn-primary w-100"
              @click="buscarAnuncio"
              :disabled="buscando || !numeroAnuncio"
            >
              <i class="fas fa-search me-2"></i>
              {{ buscando ? 'Buscando...' : 'Buscar' }}
            </button>
          </div>
        </div>
      </div>
    </div>
    <!-- Información del anuncio encontrado -->
    <div v-if="anuncioEncontrado" class="card mb-4">
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">
          <i class="fas fa-info-circle me-2 text-info"></i>
          Información del Anuncio
        </h5>
        <span class="badge fs-6" :class="anuncioEncontrado.bloqueado ? 'bg-danger' : 'bg-success'">
          {{ anuncioEncontrado.bloqueado ? 'BLOQUEADO' : 'ACTIVO' }}
        </span>
      </div>
      <div class="card-body">
        <div class="row g-3">
          <div class="col-md-3">
            <label class="form-label fw-bold">ID Anuncio</label>
            <div class="form-control-plaintext">{{ anuncioEncontrado.id_anuncio }}</div>
          </div>
          <div class="col-md-3">
            <label class="form-label fw-bold">ID Licencia</label>
            <div class="form-control-plaintext">{{ anuncioEncontrado.id_licencia }}</div>
          </div>
          <div class="col-md-3">
            <label class="form-label fw-bold">Fecha Otorgamiento</label>
            <div class="form-control-plaintext">{{ formatearFecha(anuncioEncontrado.fecha_otorgamiento) }}</div>
          </div>
          <div class="col-md-3">
            <label class="form-label fw-bold">Área Anuncio</label>
            <div class="form-control-plaintext">{{ anuncioEncontrado.area_anuncio || 'N/A' }}</div>
          </div>
          <div class="col-md-6">
            <label class="form-label fw-bold">Ubicación</label>
            <div class="form-control-plaintext">{{ anuncioEncontrado.ubicacion || 'N/A' }}</div>
          </div>
          <div class="col-md-6">
            <label class="form-label fw-bold">Medidas</label>
            <div class="form-control-plaintext">{{ anuncioEncontrado.medidas1 || 'N/A' }}</div>
          </div>
        </div>
      </div>
    </div>
    <!-- Acciones de bloqueo/desbloqueo -->
    <div v-if="anuncioEncontrado" class="card mb-4">
      <div class="card-header">
        <h5 class="mb-0">
          <i class="fas fa-cogs me-2"></i>
          Acciones
        </h5>
      </div>
      <div class="card-body">
        <div class="row g-3">
          <div class="col-md-8">
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
                v-if="!anuncioEncontrado.bloqueado"
                type="button" 
                class="btn btn-danger"
                @click="bloquearAnuncio"
                :disabled="procesando || !observaciones.trim()"
              >
                <i class="fas fa-ban me-2"></i>
                {{ procesando ? 'Bloqueando...' : 'Bloquear Anuncio' }}
              </button>
              <button 
                v-if="anuncioEncontrado.bloqueado"
                type="button" 
                class="btn btn-success"
                @click="desbloquearAnuncio"
                :disabled="procesando || !observaciones.trim()"
              >
                <i class="fas fa-unlock me-2"></i>
                {{ procesando ? 'Desbloqueando...' : 'Desbloquear Anuncio' }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Historial de bloqueos -->
    <div v-if="anuncioEncontrado" class="card">
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
          No hay movimientos registrados para este anuncio
        </div>
        <div v-else class="table-responsive">
          <table class="table table-hover table-striped mb-0">
            <thead class="table-dark">
              <tr>
                <th>Fecha</th>
                <th>Estado</th>
                <th>Capturista</th>
                <th>Observaciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="bloqueo in historialBloqueos" :key="bloqueo.id_bloqueo">
                <td>{{ formatearFecha(bloqueo.fecha_mov) }}</td>
                <td>
                  <span class="badge" :class="bloqueo.bloqueado ? 'bg-danger' : 'bg-success'">
                    {{ bloqueo.estado }}
                  </span>
                </td>
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
  name: 'BloquearAnunciorm',
  data() {
    return {
      numeroAnuncio: '',
      anuncioEncontrado: null,
      historialBloqueos: [],
      observaciones: '',
      buscando: false,
      procesando: false,
      cargandoHistorial: false,
      mensaje: null
    };
  },
  methods: {
    async buscarAnuncio() {
      if (!this.numeroAnuncio) return
      
      this.buscando = true
      this.anuncioEncontrado = null
      this.historialBloqueos = []
      this.observaciones = ''
      
      try {
        const eRequest = {
          Operacion: 'sp_buscar_anuncio',
          Base: 'licencias',
          Parametros: [
            { nombre: 'numero_anuncio', valor: this.numeroAnuncio, tipo: 'string' }
          ],
          Tenant: 'guadalajara'
        }
        
        const response = await this.$axios.post('/api/generic', {
          eRequest
        })
        
        if (response.data.eResponse.success && response.data.eResponse.data.result.length > 0) {
          this.anuncioEncontrado = response.data.eResponse.data.result[0]
          this.mostrarMensaje('success', `Anuncio ${this.numeroAnuncio} encontrado`)
          this.cargarHistorial()
        } else {
          this.mostrarMensaje('error', `No se encontró el anuncio ${this.numeroAnuncio}`)
        }
        
      } catch (error) {
        console.error('Error buscando anuncio:', error)
        this.mostrarMensaje('error', 'Error al buscar el anuncio')
      } finally {
        this.buscando = false
      }
    },
    async cargarHistorial() {
      if (!this.anuncioEncontrado) return
      
      this.cargandoHistorial = true
      
      try {
        const eRequest = {
          Operacion: 'sp_consultar_bloqueos',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_id_anuncio', valor: this.anuncioEncontrado.id_anuncio, tipo: 'integer' }
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
    async bloquearAnuncio() {
      if (!this.observaciones.trim()) return
      
      this.procesando = true
      
      try {
        const eRequest = {
          Operacion: 'sp_bloquear_anuncio',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_id_anuncio', valor: this.anuncioEncontrado.id_anuncio, tipo: 'integer' },
            { nombre: 'p_observa', valor: this.observaciones, tipo: 'string' },
            { nombre: 'p_usuario', valor: 'admin', tipo: 'string' }
          ],
          Tenant: 'guadalajara'
        }
        
        const response = await this.$axios.post('/api/generic', {
          eRequest
        })
        
        if (response.data.eResponse.success && response.data.eResponse.data.result[0]?.success) {
          this.anuncioEncontrado.bloqueado = 1
          this.observaciones = ''
          this.mostrarMensaje('success', response.data.eResponse.data.result[0].message)
          this.cargarHistorial()
        } else {
          this.mostrarMensaje('error', response.data.eResponse.data.result[0]?.message || 'Error al bloquear anuncio')
        }
        
      } catch (error) {
        console.error('Error bloqueando anuncio:', error)
        this.mostrarMensaje('error', 'Error al bloquear el anuncio')
      } finally {
        this.procesando = false
      }
    },
    async desbloquearAnuncio() {
      if (!this.observaciones.trim()) return
      
      this.procesando = true
      
      try {
        const eRequest = {
          Operacion: 'sp_desbloquear_anuncio',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_id_anuncio', valor: this.anuncioEncontrado.id_anuncio, tipo: 'integer' },
            { nombre: 'p_observa', valor: this.observaciones, tipo: 'string' },
            { nombre: 'p_usuario', valor: 'admin', tipo: 'string' }
          ],
          Tenant: 'guadalajara'
        }
        
        const response = await this.$axios.post('/api/generic', {
          eRequest
        })
        
        if (response.data.eResponse.success && response.data.eResponse.data.result[0]?.success) {
          this.anuncioEncontrado.bloqueado = 0
          this.observaciones = ''
          this.mostrarMensaje('success', response.data.eResponse.data.result[0].message)
          this.cargarHistorial()
        } else {
          this.mostrarMensaje('error', response.data.eResponse.data.result[0]?.message || 'Error al desbloquear anuncio')
        }
        
      } catch (error) {
        console.error('Error desbloqueando anuncio:', error)
        this.mostrarMensaje('error', 'Error al desbloquear el anuncio')
      } finally {
        this.procesando = false
      }
    },
    // Formatear fecha
    formatearFecha(fecha) {
      if (!fecha) return 'N/A'
      return new Date(fecha).toLocaleDateString('es-MX')
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
    console.log('🚀 BloquearAnunciorm cargado')
  }
};
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
