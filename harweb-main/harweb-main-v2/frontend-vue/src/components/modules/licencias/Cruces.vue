<template>
  <div class="municipal-form-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Cruces de Calles</li>
      </ol>
    </nav>
    <h2>Seleccione la(s) Calles de Cruce</h2>
    <div class="row mb-4">
      <div class="col-md-6">
        <label for="calle1-search" class="form-label"><strong>Entre la calle</strong></label>
        <input
          id="calle1-search"
          v-model="calle1Search"
          @input="onCalle1Search"
          class="form-control"
          placeholder="Localizar calle..."
          style="text-transform:uppercase"
        />
        <div class="municipal-search-table mt-2">
          <table class="table table-sm">
            <thead>
              <tr>
                <th>CALLE</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="row in calle1Results"
                :key="row.cvecalle"
                :class="{ 'municipal-selected': row.cvecalle === selectedCalle1 }"
                @click="selectCalle1(row.cvecalle)"
              >
                <td>{{ row.calle }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="col-md-6">
        <label for="calle2-search" class="form-label"><strong>y la calle</strong></label>
        <input
          id="calle2-search"
          v-model="calle2Search"
          @input="onCalle2Search"
          class="form-control"
          placeholder="Localizar calle..."
          style="text-transform:uppercase"
        />
        <div class="municipal-search-table mt-2">
          <table class="table table-sm">
            <thead>
              <tr>
                <th>CALLE</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="row in calle2Results"
                :key="row.cvecalle"
                :class="{ 'municipal-selected': row.cvecalle === selectedCalle2 }"
                @click="selectCalle2(row.cvecalle)"
              >
                <td>{{ row.calle }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <div class="d-flex justify-content-end">
      <button class="btn-municipal-secondary me-2" @click="onCancel">Cancelar</button>
      <button class="btn-municipal-primary" @click="onAccept">Aceptar</button>
    </div>
    <div v-if="error" class="municipal-alert-danger mt-3">{{ error }}</div>
    <div v-if="result" class="municipal-alert-success mt-3">
      <strong>Calles seleccionadas:</strong><br>
      Calle 1: {{ result.calle1 ? result.calle1.calle : 'N/A' }}<br>
      Calle 2: {{ result.calle2 ? result.calle2.calle : 'N/A' }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'CrucesForm',
  data() {
    return {
      calle1Search: '',
      calle2Search: '',
      calle1Results: [],
      calle2Results: [],
      selectedCalle1: null,
      selectedCalle2: null,
      error: '',
      result: null
    };
  },
  methods: {
    async onCalle1Search() {
      this.selectedCalle1 = null;
      if (this.calle1Search.length < 1) {
        this.calle1Results = [];
        return;
      }
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: 'cruces_search_calle1',
          params: { search: this.calle1Search }
        });
        this.calle1Results = resp.data.eResponse.data || [];
      } catch (e) {
        this.error = 'Error al buscar calles (1)';
      }
    },
    async onCalle2Search() {
      this.selectedCalle2 = null;
      if (this.calle2Search.length < 1) {
        this.calle2Results = [];
        return;
      }
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: 'cruces_search_calle2',
          params: { search: this.calle2Search }
        });
        this.calle2Results = resp.data.eResponse.data || [];
      } catch (e) {
        this.error = 'Error al buscar calles (2)';
      }
    },
    selectCalle1(cvecalle) {
      this.selectedCalle1 = cvecalle;
    },
    selectCalle2(cvecalle) {
      this.selectedCalle2 = cvecalle;
    },
    async onAccept() {
      if (!this.selectedCalle1 && !this.selectedCalle2) {
        this.error = 'Debe seleccionar al menos una calle en cada lista.';
        return;
      }
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: 'cruces_localiza_calle',
          params: {
            cvecalle1: this.selectedCalle1 || 0,
            cvecalle2: this.selectedCalle2 || 0
          }
        });
        const data = resp.data.eResponse.data || [];
        // The stored procedure returns both calles in a single result set
        this.result = {
          calle1: data.find(r => r.tipo === 1) || null,
          calle2: data.find(r => r.tipo === 2) || null
        };
        this.error = '';
      } catch (e) {
        this.error = 'Error al localizar calles seleccionadas.';
      }
    },
    onCancel() {
      this.calle1Search = '';
      this.calle2Search = '';
      this.calle1Results = [];
      this.calle2Results = [];
      this.selectedCalle1 = null;
      this.selectedCalle2 = null;
      this.result = null;
      this.error = '';
    }
  }
};
</script>

