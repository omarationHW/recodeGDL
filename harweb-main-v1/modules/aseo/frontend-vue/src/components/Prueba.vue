<template>
  <div class="prueba-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Prueba</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-header">Formulario Prueba</div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="row align-items-end">
            <div class="col-auto">
              <label for="parCtrol" class="form-label">Control Aseo</label>
              <input type="number" v-model.number="parCtrol" id="parCtrol" class="form-control" required />
            </div>
            <div class="col-auto">
              <button type="submit" class="btn btn-primary">Consultar</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="resultados.length" class="card mb-3">
      <div class="card-header">Resultados</div>
      <div class="card-body">
        <table class="table table-bordered table-sm">
          <thead>
            <tr>
              <th>#</th>
              <th>Tipo Aseo</th>
              <th>Número Contrato</th>
              <th>Licencia Giro (SP)</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, idx) in resultados" :key="idx">
              <td>{{ idx + 1 }}</td>
              <td>{{ row.tipo_aseo }}</td>
              <td>{{ row.num_contrato }}</td>
              <td>
                <button class="btn btn-outline-secondary btn-sm" @click="consultarLicenciaGiro(row)">
                  Consultar Licencia
                </button>
                <div v-if="row.licenciaGiro">
                  <span v-if="row.licenciaGiro.status_licencias === 0" class="text-success">
                    {{ row.licenciaGiro.concepto_licencias }}
                  </span>
                  <span v-else class="text-danger">
                    {{ row.licenciaGiro.concepto_licencias }}
                  </span>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="memoText" class="card">
      <div class="card-header">Memo</div>
      <div class="card-body">
        <textarea class="form-control" rows="8" v-model="memoText" readonly></textarea>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'PruebaPage',
  data() {
    return {
      parCtrol: '',
      resultados: [],
      loading: false,
      error: '',
      memoText: '',
    };
  },
  methods: {
    async onSubmit() {
      this.loading = true;
      this.error = '';
      this.resultados = [];
      this.memoText = '';
      try {
        const res = await axios.post('/api/execute', {
          action: 'prueba_query',
          params: { parCtrol: this.parCtrol }
        });
        if (res.data.status === 'success') {
          this.resultados = res.data.data.map(row => ({ ...row, licenciaGiro: null }));
          this.memoText = JSON.stringify(res.data.data, null, 2);
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = 'Error de red o servidor';
      } finally {
        this.loading = false;
      }
    },
    async consultarLicenciaGiro(row) {
      if (row.licenciaGiro) return; // Ya consultado
      try {
        const res = await axios.post('/api/execute', {
          action: 'licencia_giro_f1',
          params: { p_tipo: row.tipo_aseo, p_numero: row.num_contrato }
        });
        if (res.data.status === 'success' && res.data.data.length > 0) {
          this.$set(row, 'licenciaGiro', res.data.data[0]);
        } else {
          this.$set(row, 'licenciaGiro', { concepto_licencias: res.data.message, status_licencias: 1 });
        }
      } catch (e) {
        this.$set(row, 'licenciaGiro', { concepto_licencias: 'Error al consultar', status_licencias: 1 });
      }
    }
  }
};
</script>

<style scoped>
.prueba-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card {
  margin-bottom: 1rem;
}
</style>
