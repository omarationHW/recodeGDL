<template>
  <div class="rpt-servicios-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Servicios / Obra Pública</li>
      </ol>
    </nav>
    <div class="card shadow">
      <div class="card-header bg-white d-flex align-items-center">
        <img :src="logoSrc" alt="Logo" style="height: 50px; margin-right: 16px;" />
        <div>
          <div class="h5 mb-0">H. ATUNTAMIENTO DE GUADALAJARA</div>
          <div class="small">DIRECCIÓN DE INGRESOS</div>
          <div class="font-weight-bold mt-1" style="font-size: 1.2rem;">CATÁLOGO DE SERVICIOS / OBRA PÚBLICA</div>
        </div>
      </div>
      <div class="card-body">
        <div v-if="loading" class="text-center my-5">
          <span class="spinner-border"></span> Cargando servicios...
        </div>
        <div v-else>
          <table class="table table-bordered table-striped">
            <thead class="thead-light">
              <tr>
                <th class="text-center" style="width: 120px;">SERVICIO</th>
                <th class="text-center">DESCRIPCIÓN</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="servicio in servicios" :key="servicio.servicio">
                <td class="text-center">{{ servicio.servicio }}</td>
                <td>{{ servicio.descripcion }}</td>
              </tr>
            </tbody>
          </table>
          <div class="mt-4 d-flex justify-content-between align-items-center">
            <div class="font-weight-bold">
              TOTAL DE SERVICIOS: <span class="text-primary">{{ totalServicios }}</span>
            </div>
            <div class="text-muted small">
              Página generada el {{ fechaActual }}
            </div>
          </div>
        </div>
      </div>
      <div class="card-footer text-right small text-muted">
        RptServicios &mdash; Página {{ paginaActual }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptServiciosPage',
  data() {
    return {
      servicios: [],
      totalServicios: 0,
      loading: true,
      logoSrc: require('@/assets/logo_guadalajara.png'), // Debe existir el logo en assets
      paginaActual: 1,
      fechaActual: ''
    };
  },
  methods: {
    async fetchServicios() {
      this.loading = true;
      try {
        // Obtener todos los servicios
        const res = await this.$axios.post('/api/execute', {
          eRequest: 'RptServicios.getAll',
          params: {}
        });
        if (res.data.success) {
          this.servicios = res.data.data;
        } else {
          this.$toast.error('Error al cargar servicios: ' + (res.data.error || '')); 
        }
        // Obtener el total
        const resCount = await this.$axios.post('/api/execute', {
          eRequest: 'RptServicios.count',
          params: {}
        });
        if (resCount.data.success) {
          this.totalServicios = resCount.data.data;
        }
      } catch (err) {
        this.$toast.error('Error de conexión: ' + err.message);
      } finally {
        this.loading = false;
      }
    },
    setFechaActual() {
      const now = new Date();
      this.fechaActual = now.toLocaleString();
    }
  },
  mounted() {
    this.fetchServicios();
    this.setFechaActual();
  }
};
</script>

<style scoped>
.rpt-servicios-page {
  max-width: 900px;
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
