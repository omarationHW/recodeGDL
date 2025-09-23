<template>
  <div class="report-pagos-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte de Folios Pagados</li>
      </ol>
    </nav>
    <div class="card mb-4">
      <div class="card-header bg-primary text-white">
        <h5 class="mb-0">Folios Pagados en Recaudadora</h5>
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="mb-3">
            <label class="form-label">Tipo de Reporte</label>
            <div>
              <div class="form-check form-check-inline">
                <input class="form-check-input" type="radio" id="radioPagados" value="pagados" v-model="form.tipoReporte">
                <label class="form-check-label" for="radioPagados">Reporte de los folios pagados</label>
              </div>
              <div class="form-check form-check-inline">
                <input class="form-check-input" type="radio" id="radioElaborados" value="elaborados" v-model="form.tipoReporte">
                <label class="form-check-label" for="radioElaborados">Folios Elaborados por el Usuario Actual</label>
              </div>
            </div>
          </div>
          <div class="mb-3">
            <label for="fecha" class="form-label">Fecha</label>
            <input type="date" id="fecha" v-model="form.fecha" class="form-control" required>
          </div>
          <button type="submit" class="btn btn-success">Generar Reporte</button>
        </form>
      </div>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="result && form.tipoReporte === 'pagados'">
      <h5 class="mb-3">Reporte de Folios Pagados el {{ form.fecha }}</h5>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Recaudadora</th>
            <th>Caja</th>
            <th>Operación</th>
            <th>Año</th>
            <th>Folio</th>
            <th>Placa</th>
            <th>Fecha Folio</th>
            <th>Estado</th>
            <th>Infracción</th>
            <th>Tarifa</th>
            <th>Forma</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in result" :key="row.reca + '-' + row.folio">
            <td>{{ row.reca }}</td>
            <td>{{ row.caja }}</td>
            <td>{{ row.operacion }}</td>
            <td>{{ row.axo }}</td>
            <td>{{ row.folio }}</td>
            <td>{{ row.placa }}</td>
            <td>{{ row.fecha_folio }}</td>
            <td>{{ row.estado }}</td>
            <td>{{ row.infraccion }}</td>
            <td>{{ row.tarifa }}</td>
            <td>{{ row.codigo_movto }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <strong>Total de folios pagados:</strong> {{ result.length }}
      </div>
    </div>
    <div v-if="result && form.tipoReporte === 'elaborados'">
      <h5 class="mb-3">Folios Elaborados por el Usuario Actual el {{ form.fecha }}</h5>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Vigilante</th>
            <th>Inspector</th>
            <th>Año</th>
            <th>Folio</th>
            <th>Placa</th>
            <th>Fecha Folio</th>
            <th>Estado</th>
            <th>Infracción</th>
            <th>Tarifa</th>
            <th>Descripción</th>
            <th>Usuario Inicial</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in result" :key="row.vigilante + '-' + row.folio">
            <td>{{ row.vigilante }}</td>
            <td>{{ row.inspector }}</td>
            <td>{{ row.axo }}</td>
            <td>{{ row.folio }}</td>
            <td>{{ row.placa }}</td>
            <td>{{ row.fecha_folio }}</td>
            <td>{{ row.estado }}</td>
            <td>{{ row.infraccion }}</td>
            <td>{{ row.tarifa }}</td>
            <td>{{ row.descripcion }}</td>
            <td>{{ row.usu_inicial }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <strong>Total de folios:</strong> {{ result.length }}<br>
        <strong>Total de importe:</strong> {{ totalImporte }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ReportPagosPage',
  data() {
    return {
      form: {
        tipoReporte: 'pagados',
        fecha: new Date().toISOString().substr(0, 10)
      },
      loading: false,
      error: '',
      result: null
    };
  },
  computed: {
    totalImporte() {
      if (!this.result) return 0;
      return this.result.reduce((sum, row) => sum + (parseFloat(row.tarifa) || 0), 0).toFixed(2);
    }
  },
  methods: {
    async onSubmit() {
      this.loading = true;
      this.error = '';
      this.result = null;
      let action = '';
      let params = {};
      if (this.form.tipoReporte === 'pagados') {
        // Simular variable reca (puede venir de auth o config)
        params = { reca: 1, fechora: this.form.fecha };
        action = 'report_folios_pagados';
      } else {
        // Simular usuario actual (puede venir de auth)
        params = { fechora: this.form.fecha, vigila: 1 };
        action = 'report_folios_elaborados_usuario';
      }
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action, params })
        });
        const data = await res.json();
        if (data.success) {
          this.result = data.data;
        } else {
          this.error = data.message || 'Error al obtener datos';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.report-pagos-page {
  max-width: 1200px;
  margin: 0 auto;
}
</style>
