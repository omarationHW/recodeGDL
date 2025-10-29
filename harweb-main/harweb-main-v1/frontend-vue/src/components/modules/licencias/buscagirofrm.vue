<template>
  <div class="container mt-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item"><router-link to="/licencias">Licencias</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Búsqueda de Giros</li>
      </ol>
    </nav>

    <div class="row">
      <div class="col-md-12">
        <div class="card">
          <div class="card-header d-flex justify-content-between align-items-center">
            <h4 class="mb-0">🔍 Búsqueda de Giros Comerciales</h4>
            <span class="badge bg-primary">Consulta de Giros</span>
          </div>
          <div class="card-body">
            <!-- Formulario de Búsqueda -->
            <form @submit.prevent="buscarGiros" class="row g-3">
              <div class="col-md-6">
                <label for="descripcion" class="form-label">Descripción del Giro:</label>
                <input
                  v-model="filtros.descripcion"
                  id="descripcion"
                  type="text"
                  class="form-control"
                  placeholder="Ingrese descripción del giro..."
                />
              </div>
              <div class="col-md-3">
                <label for="codigo" class="form-label">Código:</label>
                <input
                  v-model="filtros.codigo"
                  id="codigo"
                  type="text"
                  class="form-control"
                  placeholder="Código del giro"
                />
              </div>
              <div class="col-md-3">
                <label for="categoria" class="form-label">Categoría:</label>
                <select v-model="filtros.categoria" id="categoria" class="form-select">
                  <option value="">Todas las categorías</option>
                  <option v-for="cat in categorias" :key="cat.id" :value="cat.id">
                    {{ cat.nombre }}
                  </option>
                </select>
              </div>
              <div class="col-md-3">
                <label for="tipo" class="form-label">Tipo de Giro:</label>
                <select v-model="filtros.tipo" id="tipo" class="form-select">
                  <option value="">Todos</option>
                  <option value="L">Licencia</option>
                  <option value="A">Anuncio</option>
                  <option value="M">Mixto</option>
                </select>
              </div>
              <div class="col-md-3">
                <label for="estado" class="form-label">Estado:</label>
                <select v-model="filtros.estado" id="estado" class="form-select">
                  <option value="">Todos</option>
                  <option value="S">Activos</option>
                  <option value="N">Inactivos</option>
                </select>
              </div>
              <div class="col-md-6">
                <div class="row">
                  <div class="col-6">
                    <div class="form-check mt-4">
                      <input type="checkbox" v-model="filtros.autoev" id="autoev" class="form-check-input" />
                      <label class="form-check-label" for="autoev">Solo Autoevaluación</label>
                    </div>
                  </div>
                  <div class="col-6">
                    <div class="form-check mt-4">
                      <input type="checkbox" v-model="filtros.pacto" id="pacto" class="form-check-input" />
                      <label class="form-check-label" for="pacto">Pacto Homologación</label>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-12">
                <hr>
                <button type="submit" class="btn btn-primary me-2" :disabled="loading">
                  <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
                  🔍 Buscar Giros
                </button>
                <button type="button" class="btn btn-secondary" @click="limpiarFiltros">
                  🗑️ Limpiar
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

    <!-- Alertas -->
    <div v-if="mensaje.texto" class="row mt-3">
      <div class="col-12">
        <div :class="`alert alert-${mensaje.tipo} alert-dismissible fade show`" role="alert">
          {{ mensaje.texto }}
          <button type="button" class="btn-close" @click="mensaje.texto = ''"></button>
        </div>
      </div>
    </div>

    <!-- Resultados -->
    <div v-if="giros.length > 0" class="row mt-4">
      <div class="col-md-12">
        <div class="card">
          <div class="card-header d-flex justify-content-between align-items-center">
            <h5 class="mb-0">📋 Resultados de Búsqueda</h5>
            <span class="badge bg-success">{{ giros.length }} giro(s) encontrado(s)</span>
          </div>
          <div class="card-body">
            <div class="table-responsive">
              <table class="table table-striped table-hover">
                <thead class="table-dark">
                  <tr>
                    <th>Código</th>
                    <th>Descripción</th>
                    <th>Categoría</th>
                    <th>Tipo</th>
                    <th>Estado</th>
                    <th>Características</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="giro in giros" :key="giro.id">
                    <td>
                      <code>{{ giro.codigo }}</code>
                    </td>
                    <td>
                      <strong>{{ giro.descripcion }}</strong>
                    </td>
                    <td>
                      <span class="badge bg-info">{{ giro.categoria_nombre || 'Sin categoría' }}</span>
                    </td>
                    <td>
                      <span class="badge" :class="getTipoBadgeClass(giro.tipo)">
                        {{ getTipoTexto(giro.tipo) }}
                      </span>
                    </td>
                    <td>
                      <span class="badge" :class="giro.activo === 'S' ? 'bg-success' : 'bg-danger'">
                        {{ giro.activo === 'S' ? 'Activo' : 'Inactivo' }}
                      </span>
                    </td>
                    <td>
                      <div class="small">
                        <div v-if="giro.autoev === 'S'">🔍 Autoevaluación</div>
                        <div v-if="giro.pacto === 'S'">📝 Pacto</div>
                        <div v-if="giro.costo">💰 ${{ formatearMoneda(giro.costo) }}</div>
                      </div>
                    </td>
                    <td>
                      <div class="btn-group btn-group-sm">
                        <button
                          class="btn btn-success"
                          @click="seleccionarGiro(giro)"
                          title="Seleccionar este giro"
                        >
                          ✓ Seleccionar
                        </button>
                        <button
                          class="btn btn-info"
                          @click="verDetalleGiro(giro)"
                          title="Ver detalles del giro"
                        >
                          👁️ Ver
                        </button>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Giro Seleccionado -->
    <div v-if="giroSeleccionado" class="row mt-4">
      <div class="col-md-12">
        <div class="card border-success">
          <div class="card-header bg-success text-white">
            <h5 class="mb-0">✅ Giro Seleccionado</h5>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-6">
                <p><strong>Código:</strong> {{ giroSeleccionado.codigo }}</p>
                <p><strong>Descripción:</strong> {{ giroSeleccionado.descripcion }}</p>
                <p><strong>Categoría:</strong> {{ giroSeleccionado.categoria_nombre || 'Sin categoría' }}</p>
              </div>
              <div class="col-md-6">
                <p><strong>Tipo:</strong> {{ getTipoTexto(giroSeleccionado.tipo) }}</p>
                <p><strong>Estado:</strong> {{ giroSeleccionado.activo === 'S' ? 'Activo' : 'Inactivo' }}</p>
                <p><strong>Costo:</strong> ${{ formatearMoneda(giroSeleccionado.costo || 0) }}</p>
              </div>
            </div>
            <div class="row mt-3">
              <div class="col-12">
                <button class="btn btn-warning me-2" @click="giroSeleccionado = null">
                  ❌ Quitar Selección
                </button>
                <button class="btn btn-primary" @click="confirmarSeleccion">
                  ✅ Confirmar Selección
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Detalle Giro -->
    <div class="modal fade" id="modalDetalle" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">📋 Detalle del Giro</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body" v-if="giroDetalle">
            <div class="row">
              <div class="col-md-6">
                <h6>Información General</h6>
                <table class="table table-sm">
                  <tr><td><strong>Código:</strong></td><td>{{ giroDetalle.codigo }}</td></tr>
                  <tr><td><strong>Descripción:</strong></td><td>{{ giroDetalle.descripcion }}</td></tr>
                  <tr><td><strong>Categoría:</strong></td><td>{{ giroDetalle.categoria_nombre || 'Sin categoría' }}</td></tr>
                  <tr><td><strong>Tipo:</strong></td><td>{{ getTipoTexto(giroDetalle.tipo) }}</td></tr>
                  <tr><td><strong>Estado:</strong></td><td>{{ giroDetalle.activo === 'S' ? 'Activo' : 'Inactivo' }}</td></tr>
                </table>
              </div>
              <div class="col-md-6">
                <h6>Características</h6>
                <table class="table table-sm">
                  <tr><td><strong>Costo:</strong></td><td>${{ formatearMoneda(giroDetalle.costo || 0) }}</td></tr>
                  <tr><td><strong>Autoevaluación:</strong></td><td>{{ giroDetalle.autoev === 'S' ? 'Sí' : 'No' }}</td></tr>
                  <tr><td><strong>Pacto:</strong></td><td>{{ giroDetalle.pacto === 'S' ? 'Sí' : 'No' }}</td></tr>
                  <tr><td><strong>Orden:</strong></td><td>{{ giroDetalle.orden || 0 }}</td></tr>
                </table>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
            <button type="button" class="btn btn-success" @click="seleccionarGiroDetalle" data-bs-dismiss="modal">
              Seleccionar este Giro
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'BuscagiroPage',
  data() {
    return {
      loading: false,
      filtros: {
        descripcion: '',
        codigo: '',
        categoria: '',
        tipo: '',
        estado: '',
        autoev: false,
        pacto: false
      },
      giros: [],
      categorias: [],
      giroSeleccionado: null,
      giroDetalle: null,
      mensaje: {
        texto: '',
        tipo: 'info'
      }
    };
  },
  mounted() {
    this.cargarCategorias();
  },
  methods: {
    async cargarCategorias() {
      try {
        const eRequest = {
          Operacion: 'sp_categorias_giros_listar',
          Base: 'licencias',
          Parametros: [],
          Tenant: 'guadalajara'
        };

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.categorias = data.eResponse.data || [];
        }
      } catch (error) {
        console.error('Error al cargar categorías:', error);
      }
    },

    async buscarGiros() {
      if (!this.filtros.descripcion && !this.filtros.codigo && !this.filtros.categoria) {
        this.mostrarMensaje('Ingrese al menos un criterio de búsqueda', 'warning');
        return;
      }

      this.loading = true;
      this.giros = [];
      this.giroSeleccionado = null;

      try {
        const eRequest = {
          Operacion: 'sp_giros_buscar',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_descripcion', valor: this.filtros.descripcion || null, tipo: 'varchar' },
            { nombre: 'p_codigo', valor: this.filtros.codigo || null, tipo: 'varchar' },
            { nombre: 'p_id_categoria', valor: this.filtros.categoria || null, tipo: 'integer' },
            { nombre: 'p_tipo', valor: this.filtros.tipo || null, tipo: 'char' },
            { nombre: 'p_estado', valor: this.filtros.estado || null, tipo: 'char' },
            { nombre: 'p_autoev', valor: this.filtros.autoev ? 'S' : null, tipo: 'char' },
            { nombre: 'p_pacto', valor: this.filtros.pacto ? 'S' : null, tipo: 'char' }
          ],
          Tenant: 'guadalajara'
        };

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();

        if (data.eResponse && data.eResponse.success) {
          this.giros = data.eResponse.data || [];
          if (this.giros.length === 0) {
            this.mostrarMensaje('No se encontraron giros con los criterios especificados', 'info');
          } else {
            this.mostrarMensaje(`Se encontraron ${this.giros.length} giro(s)`, 'success');
          }
        } else {
          this.mostrarMensaje('Error al buscar giros: ' + (data.eResponse?.message || 'Error desconocido'), 'danger');
        }
      } catch (error) {
        console.error('Error al buscar giros:', error);
        this.mostrarMensaje('Error de conexión al buscar giros', 'danger');
      } finally {
        this.loading = false;
      }
    },

    limpiarFiltros() {
      this.filtros = {
        descripcion: '',
        codigo: '',
        categoria: '',
        tipo: '',
        estado: '',
        autoev: false,
        pacto: false
      };
      this.giros = [];
      this.giroSeleccionado = null;
      this.mensaje.texto = '';
    },

    seleccionarGiro(giro) {
      this.giroSeleccionado = giro;
      this.mostrarMensaje(`Giro seleccionado: ${giro.descripcion}`, 'success');
    },

    verDetalleGiro(giro) {
      this.giroDetalle = giro;
      const modal = new bootstrap.Modal(document.getElementById('modalDetalle'));
      modal.show();
    },

    seleccionarGiroDetalle() {
      if (this.giroDetalle) {
        this.seleccionarGiro(this.giroDetalle);
      }
    },

    confirmarSeleccion() {
      if (this.giroSeleccionado) {
        // Emitir evento para componente padre o guardar en store
        this.$emit('giro-seleccionado', this.giroSeleccionado);
        this.mostrarMensaje(`Giro "${this.giroSeleccionado.descripcion}" confirmado para uso`, 'success');
      }
    },

    mostrarMensaje(texto, tipo = 'info') {
      this.mensaje = { texto, tipo };
      setTimeout(() => {
        this.mensaje.texto = '';
      }, 5000);
    },

    getTipoTexto(tipo) {
      const tipos = {
        'L': 'Licencia',
        'A': 'Anuncio',
        'M': 'Mixto'
      };
      return tipos[tipo] || 'Desconocido';
    },

    getTipoBadgeClass(tipo) {
      const classes = {
        'L': 'bg-primary',
        'A': 'bg-warning',
        'M': 'bg-info'
      };
      return classes[tipo] || 'bg-secondary';
    },

    formatearMoneda(valor) {
      if (!valor) return '0.00';
      return parseFloat(valor).toLocaleString('es-MX', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      });
    }
  }
};
</script>

<style scoped>
/* Estilos específicos para el componente de búsqueda de giros */
.table th {
  font-weight: 600;
}

.card-header {
  border-bottom: 2px solid #dee2e6;
}

.btn-group-sm .btn {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

.badge {
  font-size: 0.75em;
}
</style>
