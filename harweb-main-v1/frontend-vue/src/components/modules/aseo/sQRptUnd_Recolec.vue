<template>
  <div class="container py-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Claves de Recolección</li>
      </ol>
    </nav>
    <h2 class="mb-3">Catálogo de Claves de Recolección</h2>
    <div class="card mb-4">
      <div class="card-body">
        <form class="form-inline row g-3 align-items-center" @submit.prevent="fetchData">
          <div class="col-auto">
            <label for="ejercicio" class="form-label">Ejercicio:</label>
            <select v-model="ejercicio" id="ejercicio" class="form-select" required>
              <option v-for="ej in ejercicios" :key="ej" :value="ej">{{ ej }}</option>
            </select>
          </div>
          <div class="col-auto">
            <label for="clasificacion" class="form-label">Clasificación por:</label>
            <select v-model="clasificacion" id="clasificacion" class="form-select">
              <option value="ctrol">Número de Control</option>
              <option value="cve">Clave</option>
              <option value="descripcion">Descripción</option>
              <option value="costo">Costo de Unidad</option>
            </select>
          </div>
          <div class="col-auto">
            <button type="submit" class="btn btn-primary">Consultar</button>
          </div>
        </form>
      </div>
    </div>
    <div v-if="loading" class="text-center my-4">
      <span class="spinner-border" role="status"></span> Cargando...
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="rows.length > 0">
      <div class="mb-2">
        <strong>Clasificación por:</strong> {{ clasifLabel }}
      </div>
      <table class="table table-bordered table-sm">
        <thead class="table-light">
          <tr>
            <th style="width: 10%">Control</th>
            <th style="width: 10%">Clave</th>
            <th style="width: 50%">Descripción</th>
            <th style="width: 15%" class="text-end">Costo x Unidad</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in rows" :key="row.ctrol_recolec + '-' + row.cve_recolec">
            <td class="text-center">{{ row.ctrol_recolec }}</td>
            <td class="text-center">{{ row.cve_recolec }}</td>
            <td>{{ row.descripcion }}</td>
            <td class="text-end">{{ formatCurrency(row.costo_unidad) }}</td>
          </tr>
        </tbody>
      </table>
      <div class="text-muted small">Total de registros: {{ rows.length }}</div>
    </div>
    <div v-else-if="!loading && !error">
      <div class="alert alert-info">No se encontraron registros para los criterios seleccionados.</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CatalogoUnidadesRecolec',
  data() {
    return {
      ejercicios: [],
      ejercicio: '',
      clasificacion: 'ctrol',
      rows: [],
      loading: false,
      error: '',
    };
  },
  computed: {
    clasifLabel() {
      switch (this.clasificacion) {
        case 'ctrol': return 'Número de Control';
        case 'cve': return 'Clave';
        case 'descripcion': return 'Descripción';
        case 'costo': return 'Costo de Unidad';
        default: return '';
      }
    }
  },
  methods: {
    async fetchEjercicios() {
      this.loading = true;
      this.error = '';
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: 'get_ejercicios' })
        });
        const data = await resp.json();
        if (data.eResponse.success) {
          this.ejercicios = data.eResponse.data.map(e => e.ejercicio_recolec);
          if (this.ejercicios.length > 0) {
            this.ejercicio = this.ejercicios[0];
          }
        } else {
          this.error = data.eResponse.error || 'Error al obtener ejercicios';
        }
      } catch (err) {
        this.error = err.message;
      } finally {
        this.loading = false;
      }
    },
    async fetchData() {
      if (!this.ejercicio) return;
      this.loading = true;
      this.error = '';
      this.rows = [];
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'get_unidades_recolec',
            params: {
              ejercicio: this.ejercicio,
              order_by: this.clasificacion
            }
          })
        });
        const data = await resp.json();
        if (data.eResponse.success) {
          this.rows = data.eResponse.data;
        } else {
          this.error = data.eResponse.error || 'Error al consultar datos';
        }
      } catch (err) {
        this.error = err.message;
      } finally {
        this.loading = false;
      }
    },
    formatCurrency(val) {
      if (val == null) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN', minimumFractionDigits: 2 });
    }
  },
  mounted() {
    this.fetchEjercicios().then(() => {
      if (this.ejercicio) this.fetchData();
    });
  }
};
</script>

<style scoped>
.table th, .table td {
  vertical-align: middle;
}
</style>
