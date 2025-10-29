<template>
  <div class="repdoc-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Requisitos Documentales</li>
      </ol>
    </nav>
    <h2>Requisitos Documentales para el Trámite de Licencia Municipal</h2>
    <div class="form-group">
      <label for="actividad">Actividad Solicitada:</label>
      <input v-model="actividad" id="actividad" class="form-control" placeholder="Teclee la actividad..." @keyup.enter="buscarGiros" />
    </div>
    <div class="form-group">
      <label for="giro">Giro:</label>
      <v-select
        :options="giros"
        label="descripcion"
        :reduce="g => g.id_giro"
        v-model="selectedGiro"
        @input="onGiroChange"
        placeholder="Seleccione un giro..."
      />
    </div>
    <div v-if="giroInfo">
      <div class="row mb-2">
        <div class="col"><strong>Tipo:</strong> {{ giroInfo.clasificacion }}</div>
        <div class="col"><strong>Giro:</strong> {{ giroInfo.descripcion }}</div>
      </div>
      <div class="mb-3">
        <strong>Descripción:</strong>
        <div class="border p-2 bg-light">{{ giroInfo.caracteristicas }}</div>
      </div>
    </div>
    <div v-if="requisitos && requisitos.length">
      <h4>Requisitos Solicitados</h4>
      <ul class="list-group mb-3">
        <li v-for="(req, idx) in requisitos" :key="req.req" class="list-group-item">
          <span class="badge bg-primary me-2">{{ idx + 1 }}</span>
          {{ req.descripcion }}
        </li>
      </ul>
    </div>
    <div class="d-flex gap-2">
      <button class="btn btn-primary" @click="imprimir">Imprimir</button>
      <button class="btn btn-secondary" @click="limpiar">Limpiar</button>
    </div>
  </div>
</template>

<script>
import vSelect from 'vue-select';
export default {
  name: 'RepdocPage',
  components: { vSelect },
  data() {
    return {
      actividad: '',
      giros: [],
      selectedGiro: null,
      giroInfo: null,
      requisitos: [],
      loading: false
    };
  },
  mounted() {
    this.fetchGiros();
  },
  methods: {
    async fetchGiros() {
      this.loading = true;
      const res = await this.$axios.post('/api/execute', {
        eRequest: { action: 'getGiros', params: { tipo: 'L' } }
      });
      this.giros = res.data.eResponse.data;
      this.loading = false;
    },
    async buscarGiros() {
      // Filtra giros por actividad
      if (this.actividad.trim() !== '') {
        this.giros = this.giros.filter(g => g.descripcion.toUpperCase().includes(this.actividad.trim().toUpperCase()));
      } else {
        await this.fetchGiros();
      }
    },
    async onGiroChange(id_giro) {
      if (!id_giro) return;
      // Carga info del giro
      const giroRes = await this.$axios.post('/api/execute', {
        eRequest: { action: 'getGiroById', params: { id_giro } }
      });
      this.giroInfo = giroRes.data.eResponse.data;
      // Carga requisitos
      const reqRes = await this.$axios.post('/api/execute', {
        eRequest: { action: 'getRequisitosByGiro', params: { id_giro } }
      });
      this.requisitos = reqRes.data.eResponse.data;
    },
    async imprimir() {
      if (!this.selectedGiro) {
        this.$toast.error('Seleccione un giro para imprimir');
        return;
      }
      // Puede ser descarga de PDF generado por backend o impresión directa
      // Aquí solo muestra print preview del contenido actual
      window.print();
    },
    limpiar() {
      this.actividad = '';
      this.selectedGiro = null;
      this.giroInfo = null;
      this.requisitos = [];
      this.fetchGiros();
    }
  }
};
</script>

<style scoped>
.repdoc-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
</style>
