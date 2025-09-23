<template>
  <div class="rptreq-aseo-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Orden de Requerimiento de Pago y Embargo (Aseo)</li>
      </ol>
    </nav>
    <h1>Orden de Requerimiento de Pago y Embargo - Derechos de Aseo Contratado</h1>
    <form @submit.prevent="fetchReport">
      <div class="form-row">
        <div class="form-group col-md-2">
          <label for="folio1">Folio Inicial</label>
          <input type="number" v-model.number="folio1" class="form-control" id="folio1" required />
        </div>
        <div class="form-group col-md-2">
          <label for="folio2">Folio Final</label>
          <input type="number" v-model.number="folio2" class="form-control" id="folio2" required />
        </div>
        <div class="form-group col-md-2">
          <label for="ofna">Oficina (ID Recaudadora)</label>
          <input type="number" v-model.number="ofna" class="form-control" id="ofna" required />
        </div>
        <div class="form-group col-md-2 align-self-end">
          <button type="submit" class="btn btn-primary">Consultar</button>
        </div>
      </div>
    </form>

    <div v-if="loading" class="my-3">
      <span class="spinner-border spinner-border-sm"></span> Cargando...
    </div>
    <div v-if="error" class="alert alert-danger my-3">{{ error }}</div>

    <div v-if="reportData && reportData.adeudos.length > 0" class="mt-4">
      <div class="card mb-4">
        <div class="card-header bg-light">
          <strong>Datos de la Recaudadora</strong>
        </div>
        <div class="card-body">
          <div v-if="reportData.recaudadora.length">
            <div><b>Nombre:</b> {{ reportData.recaudadora[0].nomre }}</div>
            <div><b>Zona:</b> {{ reportData.recaudadora[0].zona }}</div>
            <div><b>Domicilio:</b> {{ reportData.recaudadora[0].domicilio }}</div>
            <div><b>Teléfono:</b> {{ reportData.recaudadora[0].tel }}</div>
          </div>
        </div>
      </div>

      <div v-for="(adeudo, idx) in reportData.adeudos" :key="adeudo.folio" class="card mb-3">
        <div class="card-header bg-secondary text-white">
          <b>Folio:</b> {{ adeudo.folio }} &nbsp; | &nbsp; <b>Nombre:</b> {{ adeudo.descripcion_1 }} &nbsp; | &nbsp; <b>Domicilio:</b> {{ adeudo.domicilio }}
        </div>
        <div class="card-body">
          <div class="row">
            <div class="col-md-4">
              <b>Tipo Contrato:</b> {{ adeudo.tipo_aseo }}<br />
              <b>Zona:</b> {{ adeudo.zona }}<br />
              <b>Periodo:</b> {{ adeudo.periodo }}<br />
              <b>Año:</b> {{ adeudo.ayo }}<br />
              <b>Fecha Emisión:</b> {{ formatDate(adeudo.fecha_emision) }}
            </div>
            <div class="col-md-4">
              <b>Adeudo:</b> {{ formatCurrency(adeudo.importe) }}<br />
              <b>Recargos:</b> {{ formatCurrency(adeudo.recargos) }}<br />
              <b>Multas:</b> {{ formatCurrency(adeudo.importe_multa) }}<br />
              <b>Gastos:</b> {{ formatCurrency(adeudo.importe_gastos) }}<br />
              <b>Total:</b> {{ formatCurrency(adeudo.importe + adeudo.recargos + adeudo.importe_multa + adeudo.importe_gastos) }}
            </div>
            <div class="col-md-4">
              <b>Representante:</b> {{ adeudo.representante }}<br />
              <b>Observaciones:</b> {{ adeudo.observaciones }}
            </div>
          </div>
        </div>
      </div>

      <div class="alert alert-info mt-4">
        <b>Nota legal:</b> Con fundamento en los Art. 115 de la Constitución Política de los Estados Unidos Mexicanos... (texto legal completo aquí)
      </div>
    </div>
    <div v-else-if="reportData && reportData.adeudos.length === 0" class="alert alert-warning mt-4">
      No se encontraron registros para los parámetros indicados.
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptReqAseoPage',
  data() {
    return {
      folio1: '',
      folio2: '',
      ofna: '',
      loading: false,
      error: '',
      reportData: null
    };
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.reportData = null;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: JSON.stringify({
            eRequest: 'RptReq_Aseo.getReport',
            params: {
              folio1: this.folio1,
              folio2: this.folio2,
              ofna: this.ofna
            }
          })
        });
        const data = await response.json();
        if (data.eResponse === 'RptReq_Aseo.getReport') {
          this.reportData = data.data;
        } else {
          this.error = data.message || 'Error desconocido.';
        }
      } catch (err) {
        this.error = 'Error de comunicación con el servidor.';
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
      if (val == null) return '';
      return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  }
};
</script>

<style scoped>
.rptreq-aseo-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.card-header {
  font-size: 1.1rem;
}
</style>
