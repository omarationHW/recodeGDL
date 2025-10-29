<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="users" /></div>
      <div class="module-view-info">
        <h1>Padrón Global de Locales</h1>
        <p>Mercados - Padrón Global de Locales</p>
      </div>
    </div>

    <div class="module-view-content">
    <h1>Padrón Global de Locales</h1>
    <form @submit.prevent="fetchPadron">
      <div class="form-row">
        <div class="form-group col-md-2">
          <label for="year">Año</label>
          <input type="number" v-model="form.year" class="municipal-form-control" id="year" required />
        </div>
        <div class="form-group col-md-2">
          <label for="month">Mes</label>
          <input type="number" v-model="form.month" class="municipal-form-control" id="month" min="1" max="12" required />
        </div>
        <div class="form-group col-md-3">
          <label for="status">Estatus</label>
          <select v-model="form.status" class="municipal-form-control" id="status" required>
            <option value="A">Vigentes</option>
            <option value="B">Baja</option>
            <option value="C">Baja por Acuerdo</option>
            <option value="D">Baja Administrativa</option>
            <option value="T">Todos</option>
          </select>
        </div>
        <div class="form-group col-md-3 align-self-end">
          <button type="submit" class="btn-municipal-primary">Consultar</button>
          <button type="button" class="btn btn-success ml-2" @click="exportExcel">Exportar Excel</button>
          <button type="button" class="btn btn-danger ml-2" @click="exportPDF">Reporte PDF</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="mt-3">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="padron.length > 0" class="table-responsive mt-3">
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Registro</th>
            <th>Nombre</th>
            <th>Superficie</th>
            <th>Renta</th>
            <th>Estatus</th>
            <th>Adicionales</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in padron" :key="row.id_local">
            <td>{{ row.registro }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.superficie }}</td>
            <td>{{ row.renta | currency }}</td>
            <td>{{ row.leyenda }}</td>
            <td>{{ row.descripcion_local }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-2">
        <strong>Total de Locales:</strong> {{ padron.length }}<br />
        <strong>Al Corriente de Pagos:</strong> {{ padron.filter(r => r.adeudo === 0).length }}<br />
        <strong>Con Adeudo:</strong> {{ padron.filter(r => r.adeudo === 1).length }}
      </div>
    </div>
  </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PadronGlobalPage',
  data() {
    return {
      form: {
        year: new Date().getFullYear(),
        month: new Date().getMonth() + 1,
        status: 'A'
      },
      padron: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    async fetchPadron() {
      this.loading = true;
      this.error = '';
      try {
        const response = await this.$axios.post('/api/execute', {
          action: 'getPadronGlobal',
          params: {
            year: this.form.year,
            month: this.form.month,
            status: this.form.status
          }
        });
        if (response.data.success) {
          this.padron = response.data.data;
        } else {
          this.error = response.data.message || 'Error en la consulta';
        }
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      } finally {
        this.loading = false;
      }
    },
    async exportExcel() {
      // Simulación de exportación
      alert('Exportación a Excel (simulada)');
    },
    async exportPDF() {
      // Simulación de exportación
      alert('Reporte PDF (simulado)');
    }
  },
  filters: {
    currency(val) {
      if (typeof val === 'number') {
        return '$' + val.toLocaleString('es-MX', { minimumFractionDigits: 2 });
      }
      return val;
    }
  }
};
</script>

<style scoped>
.padron-global-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
