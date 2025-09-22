<template>
  <div class="cons-und-recolec-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta Unidades de Recolección</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-body d-flex flex-wrap align-items-center">
        <div class="form-group mr-3">
          <label for="ejercicio">Ejercicio</label>
          <input v-model="ejercicio" type="number" class="form-control" id="ejercicio" min="2000" max="2100" />
        </div>
        <div class="form-group mr-3">
          <label for="order">Clasificación por</label>
          <select v-model="order" class="form-control" id="order">
            <option value="ctrol_recolec">Control</option>
            <option value="cve_recolec">Clave</option>
            <option value="descripcion">Descripción</option>
            <option value="costo_unidad">Costo x Unidad</option>
          </select>
        </div>
        <button class="btn btn-primary mr-2 mt-4" @click="fetchData"><i class="fa fa-search"></i> Buscar</button>
        <button class="btn btn-success mt-4" @click="exportExcel"><i class="fa fa-file-excel-o"></i> Exportar Excel</button>
      </div>
    </div>
    <div class="card">
      <div class="card-body p-0">
        <table class="table table-striped table-bordered mb-0">
          <thead class="thead-light">
            <tr>
              <th>Control</th>
              <th>Ejercicio</th>
              <th>Clave</th>
              <th>Descripción</th>
              <th>Costo x Unidad</th>
              <th>Costo x Excedencia</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in rows" :key="row.ctrol_recolec">
              <td>{{ row.ctrol_recolec }}</td>
              <td>{{ row.ejercicio_recolec }}</td>
              <td>{{ row.cve_recolec }}</td>
              <td>{{ row.descripcion }}</td>
              <td>{{ row.costo_unidad | currency }}</td>
              <td>{{ row.costo_exed | currency }}</td>
            </tr>
            <tr v-if="rows.length === 0">
              <td colspan="6" class="text-center">No hay datos para mostrar</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="loading" class="text-center mt-3">
      <span class="spinner-border"></span> Cargando...
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'ConsUndRecolecPage',
  data() {
    return {
      ejercicio: new Date().getFullYear(),
      order: 'ctrol_recolec',
      rows: [],
      loading: false,
      error: ''
    };
  },
  filters: {
    currency(val) {
      if (typeof val === 'number') return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
      return val;
    }
  },
  methods: {
    async fetchData() {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: 'cons_und_recolec_list',
          params: {
            ejercicio: this.ejercicio,
            order: this.order
          }
        });
        if (res.data.success) {
          this.rows = res.data.data;
        } else {
          this.error = res.data.message || 'Error al consultar datos';
        }
      } catch (e) {
        this.error = e.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    },
    async exportExcel() {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: 'cons_und_recolec_export',
          params: {
            ejercicio: this.ejercicio,
            order: this.order
          }
        });
        if (res.data.success) {
          // Simulación de exportación: descarga CSV
          const csv = this.toCSV(res.data.data);
          const blob = new Blob([csv], { type: 'text/csv' });
          const url = window.URL.createObjectURL(blob);
          const a = document.createElement('a');
          a.href = url;
          a.download = `unidades_recoleccion_${this.ejercicio}.csv`;
          a.click();
          window.URL.revokeObjectURL(url);
        } else {
          this.error = res.data.message || 'Error al exportar datos';
        }
      } catch (e) {
        this.error = e.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    },
    toCSV(data) {
      if (!data || !data.length) return '';
      const header = Object.keys(data[0]).join(',');
      const rows = data.map(row => Object.values(row).join(','));
      return [header, ...rows].join('\n');
    }
  },
  mounted() {
    this.fetchData();
  }
};
</script>

<style scoped>
.cons-und-recolec-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 20px;
}
.card {
  margin-bottom: 1rem;
}
</style>
