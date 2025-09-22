<template>
  <div class="rprt-listax-regmer-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Listado de Registros de Mercados</li>
      </ol>
    </nav>
    <h1>Listado de Registros de Mercados con Requerimientos</h1>
    <form @submit.prevent="fetchReport" class="mb-4">
      <div class="row">
        <div class="col-md-3">
          <label for="oficina">Oficina</label>
          <input v-model.number="filters.oficina" type="number" class="form-control" id="oficina" required>
        </div>
        <div class="col-md-3">
          <label for="num_mercado">Número de Mercado</label>
          <input v-model.number="filters.num_mercado" type="number" class="form-control" id="num_mercado" required>
        </div>
        <div class="col-md-3">
          <label for="vigencia">Vigencia</label>
          <select v-model="filters.vigencia" class="form-control" id="vigencia">
            <option value="todas">Todas</option>
            <option value="1">Vigente</option>
            <option value="2">Pagado</option>
            <option value="3">Cancelado</option>
            <option value="P">P</option>
          </select>
        </div>
        <div class="col-md-3">
          <label for="clave_practicado">Clave Practicado</label>
          <input v-model="filters.clave_practicado" type="text" class="form-control" id="clave_practicado" placeholder="todas">
        </div>
      </div>
      <button type="submit" class="btn btn-primary mt-3">Buscar</button>
    </form>

    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>

    <div v-if="reportData && reportData.length">
      <div class="table-responsive">
        <table class="table table-bordered table-sm">
          <thead class="thead-light">
            <tr>
              <th>Folio</th>
              <th>Fecha Emisión</th>
              <th>Clave Practicado</th>
              <th>Fecha Practicado</th>
              <th>Hora</th>
              <th>Ejecutor</th>
              <th>Entrega 1</th>
              <th>Nombre Ejecutor</th>
              <th>Fecha Pago</th>
              <th>Recaudadora</th>
              <th>Caja</th>
              <th>Operación</th>
              <th>Importe Global</th>
              <th>Recargos</th>
              <th>Multas</th>
              <th>Gastos</th>
              <th>Porcentaje Multa</th>
              <th>Importe Pago</th>
              <th>Observaciones</th>
              <th>Vigencia</th>
              <th>Zona</th>
              <th>Num Mercado</th>
              <th>Categoria</th>
              <th>Sección</th>
              <th>Local</th>
              <th>Letra Local</th>
              <th>Bloque</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in reportData" :key="row.id_control">
              <td>{{ row.folio }}</td>
              <td>{{ formatDate(row.fecha_emision) }}</td>
              <td>{{ row.clave_practicado }}</td>
              <td>{{ formatDate(row.fecha_practicado) }}</td>
              <td>{{ formatTime(row.hora) }}</td>
              <td>{{ row.ejecutor }}</td>
              <td>{{ formatDate(row.fecha_entrega1) }}</td>
              <td>{{ row.nombre_1 }}</td>
              <td>{{ formatDate(row.fecha_pago) }}</td>
              <td>{{ row.recaudadora }}</td>
              <td>{{ row.caja }}</td>
              <td>{{ row.operacion }}</td>
              <td>{{ formatCurrency(row.importe_global) }}</td>
              <td>{{ formatCurrency(row.importe_recargo) }}</td>
              <td>{{ formatCurrency(row.importe_multa) }}</td>
              <td>{{ formatCurrency(row.importe_gastos) }}</td>
              <td>{{ row.porcentaje_multa }}%</td>
              <td>{{ formatCurrency(row.importe_pago) }}</td>
              <td>{{ row.observaciones }}</td>
              <td>{{ vigenciaLabel(row.vigencia_1) }}</td>
              <td>{{ row.zona_1 }}</td>
              <td>{{ row.num_mercado }}</td>
              <td>{{ row.categoria }}</td>
              <td>{{ row.seccion }}</td>
              <td>{{ row.local }}</td>
              <td>{{ row.letra_local }}</td>
              <td>{{ row.bloque }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="mt-4">
        <h5>Totales</h5>
        <ul>
          <li>Importe Global: {{ formatCurrency(total('importe_global')) }}</li>
          <li>Recargos: {{ formatCurrency(total('importe_recargo')) }}</li>
          <li>Multas: {{ formatCurrency(total('importe_multa')) }}</li>
          <li>Gastos: {{ formatCurrency(total('importe_gastos')) }}</li>
          <li>General: {{ formatCurrency(grandTotal()) }}</li>
        </ul>
      </div>
    </div>
    <div v-else-if="!loading && !error">
      <div class="alert alert-warning">No hay datos para los filtros seleccionados.</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RprtListaxRegMerPage',
  data() {
    return {
      filters: {
        oficina: '',
        num_mercado: '',
        vigencia: 'todas',
        clave_practicado: 'todas'
      },
      reportData: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.reportData = [];
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'getRprtListaxRegMer',
            params: {
              oficina: this.filters.oficina,
              num_mercado: this.filters.num_mercado,
              vigencia: this.filters.vigencia,
              clave_practicado: this.filters.clave_practicado || 'todas'
            }
          })
        });
        const data = await response.json();
        if (data.success) {
          this.reportData = data.data;
        } else {
          this.error = data.message || 'Error al obtener datos';
        }
      } catch (err) {
        this.error = err.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    },
    formatDate(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString();
    },
    formatTime(val) {
      if (!val) return '';
      return new Date(val).toLocaleTimeString();
    },
    formatCurrency(val) {
      if (val == null) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    },
    vigenciaLabel(vig) {
      if (vig === '3') return 'CANCELADO';
      if (vig === '1') return 'VIGENTE';
      if (vig === '2') return 'PAGADO';
      if (vig === 'P') return 'P';
      return vig;
    },
    total(field) {
      return this.reportData.reduce((sum, row) => sum + (parseFloat(row[field]) || 0), 0);
    },
    grandTotal() {
      return this.total('importe_global') + this.total('importe_multa') + this.total('importe_recargo') + this.total('importe_gastos');
    }
  }
};
</script>

<style scoped>
.rprt-listax-regmer-page {
  padding: 2rem;
}
.table th, .table td {
  font-size: 0.95rem;
}
</style>
