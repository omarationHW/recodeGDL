<template>
  <div class="rpt-req-merc-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Orden de Requerimiento de Pago y Embargo (Mercados)</li>
      </ol>
    </nav>
    <h2>Orden de Requerimiento de Pago y Embargo (Mercados)</h2>
    <form @submit.prevent="fetchReporte">
      <div class="form-row">
        <div class="form-group col-md-2">
          <label>Oficina (Zona)</label>
          <input v-model="form.ofna" type="number" class="form-control" required />
        </div>
        <div class="form-group col-md-2">
          <label>Folio Inicial</label>
          <input v-model="form.folio1" type="number" class="form-control" required />
        </div>
        <div class="form-group col-md-2">
          <label>Folio Final</label>
          <input v-model="form.folio2" type="number" class="form-control" required />
        </div>
        <div class="form-group col-md-2 align-self-end">
          <button type="submit" class="btn btn-primary">Consultar</button>
        </div>
      </div>
    </form>

    <div v-if="loading" class="my-3">
      <span>Cargando datos...</span>
    </div>

    <div v-if="error" class="alert alert-danger my-3">
      {{ error }}
    </div>

    <div v-if="reporte.length > 0" class="mt-4">
      <div v-for="(item, idx) in reporte" :key="item.folio" class="card mb-4">
        <div class="card-header">
          <strong>Folio:</strong> {{ item.folio }} | <strong>Mercado:</strong> {{ item.descripcion }} | <strong>Fecha de Corte:</strong> {{ formatFecha(item.fecha_emision) }}
        </div>
        <div class="card-body">
          <div class="row mb-2">
            <div class="col-md-4"><strong>Oficina:</strong> {{ item.oficina }}</div>
            <div class="col-md-4"><strong>Registro Municipal:</strong> {{ item.num_mercado }}</div>
            <div class="col-md-4"><strong>Zona:</strong> {{ item.zona_apremio }}</div>
          </div>
          <div class="row mb-2">
            <div class="col-md-6"><strong>Nombre del Contribuyente:</strong> {{ item.nombre }}</div>
            <div class="col-md-6"><strong>Giro o Actividad:</strong> {{ item.giro }}</div>
          </div>
          <div class="row mb-2">
            <div class="col-md-6"><strong>Locales:</strong> {{ item.local }}{{ item.letra_local }}</div>
            <div class="col-md-6"><strong>Bloque:</strong> {{ item.bloque }}</div>
          </div>
          <div class="row mb-2">
            <div class="col-md-6"><strong>Descripción Local:</strong> {{ item.descripcion_local }}</div>
            <div class="col-md-6"><strong>Periodo Adeudo:</strong> {{ item.periodo }}</div>
          </div>
          <div class="row mb-2">
            <div class="col-md-3"><strong>Renta Mensual:</strong> {{ formatMoney(item.cantidad) }}</div>
            <div class="col-md-3"><strong>Adeudo:</strong> {{ formatMoney(item.importe) }}</div>
            <div class="col-md-3"><strong>Recargos:</strong> {{ formatMoney(item.recargos) }}</div>
            <div class="col-md-3"><strong>Multas:</strong> {{ formatMoney(item.importe_multa) }}</div>
          </div>
          <div class="row mb-2">
            <div class="col-md-3"><strong>Gastos:</strong> {{ formatMoney(item.total_gasto) }}</div>
            <div class="col-md-3"><strong>Total:</strong> {{ formatMoney(item.importe_global + item.importe_multa + item.importe_recargo + item.importe_gastos) }}</div>
          </div>
          <div class="row mb-2">
            <div class="col-md-12">
              <strong>Observaciones:</strong> {{ item.observaciones }}
            </div>
          </div>
        </div>
      </div>
      <div class="alert alert-info">
        <strong>Total registros:</strong> {{ reporte.length }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptReqMercPage',
  data() {
    return {
      form: {
        ofna: '',
        folio1: '',
        folio2: ''
      },
      reporte: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    async fetchReporte() {
      this.loading = true;
      this.error = '';
      this.reporte = [];
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              action: 'getRptReqMerc',
              params: {
                ofna: this.form.ofna,
                folio1: this.form.folio1,
                folio2: this.form.folio2
              }
            }
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.reporte = data.eResponse.data;
        } else {
          this.error = data.eResponse.error || 'Error desconocido al consultar el reporte.';
        }
      } catch (err) {
        this.error = err.message || 'Error de red o servidor.';
      } finally {
        this.loading = false;
      }
    },
    formatFecha(fecha) {
      if (!fecha) return '';
      return new Date(fecha).toLocaleDateString();
    },
    formatMoney(val) {
      if (val === null || val === undefined) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  }
};
</script>

<style scoped>
.rpt-req-merc-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.card-header {
  background: #f8f9fa;
  font-weight: bold;
}
</style>
