<template>
  <div class="container-fluid">
    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-search me-2 text-primary"></i>
              Búsqueda de Códigos SCIAN
            </h2>
            <p class="text-muted mb-0">Sistema de búsqueda y consulta de códigos SCIAN para actividades comerciales</p>
          </div>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
              <li class="breadcrumb-item">
                <router-link to="/dashboard" class="text-decoration-none">Dashboard</router-link>
              </li>
              <li class="breadcrumb-item">
                <router-link to="/licencias" class="text-decoration-none">Licencias</router-link>
              </li>
              <li class="breadcrumb-item active">Búsqueda SCIAN</li>
            </ol>
          </nav>
        </div>
      </div>
    </div>

    <!-- Formulario de búsqueda -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="mb-0">
          <i class="fas fa-filter me-2"></i>
          Búsqueda de Códigos SCIAN
        </h5>
      </div>
      <div class="card-body">
        <div class="row g-3">
          <div class="col-md-8">
            <label for="descripcion" class="form-label">Descripción o Código SCIAN</label>
            <div class="input-group">
              <span class="input-group-text">
                <i class="fas fa-search"></i>
              </span>
              <input
                id="descripcion"
                v-model="descripcion"
                @input="debounceSearch"
                type="text"
                class="form-control"
                placeholder="Ingrese descripción o código SCIAN..."
                maxlength="200"
                autocomplete="off"
              />
              <button
                v-if="descripcion"
                class="btn btn-outline-secondary"
                type="button"
                @click="limpiarBusqueda"
                title="Limpiar búsqueda"
              >
                <i class="fas fa-times"></i>
              </button>
            </div>
          </div>
          <div class="col-md-4">
            <label for="limitePorPagina" class="form-label">Registros por página</label>
            <select
              v-model="limitePorPagina"
              class="form-select"
              @change="buscar"
              id="limitePorPagina"
            >
              <option value="10">10 por página</option>
              <option value="25">25 por página</option>
              <option value="50">50 por página</option>
              <option value="100">100 por página</option>
            </select>
          </div>
        </div>
      </div>
    </div>

    <!-- Resultados de búsqueda -->
    <div class="card mb-4">
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">
          <i class="fas fa-list me-2"></i>
          Resultados de Búsqueda
          <span v-if="totalRegistros > 0" class="badge bg-secondary ms-2">{{ totalRegistros }}</span>
        </h5>
      </div>
      <div class="card-body p-0">
        <!-- Loading state -->
        <div v-if="buscando" class="p-4 text-center">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Buscando...</span>
          </div>
          <p class="mt-3 mb-0">Buscando códigos SCIAN...</p>
        </div>

        <!-- No results -->
        <div v-else-if="resultados.length === 0 && !primeraBusqueda" class="p-4 text-center text-muted">
          <i class="fas fa-search fa-3x mb-3"></i>
          <p class="mb-0">No se encontraron códigos SCIAN con los criterios especificados</p>
        </div>

        <!-- First search state -->
        <div v-else-if="primeraBusqueda" class="p-4 text-center text-muted">
          <i class="fas fa-info-circle fa-3x mb-3"></i>
          <p class="mb-0">Ingrese una descripción o código para buscar</p>
        </div>

        <!-- Results table -->
        <div v-else>
          <div class="table-responsive">
            <table class="table table-striped table-hover mb-0">
              <thead class="table-dark">
                <tr>
                  <th style="width: 100px;">Código SCIAN</th>
                  <th>Descripción</th>
                  <th style="width: 80px;" class="text-center">Tipo</th>
                  <th style="width: 100px;" class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="row in resultados"
                  :key="row.codigo_scian"
                  :class="{'table-primary': row.codigo_scian === seleccionado?.codigo_scian}"
                  style="cursor: pointer;"
                  @click="seleccionar(row)"
                >
                  <td class="fw-bold">{{ row.codigo_scian }}</td>
                  <td>{{ row.descripcion }}</td>
                  <td class="text-center">
                    <span class="badge bg-info">{{ row.tipo }}</span>
                  </td>
                  <td class="text-center">
                    <button
                      class="btn btn-sm btn-outline-primary"
                      @click.stop="verDetalle(row)"
                      title="Ver detalle"
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
            <nav aria-label="Paginación de resultados">
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

    <!-- Panel de selección -->
    <div v-if="seleccionado" class="card mb-4">
      <div class="card-header bg-success text-white">
        <h5 class="mb-0">
          <i class="fas fa-check-circle me-2"></i>
          Código SCIAN Seleccionado
        </h5>
      </div>
      <div class="card-body">
        <div class="row">
          <div class="col-md-8">
            <div class="mb-2">
              <strong>Código SCIAN:</strong> {{ seleccionado.codigo_scian }}
            </div>
            <div class="mb-2">
              <strong>Descripción:</strong> {{ seleccionado.descripcion }}
            </div>
            <div class="mb-2">
              <strong>Tipo:</strong>
              <span class="badge bg-info ms-2">{{ seleccionado.tipo }}</span>
            </div>
          </div>
          <div class="col-md-4 d-flex align-items-center">
            <div class="d-grid gap-2 w-100">
              <button
                class="btn btn-success"
                @click="aceptar"
              >
                <i class="fas fa-check me-2"></i>
                Confirmar Selección
              </button>
              <button
                class="btn btn-outline-secondary"
                @click="limpiarSeleccion"
              >
                <i class="fas fa-times me-2"></i>
                Cancelar
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal para detalle -->
    <div v-if="detalleSeleccionado" class="modal fade show d-block" style="background-color: rgba(0,0,0,0.5);">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <i class="fas fa-info-circle me-2"></i>
              Detalle del Código SCIAN
            </h5>
            <button type="button" class="btn-close" @click="detalleSeleccionado = null"></button>
          </div>
          <div class="modal-body">
            <div class="row g-3">
              <div class="col-md-6">
                <label class="form-label fw-bold">Código SCIAN</label>
                <div class="form-control-plaintext">{{ detalleSeleccionado.codigo_scian }}</div>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">Tipo</label>
                <div>
                  <span class="badge fs-6 bg-info">{{ detalleSeleccionado.tipo }}</span>
                </div>
              </div>
              <div class="col-12">
                <label class="form-label fw-bold">Descripción Completa</label>
                <div class="form-control-plaintext" style="white-space: pre-wrap;">
                  {{ detalleSeleccionado.descripcion }}
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="detalleSeleccionado = null">
              <i class="fas fa-times me-2"></i>
              Cerrar
            </button>
            <button type="button" class="btn btn-success" @click="seleccionarDesdeDetalle">
              <i class="fas fa-check me-2"></i>
              Seleccionar Este Código
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Alertas -->
    <div v-if="alertMessage" :class="`alert alert-${alertType} alert-dismissible fade show`">
      <i :class="`fas ${alertType === 'success' ? 'fa-check-circle' : 'fa-exclamation-triangle'} me-2`"></i>
      {{ alertMessage }}
      <button type="button" class="btn-close" @click="clearAlert"></button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'BusquedaScianPage',
  data() {
    return {
      descripcion: '',
      resultados: [],
      seleccionado: null,
      detalleSeleccionado: null,

      // Estados de UI
      buscando: false,
      primeraBusqueda: true,
      debounceTimer: null,

      // Paginación
      paginaActual: 1,
      limitePorPagina: 25,
      totalRegistros: 0,

      // Alertas
      alertMessage: '',
      alertType: 'info'
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
  mounted() {
    // No buscar automáticamente al montar
    console.log('🔍 BusquedaScianFrm cargado');
  },
  methods: {
    async buscar() {
      this.buscando = true;
      this.primeraBusqueda = false;
      this.clearAlert();

      try {
        // Parámetros de paginación
        const offset = (this.paginaActual - 1) * this.limitePorPagina;

        // Intentar primero con paginación server-side
        const eRequest = {
          Operacion: 'catalogo_scian_busqueda_paginado',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_descripcion', valor: this.descripcion || '', tipo: 'string' },
            { nombre: 'limit_records', valor: this.limitePorPagina, tipo: 'integer' },
            { nombre: 'offset_records', valor: offset, tipo: 'integer' }
          ],
          Tenant: 'guadalajara'
        };

        const response = await this.$axios.post('/api/generic', {
          eRequest
        });

        if (response.data.eResponse.success && response.data.eResponse.data.result) {
          const result = response.data.eResponse.data.result;

          if (result.length > 0 && result[0].total_registros !== undefined) {
            this.totalRegistros = parseInt(result[0].total_registros);
            this.resultados = result;
          } else {
            // Fallback al método original sin paginación
            await this.buscarCompleto();
            return;
          }

          if (this.resultados.length === 0) {
            this.showAlert('No se encontraron códigos SCIAN con los criterios especificados', 'info');
          } else {
            this.showAlert(`Se encontraron ${this.totalRegistros} código(s) SCIAN`, 'success');
          }
        } else {
          // Fallback al método original
          await this.buscarCompleto();
        }
      } catch (error) {
        console.error('Error buscando SCIAN paginado:', error);
        // Fallback al método original
        await this.buscarCompleto();
      } finally {
        this.buscando = false;
      }
    },

    async buscarCompleto() {
      try {
        const eRequest = {
          Operacion: 'catalogo_scian_busqueda',
          Base: 'licencias',
          Parametros: [
            { nombre: 'p_descripcion', valor: this.descripcion || '', tipo: 'string' }
          ],
          Tenant: 'guadalajara'
        };

        const response = await this.$axios.post('/api/generic', {
          eRequest
        });

        if (response.data.eResponse.success && response.data.eResponse.data.result) {
          const allRecords = response.data.eResponse.data.result || [];
          this.totalRegistros = allRecords.length;

          // Paginación client-side como fallback
          const start = (this.paginaActual - 1) * this.limitePorPagina;
          const end = start + this.limitePorPagina;
          this.resultados = allRecords.slice(start, end);

          if (this.resultados.length === 0) {
            this.showAlert('No se encontraron códigos SCIAN con los criterios especificados', 'info');
          } else {
            this.showAlert(`Se encontraron ${this.totalRegistros} código(s) SCIAN`, 'success');
          }
        } else {
          this.resultados = [];
          this.totalRegistros = 0;
          this.showAlert(response.data.eResponse?.message || 'Error al buscar códigos SCIAN', 'danger');
        }

      } catch (error) {
        console.error('Error buscando SCIAN:', error);
        this.showAlert('Error al realizar la búsqueda', 'danger');
        this.resultados = [];
        this.totalRegistros = 0;
      }
    },

    debounceSearch() {
      // Limpiar timer anterior
      if (this.debounceTimer) {
        clearTimeout(this.debounceTimer);
      }

      // Establecer nuevo timer
      this.debounceTimer = setTimeout(() => {
        // Reset paginación en nueva búsqueda
        this.paginaActual = 1;
        this.buscar();
      }, 500); // Buscar después de 500ms de inactividad
    },

    cambiarPagina(nuevaPagina) {
      if (typeof nuevaPagina === 'number' && nuevaPagina >= 1 && nuevaPagina <= this.totalPaginas) {
        this.paginaActual = nuevaPagina;
        this.buscar();
      }
    },

    limpiarBusqueda() {
      this.descripcion = '';
      this.resultados = [];
      this.seleccionado = null;
      this.primeraBusqueda = true;
      this.paginaActual = 1;
      this.totalRegistros = 0;
      this.clearAlert();
    },

    seleccionar(row) {
      this.seleccionado = row;
      this.showAlert(`Código SCIAN seleccionado: ${row.codigo_scian}`, 'info');
    },

    limpiarSeleccion() {
      this.seleccionado = null;
      this.showAlert('Selección cancelada', 'info');
    },

    verDetalle(row) {
      this.detalleSeleccionado = { ...row };
    },

    seleccionarDesdeDetalle() {
      if (this.detalleSeleccionado) {
        this.seleccionado = { ...this.detalleSeleccionado };
        this.detalleSeleccionado = null;
        this.showAlert(`Código SCIAN seleccionado: ${this.seleccionado.codigo_scian}`, 'success');
      }
    },

    aceptar() {
      if (this.seleccionado) {
        // Emitir evento para componente padre
        this.$emit('scian-selected', this.seleccionado);

        // Mostrar confirmación
        this.showAlert(
          `Código SCIAN confirmado: ${this.seleccionado.codigo_scian} - ${this.seleccionado.descripcion}`,
          'success'
        );

        // Si es una ventana modal o popup, cerrarla
        if (this.$route.query.modal === 'true') {
          window.close();
        }
      }
    },

    showAlert(message, type = 'info') {
      this.alertMessage = message;
      this.alertType = type;

      // Auto-hide después de 5 segundos para success/info
      if (type === 'success' || type === 'info') {
        setTimeout(() => {
          this.clearAlert();
        }, 5000);
      }
    },

    clearAlert() {
      this.alertMessage = '';
      this.alertType = 'info';
    }
  },

  beforeUnmount() {
    // Limpiar timer si existe
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer);
    }
  }
};
</script>

<style scoped>
.form-control-plaintext {
  background: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 0.375rem;
  padding: 0.375rem 0.75rem;
}

.table th {
  border-top: none;
  font-weight: 500;
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

.table-hover tbody tr:hover {
  background-color: rgba(0, 0, 0, 0.075);
}

.table-primary {
  --bs-table-accent-bg: var(--bs-primary-bg-subtle);
  border-color: var(--bs-primary-border-subtle);
}

.spinner-border {
  width: 2rem;
  height: 2rem;
}

.gap-2 {
  gap: 0.5rem;
}

.text-decoration-none:hover {
  text-decoration: underline !important;
}

.input-group .btn {
  border-left: 0;
}

.fw-bold {
  font-weight: 600 !important;
}
</style>
