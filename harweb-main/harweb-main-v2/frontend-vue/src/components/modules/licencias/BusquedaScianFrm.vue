<template>
  <div class="busqueda-scian-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Búsqueda de giros</li>
      </ol>
    </nav>
    <div class="municipal-header">
      <i class="fas fa-industry text-white me-2"></i>
      <h2>BÚSQUEDA DE GIROS</h2>
    </div>
    <div class="municipal-card">
      <div class="card-body">
        <form @submit.prevent class="mb-4">
          <div class="row align-items-end">
            <div class="col-md-3">
              <label for="descripcion" class="form-label">
                <i class="fas fa-industry me-2"></i>Descripción del giro
              </label>
            </div>
            <div class="col-md-9">
              <input
                id="descripcion"
                v-model="descripcion"
                @input="buscar"
                type="text"
                class="form-control"
                placeholder="Ingrese descripción o código SCIAN..."
                style="text-transform:uppercase"
                maxlength="200"
                autocomplete="off"
              />
            </div>
          </div>
        </form>
        <div class="table-responsive" style="max-height: 450px;">
          <table class="table table-sm municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th style="width: 100px;">SCIAN</th>
                <th>Descripción</th>
                <th style="width: 80px;">Tipo</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in resultados" :key="row.codigo_scian" @click="seleccionar(row)" :class="{'municipal-selected': row.codigo_scian === seleccionado?.codigo_scian}" style="cursor:pointer">
                <td><span class="badge bg-info text-dark">{{ row.codigo_scian }}</span></td>
                <td>{{ row.descripcion }}</td>
                <td>
                  <span class="badge" :class="{
                    'bg-primary': row.tipo === 'A',
                    'bg-success': row.tipo === 'S',
                    'bg-warning text-dark': row.tipo === 'C',
                    'bg-secondary': !['A', 'S', 'C'].includes(row.tipo)
                  }">
                    {{ row.tipo }}
                  </span>
                </td>
              </tr>
              <tr v-if="resultados.length === 0">
                <td colspan="3" class="text-center text-muted py-4">
                  <i class="fas fa-search me-2"></i>No se encontraron resultados.
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="d-flex justify-content-end mt-4">
          <div class="btn-group municipal-group-btn" role="group">
            <button class="btn btn-outline-primary" :disabled="!seleccionado" @click="aceptar">
              <i class="fas fa-check me-1"></i>Aceptar
            </button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger mt-3">
      <i class="fas fa-exclamation-triangle me-2"></i>{{ error }}
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
      error: null
    };
  },
  mounted() {
    this.buscar();
  },
  methods: {
    buscar() {
      this.error = null;
      fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify({
          eRequest: 'catalog.scian.search',
          params: { descripcion: this.descripcion }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.success) {
            this.resultados = json.data;
            // Si la búsqueda cambia, deselecciona
            this.seleccionado = null;
          } else {
            this.error = json.error || 'Error al buscar.';
            this.resultados = [];
          }
        })
        .catch(err => {
          this.error = err.message || 'Error de red.';
          this.resultados = [];
        });
    },
    seleccionar(row) {
      this.seleccionado = row;
    },
    aceptar() {
      if (this.seleccionado) {
        // Aquí puedes emitir un evento, redirigir, o guardar la selección
        // Por ejemplo, emitir evento:
        this.$emit('scian-selected', this.seleccionado);
        // O mostrar un mensaje
        alert(`SCIAN seleccionado: ${this.seleccionado.codigo_scian} - ${this.seleccionado.descripcion}`);
      }
    }
  }
};
</script>

<style scoped>
.busqueda-scian-page {
  max-width: 950px;
  margin: 0 auto;
  padding: 2rem 1rem;
  background: white;
  min-height: 100vh;
  font-family: var(--font-municipal);
}

/* Municipal Header */
.municipal-header {
  background: linear-gradient(135deg, var(--municipal-primary) 0%, var(--municipal-secondary) 100%);
  color: white;
  padding: 1.5rem 2rem;
  border-radius: var(--radius-lg);
  margin-bottom: 2rem;
  display: flex;
  align-items: center;
  box-shadow: var(--shadow-md);
}

.municipal-header h2 {
  margin: 0;
  font-weight: var(--font-weight-bold);
  font-size: 1.75rem;
}

/* Municipal Cards */
.municipal-card {
  background: white;
  border: none;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  border-top: 4px solid var(--municipal-primary);
  transition: var(--transition-normal);
}

