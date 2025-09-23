<template>
  <div class="busca-registro-modulo">
    <h1>Buscar Registro a Conveniar</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Buscar Registro</li>
      </ol>
    </nav>
    <div class="form-group">
      <label for="tipo">Tipo de Registro</label>
      <select v-model="tipo" class="form-control" id="tipo">
        <option value="multas">Multas Municipales y Federales</option>
        <option value="lic_construccion">Lic. Construcción</option>
        <option value="predial">Predial</option>
        <option value="lic_giros">Licencias Giros</option>
        <option value="mercados">Mercados</option>
        <option value="cementerios">Cementerios</option>
        <option value="aseo">Aseo Contratado</option>
        <option value="obras_publicas">Obras Públicas</option>
        <option value="anuncios">Licencias Anuncios</option>
        <option value="energia">Energía Eléctrica</option>
        <option value="estacionamiento_publico">Estacionamiento Público</option>
        <option value="estacionamiento_exclusivo">Estacionamiento Exclusivo</option>
      </select>
    </div>
    <form @submit.prevent="buscarRegistro">
      <component :is="currentFormComponent" v-model="form" :catalogos="catalogos" />
      <button type="submit" class="btn btn-primary mt-3">Buscar</button>
    </form>
    <div v-if="loading" class="mt-3">Buscando...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="resultados && resultados.length" class="mt-3">
      <h3>Resultados</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Modulo</th>
            <th>Control</th>
            <th>Registro</th>
            <th>Nombre</th>
            <th>Ubicación</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="r in resultados" :key="r.control">
            <td>{{ r.modulo || '-' }}</td>
            <td>{{ r.control }}</td>
            <td>{{ r.calcregistro }}</td>
            <td>{{ r.nombre }}</td>
            <td>{{ r.ubicacion }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import MultasForm from './forms/MultasForm.vue';
import LicConstruccionForm from './forms/LicConstruccionForm.vue';
import PredialForm from './forms/PredialForm.vue';
import LicGirosForm from './forms/LicGirosForm.vue';
import MercadosForm from './forms/MercadosForm.vue';
import CementeriosForm from './forms/CementeriosForm.vue';
import AseoForm from './forms/AseoForm.vue';
import ObrasPublicasForm from './forms/ObrasPublicasForm.vue';
import AnunciosForm from './forms/AnunciosForm.vue';
import EnergiaForm from './forms/EnergiaForm.vue';
import EstacionamientoPublicoForm from './forms/EstacionamientoPublicoForm.vue';
import EstacionamientoExclusivoForm from './forms/EstacionamientoExclusivoForm.vue';

export default {
  name: 'BuscaRegistroModulo',
  components: {
    MultasForm,
    LicConstruccionForm,
    PredialForm,
    LicGirosForm,
    MercadosForm,
    CementeriosForm,
    AseoForm,
    ObrasPublicasForm,
    AnunciosForm,
    EnergiaForm,
    EstacionamientoPublicoForm,
    EstacionamientoExclusivoForm
  },
  data() {
    return {
      tipo: 'multas',
      form: {},
      resultados: [],
      loading: false,
      error: '',
      catalogos: {
        mercados: [],
        aseoTipos: [],
        dependencias: []
      }
    };
  },
  computed: {
    currentFormComponent() {
      switch (this.tipo) {
        case 'multas': return 'MultasForm';
        case 'lic_construccion': return 'LicConstruccionForm';
        case 'predial': return 'PredialForm';
        case 'lic_giros': return 'LicGirosForm';
        case 'mercados': return 'MercadosForm';
        case 'cementerios': return 'CementeriosForm';
        case 'aseo': return 'AseoForm';
        case 'obras_publicas': return 'ObrasPublicasForm';
        case 'anuncios': return 'AnunciosForm';
        case 'energia': return 'EnergiaForm';
        case 'estacionamiento_publico': return 'EstacionamientoPublicoForm';
        case 'estacionamiento_exclusivo': return 'EstacionamientoExclusivoForm';
        default: return 'MultasForm';
      }
    }
  },
  watch: {
    tipo(newTipo) {
      this.form = {};
      this.resultados = [];
      this.error = '';
      this.loadCatalogos(newTipo);
    }
  },
  created() {
    this.loadCatalogos(this.tipo);
  },
  methods: {
    async loadCatalogos(tipo) {
      // Carga catálogos según tipo
      if (tipo === 'mercados' || tipo === 'energia') {
        const res = await this.$axios.post('/api/execute', { eRequest: { action: 'getMercados' } });
        this.catalogos.mercados = res.data.eResponse.data;
      }
      if (tipo === 'aseo') {
        const res = await this.$axios.post('/api/execute', { eRequest: { action: 'getAseoTipos' } });
        this.catalogos.aseoTipos = res.data.eResponse.data;
      }
      if (tipo === 'multas') {
        const res = await this.$axios.post('/api/execute', { eRequest: { action: 'getDependencias' } });
        this.catalogos.dependencias = res.data.eResponse.data;
      }
    },
    async buscarRegistro() {
      this.loading = true;
      this.error = '';
      this.resultados = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'buscarRegistro',
            tipo: this.tipo,
            form: this.form
          }
        });
        if (res.data.eResponse.success) {
          this.resultados = res.data.eResponse.data;
        } else {
          this.error = res.data.eResponse.message || 'No se encontraron resultados.';
        }
      } catch (e) {
        this.error = e.response?.data?.eResponse?.message || e.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.busca-registro-modulo {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
