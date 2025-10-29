<template>
  <div class="actualiza-cont-page">
    <h1>Actualización de Contratos de Desarrollo Social</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Actualiza Contratos</li>
      </ol>
    </nav>
    <div class="row">
      <div class="col-md-5">
        <h3>Diferencias (Contratos sin Catálogo)</h3>
        <button class="btn btn-secondary mb-2" @click="getDiferencias">Buscar Diferencias</button>
        <table class="table table-sm table-bordered">
          <thead>
            <tr>
              <th>Colonia</th>
              <th>Calle</th>
              <th>Contratos</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in diferencias" :key="row.colonia + '-' + row.calle">
              <td>{{ row.colonia }}</td>
              <td>{{ row.calle }}</td>
              <td>{{ row.contratos }}</td>
            </tr>
            <tr v-if="diferencias.length === 0">
              <td colspan="3" class="text-center">Sin diferencias encontradas</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="col-md-7">
        <h3>Totales de Actualización</h3>
        <button class="btn btn-primary mb-2" @click="actualizarContratos" :disabled="loading">Actualizar Contratos</button>
        <div v-if="loading" class="alert alert-info">Procesando actualización...</div>
        <table class="table table-bordered">
          <tbody>
            <tr>
              <th>Adicionados</th>
              <td>{{ totales.adicionados }}</td>
            </tr>
            <tr>
              <th>Modificados</th>
              <td>{{ totales.modificados }}</td>
            </tr>
            <tr>
              <th>Inconsistencias</th>
              <td>{{ totales.inconsistencias }}</td>
            </tr>
            <tr>
              <th>Total General</th>
              <td>{{ totales.total }}</td>
            </tr>
            <tr>
              <th>Programa Descuentos</th>
              <td>{{ totales.descuentos }}</td>
            </tr>
          </tbody>
        </table>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="success" class="alert alert-success">Actualización completada correctamente.</div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ActualizaContPage',
  data() {
    return {
      diferencias: [],
      totales: {
        adicionados: 0,
        modificados: 0,
        inconsistencias: 0,
        total: 0,
        descuentos: 0
      },
      loading: false,
      error: '',
      success: false
    };
  },
  methods: {
    async getDiferencias() {
      this.loading = true;
      this.error = '';
      this.success = false;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getDiferencias',
          params: {}
        });
        if (res.data.success) {
          this.diferencias = res.data.data;
        } else {
          this.error = res.data.message || 'Error al obtener diferencias';
        }
      } catch (e) {
        this.error = e.message;
      }
      this.loading = false;
    },
    async actualizarContratos() {
      this.loading = true;
      this.error = '';
      this.success = false;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'actualizarContratos',
          params: { user_id: this.$store.state.user.id }
        });
        if (res.data.success && res.data.data && res.data.data.length > 0) {
          const row = res.data.data[0];
          this.totales.adicionados = row.adicionados;
          this.totales.modificados = row.modificados;
          this.totales.inconsistencias = row.inconsistencias;
          this.totales.total = row.total;
          this.totales.descuentos = row.descuentos;
          this.success = true;
        } else {
          this.error = res.data.message || 'Error en la actualización';
        }
      } catch (e) {
        this.error = e.message;
      }
      this.loading = false;
    }
  },
  mounted() {
    this.getDiferencias();
  }
};
</script>

<style scoped>
.actualiza-cont-page {
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  margin-bottom: 1rem;
}
</style>
