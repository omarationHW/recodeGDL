<template>
  <div class="container mt-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item"><router-link to="/licencias">Licencias</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catastro DM</li>
      </ol>
    </nav>

    <div class="row">
      <div class="col-md-12">
        <div class="card">
          <div class="card-header d-flex justify-content-between align-items-center">
            <h4 class="mb-0">🏢 Consulta Catastral DM</h4>
            <span class="badge bg-primary">Datos Catastrales</span>
          </div>
          <div class="card-body">
            <!-- Formulario de Búsqueda -->
            <form @submit.prevent="buscarPredios" class="row g-3">
              <div class="col-md-4">
                <label for="cuentaPredial" class="form-label">Cuenta Predial:</label>
                <input
                  v-model="filtros.cuentaPredial"
                  id="cuentaPredial"
                  type="text"
                  class="form-control"
                  placeholder="Número de cuenta predial"
                />
              </div>
              <div class="col-md-4">
                <label for="propietario" class="form-label">Propietario:</label>
                <input
                  v-model="filtros.propietario"
                  id="propietario"
                  type="text"
                  class="form-control"
                  placeholder="Nombre del propietario"
                />
              </div>
              <div class="col-md-4">
                <label for="direccion" class="form-label">Dirección:</label>
                <input
                  v-model="filtros.direccion"
                  id="direccion"
                  type="text"
                  class="form-control"
                  placeholder="Calle y número"
                />
              </div>
              <div class="col-md-3">
                <label for="colonia" class="form-label">Colonia:</label>
                <input
                  v-model="filtros.colonia"
                  id="colonia"
                  type="text"
                  class="form-control"
                  placeholder="Colonia"
                />
              </div>
              <div class="col-md-3">
                <label for="zona" class="form-label">Zona:</label>
                <select v-model="filtros.zona" id="zona" class="form-select">
                  <option value="">Todas las zonas</option>
                  <option value="CENTRO">Centro</option>
                  <option value="NORTE">Norte</option>
                  <option value="SUR">Sur</option>
                  <option value="ORIENTE">Oriente</option>
                  <option value="PONIENTE">Poniente</option>
                </select>
              </div>
              <div class="col-md-3">
                <label for="tipoPropiedad" class="form-label">Tipo Propiedad:</label>
                <select v-model="filtros.tipoPropiedad" id="tipoPropiedad" class="form-select">
                  <option value="">Todos</option>
                  <option value="CASA">Casa</option>
                  <option value="EDIFICIO">Edificio</option>
                  <option value="TERRENO">Terreno</option>
                  <option value="LOCAL">Local Comercial</option>
                  <option value="BODEGA">Bodega</option>
                </select>
              </div>
              <div class="col-md-3">
                <label for="estatus" class="form-label">Estatus:</label>
                <select v-model="filtros.estatus" id="estatus" class="form-select">
                  <option value="">Todos</option>
                  <option value="VIGENTE">Vigente</option>
                  <option value="SUSPENDIDO">Suspendido</option>
                  <option value="CANCELADO">Cancelado</option>
                </select>
              </div>
              <div class="col-12">
                <hr>
                <button type="submit" class="btn btn-primary me-2" :disabled="loading">
                  <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
                  🔍 Buscar
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
    <div v-if="predios.length > 0" class="row mt-4">
      <div class="col-md-12">
        <div class="card">
          <div class="card-header d-flex justify-content-between align-items-center">
            <h5 class="mb-0">📋 Predios Encontrados</h5>
            <span class="badge bg-success">{{ predios.length }} resultado(s)</span>
          </div>
          <div class="card-body">
            <div class="table-responsive">
              <table class="table table-striped table-hover">
                <thead class="table-dark">
                  <tr>
                    <th>Cuenta Predial</th>
                    <th>Propietario</th>
                    <th>Dirección</th>
                    <th>Colonia</th>
                    <th>Zona</th>
                    <th>Tipo</th>
                    <th>Valor Catastral</th>
                    <th>Estatus</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="predio in predios" :key="predio.id">
                    <td>
                      <code>{{ predio.cuenta_predial }}</code>
                    </td>
                    <td>
                      <strong>{{ predio.propietario }}</strong>
                    </td>
                    <td>{{ predio.direccion_completa }}</td>
                    <td>{{ predio.colonia }}</td>
                    <td>
                      <span class="badge bg-info">{{ predio.zona }}</span>
                    </td>
                    <td>
                      <span class="badge bg-secondary">{{ predio.tipo_propiedad }}</span>
                    </td>
                    <td class="text-end">
                      ${{ formatearMoneda(predio.valor_catastral) }}
                    </td>
                    <td>
                      <span class="badge" :class="getEstatusClass(predio.estatus)">
                        {{ predio.estatus }}
                      </span>
                    </td>
                    <td>
                      <div class="btn-group btn-group-sm">
                        <button
                          class="btn btn-outline-primary"
                          @click="verDetallePredio(predio)"
                          title="Ver detalles"
                        >
                          👁️
                        </button>
                        <button
                          class="btn btn-outline-success"
                          @click="seleccionarPredio(predio)"
                          title="Seleccionar predio"
                        >
                          ✓
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

    <!-- Predio Seleccionado -->
    <div v-if="predioSeleccionado" class="row mt-4">
      <div class="col-md-12">
        <div class="card border-success">
          <div class="card-header bg-success text-white">
            <h5 class="mb-0">🏠 Predio Seleccionado</h5>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-6">
                <h6>Datos del Predio</h6>
                <table class="table table-sm">
                  <tr><td><strong>Cuenta Predial:</strong></td><td>{{ predioSeleccionado.cuenta_predial }}</td></tr>
                  <tr><td><strong>Propietario:</strong></td><td>{{ predioSeleccionado.propietario }}</td></tr>
                  <tr><td><strong>Dirección:</strong></td><td>{{ predioSeleccionado.direccion_completa }}</td></tr>
                  <tr><td><strong>Colonia:</strong></td><td>{{ predioSeleccionado.colonia }}</td></tr>
                  <tr><td><strong>Zona:</strong></td><td>{{ predioSeleccionado.zona }}</td></tr>
                </table>
              </div>
              <div class="col-md-6">
                <h6>Información Catastral</h6>
                <table class="table table-sm">
                  <tr><td><strong>Tipo Propiedad:</strong></td><td>{{ predioSeleccionado.tipo_propiedad }}</td></tr>
                  <tr><td><strong>Superficie:</strong></td><td>{{ predioSeleccionado.superficie }} m²</td></tr>
                  <tr><td><strong>Valor Catastral:</strong></td><td>${{ formatearMoneda(predioSeleccionado.valor_catastral) }}</td></tr>
                  <tr><td><strong>Estatus:</strong></td><td>{{ predioSeleccionado.estatus }}</td></tr>
                  <tr><td><strong>Último Pago:</strong></td><td>{{ formatearFecha(predioSeleccionado.ultimo_pago) }}</td></tr>
                </table>
              </div>
            </div>
            <div class="row mt-3">
              <div class="col-12">
                <button class="btn btn-warning me-2" @click="predioSeleccionado = null">
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

    <!-- Modal Detalle -->
    <div class="modal fade" id="modalDetalle" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">🏠 Detalle del Predio</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body" v-if="predioDetalle">
            <div class="row">
              <div class="col-md-6">
                <h6>Identificación</h6>
                <table class="table table-sm">
                  <tr><td><strong>Cuenta Predial:</strong></td><td>{{ predioDetalle.cuenta_predial }}</td></tr>
                  <tr><td><strong>Clave Catastral:</strong></td><td>{{ predioDetalle.clave_catastral }}</td></tr>
                  <tr><td><strong>Folio Real:</strong></td><td>{{ predioDetalle.folio_real }}</td></tr>
                </table>

                <h6 class="mt-3">Propietario</h6>
                <table class="table table-sm">
                  <tr><td><strong>Nombre:</strong></td><td>{{ predioDetalle.propietario }}</td></tr>
                  <tr><td><strong>RFC:</strong></td><td>{{ predioDetalle.rfc_propietario }}</td></tr>
                  <tr><td><strong>CURP:</strong></td><td>{{ predioDetalle.curp_propietario }}</td></tr>
                </table>
              </div>
              <div class="col-md-6">
                <h6>Ubicación</h6>
                <table class="table table-sm">
                  <tr><td><strong>Dirección:</strong></td><td>{{ predioDetalle.direccion_completa }}</td></tr>
                  <tr><td><strong>Colonia:</strong></td><td>{{ predioDetalle.colonia }}</td></tr>
                  <tr><td><strong>CP:</strong></td><td>{{ predioDetalle.codigo_postal }}</td></tr>
                  <tr><td><strong>Zona:</strong></td><td>{{ predioDetalle.zona }}</td></tr>
                </table>

                <h6 class="mt-3">Características</h6>
                <table class="table table-sm">
                  <tr><td><strong>Tipo:</strong></td><td>{{ predioDetalle.tipo_propiedad }}</td></tr>
                  <tr><td><strong>Superficie:</strong></td><td>{{ predioDetalle.superficie }} m²</td></tr>
                  <tr><td><strong>Construcción:</strong></td><td>{{ predioDetalle.superficie_construccion }} m²</td></tr>
                  <tr><td><strong>Valor Catastral:</strong></td><td>${{ formatearMoneda(predioDetalle.valor_catastral) }}</td></tr>
                </table>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
            <button type="button" class="btn btn-success" @click="seleccionarPredioDetalle" data-bs-dismiss="modal">
              Seleccionar este Predio
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CatastroDM',
  data() {
    return {
      loading: false,
      predios: [],
      filtros: {
        cuentaPredial: '',
        propietario: '',
        direccion: '',
        colonia: '',
        zona: '',
        tipoPropiedad: '',
        estatus: ''
      },
      predioSeleccionado: null,
      predioDetalle: null,
      mensaje: {
        texto: '',
        tipo: 'info'
      }
    };
  },
  methods: {
    async buscarPredios() {
      // Validar que al menos un campo tenga datos
      const filtrosConDatos = Object.values(this.filtros).some(valor => valor && valor.trim());
      if (!filtrosConDatos) {
        this.mostrarMensaje('Ingrese al menos un criterio de búsqueda', 'warning');
        return;
      }

      this.loading = true;
      this.predios = [];
      this.predioSeleccionado = null;

      try {
        const eRequest = {
          Operacion: 'sp_catastro_buscar',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_cuenta_predial', valor: this.filtros.cuentaPredial || null, tipo: 'varchar' },
            { nombre: 'p_propietario', valor: this.filtros.propietario || null, tipo: 'varchar' },
            { nombre: 'p_direccion', valor: this.filtros.direccion || null, tipo: 'varchar' },
            { nombre: 'p_colonia', valor: this.filtros.colonia || null, tipo: 'varchar' },
            { nombre: 'p_zona', valor: this.filtros.zona || null, tipo: 'varchar' },
            { nombre: 'p_tipo_propiedad', valor: this.filtros.tipoPropiedad || null, tipo: 'varchar' },
            { nombre: 'p_estatus', valor: this.filtros.estatus || null, tipo: 'varchar' }
          ],
          Tenant: 'guadalajara'
        };

        const response = await this.$axios.post('/api/generic', { eRequest });

        if (response.data.eResponse && response.data.eResponse.success) {
          this.predios = response.data.eResponse.data || [];
          if (this.predios.length === 0) {
            this.mostrarMensaje('No se encontraron predios con los criterios especificados', 'info');
          } else {
            this.mostrarMensaje(`Se encontraron ${this.predios.length} predio(s)`, 'success');
          }
        } else {
          this.mostrarMensaje('Error al buscar predios: ' + (response.data.eResponse?.message || 'Error desconocido'), 'danger');
        }
      } catch (error) {
        console.error('Error al buscar predios:', error);
        this.mostrarMensaje('Error de conexión al buscar predios', 'danger');
      } finally {
        this.loading = false;
      }
    },

    limpiarFiltros() {
      this.filtros = {
        cuentaPredial: '',
        propietario: '',
        direccion: '',
        colonia: '',
        zona: '',
        tipoPropiedad: '',
        estatus: ''
      };
      this.predios = [];
      this.predioSeleccionado = null;
      this.mensaje.texto = '';
    },

    seleccionarPredio(predio) {
      this.predioSeleccionado = predio;
      this.mostrarMensaje(`Predio seleccionado: ${predio.cuenta_predial}`, 'success');
    },

    verDetallePredio(predio) {
      this.predioDetalle = predio;
      const modal = new bootstrap.Modal(document.getElementById('modalDetalle'));
      modal.show();
    },

    seleccionarPredioDetalle() {
      if (this.predioDetalle) {
        this.seleccionarPredio(this.predioDetalle);
      }
    },

    confirmarSeleccion() {
      if (this.predioSeleccionado) {
        // Emitir evento para componente padre
        this.$emit('predio-seleccionado', this.predioSeleccionado);
        this.mostrarMensaje(`Predio "${this.predioSeleccionado.cuenta_predial}" confirmado para uso`, 'success');
      }
    },

    getEstatusClass(estatus) {
      const classes = {
        'VIGENTE': 'bg-success',
        'SUSPENDIDO': 'bg-warning text-dark',
        'CANCELADO': 'bg-danger'
      };
      return classes[estatus] || 'bg-secondary';
    },

    formatearMoneda(valor) {
      if (!valor) return '0.00';
      return parseFloat(valor).toLocaleString('es-MX', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      });
    },

    formatearFecha(fecha) {
      if (!fecha) return '-';
      try {
        return new Date(fecha).toLocaleDateString('es-MX', {
          day: '2-digit',
          month: '2-digit',
          year: 'numeric'
        });
      } catch {
        return fecha;
      }
    },

    mostrarMensaje(texto, tipo = 'info') {
      this.mensaje = { texto, tipo };
      setTimeout(() => {
        this.mensaje.texto = '';
      }, 5000);
    }
  }
};
</script>

<style scoped>
.alert-heading {
  color: #0c5460;
}

.card {
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.badge {
  font-size: 0.75em;
}
</style>
