<template>
  <div class="container mt-4">
    <h2 class="mb-3">Multas cobradas en centros de Recaudación asociadas al importe del pago</h2>
    <div class="mb-3">
      <form @submit.prevent="fetchData">
        <div class="row g-2 align-items-end">
          <div class="col-auto">
            <label class="form-label">Filtrar por fecha:</label>
            <input type="date" v-model="filters.fecha" class="form-control" />
          </div>
          <div class="col-auto">
            <label class="form-label">Dependencia:</label>
            <select v-model="filters.id_dependencia" class="form-select">
              <option value="">Todas</option>
              <option v-for="dep in dependencias" :key="dep.id" :value="dep.id">{{ dep.abrevia }}</option>
            </select>
          </div>
          <div class="col-auto">
            <label class="form-label">Año Acta:</label>
            <input type="number" v-model="filters.axo_acta" class="form-control" min="1900" />
          </div>
          <div class="col-auto">
            <label class="form-label">No. Acta:</label>
            <input type="number" v-model="filters.num_acta" class="form-control" min="1" />
          </div>
          <div class="col-auto">
            <button type="submit" class="btn btn-primary">Buscar</button>
            <button type="button" class="btn btn-secondary ms-2" @click="resetFilters">Limpiar</button>
          </div>
        </div>
      </form>
    </div>
    <div class="table-responsive">
      <table class="table table-bordered table-hover">
        <thead class="table-light">
          <tr>
            <th>Fecha</th>
            <th>Dep</th>
            <th>Año</th>
            <th>Acta</th>
            <th>Recibo</th>
            <th>Importe</th>
            <th>Contribuyente</th>
            <th>Domicilio</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in rows" :key="row.fecha + '-' + row.num_recibo">
            <td>{{ row.fecha }}</td>
            <td>{{ row.abrevia }}</td>
            <td>{{ row.axo_acta }}</td>
            <td>{{ row.num_acta }}</td>
            <td>{{ row.num_recibo }}</td>
            <td class="text-end">{{ row.importe_pago | currency }}</td>
            <td>{{ row.contribuyente }}</td>
            <td>{{ row.domicilio }}</td>
          </tr>
          <tr v-if="rows.length === 0">
            <td colspan="8" class="text-center">No hay registros</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsCentrosPage',
  data() {
    return {
      filters: {
        fecha: '',
        id_dependencia: '',
        axo_acta: '',
        num_acta: ''
      },
      rows: [],
      dependencias: []
    };
  },
  mounted() {
    this.fetchDependencias();
    this.fetchData();
  },
  methods: {
    async fetchDependencias() {
      // Simulación: en producción, consumir endpoint real
      this.dependencias = [
        { id: 1, abrevia: 'CENTRO' },
        { id: 2, abrevia: 'OLIMPICA' },
        { id: 3, abrevia: 'OBLATOS' },
        { id: 4, abrevia: 'MINERVA' },
        { id: 5, abrevia: 'CRUZ DEL SUR' }
      ];
    },
    async fetchData() {
      let action = 'get_centros_list';
      let params = {};
      if (this.filters.fecha) {
        action = 'get_centros_by_fecha';
        params.fecha = this.filters.fecha;
      } else if (this.filters.id_dependencia) {
        action = 'get_centros_by_dependencia';
        params.id_dependencia = this.filters.id_dependencia;
      } else if (this.filters.axo_acta && this.filters.num_acta) {
        action = 'get_centros_by_acta';
        params.axo_acta = this.filters.axo_acta;
        params.num_acta = this.filters.num_acta;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          action: `recaudadora.${action}`,
          payload: params
        });
        if (res.data.status === 'success') {
          this.rows = res.data.data;
        } else {
          this.rows = [];
        }
      } catch (e) {
        this.rows = [];
        console.error('Error de conexión:', e.message);
      }
    },
    resetFilters() {
      this.filters = { fecha: '', id_dependencia: '', axo_acta: '', num_acta: '' };
      this.fetchData();
    }
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  }
};
</script>

<style scoped>
.table th, .table td {
  vertical-align: middle;
}
</style>
