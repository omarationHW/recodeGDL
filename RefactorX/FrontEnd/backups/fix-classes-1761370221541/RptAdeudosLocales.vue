<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="store" /></div>
      <div class="module-view-info">
        <h1>Adeudos de Locales</h1>
        <p>Mercados - Adeudos de Locales</p>
      </div>
    </div>

    <div class="module-view-content">
    <h2 class="mb-4">Listado de Adeudos de Mercados</h2>
    <form @submit.prevent="consultarAdeudos">
      <div class="row mb-3">
        <div class="col-md-3">
          <label for="axo">Año</label>
          <input v-model.number="form.axo" type="number" min="1990" max="2100" class="municipal-form-control" id="axo" required />
        </div>
        <div class="col-md-3">
          <label for="oficina">Recaudadora</label>
          <select v-model.number="form.oficina" class="municipal-form-control" id="oficina" required>
            <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.recaudadora }}</option>
          </select>
        </div>
        <div class="col-md-3">
          <label for="periodo">Mes</label>
          <input v-model.number="form.periodo" type="number" min="1" max="12" class="municipal-form-control" id="periodo" required />
        </div>
        <div class="col-md-3 d-flex align-items-end">
          <button type="submit" class="btn-municipal-primary">Consultar</button>
          <button type="button" class="btn btn-success ml-2" @click="exportarExcel" :disabled="!adeudos.length">Exportar Excel</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="adeudos.length">
      <table class="table table-bordered table-sm mt-3">
        <thead class="thead-light">
          <tr>
            <th>ID Local</th>
            <th>Datos Local</th>
            <th>Nombre</th>
            <th>Superficie</th>
            <th>Meses Adeudo</th>
            <th>Renta</th>
            <th>Adeudo</th>
            <th>Recaudadora</th>
            <th>Descripción</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in adeudos" :key="row.id_local">
            <td>{{ row.id_local }}</td>
            <td>{{ row.datoslocal }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.superficie }}</td>
            <td>{{ row.meses }}</td>
            <td>{{ row.renta_calc | currency }}</td>
            <td>{{ row.adeudo | currency }}</td>
            <td>{{ row.recaudadora }}</td>
            <td>{{ row.descripcion }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <strong>Total registros:</strong> {{ adeudos.length }}
        <span class="ml-4"><strong>Total adeudo:</strong> {{ totalAdeudo | currency }}</span>
      </div>
    </div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'AdeudosLocalesPage',
  data() {
    return {
      form: {
        axo: new Date().getFullYear(),
        oficina: '',
        periodo: new Date().getMonth() + 1
      },
      recaudadoras: [],
      adeudos: [],
      loading: false,
      error: ''
    };
  },
  computed: {
    totalAdeudo() {
      return this.adeudos.reduce((sum, row) => sum + (parseFloat(row.adeudo) || 0), 0);
    }
  },
  filters: {
    currency(val) {
      if (typeof val === 'number' || !isNaN(val)) {
        return '$' + parseFloat(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
      }
      return val;
    }
  },
  created() {
    this.fetchRecaudadoras();
  },
  methods: {
    async fetchRecaudadoras() {
      this.loading = true;
      this.error = '';
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: { action: 'getRecaudadoras' }
        });
        if (resp.data.eResponse.success) {
          this.recaudadoras = resp.data.eResponse.data;
          if (this.recaudadoras.length && !this.form.oficina) {
            this.form.oficina = this.recaudadoras[0].id_rec;
          }
        } else {
          this.error = resp.data.eResponse.message;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async consultarAdeudos() {
      this.loading = true;
      this.error = '';
      this.adeudos = [];
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getAdeudosLocales',
            params: {
              axo: this.form.axo,
              oficina: this.form.oficina,
              periodo: this.form.periodo
            }
          }
        });
        if (resp.data.eResponse.success) {
          this.adeudos = resp.data.eResponse.data;
        } else {
          this.error = resp.data.eResponse.message;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async exportarExcel() {
      // Puede implementarse como descarga de archivo generado por backend
      alert('Funcionalidad de exportación a Excel no implementada en este ejemplo.');
    }
  }
};
</script>

<style scoped>
.adeudos-locales-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
</style>
