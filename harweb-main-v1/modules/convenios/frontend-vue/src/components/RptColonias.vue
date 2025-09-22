<template>
  <div class="rpt-colonias-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Colonias</li>
      </ol>
    </nav>
    <div class="card shadow">
      <div class="card-header bg-white d-flex align-items-center">
        <img :src="logoSrc" alt="Logo" style="height: 48px; margin-right: 16px;" />
        <div>
          <h5 class="mb-0">MUNICIPIO DE GUADALAJARA</h5>
          <div class="text-muted">DIRECCION DE INGRESOS</div>
          <h6 class="mt-2 font-weight-bold">CATALOGO  DE  COLONIAS</h6>
        </div>
      </div>
      <div class="card-body">
        <div v-if="loading" class="text-center my-5">
          <span class="spinner-border" role="status"></span>
          <span class="ml-2">Cargando colonias...</span>
        </div>
        <div v-else>
          <table class="table table-bordered table-sm">
            <thead class="thead-light">
              <tr>
                <th style="width: 8%">COLONIA</th>
                <th style="width: 38%">DESCRIPCIÓN</th>
                <th style="width: 8%">REC.</th>
                <th style="width: 8%">ID ZONA</th>
                <th style="width: 38%">ZONA</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="colonia in colonias" :key="colonia.colonia">
                <td class="text-center">{{ colonia.colonia }}</td>
                <td>{{ colonia.descripcion }}</td>
                <td class="text-center">{{ colonia.id_rec }}</td>
                <td class="text-center">{{ colonia.id_zona }}</td>
                <td>{{ colonia.zona }}</td>
              </tr>
            </tbody>
          </table>
          <div class="mt-3 d-flex justify-content-between align-items-center">
            <div>
              <strong>TOTAL DE COLONIAS:</strong> {{ total }}
            </div>
            <div class="text-muted small">
              <span>RptColonias</span> |
              <span>{{ currentDate }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptColoniasPage',
  data() {
    return {
      colonias: [],
      total: 0,
      loading: true,
      logoSrc: require('@/assets/logo_guadalajara.png'), // Cambia la ruta según tu proyecto
      currentDate: ''
    };
  },
  methods: {
    async fetchColonias() {
      this.loading = true;
      try {
        const response = await this.$axios.post('/api/execute', {
          eRequest: 'RptColoniasList',
          params: {}
        });
        if (response.data.eResponse === 'OK') {
          this.colonias = response.data.data.colonias;
          this.total = response.data.data.total;
        } else {
          this.$bvToast.toast(response.data.message || 'Error al cargar colonias', {
            title: 'Error',
            variant: 'danger',
            solid: true
          });
        }
      } catch (e) {
        this.$bvToast.toast('Error de comunicación con el servidor', {
          title: 'Error',
          variant: 'danger',
          solid: true
        });
      } finally {
        this.loading = false;
      }
    },
    setCurrentDate() {
      const now = new Date();
      this.currentDate = now.toLocaleString();
    }
  },
  mounted() {
    this.setCurrentDate();
    this.fetchColonias();
  }
};
</script>

<style scoped>
.rpt-colonias-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card-header {
  background: #fff;
  border-bottom: 1px solid #eee;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
