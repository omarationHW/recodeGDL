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
          No hay movimientos registrados para este anuncio
        </div>
        <div v-else>
          <div class="table-responsive">
            <table class="table table-hover table-striped mb-0">
              <thead class="table-dark">
                <tr>
                  <th>Fecha</th>
                  <th>Estado</th>
                  <th>Capturista</th>
                  <th>Observaciones</th>
                  <th>Acciones</th>
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
                  <button class="page-link" @click="cambiarPagina(pagina)">{{ pagina }}</button>
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
                  <span class="badge fs-6" :class="movimientoSeleccionado.bloqueado ? 'bg-danger' : 'bg-success'">
                    {{ movimientoSeleccionado.estado }}
                  </span>
                </div>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">Capturista</label>
                <div class="form-control-plaintext">{{ movimientoSeleccionado.capturista || 'N/A' }}</div>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">ID Movimiento</label>
                <div class="form-control-plaintext">{{ movimientoSeleccionado.id_bloqueo || 'N/A' }}</div>
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
      mensaje: null,
      // Paginación
      paginaActual: 1,
      limitePorPagina: 10,
      totalRegistros: 0,
      movimientoSeleccionado: null
    };
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
    async buscarAnuncio() {
      if (!this.numeroAnuncio) return
      
      this.buscando = true
      this.anuncioEncontrado = null
      this.historialBloqueos = []
      this.observaciones = ''
      // Reset paginación
      this.paginaActual = 1
      this.totalRegistros = 0
      this.movimientoSeleccionado = null
      
      try {
        const eRequest = {
          Operacion: 'buscar_anuncio',
          Base: 'licencias',
          Parametros: [
            { nombre: 'numero_anuncio', valor: this.numeroAnuncio, tipo: 'integer' }
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
        // Parámetros para paginación server-side
        const offset = (this.paginaActual - 1) * this.limitePorPagina;

        const eRequest = {
          Operacion: 'consultar_bloqueos_paginado',
          Base: 'licencias',
          Parametros: [
            { nombre: 'id_anuncio', valor: this.anuncioEncontrado.id_anuncio, tipo: 'integer' },
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

          // Si el SP devuelve el total en el primer registro
          if (result.length > 0 && result[0].total_registros !== undefined) {
            this.totalRegistros = parseInt(result[0].total_registros);
            this.historialBloqueos = result;
          } else {
            // Fallback al método original si no existe el SP paginado
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
          Operacion: 'consultar_bloqueos',
          Base: 'licencias',
          Parametros: [
            { nombre: 'id_anuncio', valor: this.anuncioEncontrado.id_anuncio, tipo: 'integer' }
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
    async bloquearAnuncio() {
      if (!this.observaciones.trim()) return
      
      this.procesando = true
      
      try {
        const eRequest = {
          Operacion: 'bloquear_anuncio',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_id_anuncio', valor: this.anuncioEncontrado.id_anuncio, tipo: 'integer' },
            { nombre: 'observa', valor: this.observaciones, tipo: 'string' },
            { nombre: 'usuario', valor: this.obtenerUsuario(), tipo: 'string' }
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
          // Reset paginación y recargar historial
          this.paginaActual = 1
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
          Operacion: 'desbloquear_anuncio',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_id_anuncio', valor: this.anuncioEncontrado.id_anuncio, tipo: 'integer' },
            { nombre: 'observa', valor: this.observaciones, tipo: 'string' },
            { nombre: 'usuario', valor: this.obtenerUsuario(), tipo: 'string' }
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
          // Reset paginación y recargar historial
          this.paginaActual = 1
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
