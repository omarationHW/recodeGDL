<template>
  <div class="adeudos-cond-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte de Adeudos Condonados</li>
      </ol>
    </nav>
    <h2 class="mb-4">Reporte de Adeudos Condonados de Aseo Contratado</h2>
    <form @submit.prevent="fetchReport" class="mb-4">
      <div class="row g-3 align-items-end">
        <div class="col-md-4">
          <label for="control_contrato" class="form-label">No. Contrato</label>
          <input type="number" v-model="form.control_contrato" class="form-control" id="control_contrato" required />
        </div>
        <div class="col-md-4">
          <label for="opcion" class="form-label">Clasificación por</label>
          <select v-model="form.opcion" class="form-select" id="opcion">
            <option :value="1">Periodo de Pago</option>
            <option :value="2">Operación</option>
          </select>
        </div>
        <div class="col-md-4">
          <button type="submit" class="btn btn-primary">Consultar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="reportData && reportData.length">
      <div class="table-responsive">
        <table class="table table-bordered table-sm">
          <thead class="table-light">
            <tr>
              <th>No. Contrato</th>
              <th>Tipo de Aseo</th>
              <th>Recolección</th>
              <th>Cant.</th>
              <th>Domicilio de la Recolección</th>
              <th>Rec.</th>
              <th>Sec</th>
              <th>Zona</th>
              <th>SZona</th>
              <th>Alta</th>
              <th>Fec-Baja</th>
              <th>Periodo</th>
              <th>Tipo de Adeudo</th>
              <th>Cant</th>
              <th>Importe</th>
              <th>Vig.</th>
              <th>Fecha de Condonación</th>
              <th>Oficio y/o Docto</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, idx) in reportData" :key="idx">
              <td>{{ row.num_contrato }}</td>
              <td>{{ row.descripcion }}</td>
              <td>{{ row.descripcion_1 }}</td>
              <td>{{ row.cantidad_recolec }}</td>
              <td>{{ row.domicilio }}</td>
              <td>{{ row.id_rec }}</td>
              <td>{{ row.sector }}</td>
              <td>{{ row.zona }}</td>
              <td>{{ row.sub_zona }}</td>
              <td>{{ formatDate(row.aso_mes_oblig) }}</td>
              <td>{{ formatDate(row.fecha_hora_baja) }}</td>
              <td>{{ formatDate(row.aso_mes_pago, 'yyyy-MM') }}</td>
              <td>{{ row.descripcion_3 }}</td>
              <td>{{ row.exedencias }}</td>
              <td class="text-end">{{ formatCurrency(row.importe) }}</td>
              <td>{{ row.status_vigencia_1 }}</td>
              <td>{{ row.status_vigencia_1 === 'S' ? formatDate(row.fecha_hora_pago) : '' }}</td>
              <td>{{ row.status_vigencia_1 === 'S' ? row.folio_rcbo : '' }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <!-- Totals by contract (client-side, for demo) -->
      <div class="mt-4">
        <h5>Totales por Contrato</h5>
        <ul>
          <li>Registros: {{ totals.registros }}</li>
          <li>Importe Total: {{ formatCurrency(totals.importe) }}</li>
          <li>Cuota Normal: {{ totals.cn }} ({{ formatCurrency(totals.i_cn) }})</li>
          <li>Excedente: {{ totals.exe }} ({{ formatCurrency(totals.i_exe) }})</li>
          <li>Contenedores: {{ totals.cont }} ({{ formatCurrency(totals.i_cont) }})</li>
        </ul>
      </div>
    </div>
    <div v-else-if="reportData && !reportData.length" class="alert alert-warning">No se encontraron datos para los criterios seleccionados.</div>
  </div>
</template>

<script>
export default {
  name: 'AdeudosCondonadosPage',
  data() {
    return {
      form: {
        control_contrato: '',
        opcion: 1
      },
      loading: false,
      error: '',
      reportData: null
    };
  },
  computed: {
    totals() {
      if (!this.reportData) return {
        registros: 0, importe: 0, cn: 0, i_cn: 0, exe: 0, i_exe: 0, cont: 0, i_cont: 0
      };
      let registros = this.reportData.length;
      let importe = 0, cn = 0, i_cn = 0, exe = 0, i_exe = 0, cont = 0, i_cont = 0;
      this.reportData.forEach(row => {
        importe += Number(row.importe || 0);
        if (row.descripcion_3 === 'CUOTA NORMAL') {
          cn++;
          i_cn += Number(row.importe || 0);
        }
        if (row.descripcion_3 === 'EXCEDENTE') {
          exe++;
          i_exe += Number(row.importe || 0);
        }
        if (row.descripcion_3 === 'CONTENEDORES') {
          cont++;
          i_cont += Number(row.importe || 0);
        }
      });
      return { registros, importe, cn, i_cn, exe, i_exe, cont, i_cont };
    }
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.reportData = null;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'getAdeudosCondonados',
            params: {
              control_contrato: this.form.control_contrato,
              opcion: this.form.opcion
            }
          })
        });
        const data = await response.json();
        if (data.success) {
          this.reportData = data.data;
        } else {
          this.error = data.error || 'Error desconocido al consultar el reporte.';
        }
      } catch (err) {
        this.error = err.message || 'Error de red al consultar el API.';
      } finally {
        this.loading = false;
      }
    },
    formatDate(dateStr, fmt = 'yyyy-MM-dd') {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      if (isNaN(d)) return '';
      if (fmt === 'yyyy-MM') {
        return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0');
      }
      return d.toLocaleDateString();
    },
    formatCurrency(val) {
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  }
};
</script>

<style scoped>
.adeudos-cond-page {
  max-width: 100%;
  padding: 2rem;
  background: #fff;
}
.table th, .table td {
  font-size: 0.95em;
}
</style>
