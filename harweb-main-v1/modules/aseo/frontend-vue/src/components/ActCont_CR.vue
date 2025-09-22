<template>
  <div class="actcont-cr-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Actualiza Contratos en Cantidad de Recolección</li>
      </ol>
    </nav>
    <div class="card mt-3">
      <div class="card-header">
        <h3>Actualiza Contratos en Cantidad de Recolección</h3>
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="form-group">
            <label for="tipoAseo">Tipo de Aseo</label>
            <select v-model="selectedTipoAseo" id="tipoAseo" class="form-control" required>
              <option v-for="option in tipoAseoOptions" :key="option.value" :value="option.value">
                {{ option.label }}
              </option>
            </select>
          </div>
          <button type="submit" class="btn btn-primary mt-3">Consultar Contratos</button>
        </form>
        <div v-if="loading" class="mt-3">
          <span class="spinner-border spinner-border-sm"></span> Cargando...
        </div>
        <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
        <div v-if="results.length" class="mt-4">
          <h5>Resultados de Contratos</h5>
          <table class="table table-bordered table-sm">
            <thead>
              <tr>
                <th v-for="col in columns" :key="col">{{ col }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in filteredResults" :key="row.id || row[columns[0]]">
                <td v-for="col in columns" :key="col">{{ row[col] }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-else-if="!loading && submitted" class="alert alert-info mt-3">
          No se encontraron contratos para el tipo seleccionado.
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ActContCRPage',
  data() {
    return {
      tipoAseoOptions: [
        { value: 9, label: '9 .- Zona Centro' },
        { value: 8, label: '8 .- Ordinarios' },
        { value: 4, label: '4 .- Hospitalarios' }
      ],
      selectedTipoAseo: 9,
      results: [],
      columns: [],
      loading: false,
      error: '',
      submitted: false
    };
  },
  computed: {
    filteredResults() {
      // Filtrar por tipoAseo si la columna existe
      if (!this.results.length) return [];
      const colTipo = Object.keys(this.results[0]).find(
        k => k.toLowerCase().includes('tipo') || k.toLowerCase().includes('aseo')
      );
      if (colTipo) {
        return this.results.filter(r => r[colTipo] == this.selectedTipoAseo);
      }
      return this.results;
    }
  },
  methods: {
    async onSubmit() {
      this.loading = true;
      this.error = '';
      this.results = [];
      this.columns = [];
      this.submitted = true;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'get_ta_catalog',
            params: {}
          })
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.results = data.eResponse.data || [];
          if (this.results.length) {
            this.columns = Object.keys(this.results[0]);
          }
        } else {
          this.error = data.eResponse ? data.eResponse.message : 'Error desconocido';
        }
      } catch (err) {
        this.error = err.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    }
  },
  mounted() {
    // Set default selection
    this.selectedTipoAseo = 9;
  }
};
</script>

<style scoped>
.actcont-cr-page {
  max-width: 600px;
  margin: 0 auto;
}
.card-header h3 {
  margin: 0;
}
</style>
