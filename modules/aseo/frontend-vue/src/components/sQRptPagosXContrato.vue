<template>
  <div class="pagos-contrato-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Pagos por Contrato</li>
      </ol>
    </nav>
    <h2 class="text-center">MUNICIPIO DE GUADALAJARA</h2>
    <h4 class="text-center">DIRECCION DE INGRESOS</h4>
    <h5 class="text-center">Estado de Cuenta por Contrato</h5>
    <div class="text-center mb-3">
      <span>Clasificación por: Periodo de Pago y Operación</span>
    </div>
    <form @submit.prevent="fetchReport" class="mb-4">
      <div class="row g-2">
        <div class="col-md-3">
          <label for="control" class="form-label">Control Contrato</label>
          <input type="number" v-model.number="form.control" id="control" class="form-control" required />
        </div>
        <div class="col-md-3">
          <label for="contrato" class="form-label">Contrato</label>
          <input type="number" v-model.number="form.contrato" id="contrato" class="form-control" required />
        </div>
        <div class="col-md-3">
          <label for="ctrol_aseo" class="form-label">Tipo Aseo</label>
          <select v-model.number="form.ctrol_aseo" id="ctrol_aseo" class="form-select" required>
            <option :value="4">HOSPITALARIO</option>
            <option :value="8">ORDINARIO</option>
            <option :value="9">ZONA CENTRO</option>
          </select>
        </div>
        <div class="col-md-3 d-flex align-items-end">
          <button type="submit" class="btn btn-primary w-100">Consultar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="text-center my-4">
      <span class="spinner-border"></span> Cargando...
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="reportData && reportData.length">
      <div class="mb-2">
        <strong>Contrato:</strong> {{ contrato }}<br />
        <strong>Tipo Aseo:</strong> {{ aseoLabel }}
      </div>
      <div class="table-responsive">
        <table class="table table-bordered table-sm align-middle">
          <thead class="table-light">
            <tr>
              <th>Periodo</th>
              <th>Tipo de Adeudo</th>
              <th>Cant</th>
              <th>Importe</th>
              <th>Vig.</th>
              <th>Fecha de Pago</th>
              <th>Rec. de Pago</th>
              <th>Caja</th>
              <th>Cons. de Oper.</th>
              <th>Folio rcbo.</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, idx) in reportData" :key="idx">
              <td class="text-center">{{ formatPeriodo(row.aso_mes_pago) }}</td>
              <td>{{ row.descripcion }}</td>
              <td class="text-center">{{ row.exedencias }}</td>
              <td class="text-end">{{ formatCurrency(row.importe) }}</td>
              <td class="text-center">{{ row.status_vigencia }}</td>
              <td class="text-center">{{ row.status_vigencia === 'P' ? formatFecha(row.fecha_hora_pago) : '' }}</td>
              <td class="text-center">{{ row.status_vigencia === 'P' ? row.id_rec : '' }}</td>
              <td class="text-center">{{ row.status_vigencia === 'P' ? row.caja : '' }}</td>
              <td class="text-center">{{ row.status_vigencia === 'P' ? row.consec_operacion : '' }}</td>
              <td class="text-center">{{ row.status_vigencia === 'P' ? row.folio_rcbo : '' }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="mt-4">
        <h6>CIFRAS:</h6>
        <div class="row">
          <div class="col-md-6">
            <table class="table table-bordered table-sm w-auto">
              <tbody>
                <tr>
                  <td>REGISTROS</td>
                  <td class="text-end">{{ summary.total_registros }}</td>
                  <td class="text-end">{{ formatCurrency(summary.total_importe) }}</td>
                </tr>
                <tr>
                  <td>CUOTA NORMAL</td>
                  <td class="text-end">{{ summary.cuota_normal.count }}</td>
                  <td class="text-end">{{ formatCurrency(summary.cuota_normal.importe) }}</td>
                </tr>
                <tr>
                  <td>EXCEDENTES</td>
                  <td class="text-end">{{ summary.excedente.count }}</td>
                  <td class="text-end">{{ formatCurrency(summary.excedente.importe) }}</td>
                </tr>
                <tr>
                  <td>CONTENEDORES</td>
                  <td class="text-end">{{ summary.contenedores.count }}</td>
                  <td class="text-end">{{ formatCurrency(summary.contenedores.importe) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="col-md-6">
            <div><strong>Contrato:</strong> {{ contrato }}</div>
            <div><strong>Tipo Aseo:</strong> {{ aseoLabel }}</div>
          </div>
        </div>
      </div>
    </div>
    <div v-else-if="!loading && !error && reportData && !reportData.length" class="alert alert-info">
      No se encontraron registros para los parámetros ingresados.
    </div>
  </div>
</template>

<script>
export default {
  name: 'PagosPorContratoPage',
  data() {
    return {
      form: {
        control: '',
        contrato: '',
        ctrol_aseo: 4
      },
      loading: false,
      error: '',
      reportData: null,
      summary: null,
      contrato: '',
      aseoLabel: ''
    };
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.reportData = null;
      this.summary = null;
      this.contrato = '';
      this.aseoLabel = '';
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'getPagosPorContrato',
            params: {
              control: this.form.control,
              contrato: this.form.contrato,
              ctrol_aseo: this.form.ctrol_aseo
            }
          })
        });
        const data = await response.json();
        if (data.eResponse === 'success') {
          this.reportData = data.data;
          this.summary = data.summary;
          this.contrato = data.contrato;
          this.aseoLabel = data.aseo_label;
        } else {
          this.error = data.message || 'Error desconocido.';
        }
      } catch (err) {
        this.error = 'Error de conexión o del servidor.';
      } finally {
        this.loading = false;
      }
    },
    formatPeriodo(dateStr) {
      if (!dateStr) return '';
      // PostgreSQL returns ISO string or date
      const d = new Date(dateStr);
      return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0');
    },
    formatFecha(dateStr) {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      return d.toLocaleDateString();
    },
    formatCurrency(val) {
      if (val == null) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN', minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.pagos-contrato-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.table th, .table td {
  font-size: 0.95rem;
}
</style>
