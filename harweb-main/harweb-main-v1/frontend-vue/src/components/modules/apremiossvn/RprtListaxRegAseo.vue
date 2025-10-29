<template>
  <div class="rprt-listax-reg-aseo-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Listado Registros Aseo</li>
      </ol>
    </nav>
    <h1>Listado de Registros de Mercados con Requerimientos</h1>
    <div class="card mb-3">
      <div class="card-body">
        <form @submit.prevent="fetchReport">
          <div class="row">
            <div class="col-md-3">
              <label>Oficina (id_rec)</label>
              <input v-model="filters.id_rec" type="number" class="form-control" required />
            </div>
            <div class="col-md-3">
              <label>Tipo de Aseo</label>
              <input v-model="filters.tipo_aseo" type="text" class="form-control" required />
            </div>
            <div class="col-md-3">
              <label>Clave Practicado</label>
              <select v-model="filters.clave_practicado" class="form-control">
                <option value="todas">Todas</option>
                <option v-for="c in clavesPracticado" :key="c" :value="c">{{ c }}</option>
              </select>
            </div>
            <div class="col-md-3">
              <label>Vigencia</label>
              <select v-model="filters.vigencia" class="form-control">
                <option value="todas">Todas</option>
                <option value="1">Vigente</option>
                <option value="2">Vencido</option>
                <option value="P">Parcial</option>
              </select>
            </div>
          </div>
          <div class="mt-3">
            <button class="btn btn-primary" type="submit">Buscar</button>
          </div>
        </form>
      </div>
    </div>
    <div v-if="loading" class="text-center my-4">
      <span class="spinner-border"></span> Cargando...
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="reportData.length">
      <div class="mb-3">
        <button class="btn btn-secondary" @click="exportCSV">Exportar CSV</button>
      </div>
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
              <th>Fecha Entrega 1</th>
              <th>Nombre Ejecutor</th>
              <th>Fecha Pago</th>
              <th>Recaudadora</th>
              <th>Caja</th>
              <th>Operación</th>
              <th>Importe Global</th>
              <th>Importe Recargo</th>
              <th>Importe Multa</th>
              <th>Importe Gastos</th>
              <th>Porcentaje Multa</th>
              <th>Importe Pago</th>
              <th>Observaciones</th>
              <th>Tipo Aseo</th>
              <th>Número Contrato</th>
              <th>Vigencia</th>
              <th>Status Vigencia</th>
              <th>Zona</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in reportData" :key="row.folio">
              <td>{{ row.folio }}</td>
              <td>{{ row.fecha_emision }}</td>
              <td>{{ row.clave_practicado }}</td>
              <td>{{ row.fecha_practicado }}</td>
              <td>{{ row.hora }}</td>
              <td>{{ row.ejecutor }}</td>
              <td>{{ row.fecha_entrega1 }}</td>
              <td>{{ row.nombre }}</td>
              <td>{{ row.fecha_pago }}</td>
              <td>{{ row.recaudadora }}</td>
              <td>{{ row.caja }}</td>
              <td>{{ row.operacion }}</td>
              <td>{{ row.importe_global }}</td>
              <td>{{ row.importe_recargo }}</td>
              <td>{{ row.importe_multa }}</td>
              <td>{{ row.importe_gastos }}</td>
              <td>{{ row.porcentaje_multa }}</td>
              <td>{{ row.importe_pago }}</td>
              <td>{{ row.observaciones }}</td>
              <td>{{ row.tipo_aseo }}</td>
              <td>{{ row.num_contrato }}</td>
              <td>{{ row.vigencia }}</td>
              <td>{{ row.status_vigencia }}</td>
              <td>{{ row.zona }}</td>
            </tr>
          </tbody>
          <tfoot>
            <tr class="font-weight-bold">
              <td colspan="12">Totales</td>
              <td>{{ sum('importe_global') }}</td>
              <td>{{ sum('importe_recargo') }}</td>
              <td>{{ sum('importe_multa') }}</td>
              <td>{{ sum('importe_gastos') }}</td>
              <td></td>
              <td>{{ sum('importe_pago') }}</td>
              <td colspan="6"></td>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
    <div v-else-if="!loading && !error">
      <div class="alert alert-info">No hay datos para los filtros seleccionados.</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RprtListaxRegAseoPage',
  data() {
    return {
      filters: {
        id_rec: '',
        tipo_aseo: '',
        clave_practicado: 'todas',
        vigencia: 'todas'
      },
      clavesPracticado: ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'], // Ajustar según catálogo real
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
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'getReportData',
              params: { ...this.filters }
            }
          })
        });
        const json = await response.json();
        if (json.eResponse.success) {
          this.reportData = json.eResponse.data;
        } else {
          this.error = json.eResponse.message || 'Error al obtener datos';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    sum(field) {
      return this.reportData.reduce((acc, row) => acc + (parseFloat(row[field]) || 0), 0).toLocaleString();
    },
    exportCSV() {
      if (!this.reportData.length) return;
      const headers = Object.keys(this.reportData[0]);
      const csvRows = [headers.join(',')];
      this.reportData.forEach(row => {
        csvRows.push(headers.map(h => '"' + (row[h] ?? '') + '"').join(','));
      });
      const blob = new Blob([csvRows.join('\n')], { type: 'text/csv' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'rprt_listax_reg_aseo.csv';
      a.click();
      URL.revokeObjectURL(url);
    }
  }
};
</script>

<style scoped>
.rprt-listax-reg-aseo-page {
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
.table th, .table td {
  font-size: 0.95rem;
}
</style>
