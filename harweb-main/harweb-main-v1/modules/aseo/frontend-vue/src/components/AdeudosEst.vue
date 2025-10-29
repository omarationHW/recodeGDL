<template>
  <div class="estadistico-pagos-page">
    <h1>Estadístico de Pagos</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Estadístico de Pagos</li>
      </ol>
    </nav>
    <form @submit.prevent="ejecutar">
      <div class="form-row">
        <div class="form-group col-md-3">
          <label>Periodo Inicial</label>
          <div class="input-group">
            <input type="number" v-model="aso_in" min="1900" max="2100" class="form-control" placeholder="Año" required>
            <select v-model="mes_in" class="form-control" required>
              <option v-for="m in 12" :key="m" :value="m">{{ m.toString().padStart(2, '0') }}</option>
            </select>
          </div>
        </div>
        <div class="form-group col-md-3">
          <label>Periodo Final</label>
          <div class="input-group">
            <input type="number" v-model="aso_fin" min="1900" max="2100" class="form-control" placeholder="Año" required>
            <select v-model="mes_fin" class="form-control" required>
              <option v-for="m in 12" :key="m" :value="m">{{ m.toString().padStart(2, '0') }}</option>
            </select>
          </div>
        </div>
        <div class="form-group col-md-3 align-self-end">
          <button type="submit" class="btn btn-primary">Ejecutar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info mt-3">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="result && result.length" class="mt-4">
      <h3>Resultados</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Periodo</th>
            <th>Cuota Normal</th>
            <th>Excedente</th>
            <th>Contenedores</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in result" :key="row.periodo">
            <td>{{ row.periodo }}</td>
            <td>{{ currency(row.cuota_normal) }}</td>
            <td>{{ currency(row.excedente) }}</td>
            <td>{{ currency(row.contenedores) }}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <th>Total</th>
            <th>{{ currency(total('cuota_normal')) }}</th>
            <th>{{ currency(total('excedente')) }}</th>
            <th>{{ currency(total('contenedores')) }}</th>
          </tr>
        </tfoot>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EstadisticoPagos',
  data() {
    const now = new Date();
    return {
      aso_in: now.getFullYear(),
      mes_in: 1,
      aso_fin: now.getFullYear(),
      mes_fin: now.getMonth() + 1,
      loading: false,
      error: '',
      result: []
    };
  },
  methods: {
    async ejecutar() {
      this.loading = true;
      this.error = '';
      this.result = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'get_estadistico_pagos',
            params: {
              aso_in: this.aso_in,
              mes_in: this.mes_in,
              aso_fin: this.aso_fin,
              mes_fin: this.mes_fin
            }
          })
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
    },
    currency(val) {
      if (val == null) return '-';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    },
    total(field) {
      return this.result.reduce((acc, r) => acc + (parseFloat(r[field]) || 0), 0);
    }
  }
};
</script>

<style scoped>
.estadistico-pagos-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
