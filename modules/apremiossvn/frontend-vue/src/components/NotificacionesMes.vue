<template>
  <div class="notificaciones-mes-page">
    <h1>Notificaciones por Mes</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Notificaciones por Mes</li>
      </ol>
    </nav>
    <form @submit.prevent="consultar">
      <div class="form-row">
        <div class="form-group col-md-3">
          <label for="axoPract">Año de Practicado</label>
          <input type="number" v-model="form.axo_pract" class="form-control" id="axoPract" required min="2000" max="2100">
        </div>
        <div class="form-group col-md-3">
          <label for="axoEmi">Año de Emisión</label>
          <input type="number" v-model="form.axo_emi" class="form-control" id="axoEmi" required min="2000" max="2100">
        </div>
        <div class="form-group col-md-3">
          <label for="fechaDesde">Fecha Pago Desde</label>
          <input type="date" v-model="form.fecha_desde" class="form-control" id="fechaDesde" required>
        </div>
        <div class="form-group col-md-3">
          <label for="fechaHasta">Fecha Pago Hasta</label>
          <input type="date" v-model="form.fecha_hasta" class="form-control" id="fechaHasta" required>
        </div>
      </div>
      <div class="form-row mt-2">
        <div class="col">
          <button type="submit" class="btn btn-primary">Consultar</button>
          <button type="button" class="btn btn-success ml-2" @click="exportarExcel" :disabled="!resultados.length">Exportar Excel</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="mt-3">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="resultados.length" class="mt-4">
      <h3>Resultados</h3>
      <div class="table-responsive">
        <table class="table table-bordered table-sm">
          <thead>
            <tr>
              <th>Módulo</th>
              <th>Mes</th>
              <th>Año</th>
              <th>Ejecutor</th>
              <th>Asignados</th>
              <th>Practicados</th>
              <th>Cancelados</th>
              <th>Pagados</th>
              <th>Recaudado</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, idx) in resultados" :key="idx">
              <td>{{ row.modulo }}</td>
              <td>{{ row.mes }}</td>
              <td>{{ row.axo }}</td>
              <td>{{ row.ejecutor }}</td>
              <td>{{ row.asignados }}</td>
              <td>{{ row.practicados }}</td>
              <td>{{ row.cancelados }}</td>
              <td>{{ row.pagados }}</td>
              <td>{{ row.recaudado | currency }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'NotificacionesMesPage',
  data() {
    return {
      form: {
        axo_pract: new Date().getFullYear(),
        axo_emi: new Date().getFullYear(),
        fecha_desde: '',
        fecha_hasta: ''
      },
      resultados: [],
      loading: false,
      error: ''
    };
  },
  filters: {
    currency(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', {minimumFractionDigits: 2});
    }
  },
  methods: {
    async consultar() {
      this.loading = true;
      this.error = '';
      this.resultados = [];
      try {
        const { data } = await axios.post('/api/execute', {
          action: 'getNotificacionesMes',
          params: this.form
        });
        if (data.success) {
          this.resultados = data.data;
        } else {
          this.error = data.message || 'Error en la consulta';
        }
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      } finally {
        this.loading = false;
      }
    },
    async exportarExcel() {
      // Exportar a Excel usando SheetJS o similar (aquí solo ejemplo básico)
      if (!this.resultados.length) return;
      const headers = ['Módulo','Mes','Año','Ejecutor','Asignados','Practicados','Cancelados','Pagados','Recaudado'];
      const rows = this.resultados.map(r => [r.modulo, r.mes, r.axo, r.ejecutor, r.asignados, r.practicados, r.cancelados, r.pagados, r.recaudado]);
      let csv = headers.join(',') + '\n';
      rows.forEach(row => {
        csv += row.join(',') + '\n';
      });
      const blob = new Blob([csv], { type: 'text/csv' });
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'notificaciones_mes.csv';
      a.click();
      window.URL.revokeObjectURL(url);
    }
  }
};
</script>

<style scoped>
.notificaciones-mes-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
