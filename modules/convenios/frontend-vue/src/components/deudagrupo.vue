<template>
  <div class="deuda-grupo-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Deuda de Contratos con Recargos</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-header">Filtros de búsqueda</div>
      <div class="card-body row g-3 align-items-center">
        <div class="col-auto">
          <label for="axo" class="col-form-label">Año de la Obra</label>
        </div>
        <div class="col-auto">
          <input type="number" min="1993" max="2099" v-model="filters.axo" class="form-control" id="axo" />
        </div>
        <div class="col-auto">
          <label for="fecha_recargo" class="col-form-label">Fecha para calcular recargos</label>
        </div>
        <div class="col-auto">
          <input type="date" v-model="filters.fecha_recargo" class="form-control" id="fecha_recargo" />
        </div>
        <div class="col-auto">
          <button class="btn btn-primary" @click="buscar"><i class="bi bi-search"></i> Buscar</button>
        </div>
        <div class="col-auto">
          <button class="btn btn-success" @click="exportar"><i class="bi bi-file-earmark-excel"></i> Exportar</button>
        </div>
      </div>
    </div>
    <div class="card">
      <div class="card-header">Resultados</div>
      <div class="card-body p-0">
        <table class="table table-striped table-hover table-bordered mb-0">
          <thead>
            <tr>
              <th>Control</th>
              <th>Obra</th>
              <th>Colonia</th>
              <th>Calle</th>
              <th>Folio</th>
              <th>Nombre</th>
              <th>Pago total</th>
              <th>No. Pagos</th>
              <th>Clave descuento</th>
              <th>Total Pagos</th>
              <th>Deuda</th>
              <th>Recargos</th>
              <th>Total</th>
              <th>Fecha vencimiento</th>
              <th>Descripción de Calle</th>
              <th>Descripción de Colonia</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in rows" :key="row.id_convenio">
              <td>{{ row.id_convenio }}</td>
              <td>{{ row.obra }}</td>
              <td>{{ row.colonia }}</td>
              <td>{{ row.calle }}</td>
              <td>{{ row.folio }}</td>
              <td>{{ row.nombre }}</td>
              <td>{{ formatCurrency(row.pago_total) }}</td>
              <td>{{ row.numpagos }}</td>
              <td>{{ row.cve_descuento }}</td>
              <td>{{ formatCurrency(row.pagos) }}</td>
              <td>{{ formatCurrency(row.deuda) }}</td>
              <td>{{ formatCurrency(row.recargos) }}</td>
              <td>{{ formatCurrency(row.total) }}</td>
              <td>{{ formatDate(row.fecha_vencimiento) }}</td>
              <td>{{ row.desc_calle }}</td>
              <td>{{ row.descripcion }}</td>
            </tr>
            <tr v-if="rows.length === 0">
              <td colspan="16" class="text-center">No hay resultados</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="loading" class="text-center my-3">
      <span class="spinner-border" role="status"></span> Cargando...
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'DeudaGrupoPage',
  data() {
    return {
      filters: {
        axo: new Date().getFullYear(),
        fecha_recargo: new Date().toISOString().substr(0, 10)
      },
      rows: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    buscar() {
      this.loading = true;
      this.error = '';
      fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          action: 'getDeudaGrupo',
          params: this.filters
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.success) {
            this.rows = json.data;
          } else {
            this.error = json.message || 'Error al consultar datos';
          }
        })
        .catch(err => {
          this.error = err.message;
        })
        .finally(() => {
          this.loading = false;
        });
    },
    exportar() {
      this.loading = true;
      this.error = '';
      fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          action: 'exportDeudaGrupo',
          params: this.filters
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.success && json.data && json.data.exported) {
            // Aquí podrías descargar el archivo generado si implementas esa lógica en backend
            alert('Exportación realizada.');
          } else {
            this.error = json.message || 'Error al exportar datos';
          }
        })
        .catch(err => {
          this.error = err.message;
        })
        .finally(() => {
          this.loading = false;
        });
    },
    formatCurrency(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    },
    formatDate(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString('es-MX');
    }
  },
  mounted() {
    this.buscar();
  }
};
</script>

<style scoped>
.deuda-grupo-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.card {
  margin-bottom: 1rem;
}
</style>
