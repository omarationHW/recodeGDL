<template>
  <div class="estadisticas-periodos-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Estadísticas por Periodo</li>
      </ol>
    </nav>
    <h2>Estadística de Adeudos por Periodo</h2>
    <form @submit.prevent="consultar">
      <div class="row mb-3">
        <div class="col-md-3">
          <label for="axo">Año de Obra</label>
          <input v-model.number="form.axo" type="number" min="1900" max="2100" class="form-control" id="axo" required />
        </div>
        <div class="col-md-3">
          <label for="adeudo">Adeudo mínimo</label>
          <input v-model.number="form.adeudo" type="number" step="0.01" class="form-control" id="adeudo" />
        </div>
        <div class="col-md-3">
          <label for="opc">Detalle</label>
          <select v-model.number="form.opc" class="form-control" id="opc">
            <option :value="1">Mostrar Detalle</option>
            <option :value="2">Solo Totales</option>
          </select>
        </div>
        <div class="col-md-3 d-flex align-items-end">
          <button type="submit" class="btn btn-primary">Consultar</button>
          <button type="button" class="btn btn-success ml-2" @click="exportar" :disabled="loading">Exportar Excel</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="resultados && resultados.length">
      <table class="table table-bordered table-sm mt-4">
        <thead>
          <tr>
            <th>Plazo</th>
            <th>Descripción Plazo</th>
            <th>Año Firma</th>
            <th>Costo</th>
            <th>Pagos</th>
            <th>Adeudo</th>
            <th>Estado</th>
            <th v-if="form.opc === 1">Colonia</th>
            <th v-if="form.opc === 1">Calle</th>
            <th v-if="form.opc === 1">Folio</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in resultados" :key="idx">
            <td>{{ row.plazo }}</td>
            <td>{{ row.desc_plazo }}</td>
            <td>{{ row.axo_firma }}</td>
            <td>{{ row.costo | currency }}</td>
            <td>{{ row.parc_pagos }}</td>
            <td>{{ row.saldo_real | currency }}</td>
            <td>{{ row.estado }}</td>
            <td v-if="form.opc === 1">{{ row.colonia }}</td>
            <td v-if="form.opc === 1">{{ row.calle }}</td>
            <td v-if="form.opc === 1">{{ row.folio }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else-if="!loading && resultados && !resultados.length" class="alert alert-warning">
      No se encontraron resultados para los criterios seleccionados.
    </div>
  </div>
</template>

<script>
export default {
  name: 'EstadisticasPeriodosPage',
  data() {
    return {
      form: {
        axo: new Date().getFullYear(),
        adeudo: 0,
        opc: 1
      },
      resultados: null,
      loading: false,
      error: ''
    };
  },
  methods: {
    async consultar() {
      this.loading = true;
      this.error = '';
      this.resultados = null;
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'getEstadisticasPeriodos',
              params: this.form
            }
          })
        });
        const json = await resp.json();
        if (json.eResponse.success) {
          this.resultados = json.eResponse.data;
        } else {
          this.error = json.eResponse.message || 'Error desconocido';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async exportar() {
      this.loading = true;
      this.error = '';
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'exportEstadisticasPeriodos',
              params: this.form
            }
          })
        });
        const json = await resp.json();
        if (json.eResponse.success && json.eResponse.data.download_url) {
          window.open(json.eResponse.data.download_url, '_blank');
        } else {
          this.error = json.eResponse.message || 'No se pudo exportar.';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    }
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return '$' + val.toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.estadisticas-periodos-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
</style>
