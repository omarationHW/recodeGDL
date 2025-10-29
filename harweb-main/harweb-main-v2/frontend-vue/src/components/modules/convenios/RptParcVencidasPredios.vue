<template>
  <div class="page-container">
    <h1>Reporte de Parcialidades Vencidas de Predios</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Parcialidades Vencidas Predios</li>
      </ol>
    </nav>
    <form @submit.prevent="fetchData">
      <div class="form-group">
        <label for="subtipo">Subtipo de Predio</label>
        <select v-model="form.subtipo" id="subtipo" class="form-control" required>
          <option v-for="s in subtipos" :key="s.value" :value="s.value">{{ s.label }}</option>
        </select>
      </div>
      <div class="form-group">
        <label for="fechahst">Fecha de Corte</label>
        <input type="date" v-model="form.fechahst" id="fechahst" class="form-control" required />
      </div>
      <div class="form-group">
        <label for="est">Estado</label>
        <select v-model="form.est" id="est" class="form-control">
          <option value="A">VIGENTES</option>
          <option value="B">DADOS DE BAJA</option>
          <option value="P">PAGADOS</option>
        </select>
      </div>
      <button type="submit" class="btn btn-primary">Consultar</button>
    </form>
    <div v-if="loading" class="mt-3">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="results.length" class="mt-4">
      <h3>Resultados</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Manzana</th>
            <th>Lote</th>
            <th>Letra</th>
            <th>Nombre</th>
            <th>Calle</th>
            <th>Num. Ext</th>
            <th>Num. Int</th>
            <th>Inciso</th>
            <th>Costo</th>
            <th>Pagos Corriente</th>
            <th>Pagos Vencidos</th>
            <th>Recargos</th>
            <th>Adeudos</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in results" :key="row.id_conv_predio">
            <td>{{ row.manzana }}</td>
            <td>{{ row.lote }}</td>
            <td>{{ row.letracomp }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.calle }}</td>
            <td>{{ row.num_exterior }}</td>
            <td>{{ row.num_interior }}</td>
            <td>{{ row.inciso }}</td>
            <td>{{ row.costo | currency }}</td>
            <td>{{ row.pagos_corriente | currency }}</td>
            <td>{{ row.pagos_vencidos | currency }}</td>
            <td>{{ row.recargos | currency }}</td>
            <td>{{ row.adeudos | currency }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ParcialidadesVencidasPredios',
  data() {
    return {
      form: {
        subtipo: '',
        fechahst: '',
        est: 'A'
      },
      subtipos: [
        { value: 1, label: 'Residencial' },
        { value: 2, label: 'Comercial' },
        { value: 3, label: 'Industrial' }
        // ... cargar dinámicamente si es necesario
      ],
      results: [],
      loading: false,
      error: ''
    };
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return '$' + val.toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  },
  methods: {
    async fetchData() {
      this.loading = true;
      this.error = '';
      this.results = [];
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            action: 'getParcialidadesVencidasPredios',
            params: this.form
          })
        });
        const data = await response.json();
        if (data.status === 'success') {
          // Map fields for display
          this.results = data.data.map(row => ({
            ...row,
            pagos_corriente: row.venc === 1 ? row.pagos : 0,
            pagos_vencidos: row.venc === 2 ? row.pagos : 0,
            adeudos: row.venc === 3 ? row.adeudos : 0
          }));
        } else {
          this.error = data.message || 'Error desconocido';
        }
      } catch (e) {
        this.error = 'Error de comunicación con el servidor';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.page-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
