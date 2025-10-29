<template>
  <div class="lista-diferencias-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Listado de Diferencias</li>
      </ol>
    </nav>
    <h1 class="mb-4">Listado de Diferencias de Transmisiones Patrimoniales</h1>
    <form @submit.prevent="fetchDiferencias" class="mb-4">
      <div class="row">
        <div class="col-md-3">
          <label>Fecha Desde</label>
          <input type="date" v-model="filters.fecha1" class="form-control" required />
        </div>
        <div class="col-md-3">
          <label>Fecha Hasta</label>
          <input type="date" v-model="filters.fecha2" class="form-control" required />
        </div>
        <div class="col-md-3">
          <label>Vigencia</label>
          <select v-model="filters.vigencia" class="form-control">
            <option value="">Todas</option>
            <option value="V">Vigentes</option>
            <option value="P">Pagadas</option>
            <option value="C">Canceladas</option>
          </select>
        </div>
        <div class="col-md-3 d-flex align-items-end">
          <button type="submit" class="btn btn-primary mr-2">Buscar</button>
          <button type="button" class="btn btn-success" @click="exportExcel" :disabled="loading">Exportar Excel</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="diferencias.length > 0">
      <table class="table table-bordered table-sm table-hover">
        <thead>
          <tr>
            <th>Folio Glosa</th>
            <th>Cuenta</th>
            <th>FolioT</th>
            <th>Avalúo</th>
            <th>Perito</th>
            <th>Fecha Alta</th>
            <th>Vigencia</th>
            <th>Recaud</th>
            <th>Urbrus</th>
            <th>Total</th>
            <th>Depto</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in diferencias" :key="row.id">
            <td>{{ row.folio_glosa }}</td>
            <td>{{ row.cuenta }}</td>
            <td>{{ row.foliot }}</td>
            <td>{{ row.avaluo }}</td>
            <td>{{ row.noperito }}</td>
            <td>{{ row.fecha_alta }}</td>
            <td>{{ row.vigencia }}</td>
            <td>{{ row.recaud }}</td>
            <td>{{ row.urbrus }}</td>
            <td>{{ row.total }}</td>
            <td>{{ row.nombredepto }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <strong>Total de registros:</strong> {{ diferencias.length }}
        <strong class="ml-4">Suma total:</strong> {{ sumaTotal | currency }}
      </div>
    </div>
    <div v-else-if="!loading && !error">
      <div class="alert alert-warning">No se encontraron resultados.</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ListaDiferenciasPage',
  data() {
    return {
      filters: {
        fecha1: '',
        fecha2: '',
        vigencia: ''
      },
      diferencias: [],
      loading: false,
      error: null
    };
  },
  computed: {
    sumaTotal() {
      return this.diferencias.reduce((sum, row) => sum + (parseFloat(row.total) || 0), 0);
    }
  },
  methods: {
    async fetchDiferencias() {
      this.loading = true;
      this.error = null;
      this.diferencias = [];
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'getListaDiferencias',
              params: {
                fecha1: this.filters.fecha1,
                fecha2: this.filters.fecha2,
                vigencia: this.filters.vigencia
              }
            }
          })
        });
        const json = await response.json();
        if (json.eResponse && json.eResponse.success) {
          this.diferencias = json.eResponse.data;
        } else {
          this.error = json.eResponse && json.eResponse.error ? json.eResponse.error : 'Error desconocido';
        }
      } catch (err) {
        this.error = err.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    },
    async exportExcel() {
      this.loading = true;
      this.error = null;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'exportListaDiferenciasExcel',
              params: {
                fecha1: this.filters.fecha1,
                fecha2: this.filters.fecha2,
                vigencia: this.filters.vigencia
              }
            }
          })
        });
        const json = await response.json();
        if (json.eResponse && json.eResponse.success) {
          // Aquí deberías descargar el archivo Excel generado
          // Por simplicidad, mostramos los datos en consola
          console.log('Datos para Excel:', json.eResponse.data);
          alert('Exportación simulada. Ver consola para datos.');
        } else {
          this.error = json.eResponse && json.eResponse.error ? json.eResponse.error : 'Error desconocido';
        }
      } catch (err) {
        this.error = err.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    }
  },
  filters: {
    currency(value) {
      if (!value) return '$0.00';
      return '$' + parseFloat(value).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  },
  mounted() {
    // Opcional: cargar por defecto últimos 30 días
    const today = new Date();
    const prior = new Date();
    prior.setDate(today.getDate() - 30);
    this.filters.fecha1 = prior.toISOString().substr(0, 10);
    this.filters.fecha2 = today.toISOString().substr(0, 10);
    this.fetchDiferencias();
  }
};
</script>

<style scoped>
.lista-diferencias-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