.municipal-card:hover {
  box-shadow: var(--shadow-md);
  transform: translateY(-2px);
}

/* Municipal Button Groups */
.municipal-group-btn {
  box-shadow: var(--shadow-sm);
  border-radius: var(--radius-md);
}

.municipal-group-btn .btn {
  border: 1px solid var(--municipal-primary);
  font-weight: var(--font-weight-bold);
  transition: var(--transition-normal);
  font-family: var(--font-municipal);
}

.municipal-group-btn .btn-outline-primary {
  color: var(--municipal-primary);
  background: white;
}

.municipal-group-btn .btn-outline-primary:hover,
.municipal-group-btn .btn-outline-primary:focus {
  background: var(--municipal-primary);
  border-color: var(--municipal-primary);
  color: white;
  box-shadow: 0 0 0 0.2rem rgba(234, 130, 21, 0.25);
}

.municipal-group-btn .btn-outline-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Municipal Tables */
.municipal-table {
  background: white;
  border-radius: var(--radius-md);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
}

.municipal-table-header {
  background: linear-gradient(135deg, var(--municipal-primary) 0%, var(--municipal-secondary) 100%);
  color: white;
}

.municipal-table-header th {
  border: none;
  font-weight: var(--font-weight-bold);
  padding: 1rem;
  font-family: var(--font-municipal);
}

.municipal-table td {
  border: none;
  border-bottom: 1px solid var(--slate-100);
  padding: 0.75rem 1rem;
  transition: var(--transition-normal);
}

.municipal-table tr:hover td {
  background-color: var(--slate-50);
}

.municipal-table tr:last-child td {
  border-bottom: none;
}

.municipal-selected td {
  background-color: rgba(234, 130, 21, 0.1) !important;
  border-left: 4px solid var(--municipal-primary) !important;
}

/* Form Controls */
.form-control {
  border: 2px solid var(--slate-200);
  border-radius: var(--radius-md);
  padding: 0.75rem 1rem;
  font-family: var(--font-municipal);
  transition: var(--transition-normal);
}

.form-control:focus {
  border-color: var(--municipal-primary);
  box-shadow: 0 0 0 0.2rem rgba(234, 130, 21, 0.25);
  outline: none;
}

.form-label {
  font-weight: var(--font-weight-bold);
  color: var(--slate-700);
  font-family: var(--font-municipal);
}

/* Badges */
.badge {
  font-family: var(--font-municipal);
  font-weight: var(--font-weight-bold);
  font-size: 0.75rem;
  padding: 0.25rem 0.5rem;
}

.bg-info {
  background-color: var(--municipal-info) !important;
  color: white !important;
}

.bg-primary {
  background-color: var(--municipal-primary) !important;
}

.bg-success {
  background-color: var(--municipal-success) !important;
}

.bg-warning {
  background-color: var(--municipal-warning) !important;
}

.bg-secondary {
  background-color: var(--slate-500) !important;
}

.text-dark {
  color: var(--slate-800) !important;
}

/* Text Colors */
.text-muted {
  color: var(--slate-500) !important;
}

/* Alert Styling */
.alert {
  border: none;
  border-radius: var(--radius-md);
  font-family: var(--font-municipal);
  font-weight: var(--font-weight-bold);
}

.alert-danger {
  background-color: rgba(233, 108, 176, 0.1);
  color: var(--municipal-danger);
  border-left: 4px solid var(--municipal-danger);
}

/* Responsive */
@media (max-width: 768px) {
  .busqueda-scian-page {
    padding: 1rem 0.5rem;
  }

  .municipal-header {
    padding: 1rem;
    text-align: center;
  }

  .municipal-header h2 {
    font-size: 1.5rem;
  }

  .table-responsive {
    font-size: 0.85rem;
    max-height: 350px !important;
  }

  .btn-group {
    width: 100%;
  }

  .btn-group .btn {
    border-radius: var(--radius-md) !important;
  }
}

/* Scrollbar for table */
.table-responsive::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

.table-responsive::-webkit-scrollbar-track {
  background: var(--slate-100);
}

.table-responsive::-webkit-scrollbar-thumb {
  background: var(--municipal-primary);
  border-radius: var(--radius-full);
}

.table-responsive::-webkit-scrollbar-thumb:hover {
  background: var(--municipal-secondary);
}
</style>
