<template>
  <div class="rptrecup-aseo-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Orden de Requerimiento de Pago y Embargo - Aseo</li>
      </ol>
    </nav>
    <h2>Orden de Requerimiento de Pago y Embargo - Derechos de Aseo Contratado</h2>
    <form @submit.prevent="fetchReport">
      <div class="form-row">
        <div class="form-group col-md-2">
          <label for="folio1">Folio Inicial</label>
          <input type="number" v-model="folio1" class="form-control" id="folio1" required />
        </div>
        <div class="form-group col-md-2">
          <label for="folio2">Folio Final</label>
          <input type="number" v-model="folio2" class="form-control" id="folio2" required />
        </div>
        <div class="form-group col-md-2">
          <label for="ofna">Oficina (ID)</label>
          <input type="number" v-model="ofna" class="form-control" id="ofna" required />
        </div>
        <div class="form-group col-md-2 align-self-end">
          <button type="submit" class="btn btn-primary">Generar Reporte</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info mt-3">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="report && report.adeudos.length" class="mt-4">
      <div v-for="(item, idx) in report.adeudos" :key="item.folio + '-' + idx" class="card mb-4">
        <div class="card-header">
          <strong>Folio:</strong> {{ item.folio }} | <strong>Periodo:</strong> {{ item.periodo }} | <strong>Año:</strong> {{ item.ayo }}
        </div>
        <div class="card-body">
          <div class="row">
            <div class="col-md-6">
              <p><strong>Oficina:</strong> {{ item.id_rec }}</p>
              <p><strong>Tipo Contrato:</strong> {{ item.tipo_aseo }}</p>
              <p><strong>Nombre Contribuyente:</strong> {{ item.descripcion_1 }}</p>
              <p><strong>Domicilio:</strong> {{ item.domicilio }}</p>
              <p><strong>Zona:</strong> {{ item.zona }}</p>
              <p><strong>Servicio:</strong> {{ item.descripcion }}</p>
              <p><strong>Fecha Emisión:</strong> {{ formatDate(item.fecha_emision) }}</p>
            </div>
            <div class="col-md-6">
              <p><strong>Adeudo:</strong> ${{ formatCurrency(item.importe) }}</p>
              <p><strong>Recargos:</strong> ${{ formatCurrency(item.recargos) }}</p>
              <p><strong>Multas:</strong> ${{ formatCurrency(item.importe_multa) }}</p>
              <p><strong>Gastos:</strong> ${{ formatCurrency(item.importe_gastos) }}</p>
              <p><strong>Total:</strong> ${{ formatCurrency(item.importe_gastos + item.importe_global + item.importe_multa + item.importe_recargo) }}</p>
            </div>
          </div>
          <hr />
          <div>
            <strong>Texto Legal:</strong>
            <p class="small">
              Con fundamento en los Art. 115 de la Constitución Política de los Estados Unidos Mexicanos ... (texto legal completo aquí)
            </p>
          </div>
        </div>
      </div>
      <div class="alert alert-secondary">
        <strong>Recaudadora:</strong>
        <span v-if="report.recaudadora && report.recaudadora.length">
          {{ report.recaudadora[0].recaudadora }} - {{ report.recaudadora[0].domicilio }}
        </span>
      </div>
    </div>
    <div v-else-if="report && !report.adeudos.length" class="alert alert-warning mt-4">
      No se encontraron registros para los criterios ingresados.
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptRecupAseoPage',
  data() {
    return {
      folio1: '',
      folio2: '',
      ofna: '',
      loading: false,
      error: '',
      report: null
    };
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = null;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'RptRecup_Aseo.getReport',
            params: {
              folio1: this.folio1,
              folio2: this.folio2,
              ofna: this.ofna
            }
          })
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.report = data.eResponse.data;
        } else {
          this.error = data.eResponse.message || 'Error desconocido';
        }
      } catch (err) {
        this.error = err.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    },
    formatDate(dateStr) {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      return d.toLocaleDateString();
    },
    formatCurrency(val) {
      if (val == null) return '0.00';
      return Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.rptrecup-aseo-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.card-header {
  background: #f8f9fa;
  font-weight: bold;
}
</style>
