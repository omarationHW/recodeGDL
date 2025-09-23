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
          <span v-if="totalRegistros > 0" class="badge bg-secondary ms-2">{{ totalRegistros }}</span>
        </h5>
        <div class="d-flex gap-2">
          <select
            v-model="limitePorPagina"
            class="form-select form-select-sm"
            @change="cargarHistorial"
            style="width: auto;"
          >
            <option value="5">5 por página</option>
            <option value="10">10 por página</option>
            <option value="25">25 por página</option>
            <option value="50">50 por página</option>
          </select>
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
      </div>
      <div class="card-body p-0">
        <!-- Loading state with spinner -->
        <div v-if="cargandoHistorial" class="p-4 text-center">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
          <p class="mt-3 mb-0"><i class="fas fa-clock me-2"></i>Cargando historial...</p>
        </div>
        <div v-else-if="historialBloqueos.length === 0" class="p-4 text-center text-muted">
          <i class="fas fa-info-circle me-2"></i>
          No hay movimientos registrados para esta licencia
        </div>
        <div v-else>
          <div class="table-responsive">
            <table class="table table-hover table-striped mb-0">
              <thead class="table-dark">
                <tr>
                  <th>Fecha</th>
                  <th>Estado</th>
                  <th>Tipo</th>
                  <th>Capturista</th>
                  <th>Observaciones</th>
                  <th>Acciones</th>
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
                  <td class="text-truncate" style="max-width: 200px;" :title="bloqueo.observa">
                    {{ bloqueo.observa || 'Sin observaciones' }}
                  </td>
                  <td>
                    <button
                      type="button"
                      class="btn btn-outline-info btn-sm"
                      @click="verDetalleMovimiento(bloqueo)"
                      title="Ver detalles"
                    >
                      <i class="fas fa-eye"></i>
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="card-footer d-flex justify-content-between align-items-center">
            <small class="text-muted">
              Mostrando {{ ((paginaActual - 1) * limitePorPagina) + 1 }} a
              {{ Math.min(paginaActual * limitePorPagina, totalRegistros) }} de
              {{ totalRegistros }} registros
            </small>
            <nav aria-label="Paginación del historial">
              <ul class="pagination pagination-sm mb-0">
                <li class="page-item" :class="{ disabled: paginaActual === 1 }">
                  <button class="page-link" @click="cambiarPagina(paginaActual - 1)" :disabled="paginaActual === 1">
                    <i class="fas fa-chevron-left"></i>
                  </button>
                </li>
                <li
                  v-for="pagina in paginasVisibles"
                  :key="pagina"
                  class="page-item"
                  :class="{ active: pagina === paginaActual }"
                >
                  <button class="page-link" @click="cambiarPagina(pagina)" v-if="typeof pagina === 'number'">{{ pagina }}</button>
                  <span class="page-link" v-else>{{ pagina }}</span>
                </li>
                <li class="page-item" :class="{ disabled: paginaActual === totalPaginas }">
                  <button class="page-link" @click="cambiarPagina(paginaActual + 1)" :disabled="paginaActual === totalPaginas">
                    <i class="fas fa-chevron-right"></i>
                  </button>
                </li>
              </ul>
            </nav>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal para detalle de movimiento -->
    <div v-if="movimientoSeleccionado" class="modal fade show d-block" style="background-color: rgba(0,0,0,0.5);">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <i class="fas fa-info-circle me-2"></i>
              Detalle del Movimiento
            </h5>
            <button type="button" class="btn-close" @click="movimientoSeleccionado = null"></button>
          </div>
          <div class="modal-body">
            <div class="row g-3">
              <div class="col-md-6">
                <label class="form-label fw-bold">Fecha y Hora</label>
                <div class="form-control-plaintext">{{ formatearFechaCompleta(movimientoSeleccionado.fecha_mov) }}</div>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">Estado</label>
                <div>
                  <span class="badge fs-6" :class="getBadgeClass(movimientoSeleccionado.bloqueado)">
                    {{ getEstadoBloqueo(movimientoSeleccionado.bloqueado) }}
                  </span>
                </div>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">Tipo de Bloqueo</label>
                <div class="form-control-plaintext">{{ getTipoBloqueoNombre(movimientoSeleccionado.bloqueado) }}</div>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">Capturista</label>
                <div class="form-control-plaintext">{{ movimientoSeleccionado.capturista || 'N/A' }}</div>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">ID Movimiento</label>
                <div class="form-control-plaintext">{{ movimientoSeleccionado.id_bloqueo || 'N/A' }}</div>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">ID Licencia</label>
                <div class="form-control-plaintext">{{ licenciaEncontrada.id_licencia }}</div>
              </div>
              <div class="col-12">
                <label class="form-label fw-bold">Observaciones</label>
                <div class="form-control-plaintext" style="white-space: pre-wrap;">
                  {{ movimientoSeleccionado.observa || 'Sin observaciones registradas' }}
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="movimientoSeleccionado = null">
              <i class="fas fa-times me-2"></i>
              Cerrar
            </button>
          </div>
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
      mensaje: null,
      // Paginación
      paginaActual: 1,
      limitePorPagina: 10,
      totalRegistros: 0,
      movimientoSeleccionado: null
    }
  },
  computed: {
    totalPaginas() {
      return Math.ceil(this.totalRegistros / this.limitePorPagina);
    },
    paginasVisibles() {
      const total = this.totalPaginas;
      const actual = this.paginaActual;
      const paginas = [];

      if (total <= 7) {
        for (let i = 1; i <= total; i++) {
          paginas.push(i);
        }
      } else {
        if (actual <= 4) {
          for (let i = 1; i <= 5; i++) {
            paginas.push(i);
          }
          paginas.push('...');
          paginas.push(total);
        } else if (actual >= total - 3) {
          paginas.push(1);
          paginas.push('...');
          for (let i = total - 4; i <= total; i++) {
            paginas.push(i);
          }
        } else {
          paginas.push(1);
          paginas.push('...');
          for (let i = actual - 1; i <= actual + 1; i++) {
            paginas.push(i);
          }
          paginas.push('...');
          paginas.push(total);
        }
      }

      return paginas;
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
      // Reset paginación
      this.paginaActual = 1
      this.totalRegistros = 0
      this.movimientoSeleccionado = null
      
      try {
        const eRequest = {
          Operacion: 'buscar_licencia',
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
            { nombre: 'p_usuario', valor: this.obtenerUsuario(), tipo: 'string' }
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
            { nombre: 'p_usuario', valor: this.obtenerUsuario(), tipo: 'string' }
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

    // Cargar historial de bloqueos con paginación
    async cargarHistorial() {
      if (!this.licenciaEncontrada) return

      this.cargandoHistorial = true

      try {
        // Intentar paginación server-side primero
        const offset = (this.paginaActual - 1) * this.limitePorPagina;

        const eRequest = {
          Operacion: 'sp_consultar_historial_licencia_paginado',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_id_licencia', valor: this.licenciaEncontrada.id_licencia, tipo: 'integer' },
            { nombre: 'limit_records', valor: this.limitePorPagina, tipo: 'integer' },
            { nombre: 'offset_records', valor: offset, tipo: 'integer' }
          ],
          Tenant: 'guadalajara'
        }

        const response = await this.$axios.post('/api/generic', {
          eRequest
        })

        if (response.data.eResponse.success) {
          const result = response.data.eResponse.data.result || [];

          if (result.length > 0 && result[0].total_registros !== undefined) {
            this.totalRegistros = parseInt(result[0].total_registros);
            this.historialBloqueos = result;
          } else {
            // Fallback al método original
            await this.cargarHistorialCompleto();
          }
        }

      } catch (error) {
        console.error('Error cargando historial paginado:', error);
        // Fallback al método original
        await this.cargarHistorialCompleto();
      } finally {
        this.cargandoHistorial = false
      }
    },

    async cargarHistorialCompleto() {
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
          const allRecords = response.data.eResponse.data.result || [];
          this.totalRegistros = allRecords.length;

          // Paginación client-side como fallback
          const start = (this.paginaActual - 1) * this.limitePorPagina;
          const end = start + this.limitePorPagina;
          this.historialBloqueos = allRecords.slice(start, end);
        }

      } catch (error) {
        console.error('Error cargando historial completo:', error);
        this.historialBloqueos = [];
        this.totalRegistros = 0;
      }
    },

    cambiarPagina(nuevaPagina) {
      if (typeof nuevaPagina === 'number' && nuevaPagina >= 1 && nuevaPagina <= this.totalPaginas) {
        this.paginaActual = nuevaPagina;
        this.cargarHistorial();
      }
    },

    verDetalleMovimiento(movimiento) {
      this.movimientoSeleccionado = { ...movimiento };
    },

    // Formatear fecha
    formatearFecha(fecha) {
      if (!fecha) return 'N/A'
      return new Date(fecha).toLocaleDateString('es-MX')
    },

    // Formatear fecha completa con hora
    formatearFechaCompleta(fecha) {
      if (!fecha) return 'N/A'
      return new Date(fecha).toLocaleString('es-MX', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
      })
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
    },

    // Obtener usuario autenticado
    obtenerUsuario() {
      // Implementar lógica para obtener el usuario autenticado
      // Por ahora retornamos un valor por defecto
      return (window.user && window.user.username) || 'admin'
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