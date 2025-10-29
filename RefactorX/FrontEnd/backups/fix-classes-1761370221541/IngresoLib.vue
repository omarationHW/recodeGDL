<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-alt" /></div>
      <div class="module-view-info">
        <h1>Ingreso Mercado Libertad</h1>
        <p>Mercados - Ingreso Mercado Libertad</p>
      </div>
    </div>

    <div class="module-view-content">
    <div class="card mb-3">
      <div class="municipal-card-header">Ingreso del Mercado Libertad</div>
      <div class="municipal-card-body">
        <form @submit.prevent="fetchData">
          <div class="row mb-3">
            <div class="col-md-3">
              <label for="mes" class="municipal-form-label">Mes a Procesar</label>
              <input type="number" min="1" max="12" v-model.number="mes" class="municipal-form-control" id="mes" required />
            </div>
            <div class="col-md-3">
              <label for="anio" class="municipal-form-label">Año</label>
              <input type="number" v-model.number="anio" class="municipal-form-control" id="anio" required />
            </div>
            <div class="col-md-6">
              <label for="mercado" class="municipal-form-label">Mercado</label>
              <select v-model="mercado_id" class="form-select" id="mercado" required>
                <option v-for="m in mercados" :key="m.id" :value="m.id">
                  {{ m.num_mercado_nvo }} - {{ m.descripcion }}
                </option>
              </select>
            </div>
          </div>
          <div class="mb-3">
            <button type="submit" class="btn btn-primary me-2">Procesar</button>
            <button type="button" class="btn-municipal-secondary" @click="resetForm">Limpiar</button>
          </div>
        </form>
      </div>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="ingresos.length">
      <h5>Ingresos por Fecha y Caja</h5>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Fecha Pago</th>
            <th>Caja</th>
            <th>Total Pagos</th>
            <th>Renta Pagada</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in ingresos" :key="row.fecha_pago + '-' + row.caja_pago">
            <td>{{ row.fecha_pago }}</td>
            <td>{{ row.caja_pago }}</td>
            <td>{{ row.pagos }}</td>
            <td>{{ currency(row.importe) }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="cajas.length">
      <h5>Totales por Caja</h5>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Caja</th>
            <th>Total Pagos</th>
            <th>Renta Pagada</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in cajas" :key="row.caja_pago">
            <td>{{ row.caja_pago }}</td>
            <td>{{ row.pagos }}</td>
            <td>{{ currency(row.importe) }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="totals">
      <h5>Totales Globales</h5>
      <ul class="list-group">
        <li class="list-group-item">Total Pagos: <strong>{{ totals.total_pagos }}</strong></li>
        <li class="list-group-item">Total Pagado: <strong>{{ currency(totals.total_importe) }}</strong></li>
      </ul>
    </div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'IngresoLibPage',
  data() {
    const today = new Date();
    return {
      mes: today.getMonth() + 1,
      anio: today.getFullYear(),
      mercado_id: '',
      mercados: [],
      ingresos: [],
      cajas: [],
      totals: null,
      loading: false,
      error: ''
    };
  },
  mounted() {
    this.fetchMercados();
  },
  methods: {
    async fetchMercados() {
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'get_mercados' })
        });
        const data = await res.json();
        if (data.success) {
          this.mercados = data.data.map(m => ({
            id: m.num_mercado_nvo,
            num_mercado_nvo: m.num_mercado_nvo,
            descripcion: m.descripcion
          }));
          if (this.mercados.length) this.mercado_id = this.mercados[0].id;
        } else {
          this.error = data.message || 'Error al cargar mercados';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async fetchData() {
      this.loading = true;
      this.error = '';
      this.ingresos = [];
      this.cajas = [];
      this.totals = null;
      try {
        // Ingresos
        let res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'get_ingresos',
            params: { mes: this.mes, anio: this.anio, mercado_id: this.mercado_id }
          })
        });
        let data = await res.json();
        if (data.success) {
          this.ingresos = data.data;
        } else {
          this.error = data.message || 'Error al cargar ingresos';
          return;
        }
        // Cajas
        res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'get_cajas',
            params: { mes: this.mes, anio: this.anio, mercado_id: this.mercado_id }
          })
        });
        data = await res.json();
        if (data.success) {
          this.cajas = data.data;
        } else {
          this.error = data.message || 'Error al cargar cajas';
          return;
        }
        // Totals
        res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'get_totals',
            params: { mes: this.mes, anio: this.anio, mercado_id: this.mercado_id }
          })
        });
        data = await res.json();
        if (data.success) {
          this.totals = data.data;
        } else {
          this.error = data.message || 'Error al cargar totales';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    resetForm() {
      const today = new Date();
      this.mes = today.getMonth() + 1;
      this.anio = today.getFullYear();
      this.mercado_id = this.mercados.length ? this.mercados[0].id : '';
      this.ingresos = [];
      this.cajas = [];
      this.totals = null;
      this.error = '';
    },
    currency(val) {
      if (val == null) return '';
      return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(val);
    }
  }
};
</script>

<style scoped>
.ingreso-lib-page {
  max-width: 900px;
  margin: 0 auto;
}
.card {
  margin-bottom: 1rem;
}
</style>
