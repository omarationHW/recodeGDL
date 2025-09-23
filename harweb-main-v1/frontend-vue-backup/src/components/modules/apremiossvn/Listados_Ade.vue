<template>
  <div class="listados-ade">
    <h1>Listado de Adeudos</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active">Listado de Adeudos</li>
      </ol>
    </nav>
    <div class="form-section">
      <label>Aplicación:</label>
      <select v-model="form.aplicacion">
        <option value="mercados">Mercados</option>
        <option value="aseo">Aseo</option>
        <option value="publicos">Estacionamientos Públicos</option>
        <option value="exclusivos">Estacionamientos Exclusivos</option>
        <option value="infracciones">Estacionómetros</option>
      </select>
    </div>
    <component :is="currentForm" :form.sync="form" @submit="onSubmit" />
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="result && result.data">
      <h2>Resultados</h2>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th v-for="(v, k) in result.data[0]" :key="k">{{ k }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in result.data" :key="idx">
            <td v-for="(v, k) in row" :key="k">{{ v }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import MercadosForm from './ListadosAdeMercadosForm.vue';
import AseoForm from './ListadosAdeAseoForm.vue';
import PublicosForm from './ListadosAdePublicosForm.vue';
import ExclusivosForm from './ListadosAdeExclusivosForm.vue';
import InfraccionesForm from './ListadosAdeInfraccionesForm.vue';

export default {
  name: 'ListadosAde',
  components: {
    MercadosForm,
    AseoForm,
    PublicosForm,
    ExclusivosForm,
    InfraccionesForm
  },
  data() {
    return {
      form: {
        aplicacion: 'mercados',
        // ...campos específicos de cada formulario
      },
      loading: false,
      error: '',
      result: null
    };
  },
  computed: {
    currentForm() {
      switch (this.form.aplicacion) {
        case 'mercados': return 'MercadosForm';
        case 'aseo': return 'AseoForm';
        case 'publicos': return 'PublicosForm';
        case 'exclusivos': return 'ExclusivosForm';
        case 'infracciones': return 'InfraccionesForm';
        default: return 'div';
      }
    }
  },
  methods: {
    async onSubmit(params) {
      this.loading = true;
      this.error = '';
      this.result = null;
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: this.form.aplicacion,
            params
          }
        });
        this.result = resp.data.eResponse;
      } catch (e) {
        this.error = e.response?.data?.eResponse?.error || e.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.listados-ade { max-width: 900px; margin: 0 auto; }
.form-section { margin-bottom: 1em; }
.loading { color: #888; }
.error { color: red; }
</style>
