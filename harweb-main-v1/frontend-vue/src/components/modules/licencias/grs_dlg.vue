<template>
  <div class="grs-dlg-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Búsqueda Rápida</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header">
        <h5>Búsqueda Rápida en Tabla</h5>
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="mb-3 row">
            <label class="col-sm-2 col-form-label">Tabla</label>
            <div class="col-sm-10">
              <input v-model="form.table" type="text" class="form-control" required placeholder="Nombre de la tabla" />
            </div>
          </div>
          <div class="mb-3 row">
            <label class="col-sm-2 col-form-label">Campo</label>
            <div class="col-sm-10">
              <input v-model="form.field" type="text" class="form-control" required placeholder="Nombre del campo" />
            </div>
          </div>
          <div class="mb-3 row">
            <label class="col-sm-2 col-form-label">Valor a buscar</label>
            <div class="col-sm-10">
              <input v-model="form.value" type="text" class="form-control" placeholder="Texto a buscar" @input="onInputChange" />
            </div>
          </div>
          <div class="mb-3 row">
            <label class="col-sm-2 col-form-label">Mayúsculas/Minúsculas</label>
            <div class="col-sm-10">
              <select v-model="form.case_insensitive" class="form-select">
                <option :value="true">No distinguir</option>
                <option :value="false">Distinguir</option>
              </select>
            </div>
          </div>
          <div class="mb-3 row">
            <label class="col-sm-2 col-form-label">Búsqueda parcial</label>
            <div class="col-sm-10">
              <select v-model="form.partial" class="form-select">
                <option :value="true">Sí</option>
                <option :value="false">No</option>
              </select>
            </div>
          </div>
          <div class="mb-3 row">
            <div class="col-sm-10 offset-sm-2">
              <button type="submit" class="btn btn-primary">Buscar</button>
              <button type="button" class="btn btn-secondary ms-2" @click="onReset">Limpiar</button>
            </div>
          </div>
        </form>
        <div v-if="loading" class="alert alert-info mt-3">Buscando...</div>
        <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
        <div v-if="results.length" class="mt-4">
          <h6>Resultados:</h6>
          <div class="table-responsive">
            <table class="table table-bordered table-sm">
              <thead>
                <tr>
                  <th v-for="(val, key) in results[0]" :key="key">{{ key }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in results" :key="idx">
                  <td v-for="(val, key) in row" :key="key">{{ val }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        <div v-else-if="!loading && !error && submitted" class="alert alert-warning mt-3">
          No se encontraron resultados.
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'GrsDlgPage',
  data() {
    return {
      form: {
        table: '',
        field: '',
        value: '',
        case_insensitive: true,
        partial: true
      },
      results: [],
      loading: false,
      error: '',
      submitted: false
    };
  },
  methods: {
    async onSubmit() {
      this.loading = true;
      this.error = '';
      this.results = [];
      this.submitted = true;
      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'grs_dlg_search',
            params: this.form
          })
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.results = data.eResponse.data;
        } else {
          this.error = data.eResponse ? data.eResponse.message : 'Error desconocido.';
        }
      } catch (err) {
        this.error = err.message || 'Error de red.';
      } finally {
        this.loading = false;
      }
    },
    onInputChange() {
      // Búsqueda en vivo (opcional)
      // this.onSubmit();
    },
    onReset() {
      this.form.value = '';
      this.results = [];
      this.error = '';
      this.submitted = false;
    }
  }
};
</script>

<style scoped>
.grs-dlg-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem 0;
}
</style>
