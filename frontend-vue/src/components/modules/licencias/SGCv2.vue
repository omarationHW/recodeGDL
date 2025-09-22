<template>
  <div class="sgcv2-formulario">
    <h1>Sistema de Gestión de Licencias (SGCv2)</h1>
    <nav class="breadcrumb">
      <router-link to="/">Inicio</router-link>
      <span v-if="currentPage">/ {{ currentPage }}</span>
    </nav>
    <component :is="currentComponent" :form-data="formData" @submit="handleSubmit" />
  </div>
</template>

<script>
import BuscarCuentaCatastral from './BuscarCuentaCatastral.vue';
import AltaTramiteLicencia from './AltaTramiteLicencia.vue';
import ConsultaLicencia from './ConsultaLicencia.vue';
import ConsultaAnuncio from './ConsultaAnuncio.vue';
import BloquearLicencia from './BloquearLicencia.vue';
import DesbloquearLicencia from './DesbloquearLicencia.vue';
import BajaLicencia from './BajaLicencia.vue';
import BajaAnuncio from './BajaAnuncio.vue';
import ConsultaTramite from './ConsultaTramite.vue';

export default {
  name: 'SGCv2Formulario',
  components: {
    BuscarCuentaCatastral,
    AltaTramiteLicencia,
    ConsultaLicencia,
    ConsultaAnuncio,
    BloquearLicencia,
    DesbloquearLicencia,
    BajaLicencia,
    BajaAnuncio,
    ConsultaTramite
  },
  data() {
    return {
      currentPage: '',
      currentComponent: null,
      formData: {},
    };
  },
  created() {
    this.routeToComponent();
  },
  watch: {
    '$route'(to) {
      this.routeToComponent();
    }
  },
  methods: {
    routeToComponent() {
      const page = this.$route.name;
      this.currentPage = page;
      switch (page) {
        case 'BuscarCuentaCatastral':
          this.currentComponent = 'BuscarCuentaCatastral';
          break;
        case 'AltaTramiteLicencia':
          this.currentComponent = 'AltaTramiteLicencia';
          break;
        case 'ConsultaLicencia':
          this.currentComponent = 'ConsultaLicencia';
          break;
        case 'ConsultaAnuncio':
          this.currentComponent = 'ConsultaAnuncio';
          break;
        case 'BloquearLicencia':
          this.currentComponent = 'BloquearLicencia';
          break;
        case 'DesbloquearLicencia':
          this.currentComponent = 'DesbloquearLicencia';
          break;
        case 'BajaLicencia':
          this.currentComponent = 'BajaLicencia';
          break;
        case 'BajaAnuncio':
          this.currentComponent = 'BajaAnuncio';
          break;
        case 'ConsultaTramite':
          this.currentComponent = 'ConsultaTramite';
          break;
        default:
          this.currentComponent = null;
      }
    },
    async handleSubmit(payload) {
      // Unificado: /api/execute
      const response = await this.$axios.post('/api/execute', {
        eRequest: payload
      });
      if (response.data && response.data.eResponse) {
        this.$emit('result', response.data.eResponse);
      } else {
        this.$emit('error', response.data);
      }
    }
  }
};
</script>

<style scoped>
.sgcv2-formulario {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.breadcrumb {
  margin-bottom: 1rem;
}
</style>
